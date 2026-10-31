# GitHub Copilot CLI — l'équivalent de chaque commande — Guide (FR)

> **Aide à la lecture (FR).** Le fichier canonique est
> [`copilot-cli-commands.md`](./copilot-cli-commands.md) (anglais) ; il fait autorité. Ce guide
> explique la même chose en français.

Les commandes Claude Code (`/ship`, `/daily`…) sont **spécifiques à Claude** : elles vivent dans
`commands/` et Copilot CLI ne les lit pas. Mais une commande n'est qu'un prompt sauvegardé qui
**orchestre les standards/agents/skills**. Donc sous Copilot tu obtiens le même résultat en
**tapant ce prompt toi-même** — en pointant vers le même standard (et, si utile, le skill partagé).

> Prérequis : le socle est câblé globalement (voir [`copilot-cli.fr.md`](./copilot-cli.fr.md)),
> donc `AGENTS.md` + les instructions ciblées sont déjà en contexte et les standards sont dans ton
> clone `~/buildcraft-ai`. Les skills sont dispo aussi (Copilot les lit dans `~/.agents/skills`)
> : tu peux invoquer directement `security-review`, `scaffold-fastapi-feature`, etc.

## Carte rapide

| Commande Claude | Équivalent Copilot | S'appuie sur |
|---|---|---|
| `/new-project` | prompt : scaffolder depuis les standards (pas de `CLAUDE.md`/`.mcp.json`) | `project-layout`, `backend-fastapi`, `frontend-react`, `pre-commit` |
| `/onboard-project` | **rien à faire** — le socle est déjà global ; au besoin, mettre pre-commit | `pre-commit` |
| `/refonte` | prompt : rétro-ingénierie → reconstruction sur les standards (par étapes) | méthode `legacy-analyst`, standards dev |
| `/refactor-audit` | prompt : audit vs les standards, écarts classés avec `fichier:ligne` | tous les standards |
| `/setup-precommit` | prompt : mettre en place pre-commit pour la stack | `pre-commit` |
| `/setup-observability` | prompt : ajouter des logs structurés (opt-in ; metrics/traces à la demande) | `observability` |
| `/plan-feature` | prompt : PRD + découpage en stories → specs locales (défaut) ou JIRA | `tracker` (JIRA optionnel) |
| `/daily` | prompt : réconcilier git ↔ specs, proposer les transitions | `tracker` (JIRA optionnel) |
| `/ship` | prompt : tests + lint + revue sécu → PR | `pull-request`, skill `security-review` |
| `/adr` | prompt : rédiger le prochain ADR | `adr` |

Il n'y a **pas de raccourci sauvegardé** — tu tapes le prompt. (Tu *pourrais* transformer les plus
fréquents en vrais raccourcis Copilot via des custom agents `.github/agents/*.agent.md` ;
volontairement non fait — voir la discussion sur les agents dans `copilot-cli.fr.md`.)

## Par commande (prompts à copier-coller)

Les prompts canoniques (en anglais) sont dans
[`copilot-cli-commands.md`](./copilot-cli-commands.md). En résumé :

- **`/new-project`** → demander à Copilot de scaffolder un monorepo FastAPI + React selon
  `standards/project-layout.md` (+ `backend-fastapi`, `frontend-react`, `pre-commit`). Orchestration
  lourde, à piloter par étapes. Pas de `CLAUDE.md`/`.mcp.json` (propres à Claude).
- **`/onboard-project`** → **rien à onboarder** en général : le setup global a déjà câblé le socle
  pour tous les projets, et il n'y a pas de `CLAUDE.md`/`.mcp.json` à générer. Seul artefact partagé
  utile : pre-commit (voir ci-dessous).
- **`/refonte`** → demander une rétro-ingénierie en spec (inventaire stack/données/API/règles/risques
  avec `fichier:ligne`), puis reconstruire sur les standards avec parité. Grosse tâche → par étapes.
- **`/refactor-audit`** → « Audite ce projet vs les standards de `~/buildcraft-ai/standards` ;
  liste les écarts classés Critical/High/Medium/Low avec `fichier:ligne` et un correctif ; ne change
  rien encore. »
- **`/setup-precommit`** → « Mets en place pre-commit selon `standards/pre-commit.md` pour cette
  stack… » Pre-commit est **agnostique de l'outil** → résultat identique à la commande Claude. C'est
  la barrière d'enforcement commune aux deux outils.
- **`/setup-observability`** → **opt-in** : demander à Copilot d'ajouter, selon
  `standards/observability.md`, des logs JSON structurés sur stdout (structlog) + middleware
  `request_id` + `/health` `/ready`. Metrics (`prometheus-client` sur `/metrics`) et tracing
  distribué (OpenTelemetry/OTLP) **seulement si tu le demandes**. Rien n'est ajouté par défaut.
- **`/plan-feature`** → demander un PRD léger + des stories en tranches verticales (critères
  Given/When/Then, S/M/L). **Réutiliser d'abord les specs déjà présentes** dans le repo, puis
  **demander où vont les specs** : Markdown local sous `specs/epic-xx/us-xxx` (défaut, sans MCP) ou
  JIRA. Toujours poser la question ; JIRA seulement si l'équipe suit son travail là-bas.
- **`/daily`** → demander la réconciliation git ↔ specs + un standup (Done/In progress/Next/
  Blockers) + transitions proposées. Par défaut la source est **les specs Markdown locales** (sans
  MCP, met à jour le champ `status:`) ; JIRA seulement si le projet y suit son travail. Sans ni l'un
  ni l'autre, ça se réduit à un résumé git.
- **`/ship`** → « Prépare cette branche pour la livraison selon `standards/pull-request.md` : tests +
  lint, revue sécu (skill `security-review`), et si tout est vert, commit Conventional + PR via
  `gh`. » Contrairement à la commande Claude, c'est une **gate manuelle** (pas d'arrêt forcé) → relis
  chaque étape.
- **`/adr`** → « Rédige le prochain ADR dans `docs/adr/` selon `standards/adr.md` (format Nygard) pour
  cette décision : … »
