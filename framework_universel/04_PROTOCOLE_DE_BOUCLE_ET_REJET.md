# PROTOCOLE UNIVERSEL DE REJET & ITÉRATION EN BOUCLE FERMÉE
*Standard de communication structurée entre Orchestrateur et Sous-Agents pour piloter la correction sans perte de contexte.*

---

## 1. Pourquoi un Protocole de Rejet Structuré ?

Dans un système multi-agents, les échecs de convergence proviennent généralement de retours vagues (ex. *"ce n'est pas bon, recommence"*). L'agent tourne alors en rond ou introduit des compensations destructrices.

Le protocole exige un retour **chirurgical en 4 points**.

---

## 2. Template Universel de Rejet (Message Orchestrateur -> Sous-Agent)

```markdown
[REFUS DE LIVRABLE — RETOUR CRITIQUE ORCHESTRATEUR]

1. CONSTATS FACTUELS DE NON-CONFORMITÉ :
- Défaut 1 : [Description précise et observable du défaut, avec valeurs ou captures]
- Défaut 2 : [Régression ou anomalie constatée par rapport à la spécification]

2. CAUSE RACINE IDENTIFIÉE :
- [Analyse technique expliquant pourquoi le code produit ce résultat indésirable, ex: variable erronée, mauvaise articulation, logique conditionnelle inversée, hack de compensation]

3. ACTIONS CORRECTIVES EXIGÉES :
- Action 1 : [Modification structurelle précise attendue dans tel fichier/module]
- Action 2 : [Suppression explicite de tout contournement artificiel ou valeur forcée]

4. PREUVE EXIGÉE POUR NOUVELLE SOUMISSION :
- [Test, script de vérification ou inspection directe que l'agent doit obligatoirement exécuter et présenter avant de soumettre son nouveau livrable]
```

---

## 3. Grille Universelle d'Acceptation (Definition of Done)

L'orchestrateur n'a le droit de valider et de clore la boucle que lorsque TOUTES ces conditions sont remplies :

| Critère | Question de Contrôle | Action si Échec |
|---|---|---|
| **1. Compilation / Build** | Le projet compile-t-il avec `exit code 0` ? | Rejet immédiat avec log d'erreur |
| **2. Fichiers réels sur disque** | Les fichiers cibles ont-ils un horodatage récent et une taille cohérente ? | Rejet (suspicion de rapport halluciné) |
| **3. Tests automatisés** | Les suites de tests ciblées passent-elles à 100% ? | Rejet avec détail du test échoué |
| **4. Contrôle visuel / comportemental** | Le comportement opérationnel de bout en bout est-il exempt d'artefacts évidents ? | Rejet avec description du défaut |
| **5. Zéro hack résiduel** | Les modifications traitent-elles la cause racine sans artifices de contournement ? | Rejet avec obligation de nettoyage |
