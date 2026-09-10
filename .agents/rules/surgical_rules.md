# Règles Chirurgicales & Boucle d'Élasticité (Protocole Brooks-Zero)

> **Fondement théorique (L'expérience des 1200 agents)** :
> L'ajout anarchique d'agents autonomes produit la loi de Brooks : le coût de communication quadratique \(O(N^2)\), les hallucinations croisées et les conflits de merge anéantissent la productivité.
> Pour garantir une vélocité maximale, le système applique un dimensionnement dynamique strict : **Chirurgien Unique + Workers Éphémères en Étoile**.

---

## 1. Topologie & Communication

```
                     ┌────────────────────────┐
                     │   CHIRURGIEN UNIQUE    │
                     │  (Lead Agent / Écriture│
                     │   Bistouri Unique)     │
                     └───────────┬────────────┘
                                 │
                 ┌───────────────┴───────────────┐
                 │                               │
                 ▼                               ▼
       ┌──────────────────┐            ┌──────────────────┐
       │   SOUS-AGENT 1   │            │   SOUS-AGENT 2   │
       │ (Lecture Seule)  │            │ (Lecture Seule)  │
       │ Scratchpad Dédié │            │ Scratchpad Dédié │
       └──────────────────┘            └──────────────────┘
                 │                               │
                 x <--- AUCUN ÉCHANGE CROISÉ ---> x
```

- **Topologie en étoile de rayon 1** : Tous les flux passent obligatoirement par le Chirurgien.
- **Interdiction absolue** : Les sous-agents ne s'invoquent pas mutuellement et ne se parlent jamais entre eux.

---

## 2. Boucle Logique d'Élasticité (Scaling Policy)

Le Chirurgien évalue au début de chaque cycle si l'instanciation d'un sous-agent temporaire est justifiée.  
**Par défaut : Pool = 1 (Le Chirurgien opère seul).**

### A. Conditions d'Ajout (Scale-Up)
Instancier un sous-agent temporaire **UNIQUEMENT** si au moins l'une des conditions suivantes est validée :

- [ ] **Isolation stricte** : Tâche d'audit de sécurité, revue de conformité, ou exploration en lecture seule sur un périmètre bien délimité sans conflit d'écriture.
- [ ] **Explosion combinatoire** : Plus de 3 benchmarks, suites de tests ou scénarios indépendants à exécuter/analyser en parallèle.
- [ ] **Cloisonnement de contexte** : Ingestion d'une documentation technique volumineuse (> 20 000 tokens) qui risquerait de saturer la fenêtre de contexte du Chirurgien.

> **Contraintes d'instanciation :**
> - **Modèle** : Préférer un modèle léger et rapide (`flash` ou `inherit`).
> - **Permissions** : `read-only` sur l'ensemble du dépôt. Écriture réservée au fichier temporaire `.agents/scratchpad/worker_{id}.md`.
> - **Plafond strict** : Maximum **2 sous-agents actifs simultanément**.

### B. Conditions de Retrait / Destruction Immédiate (Scale-Down)
Détruire immédiatement le sous-agent et reprendre la main si :

- [ ] **Conflit logique** : La proposition contredit une décision enregistrée dans `.agents/memory/decisions.md` ou les standards du projet.
- [ ] **Taux de reprise élevé** : Le Chirurgien doit corriger ou ajuster plus d'une fois l'output produit par l'agent.
- [ ] **Fin de mission** : Dès que l'analyse ou le rapport est consigné dans le scratchpad, la session du worker est terminée.
- [ ] **Surconsommation de budget** : Dépassement du seuil de tokens alloué sans livrable exploitable.

---

## 3. Protocole de Mémoire (« Découper, Trancher, Garder »)

Pour éviter la saturation de contexte et la dérive d'alignement, la mémoire est strictement partitionnée en 3 couches étanches :

| Niveau | Emplacement | Propriétaire | Cycle de Vie & Description |
| :--- | :--- | :--- | :--- |
| **1. Mémoire Vive (Tâche)** | `.agents/scratchpad/` | Sous-agent éphémère | Notes de travail, brouillons, analyses brutes. **Purgée dès le merge**. |
| **2. Mémoire Projet (Décisions)** | `.agents/memory/decisions.md` | Le Chirurgien | Registre d'arbitrage (ADR). Consigne les choix techniques et leur justification. |
| **3. Mémoire Système (Règles)** | `GEMINI.md` / `surgical_rules.md` | L'Humain (User) | Lois fondamentales et règles intangibles du projet. |

### Protocole de Merge du Chirurgien :
1. Le sous-agent dépose sa synthèse dans `.agents/scratchpad/worker_{id}.md`.
2. Le Chirurgien examine la synthèse, vérifie sa conformité avec les tests et les décisions antérieures.
3. Le Chirurgien applique lui-même les changements dans le codebase (**le bistouri unique**).
4. Le fichier temporaire de scratchpad est supprimé pour garder le workspace immaculé.
