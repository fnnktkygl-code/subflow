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

### 2026-09-10 | Fiabilité & Robustesse : Stress Test & Hardening (Arrondis, Dates Bancaires, Merge Sync)
- **Contexte / Problème** : Risques de dérive d'arrondi décimal IEEE 754 sur de gros volumes d'abonnements, contamination de périodicité par des dates futures aberrantes dans les relevés Open Banking, et risque d'écrasement silencieux lors des synchronisations multi-écrans.
- **Décision tranchée** : 
  1. Ajout de `roundToCents` systématique sur les totaux mensuels, annuels et simulations What-If.
  2. Filtrage défensif des dates bancaires corrompues ou futures (> 45j) dans le détecteur TrueLayer.
  3. Implémentation de `mergeSubscriptionsSnapshot` avec fusion par identifiant unique et horodatage `updatedAt`.
  4. Suite de stress tests automatisée validant 2 000 abonnements sous 50ms.
- **Raison / Pourquoi** : Élimine toute anomalie d'affichage financier et garantit l'intégrité des données à l'échelle.

