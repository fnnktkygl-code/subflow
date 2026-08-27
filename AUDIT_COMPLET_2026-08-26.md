# Audit complet — SubFlow

Date : 26 août 2026  
Nature : audit statique complet + vérifications de tooling, sans modification du produit.  
Périmètre : dépôt racine Flutter, copie non suivie `trhack_app/`, configurations Android/iOS/web, dépendances, tests, intégration TrueLayer et pratiques de livraison.

## Verdict

**L'application ne doit pas être livrée dans son état actuel.** Deux risques P0 sont indépendants :

1. Le client mobile embarque un secret TrueLayer et effectue l'échange OAuth dans l'application.
2. Le projet ne peut actuellement pas résoudre ses dépendances, et plusieurs imports Dart de la source racine pointent vers des fichiers inexistants.

Il n'y a pas de backend applicatif dans ce dépôt. L'application appelle directement TrueLayer et stocke les données localement. Cela rend les stress tests d'un backend impossibles aujourd'hui ; ils doivent cibler le futur BFF (backend-for-frontend), et non TrueLayer en production.

## Méthode et limites

La grille reprend les principes du kit trouvé dans `vital_track` : audit E2E, accessibilité/UI, utilité fonctionnelle, résilience et exigence de preuve. Elle est complétée par Flutter, WCAG 2.2, OAuth natif, OWASP API et NIST AI RMF.

Vérifications exécutées : inventaire Git et fichiers, inspection de code/configuration, recherche de secrets sans jamais les afficher, résolution Flutter et recherche d'importations relatives invalides. `flutter analyze` n'a pas pu commencer l'analyse car `flutter pub get` échoue sur le conflit `intl`. Aucun test n'est donc déclaré réussi dans ce rapport.

## Cartographie réelle

| Élément | Constat |
|---|---|
| Client | Flutter/Dart, Provider, Hive, notifications locales, WebView, Android/iOS/web/desktop déclarés |
| Fonction cœur | ajout et suivi de prélèvements, calendrier, notifications, connexion bancaire TrueLayer |
| Données | abonnements et profil sur l'appareil ; token dans `flutter_secure_storage` |
| Serveur | aucun BFF, aucune API maison, aucune CI, aucun monitoring applicatif détectés |
| Volume | 53 fichiers Dart sous `lib/`, environ 15 000 lignes avec les widgets ; monolithes jusqu'à 1 144 lignes |
| État Git | 345 fichiers suivis modifiés, 2 répertoires non suivis ; `trhack_app/` est une seconde copie de l'app, environ 1,5 Go |

La racine est le code suivi par Git. `trhack_app/` est une copie non suivie, divergente (notamment une migration `core/features` inachevée). Il faut désigner une seule source de vérité avant toute correction.

## Constats prioritaires

### P0 — à corriger avant toute diffusion

| Constat | Preuve | Risque | Décision |
|---|---|---|---|
| Secret OAuth distribué au client | `.env` est déclaré comme asset dans `pubspec.yaml:60-63`; il est chargé par `main.dart:23`; le secret est envoyé par `truelayer_service.dart:15-18, 85-94`. | Toute personne peut extraire le secret de l'APK/IPA/web build et usurper l'intégration. | **Révoquer/faire tourner le secret immédiatement**, le retirer de tous les artefacts, puis déplacer l'échange code→token et les appels Data API dans un BFF. |
| OAuth natif non sûr | `truelayer_service.dart:18,35-50` : redirect localhost, aucune valeur `state`, aucun PKCE ; `truelayer_connect_page.dart:45-70` : WebView JavaScript non restreint. | Interception/CSRF du retour OAuth, hameçonnage et incompatibilités banque. | Utiliser navigateur système + App/Universal Links, `state` aléatoire validé, PKCE S256, redirect HTTPS déclaré exactement. Le BFF garde le secret et applique les autorisations. |
| Projet non analysable/non testable | `flutter analyze` échoue : `intl ^0.19.0` contredit Flutter 3.41 qui impose `intl 0.20.2`; `pubspec.yaml:21-23`. | Aucun garde-fou de compilation. | Réconcilier les contraintes, régénérer le lockfile de manière contrôlée, puis exiger analyse/test/build release. |
| Imports cassés dans la source suivie | `lib/provider/simplified_subscription_provider.dart:7`, `lib/theme/theme_helpers.dart:5`, `lib/views/upcoming_list_widget.dart:6-10` montent hors de `lib/`. | Échec de compilation après résolution des paquets. | Corriger la migration d'imports dans un unique changement atomique, avec `dart format` et analyse. |
| Release Android signée avec la clé debug | `android/app/build.gradle:36-41`. | Application non publiable de façon sûre, identité de release non protégée. | CI avec keystore/identité de signature dans un coffre de secrets ; ne jamais versionner la clé. |
| Deux applications concurrentes | `trhack_app/` est non suivi et diffère de la racine ; la copie contient une migration inachevée. | Correctifs et releases peuvent être produits depuis un mauvais arbre. | Décider de la racine canonique, déplacer/archiver l'autre copie hors du dépôt après validation, puis restaurer un Git propre. |

### P1 — risque élevé ou valeur utilisateur directement affectée

| Domaine | Constat prouvé | Correction attendue |
|---|---|---|
| Calculs financiers | Les cycles ne sont pas cohérents : le modèle traite `annually`, le provider utilise `Yearly`, et la semaine vaut 4 dans le modèle mais 4,348 dans le provider (`subscription_model.dart:51-64`, `simplified_subscription_provider.dart:60-70`). Un abonnement annuel peut donc être affiché à son montant total au lieu du mensuel. | Créer un type `BillingCycle` et un type monétaire, une seule règle de conversion, arrondi explicite ; tests de propriété et cas 29 février/fin de mois. |
| Résilience réseau | Appels `http` sans timeout, annulation, retry borné, résultats typés ni visibilité utilisateur ; des `catch` retournent silencieusement `[]` (`truelayer_service.dart:54-79, 233-278`). | Client API injectable : délais, backoff avec jitter, erreur typée, états offline/retry ; ne jamais confondre échec et « aucun abonnement ». |
| Vie privée | Hive conserve les données financières localement, sans chiffrement applicatif, durée de conservation, suppression/export, ni politique de confidentialité visibles. | Analyse DPIA/RGPD avec DPO ; minimisation, chiffrement au repos adapté au risque, effacement du compte/données/tokens, consentements et registre de traitements. |
| Observabilité | Pas de gestion centralisée des erreurs, crash reporting, métriques de latence/frame ou traces ; des logs debug incluent comptes, commerçants et montants. | `FlutterError.onError` + zone surveillée, journalisation structurée et sans PII, traces anonymisées/opt-in et alerting. |
| Tests | Un seul test est le template Counter et ne teste pas le produit (`test/widget_test.dart:14-28`). Pas de test unitaire réel, widget, E2E, golden, contrat, sécurité, charge, ni CI. | Construire la pyramide ci-dessous avant de reprendre les évolutions produit. |
| Permissions | Notifications et alarmes exactes sont demandées au démarrage (`main.dart:41-44`, `notification_service.dart:31-48`). | Demander au moment où l'utilisateur active un rappel ; prévoir refus, paramétrage et dégradation gracieuse. |
| UX/a11y | Gestes nus pour navigation/calendrier, petites cibles et textes 9–11sp, aucun support clavier/semantics identifié ; calendrier à hauteur fixe. | Cibles 48 dp, widgets sémantiques, labels/hints, focus, lecteurs d'écran, zoom 200 %, TalkBack/VoiceOver et tests d'accessibilité. |
| Localisation | `l10n` est annoncé mais pas de fichiers ARB ni de delegates/locales dans l'app ; chaînes, dates et euro sont codés en dur. | ARB FR/EN (puis pays cibles), `NumberFormat.currency` et `DateFormat` pilotés par locale/devise ; tests de pluralisation et formats. |
| Produit | L'accueil assemble objectifs, revenu, santé financière, paiements, graphiques, gamification, animations et « What if ». Le mode « What if » et les graphiques demandent des gestes difficiles à découvrir. | Recentrer la promesse : « prochains prélèvements + ajouter/corriger ». Divulgation progressive, mesure d'usage et suppression/désactivation des fonctions non démontrées utiles. |

### P2 — dette qui doit être planifiée

- Les widgets/calendrier/popup/graphique de 500–1 144 lignes et les imports croisés empêchent les tests et les évolutions sûres. Découper par fonctionnalité, pas par type technique uniquement.
- Le design system ne centralise pas suffisamment les tokens sémantiques ; les polices déclarées ne correspondent pas aux familles demandées par le thème. Ajouter tokens de couleur/typo/espacement/état, composants de base et goldens.
- Le web manifeste une description et un nom de template, force le portrait et ne reflète pas l'application. Web/desktop devraient avoir breakpoints et navigation adaptative.
- `isProduction` est une constante compilée (`truelayer_service.dart:23-32`). Les environnements doivent être une configuration de build validée par la CI, jamais un interrupteur modifiable dans le client.

## Architecture cible proportionnée

Ne pas sur-architecturer le client. En revanche, la frontière finance doit être nette :

```text
Flutter (features, UI, accessibilité)
       ↓ use cases testables
Domaine : Subscription, Money, BillingCycle, consentement
       ↓ ports/repositories
Données : Hive chiffré/migré       BFF sécurisé
                                 ├─ OAuth/PKCE et secret TrueLayer
                                 ├─ token/consentement/rotation
                                 ├─ rate-limit, anti-abus, audit
                                 └─ contrat API versionné
```

- **Client** : architecture par feature (`onboarding`, `subscriptions`, `calendar`, `bank_connection`, `settings`), état ciblé, interfaces de repositories, aucune clé secrète.
- **BFF** : API minimale ; authentification utilisateur, contrôle d'accès objet, validation de schéma, timeout/retry/circuit breaker, quotas, idempotence, journal d'audit sans données bancaires brutes.
- **Données** : migrations Hive versionnées et testées, modèle de consentement, rétention/effacement documentés.
- **Release** : environnements isolés sandbox/staging/prod, secrets dans coffre, signature mobile, SBOM et scans de dépendances.

## Pyramide de tests et qualité obligatoire

| Niveau | À tester | Outil/pratique |
|---|---|---|
| Rapide à chaque PR | format, analyse, imports, licences/secrets/dépendances vulnérables | `dart format --set-exit-if-changed`, `flutter analyze`, secret scan, SBOM/OSV ou équivalent |
| Unitaire | `Money`, récurrences, calendrier, filtres, projections, migrations, erreur API | `flutter_test`, fakes, horloge contrôlée ; tests de propriétés sur dates/montants |
| Widget | formulaires, validation, états vide/chargement/erreur/offline, thèmes, zoom, semantics | `flutter_test`, mocks des ports, test de sémantique |
| Golden | petit/grand mobile, tablette, desktop, clair/sombre/rose, texte agrandi | goldens revus humainement, stockage des baselines en Git |
| Intégration | onboarding, ajout/édition/suppression, persistance, opt-in rappel, consentement bancaire simulé | `integration_test`; Patrol seulement si les dialogues natifs doivent être pilotés |
| Contrat BFF | OAuth callback, autorisations, schémas, erreurs, pagination/idempotence | OpenAPI + tests de contrat consumer/provider |
| Sécurité | SAST, dépendances, secrets, tests authz, pentest avant prod | OWASP MASVS/API Top 10 ; revue mobile et BFF indépendante |
| Performance/charge | 100/500/1 000 abonnements et logos défaillants ; API BFF p95/p99, saturation et reprise | profilage Flutter sur appareil réel ; k6/Gatling contre staging du BFF, jamais contre TrueLayer production |

Gates minimaux de PR : dépendances résolues, format/analyse verts, tous les tests rapides verts, tests nouveaux pour tout changement métier, zéro secret, revue humaine. Gates de release : E2E sur Android+iOS, vérification a11y manuelle, build signé, scan de dépendances, test de restauration/migration et feu vert produit/confidentialité.

## Plan de remise en état

1. **Stop-ship (J0–J2).** Tourner le secret TrueLayer ; désactiver l'accès live si nécessaire. Désigner la source racine et enlever la duplication du chemin de livraison. Réparer `intl` et les six imports invalides. Corriger la signature release.
2. **Fondation (semaine 1).** Mettre CI et les gates, remplacer le test template par les tests des règles de calcul, et extraire `Money`/`BillingCycle`/repositories. Aucune fonctionnalité nouvelle avant un build reproductible.
3. **Frontière bancaire (semaines 1–3).** Construire le BFF, externaliser OAuth et secrets, migrer vers navigateur système + state/PKCE, ajouter sandbox et tests de contrat. Faire une revue sécurité/RGPD.
4. **Fiabilité produit (semaines 2–4).** Pyramide widget/golden/E2E, erreurs réseau explicites, opt-in notifications, migrations de données, observabilité respectueuse de la vie privée.
5. **Qualité d'expérience (semaines 3–5).** ARB/locales, correction a11y, responsive, réduction de la charge cognitive et tests sur appareils/cibles réels.
6. **Charge et exploitation (après BFF).** Budgets de frame/mémoire et charge p95/p99, tests de panne/retour réseau, dashboards/alertes et exercice de rotation des secrets.

## Gouvernance des agents IA pour ce projet

Le dépôt ne contient pas de fonctionnalité IA utilisateur ; il faut donc gouverner l'IA de développement, pas ajouter un système d'agents à l'app.

- Un agent orchestrateur découpe, conserve une matrice risques/décisions et ne valide jamais son propre travail.
- Agents spécialisés séparés : architecture/tests, sécurité/confidentialité, UX/accessibilité, implémentation, puis vérificateur indépendant.
- Chaque agent a un périmètre de fichiers, droits minimaux, aucune lecture/écriture de secret et aucune action externe sans approbation humaine.
- Toute affirmation de test contient la commande, l'environnement, le résultat et les limites ; aucun « vert » déduit.
- Les changements à risque (OAuth, données, paiement, suppression, production) exigent revue humaine, threat model et tests de régression avant fusion.
- Versionner prompts, modèles, outils autorisés, journaux de décision et procédures d'incident. Réévaluer les risques avant tout ajout d'IA conforme aux pratiques de gouvernance NIST.

## Références standards actuelles

- [Flutter — stratégie unit/widget/intégration et CI](https://docs.flutter.dev/testing/overview)
- [Flutter — tests d'intégration et mesures de performance](https://docs.flutter.dev/testing/integration-tests)
- [W3C — WCAG 2.2, cible recommandée](https://www.w3.org/TR/WCAG22/)
- [RFC 8252 — OAuth pour apps natives](https://oauth.net/2/native-apps/)
- [TrueLayer — auth link, state et PKCE](https://docs.truelayer.com/docs/generate-an-auth-link)
- [OWASP API Security Top 10 2023](https://owasp.org/www-project-api-security/)
- [Android — configuration de sécurité réseau](https://developer.android.com/privacy-and-security/security-config)
- [NIST AI RMF et profil Generative AI](https://www.nist.gov/itl/ai-risk-management-framework)
