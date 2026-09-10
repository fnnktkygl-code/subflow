# Configuration Antigravity 2.0 — Protocole Équipe Chirurgicale (Brooks-Zero)

> Ce projet applique le modèle d'**Équipe Chirurgicale** (inspiré de l'approche IBM de Harlan Mills / Fred Brooks) afin d'éliminer la loi de Brooks (explosion du bavardage d'agents en \(O(N^2)\), perte de contexte et conflits de merge).
> Consultez impérativement `.agents/rules/surgical_rules.md` pour toute intervention.

---

## 1. Rôles & Autorité (Le « Bistouri Unique »)

- **Chirurgien Unique (Lead Agent Antigravity)** :
  - **Une seule main écrit dans le code source** : le Chirurgien.
  - Il détient l'autorité exclusive sur le codebase, la validation finale et les décisions d'architecture.
  - Il est responsable de la cohérence, du typage, des tests et du déploiement.
- **Sous-agents Éphémères (Workers en Lecture Seule)** :
  - Instanciés **à la demande** selon la politique d'élasticité (Dynamic Agent Scaling Policy).
  - Mode **`read-only` strict sur le dépôt**. Ils n'ont **aucun droit d'écriture directe** dans le code.
  - Ils déposent leurs analyses, audits ou benchmarks uniquement dans le buffer temporaire `.agents/scratchpad/worker_{id}.md`.
  - **Topologie en étoile stricte** : Les sous-agents ne communiquent **JAMAIS** entre eux. Le graphe de communication reste centré sur le Chirurgien (\(O(N)\)).

---

## 2. Boucle de Décision & Mémoire Partagée (« Découper, Trancher, Garder »)

1. **Découper (Mémoire Vive / Tâche)** :
   - Découpage en sous-tâches atomiques isolées.
   - Les résultats intermédiaires vivent dans `.agents/scratchpad/` et sont purgés après validation.
2. **Trancher (Autorité du Chirurgien)** :
   - Le Chirurgien lit les propositions, valide ou rejette, et applique lui-même la modification dans le codebase.
   - Si un sous-agent génère des conflits ou nécessite plus d'une correction, il est immédiatement détruit (Scale-Down).
3. **Garder (Mémoire Projet / ADR)** :
   - Avant toute modification d'architecture, vérifiez `.agents/memory/decisions.md`.
   - Tout choix technique structurant ou correction d'erreur récurrente y est obligatoirement consigné avec le **contexte** et le **pourquoi**.

---

## 3. Piles Technologiques & Standards du Projet

- **Architecture** : Monorepo Turborepo + pnpm (`apps/web`, `packages/core`, `packages/ui`).
- **Design System** : Japandi UI (minimalisme japonais Wabi-Sabi, fonctionnalité scandinave Lagom, palette Vert Pin `#1B3B2F` et Ivoire/Sable `#F5EFE6`, WCAG 2.2 AAA).
- **Zéro Régression & Intégrité** :
  - Tests unitaires systématiques avant commit (`pnpm test`).
  - Validation de compilation statique et serverless (`pnpm run build`).
  - Radical Honesty : Ne jamais masquer un problème, une erreur d'accès ou un échec de quota.
