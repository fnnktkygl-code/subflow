# DIRECTIVES UNIVERSELLES D'EFFICIENCE & DE SOBRIÉTÉ EN TOKENS
*Bonnes pratiques universelles pour maximiser l'efficacité et préserver les quotas dans tout harnais multi-agents.*

---

## 1. Le Paradoxe des Plafonds d'Outils Arbitraires

* **L'Erreur Classique** : Imposer un plafond dur d'appels d'outils (ex. *"tu n'as droit qu'à 5 outils maximum"* ou *"mission en un seul tour"*).
* **Conséquence Réelle** : Face à une telle contrainte, les modèles de langage paniquent, sautent les étapes de vérification, bâclent leur travail ou inventent des réussites imaginaires pour respecter la contrainte.
* **La Solution Structurelle** : Supprimer les compteurs rigides et imposer une discipline d'exécution :
  1. Un périmètre géographique strict (fichiers autorisés désignés).
  2. Une interdiction de lancer des tâches secondaires hors-scope.
  3. Une obligation d'inspection ciblée plutôt que d'exploration aveugle.

---

## 2. Matrice d'Allocation Cognitive selon la Tâche

Tous les sous-agents n'ont pas besoin du même niveau d'effort de réflexion (*thinking/reasoning*). Adaptez la puissance à l'enjeu :

| Niveau d'Effort | Type de Tâche | Modèle / Configuration | Objectif |
|---|---|---|---|
| **Sobre (Direct)** | Compilation, exécution de scripts, renommages, migrations de fichiers | Modèle rapide / Thinking minimal | Exécution chirurgicale, consommation minimale de tokens |
| **Moyen (Structuré)** | Résolution de bugs ciblés, ajustement de paramètres, écriture de tests | Modèle intermédiaire / Thinking modéré | Autonomie d'itération locale avec auto-correction |
| **Élevé (Profond)** | Conception d'architecture, algorithmes critiques, impasses complexes | Modèle le plus capable / Thinking élevé | Une seule passe de réflexion profonde pour concevoir la bonne solution |

---

## 3. Règle d'Or des Artefacts et Données Intermédiaires

* **Zéro Génération Massive Inutile** : Ne générez jamais d'artefacts volumineux, de dumps de base de données complets ou de jeux d'assets massifs simplement pour vérifier une valeur ou un comportement ponctuel.
* **Validation par Cas Limites** : Écrivez des scripts de test concis ciblant les cas limites (*edge cases*) et vérifiant les invariants clés.
* **Nettoyage Automatique** : Tout fichier temporaire de diagnostic doit être nettoyé ou consigné dans un répertoire temporaire isolé (`scratch/` ou `tmp/`) sans polluer l'espace de travail ni l'historique Git.
