# Gouvernance appliquée à SubFlow

Révision : 13 septembre 2026. Les cinq fichiers 01–05 restent intacts comme référentiel fourni par le propriétaire. Les règles exécutables du projet sont dans `../AGENTS.md` ; ce document explique les arbitrages et n’a pas à être chargé lors de chaque tâche.

## Ce que nous gardons et changeons

| Proposition générique | Application à SubFlow | Raison |
|---|---|---|
| Un propriétaire par composant | Un seul auteur par ensemble de fichiers ; responsable auteur par défaut | Le dépôt mélange web, composants partagés et Flutter ; éviter les reprises concurrentes |
| Orchestrateur interdit d’implémenter | Non retenu comme obligation ; délégation explicite possible sur un périmètre exclusif | Déléguer toute petite modification coûte du contexte et crée une file d’attente artificielle |
| Audit indépendant | Revue sur diff, tests et comportement ; agent ciblé pour logique sensible | Une déclaration « terminé » ne suffit pas, mais une seconde exécution identique de tout n’est pas automatiquement utile |
| Surveillance régulière des traces | Retour sur événement ; inspection si erreur, blocage ou divergence signalée | Éviter les réveils sans information et les répétitions du contexte parent |
| Rejet jusqu’au résultat irréprochable | Correction motivée, puis changement de stratégie en l’absence de progrès | L’absence totale de défaut ne peut être prouvée ; pas de boucle infinie ni de réussite inventée |
| « Cause racine identifiée » obligatoire | Cause prouvée ou hypothèse explicitement nommée | Ne pas pousser un relecteur à inventer une certitude |
| Pas de plafond arbitraire d’outils | Périmètre et critères de fin ; budget explicite respecté s’il est fourni | Un plafond ne doit ni supprimer un contrôle essentiel ni être ignoré |
| Toute doc relue avant travail | Sources ciblées ; décision durable lue lorsqu’elle s’applique | Éviter de charger de longs textes inutiles |

## Contrat de mission minimal

Objectif : résultat vérifiable. Périmètre : fichiers en lecture et éventuels fichiers exclusifs en écriture. Invariants : données préservées, aucune requête privée non autorisée, pas de migration implicite. Preuve attendue : test reproduisant un défaut, source primaire ou parcours UI observé. Retour : résultats prioritaires, fichiers, contrôles exécutés et limites. Pas d’autres agents ni de tâches annexes.

Exemples adaptés : revue de la concurrence Google Drive ; recherche sourcée des retours Cashew ; vérification des dates fin de mois. Ne pas déléguer la simple exécution d’une commande locale dont le résultat tient en quelques lignes.

## Budgets : ce qui est mesurable

L’incident du 13 septembre 2026 a montré que la règle précédente n’était pas opérationnelle : les sous-agents ont été lancés sans sélection explicite et ont donc hérité de GPT-6 Astra et de l’effort du responsable. La documentation OpenAI confirme ce comportement d’héritage. Le projet impose désormais un défaut exécutable dans `.codex/config.toml` et un routage obligatoire dans `AGENTS.md`.

Le défaut projet est `gpt-5.6-terra` avec effort `low`, limité à deux sous-agents simultanés. Une mission étroite et répétable descend vers `gpt-5.6-luna`. Une mission complexe monte vers `gpt-5.6-sol` seulement après justification. GPT-6 Astra n’est pas utilisé par les sous-agents sans demande explicite du propriétaire. Chaque lancement indique aussi un contexte minimal afin d’éviter de recopier l’historique complet dans chaque fenêtre de tokens.

Aucun budget chiffré de session n’a été imposé ici. Ne pas créer de limite fictive, ne pas promettre un pourcentage d’économie et ne pas convertir les tokens en quota Codex par une règle de trois. Le routage réduit le coût attendu ; seul le relevé d’usage réel permet de mesurer l’économie obtenue.

Pour comparer deux stratégies sur des tâches comparables, conserver : résultat accepté ou non, régressions, temps total, nombre de retours correctifs, tokens d’entrée/cachés/sortie/raisonnement lorsque disponibles, coûts d’outils et montant facturé lorsqu’il est exposé. Comparer le coût par résultat accepté, pas uniquement le nombre d’agents. Les tests/calculs de code s’exécutent directement sans payer un modèle pour les simuler.

Les fenêtres d’usage du compte Codex sont partagées. Un relevé avant/après n’isole pas le coût de ce projet si d’autres tâches tournent. L’absence de télémétrie détaillée doit apparaître comme « non disponible ». Ne pas lire toute la télémétrie ou les conversations personnelles pour produire un faux chiffre précis.

## Documentation OpenAI vérifiée

- [Rethinking skills and prompts for GPT-6 Astra — 11 septembre 2026](https://learn.chatgpt.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra) : descriptions de skills précises, documentation révélée progressivement et consignes de dépôt épurées. Application : un point d’entrée court ; pas de lecture obligatoire du framework complet à chaque édition.
- [Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents) : un sous-agent sans modèle ou effort configuré hérite du parent ; `gpt-5.6-terra` convient aux explorations économiques, `gpt-5.6-luna` aux missions étroites et répétables, et un effort supérieur consomme davantage de tokens. Application : défaut Terra/low, deux agents maximum, contexte minimal et lecture seule par défaut. La limite de deux est notre décision, pas une prescription universelle d’OpenAI.
- [AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md) : découverte hiérarchique des instructions. Application : véritable `AGENTS.md` à la racine, plutôt que supposer que `GEMINI.md` est automatiquement découvert par Codex.
- [Prompt caching](https://developers.openai.com/api/docs/guides/prompt-caching) : le cache repose sur les préfixes réutilisables ; paramètres et durée dépendent du modèle. Pour GPT-5.6 et ultérieurs, la page indique `prompt_cache_options.ttl: "30m"`. C’est une configuration API, pas un réglage à ajouter au navigateur SubFlow ni une garantie de quota Codex gratuit.
- [Guide des modèles](https://developers.openai.com/api/docs/guides/latest-model) : adapter l’effort et les instructions ; capacités asynchrones et compaction selon API/harnais. Ne pas assimiler disponibilité API et outils disponibles dans cette session.

Le fragment communautaire `[features.multi_agent_v2]` et ses délais de 25 minutes n’est pas appliqué automatiquement : les pages officielles consultées n’établissent pas ce réglage comme interface stable. La documentation actuelle expose notamment `agents.max_concurrent_threads_per_session`, `agents.default_subagent_model` et `agents.default_subagent_reasoning_effort`. Aucun fichier global `~/.codex/config.toml` n’a été modifié ; la configuration ajoutée est limitée à ce projet.

## Skills et plugins

OpenAI Docs et les outils de navigateur existants couvrent les besoins actuels. Pas de nouveau plugin, SDK d’orchestration ou framework à intégrer à l’application pour organiser cette session. Le guide officiel mentionne `skill-creator` pour les workflows réellement réutilisables ; créer un skill supplémentaire ici doublerait principalement AGENTS.md. Si un workflow stable apparaît (par exemple une qualification de release répétée), extraire ce workflow précis avec déclencheur étroit, scripts vérifiables et ressources chargées à la demande.

## Qualification SubFlow

Les défauts de perte de données, OAuth, stockage de secrets, imports et dates demandent des tests de régression. Les captures proviennent uniquement de la démo. La compilation et les tests unitaires ne certifient ni la sécurité, ni la conformité RGPD, ni le fonctionnement d’une banque réelle. Les points impossibles à vérifier localement restent listés dans le rapport de qualification ; ils ne disparaissent pas derrière une formule « prêt pour production ».
