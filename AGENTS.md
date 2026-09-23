# SubFlow — règles actives

## Produit et confidentialité
SubFlow suit les abonnements et prélèvements récurrents. Garder ce périmètre : pas de comptabilité générale, de recommandations financières personnalisées ni de résiliation prétendument automatique. La sécurité, la vie privée, l’intégrité des données et l’accessibilité priment sur l’animation ou la monétisation.

Le web est dans `apps/web`, les calculs/exports partagés dans `packages/core`, les composants dans `packages/ui`. Flutter est une implémentation distincte (`lib`, `test`) : une validation web ne prouve pas la parité mobile. Ne jamais lire ou imprimer les valeurs des secrets pour un audit. Utiliser des données fictives pour les captures et tests.

## Travail et délégation
Travailler seul par défaut. Déléguer seulement une tâche indépendante qui réduit un risque ou un délai réel pendant qu’un travail utile reste au responsable. Maximum deux sous-agents simultanés ; aucun sous-agent ne délègue à son tour.

Le responsable est l’unique auteur du code par défaut ; les agents font des recherches/revues en lecture seule. Une mission d’implémentation peut être confiée explicitement à un agent sur des fichiers exclusifs : le responsable n’y écrit pas pendant cette mission. Aucun second auteur sur le même périmètre. Ne pas redéléguer mécaniquement les tests ou les petites corrections.

Chaque mission précise objectif, fichiers autorisés, invariants, livrable et preuve de fin. Fournir le contexte nécessaire, pas toute l’histoire si un bref contrat suffit.

### Routage obligatoire des modèles
Ne jamais laisser un sous-agent hériter implicitement du modèle ou de l’effort du responsable. Chaque délégation précise `model`, `reasoning_effort` et un `fork_turns` minimal. Utiliser `fork_turns="none"` avec un brief autonome par défaut, ou seulement les derniers tours indispensables. Ne jamais transmettre tout l’historique par confort.

| Mission | Modèle | Effort initial |
|---|---|---|
| Recherche étroite, commande répétable, tri ou extraction | `gpt-5.6-luna` | `low` |
| Exploration du dépôt, benchmark, revue documentaire, synthèse | `gpt-5.6-terra` | `low` |
| Implémentation bornée ou revue technique avec ambiguïté | `gpt-5.6-terra` | `medium` |
| Sécurité complexe, architecture ou blocage prouvé après un premier essai | `gpt-5.6-sol` | `medium`, puis `high` seulement si nécessaire |

`gpt-6-astra` est réservé au responsable pour les arbitrages réellement difficiles. Il est interdit pour un sous-agent sauf demande explicite du propriétaire. L’effort `high` ou supérieur exige dans la mission une raison liée à la complexité ; il n’est jamais le réglage par défaut.

Commencer au niveau le moins coûteux compatible avec le risque. Monter d’un seul niveau après un résultat insuffisant documenté, plutôt que relancer la même mission. Pour les tests déterministes, exécuter directement les outils locaux : ne pas payer un agent pour simuler une commande. Le responsable consigne dans son compte rendu les modèles et efforts réellement utilisés.

Ne pas sonder périodiquement un agent pour constater qu’il travaille encore. Exploiter les retours d’événements ; utiliser les attentes prises en charge par le harnais lorsque rien d’utile ne reste. Ne pas interrompre à cause d’un simple délai expiré. Un échec répété sans preuve nouvelle impose un diagnostic ou un périmètre plus petit, pas une boucle identique.

## Vérification proportionnée
Exécuter les tests ciblés sur les changements de logique. Pour une livraison web, `pnpm test` et `pnpm run build` doivent passer. Vérifier dans le navigateur les parcours UI modifiés sur ordinateur et mobile. Ne répéter des contrôles réussis que si un changement ou un défaut le justifie. Ces contrôles locaux sur fixtures sont autorisés ; pas d’appel bancaire réel ou d’envoi de données privées dans les tests.

Distinguer résultat exécuté, cache de tests, hypothèse et limitation. Inspecter les preuves d’un agent avant de les adopter. Une limite de budget ne transforme jamais un travail incomplet en réussite. Aucun engagement de sécurité absolue ou conformité certifiée sans preuve.

## Mémoire et contexte
Lire `.agents/memory/decisions.md` lors d’un arbitrage d’architecture, pas avant chaque retouche. Le responsable y conserve les décisions durables ; les diagnostics temporaires vont dans `/tmp` et les résultats utiles dans `docs/`. Ne charger les cinq documents génériques de `framework_universel` que pour modifier la gouvernance ; ils sont des sources historiques, pas une deuxième pile de consignes actives.

La justification, les sources officielles et les limites de mesure figurent dans `framework_universel/ADAPTATION_SUBFLOW.md`. `GEMINI.md` et `.agents/rules/surgical_rules.md` renvoient ici pour éviter les contradictions.
