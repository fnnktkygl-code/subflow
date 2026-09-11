# Registre des Décisions & Mémoire Commune (Architecture Decision Record - ADR)

> Ce fichier consigne les choix structurants, les arbitrages techniques et les corrections d'incidents du projet.
> **Règle impérative** : Tout nouvel arbitrage ou changement d'architecture doit être ajouté ici avec son contexte et sa justification explicite.

---

## Format Standard d'Entrée

```markdown
### [YYYY-MM-DD] | [Domaine] : [Titre de la décision]
- **Contexte / Problème** : Ce qui a nécessité un arbitrage (contrainte technique, bug, limite d'API).
- **Décision tranchée** : La solution adoptée et le standard fixé.
- **Raison / Pourquoi** : Pourquoi cette solution et pas une alternative.
- **Impacts & Conséquences** : Ce qui change pour le code ou les agents futurs.
```

---

## Historique des Décisions Tranchées

### 2026-09-10 | Orchestration : Adoption du protocole Brooks-Zero & Équipe Chirurgicale
- **Contexte / Problème** : Risque d'inflation de sous-agents, de conflits d'écritures concurrentes et de saturation de contexte documenté dans l'expérience des 1200 agents.
- **Décision tranchée** : Adoption du modèle du Chirurgien Unique (Lead Agent seul détenteur du droit d'écriture dans le codebase). Sous-agents strictement éphémères, en lecture seule, avec topologie en étoile.
- **Raison / Pourquoi** : Maintient la complexité des échanges linéaire \(O(N)\) au lieu de quadratique \(O(N^2)\), élimine les régressions et garantit une traçabilité totale.
- **Impacts & Conséquences** : Les sous-agents écrivent uniquement dans `.agents/scratchpad/` ; seul le Lead merge dans le code source.

### 2026-08-28 | Authentification & Cloud : Scope Google Drive Sandbox (`drive.appdata`)
- **Contexte / Problème** : Les utilisateurs de SubFlow doivent pouvoir sauvegarder et restaurer leurs abonnements en temps réel sur mobile et ordinateur sans exposer leurs fichiers personnels Google Drive.
- **Décision tranchée** : Utilisation exclusive du scope restreint `https://www.googleapis.com/auth/drive.appdata` et du dossier applicatif isolé `appDataFolder`.
- **Raison / Pourquoi** : Confidentialité totale (SubFlow ne peut lire ni modifier aucun autre document du Drive utilisateur) et conformité allégée auprès de Google Cloud OAuth.

### 2026-08-28 | Intégration Bancaire : Proxy Serverless pour TrueLayer Open Banking
- **Contexte / Problème** : L'appel direct depuis le navigateur client (`window.fetch`) vers les endpoints TrueLayer (`auth.truelayer.com` et `api.truelayer.com`) est bloqué par les restrictions de sécurité CORS / DSP2 des banques européennes (erreur `Failed to fetch`).
- **Décision tranchée** : Migration de l'application web vers un modèle Next.js Serverless avec 3 routes proxies dédiées (`/api/truelayer/token`, `/api/truelayer/accounts`, `/api/truelayer/transactions`).
- **Raison / Pourquoi** : Les appels serveur-à-serveur contournent les restrictions CORS du navigateur tout en sécurisant les secrets d'authentification bancaire.

### 2026-08-28 | Stockage & Persistance : Hybridation Cloud Drive vs Local-First
- **Contexte / Problème** : Deux types d'utilisateurs : ceux voulant une synchronisation automatique multi-écrans et ceux exigeant une confidentialité 100% hors-ligne sans compte.
- **Décision tranchée** : Onboarding transparent à deux choix : Cloud Google Drive (recommandé) ou Mode Local (avertissement de risque de perte si cache vidé). Clé Zustand incrémentée (`subflow-storage-v2`) avec purge automatique des anciens caches de test.
- **Raison / Pourquoi** : Respecte l'autonomie de l'utilisateur tout en garantissant une base saine et zéro données mockées en production.

### 2026-09-11 | Qualité & Tests : Optimisation et Épuration Chirurgicale des Tests (Brooks-Zero)
- **Contexte / Problème** : Présence de ~25-30% de tests redondants (boucle d'assertions 350+ dupliquée, doublon de formatage monétaire, template Flutter par défaut obsolète), pollution console persistante de Zustand (`storage unavailable` en SSR/Vitest), et angles morts sans tests sur les proxies API Next.js Serverless et la synchro Google Drive Web.
- **Décision tranchée** :
  1. Suppression de la Suite 3 dans `validation.test.ts` (doublon strict avec `presets_350_catalog.test.ts`), du bloc formatage de `budget.test.ts`, et de `test/widget_test.dart`.
  2. Configuration d'un storage fallback sécurisé SSR dans `useSubscriptionStore.ts` éliminant 100% des avertissements console Zustand.
  3. Ajout de `apps/web/test/api_truelayer.test.ts` (8 tests couvrant les 3 routes proxy `/api/truelayer/*`).
  4. Ajout de `apps/web/test/googleDriveSync.test.ts` (9 tests couvrant les flux Google Drive client & user profile).
  5. Extension de `google_drive_backup.test.ts` avec les cas d'erreurs HTTP (401, 403, 404).
  6. Fusion et unification des tests Dart Flutter jumeaux (`subscription_provider_test.dart` et `user_profile_provider_test.dart`).
- **Raison / Pourquoi** : Réduit le bruit de fond en CI à zéro, protège les points d'intégration critiques et garde la base de tests affûtée et maintenable.

### 2026-09-11 | UI & Assets : Standardisation des Icônes SVG Natives et Fallbacks Épurés
- **Contexte / Problème** : En cas d'échec de récupération de favicon ou de logo manquant (ou par préférence de personnalisation de l'utilisateur), l'application affichait une simple lettre initiale sur fond dégradé. L'utilisateur souhaitait des icônes SVG natives, classées par catégorie, conformes aux standards de l'industrie pour remplacer ou supplanter le logo prédit.
- **Décision tranchée** :
  1. Création d'une bibliothèque d'icônes vectorielles standardisées dans `@subflow/core` (`packages/core/src/utils/nativeSvgIcons.ts`) classées par catégories (Streaming, Tech/IA, Énergie/Box, Sport, Alimentation, Shopping, Transport, Banque/Général).
  2. Mise à niveau du composant `SubscriptionLogo` dans `@subflow/ui` : prise en charge des identifiants `svg:<icon_id>` et fallback SVG catégorisé haute fidélité au lieu d'une initiale texte brute.
  3. Intégration d'un sélecteur modal visuel `SvgIconPickerModal` dans `AddSubscriptionModal` (recherche textuelle + onglets par catégorie).
  4. Couverture par tests unitaires automatisés (`packages/core/test/native_svg_icons.test.ts`).
- **Raison / Pourquoi** : Garantit une cohérence esthétique Japandi sans aucune dépendance réseau pour les logos, et offre un contrôle total à l'utilisateur.
- **Impacts & Conséquences** : 109 tests automatisés au vert, déploiement Vercel mis à jour immédiatement en production.


