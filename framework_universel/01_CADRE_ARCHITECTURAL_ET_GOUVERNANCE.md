# CADRE UNIVERSEL D'ARCHITECTURE & DE GOUVERNANCE MULTI-AGENTS
*Référentiel agnostique applicable à tout projet logiciel, infrastructure ou système autonome, quel que soit le harnais d'IA (Claude Code, Cursor, Windsurf, LangGraph, AutoGen, CrewAI, CLI personnalisées).*

---

## 1. Principes Architecturaux Fondamentaux

### A. Asymétrie Fonctionnelle (Pilote vs Exécutant)
* **L'Orchestrateur** opère avec la pleine puissance cognitive. Il assure le dialogue, la compréhension des besoins, l'architecture d'ensemble et l'audit critique indépendant des livrables.
* **Le Sous-Agent / Worker** est un exécutant spécialisé, déployé sur une mission ciblée, directe et délimitée.

### B. Isolation & Non-Concurrence (Verrouillage Exclusif)
* **Un seul agent actif par composant, sous-système ou fichier critique à un instant T**.
* Interdiction stricte de lancer plusieurs agents en parallèle sur les mêmes fichiers ou les mêmes fonctions. Les éditions concurrentes provoquent des écrasements de code (*race conditions*), des régressions croisées et une consommation exponentielle de tokens.

### C. Périmètres Délimités et Critères d'Arrêt Nets
* Chaque mission déléguée doit comporter un périmètre sans équivoque :
  1. Les fichiers / modules autorisés en écriture.
  2. La spécification étalon (*Ground Truth*) à satisfaire.
  3. Les critères de fin de mission (*Definition of Done*).
* Aucun ordre exploratoire flou ne doit être délégué sans bornage strict.

### D. Hiérarchie Plate (Zéro Délégation Récursive)
* Un sous-agent n'a jamais l'autorisation d'invoquer lui-même d'autres sous-agents.
* La structure reste strictement à deux niveaux : **Orchestrateur -> Sous-Agents spécialisés**, éliminant tout risque de cascade incontrôlée en arrière-plan.

### E. Non-Ingérence Technique de l'Orchestrateur
* L'orchestrateur ne modifie pas le code source lui-même et n'exécute pas les manipulations d'implémentation à la place de ses exécutants. Son rôle est de cadrer, auditer et challenger.

### F. Mémoire Partagée Persistante (Shared Blackboard)
* La mémoire vive d'une session d'IA étant volatile, les décisions d'architecture, les paramètres validés et les impasses techniques doivent être écrits sur disque dans un cahier de bord persistant.
* Tout nouvel agent débutant une tâche doit d'abord lire ce cahier pour ne jamais reproduire une erreur documentée ni régresser sur un acquis.

---

## 2. Flux d'Exécution Type

```
+-------------------------------------------------------------------------+
|                              ORCHESTRATEUR                              |
|  - Rôle : Vision stratégique, dialogue utilisateur, tenue des standards  |
|  - Règle 1 : Zéro ingérence dans le code (délégation stricte)            |
|  - Règle 2 : Quality Gatekeeper (zéro transmission de travail bâclé)     |
|  - Règle 3 : Boucle fermée (rejet motivé et re-délégation automatique)  |
+------------------------------------+------------------------------------+
                                     │
                 Mission Délimitée & Isolée (Non-concurrente)
                                     │
            ┌────────────────────────┴────────────────────────┐
            ▼                                                 ▼
+──────────────────────────────+         +──────────────────────────────+
|    SOUS-AGENT SPÉCIALISÉ     |         |     SOUS-AGENT EXÉCUTANT     |
| - Implémentation algorithme  |         | - Build, compilation, tests  |
| - Autonomie d'itération      |         | - Débogage méthodique        |
| - Auto-contrôle obligatoire  |         | - Auto-contrôle obligatoire  |
| - Preuve de travail formelle |         | - Preuve de travail formelle |
+──────────────────────────────+         +──────────────────────────────+
```
