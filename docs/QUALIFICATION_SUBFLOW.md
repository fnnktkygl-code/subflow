# Qualification SubFlow — 13 septembre 2026

## Verdict

La version web est une candidate crédible pour une bêta privée. La landing page, la démonstration et les parcours locaux principaux compilent et passent les contrôles automatisés. Une mise en production publique avec connexion bancaire reste conditionnée à des essais OAuth/TrueLayer réels, une validation des textes juridiques et une observation sur plusieurs navigateurs et appareils.

Les implémentations mobiles ne sont pas qualifiées par ce rapport. Le SDK Flutter n’est pas installé sur la machine de contrôle et `apps/mobile` ne contient actuellement aucun fichier source TypeScript ou TSX à compiler.

## Positionnement retenu

SubFlow reste centré sur les prélèvements et abonnements : coût mensuel équivalent, prochaines sorties réelles, calendrier et simulation d’économies. Le produit n’ajoute pas de comptabilité générale, de gestion de patrimoine ou de résiliation prétendument automatique.

Cashew fournit de bons repères sur le mode local, l’absence de publicité, la gratuité utile, la personnalisation et les exports. Ses limites documentées autour de la synchronisation et de la séparation des achats selon les plateformes renforcent deux choix SubFlow : rendre l’état des sauvegardes explicite et ne jamais bloquer l’export ou la récupération des données derrière un paiement. Sources : [site et démo Cashew](https://cashewapp.web.app/), [FAQ](https://cashewapp.web.app/faq.html), [politique de confidentialité](https://cashewapp.web.app/policy.html), [versions](https://github.com/jameskokoska/Cashew/releases).

Le modèle économique recommandé est un cœur gratuit sans publicité, avec soutien facultatif discret. Si un service futur crée un coût récurrent réel, il peut devenir une option payante séparée et transparente. La sécurité, l’export, la restauration locale et l’accès aux données restent gratuits.

## Sécurité et intégrité vérifiées

- Les jetons Google ne font plus partie de l’état persistant. Un ancien snapshot est assaini à l’ouverture ; s’il ne peut pas être réécrit, SubFlow refuse de le charger et tente de supprimer l’entrée contenant le jeton.
- L’authentification bancaire utilise `state`, PKCE, une durée de validité et une consommation unique de la transaction OAuth.
- Les imports et restaurations valident toutes les données avant modification. Ils écrivent désormais le prochain snapshot durable avant de publier le nouvel état en mémoire.
- Une restauration Drive conserve d’abord une copie locale récupérable.
- La démonstration n’utilise pas le stockage persistant et ne présente plus les actions de connexion bancaire.
- Les exports CSV neutralisent les formules de tableur et les sauvegardes chiffrées exigent un mot de passe d’au moins douze caractères.

Ces contrôles ne constituent ni un audit indépendant, ni une certification RGPD, ni une preuve du comportement d’une banque réelle.

## UI, accessibilité et fidélité de la landing page

- La landing page explique la mensualisation des paiements annuels, les limites de la simulation et la réalité du stockage local sans promesse de chiffrement inexistante.
- La démonstration utilise cinq prélèvements fictifs cohérents et permet de parcourir vue d’ensemble, prélèvements, calendrier et ajout manuel.
- Les captures ordinateur et mobile ont été régénérées à partir de la vraie route `/demo`, aux formats 1120 × 850 et 390 × 844.
- Les libellés visibles du graphique et du simulateur sont localisés en français.
- Les dialogues gèrent Échap, le retour du focus et la navigation au clavier ; la modale de sauvegarde reçoit explicitement le focus à son ouverture.

## Contrôles exécutés

- Tests monorepo : 131 tests réussis, dont 92 dans le cœur et 39 dans le web.
- Stress calendrier : 10 000 récurrences anciennes calculées en environ 713 ms sur la machine de contrôle, sous la limite de test de 3 secondes.
- Build de production Next.js : réussi pour 16 pages/routes.
- Poids initial indiqué par le build : landing 110 kB, application 216 kB, démonstration 224 kB.
- Contrôle interactif : landing, démonstration, ajout manuel et présentation mobile observés sur la version de production locale.

Les mesures locales donnent une base de non-régression ; elles ne remplacent pas les Core Web Vitals recueillis chez de vrais utilisateurs.

## Conditions restantes avant ouverture publique

1. Tester Google Drive et TrueLayer avec des comptes de test dédiés, y compris refus, expiration, retour arrière et double clic.
2. Vérifier la politique de confidentialité et les conditions avec le fonctionnement réellement déployé et les sous-traitants choisis.
3. Faire un passage sur Safari iOS, Chrome Android, Firefox et navigation clavier complète.
4. Décider si Flutter reste la cible mobile. Installer son SDK et exécuter les tests Dart avant toute annonce d’application native.
5. Ajouter une télémétrie respectueuse de la vie privée uniquement si elle répond à une question produit précise, avec consentement et durée de conservation documentés.
