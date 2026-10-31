# Utiliser le socle avec Claude Code — Guide de lecture (FR)

> **Aide à la lecture pour les non-anglophones.** Les fichiers de référence du socle
> (standards, agents, skills, commandes) restent **en anglais** : c'est la langue de travail
> des agents Claude, qui les chargent dans leur contexte. Ce guide **explique et cartographie**
> le repo en français — il ne le traduit pas et ne fait pas autorité. En cas de doute, le
> fichier anglais correspondant prime. Voir aussi le [README racine](../README.md).

> 🛠️ **Tu veux faire évoluer le repo ?** Tout est dans le repo (aucune mémoire externe
> requise) : principes & how-to dans [`CONTRIBUTING.md`](../CONTRIBUTING.md), décisions et
> leur pourquoi dans [`docs/adr/`](./adr/README.md), avancement dans
> [`ROADMAP.md`](../ROADMAP.md).

## C'est quoi ?

Un **socle de développement assisté par IA**, *Claude-natif*, distribué comme **plugin
Claude Code** et réutilisable sur tous les projets `portfolio/`. Il fournit des **agents
spécialisés**, des **skills** (procédures), des **commandes** (workflows) et des
**standards** (les règles, source de vérité) pour construire et maintenir des projets
**FastAPI + React** de façon cohérente et autonome.

Idée directrice : la même qualité de bout en bout — *édition → commit → revue → livraison →
suivi* — sans réinventer les conventions à chaque projet.

## Installation (rappel)

Une fois par machine (ensuite agents/skills/commandes/standards sont dispo dans tous les
projets). Enregistrer la marketplace **selon où se trouve le repo du socle** :

```bash
# Cas A — repo en LOCAL (clone sur la machine)
claude plugin marketplace add ~/Sources/portfolio/buildcraft-ai

# Cas B — repo DISTANT (une fois qu'il a un remote, ex. GitHub) : pointer l'URL
claude plugin marketplace add https://github.com/rodriguemakeit-oss/buildcraft-ai.git

# puis, dans les deux cas :
claude plugin install buildcraft-ai@renewable-flex-internal
```

`renewable-flex-internal` = nom de la marketplace, `buildcraft-ai` = nom du plugin. Le
**distant** est préférable en équipe : chacun fait `marketplace update` + `plugin update`
sans clone local. Un **redémarrage de session** applique les mises à jour.

Puis, dans un projet : `/onboard-project` (projet existant) ou `/new-project` (projet neuf).

## Configuration des MCP (outils externes)

Les **MCP** (Model Context Protocol) donnent aux agents l'accès à des outils externes. Ils
se configurent **par projet** dans un fichier **`.mcp.json`** — généré automatiquement par
`/onboard-project` ou `/new-project` (à ne pas commiter : il reste **local**, comme le
`CLAUDE.md`). Serveurs câblés par défaut :

- **`postgres`** — `@crystaldba/postgres-mcp --access-mode=restricted` : l'agent inspecte le
  schéma / valide une requête en **lecture seule**. URL de connexion construite depuis les
  valeurs de dev local (jamais de creds de prod en dur).
- **`atlassian`** (JIRA) — serveur MCP hébergé (OAuth) : lire/créer/transitionner les
  tickets, **uniquement** si le projet suit son travail dans JIRA. Par défaut les specs sont
  des fichiers Markdown locaux sous `specs/` (cf. standard `tracker`), sans MCP.

Les secrets/tokens vivent dans la config MCP (OAuth), **jamais dans le code**. Détails et
mise à jour du plugin dans le [README racine](../README.md).

## Multi-outils : Claude Code + Copilot CLI

Le socle sert une **équipe mixte** : Claude Code **et** GitHub Copilot CLI, depuis une **source
unique** (`standards/`). Les fichiers côté Copilot (`AGENTS.md`, `.github/instructions/*`) ne
contiennent **aucune règle** — ils pointent vers les standards, donc une seule évolution atteint
les deux outils (ADR-0007). Copilot n'ayant pas de mécanisme de plugin, chaque dev Copilot câble
le socle **globalement, une fois** :

```bash
git clone https://github.com/rodriguemakeit-oss/buildcraft-ai.git ~/buildcraft-ai
~/buildcraft-ai/scripts/copilot-setup.sh      # symlink des skills + ligne d'env à ajouter
~/buildcraft-ai/scripts/copilot-doctor.sh     # vérification
```

Modèle complet, exemple d'usage et compromis : **[`copilot-cli.fr.md`](./copilot-cli.fr.md)**
(version anglaise faisant autorité : [`copilot-cli.md`](./copilot-cli.md)).

## Par où commencer un projet ? (les 4 portes d'entrée)

| Commande | Quand l'utiliser |
|---|---|
| **`/new-project`** | Projet **neuf**, rien à reprendre (pose les questions : monorepo ou repos séparés, stack, infra). |
| **`/onboard-project`** | **Adopter un projet existant** tel quel. Si la stack n'est pas FastAPI+React, il **propose** soit `/refonte`, soit un *onboard dégradé* (standards transverses seulement). |
| **`/refactor-audit`** | **Améliorer en place** un projet existant (même stack) : écarts vs les standards + plan priorisé. |
| **`/refonte`** | **Réécrire** un projet legacy (n'importe quelle stack) sur les standards, **avec parité**, quand une refacto en place coûte trop cher. |

## Les agents (sous-agents spécialisés)

| Agent | Rôle |
|---|---|
| `backend-fastapi` | Construit/refactore le backend FastAPI (Clean Archi : Router→Service→Repository→Model, async, tests). |
| `frontend-react` | Construit/refactore le front React + TypeScript, **toujours** Tailwind + portfolio Fluid Design System. |
| `db-migration` | Gère les migrations Alembic (autogenerate + revue manuelle). |
| `qa-tester` | Écrit/renforce les tests (pyramide, cas nominaux **et** d'erreur). |
| `security-reviewer` | Relit les diffs sensibles (OWASP, secrets, Okta, injections) — **revue seule**, ne modifie pas. |
| `pm-planner` | Transforme une idée en mini-PRD + découpage en stories, puis crée les tickets. |
| `tracker-sync` | Fait le pont git ↔ specs (Markdown local, sinon JIRA) : standup, mise à jour des statuts. |
| `doc-writer` | Maintient la **doc utilisateur/API** depuis le code réel (pas le CLAUDE.md ni les ADR). |
| `legacy-analyst` | **Rétro-ingénierie** d'un code existant (toute stack) en une spec — alimente `/refonte`. |

## Les skills (procédures réutilisables)

| Skill | Ce qu'il génère/fait |
|---|---|
| `scaffold-fastapi-feature` | Une feature backend complète (router, service, repository, modèles, schémas, exceptions) + tests. |
| `alembic-migration` | Une migration Alembic (autogenerate + revue). |
| `react-feature` | Une feature React (composant + hook + test), Fluid DS + Tailwind. |
| `scaffold-celery-task` | Une tâche Celery (tâche mince → service), endpoint d'enqueue, suivi de job, tests. |
| `sync-api-types` | Régénère les types TypeScript du front depuis l'OpenAPI du backend. |
| `security-review` | Applique la checklist de sécurité à un diff/zone (par sévérité). |
| `docker-stack` | Génère/ajuste le `docker-compose` (back + front + postgres + Traefik + Adminer…). |

## Les commandes (workflows à lancer avec `/`)

| Commande | Effet |
|---|---|
| `/new-project` | Scaffolde un projet neuf (interactif). |
| `/onboard-project` | Intègre un projet existant (CLAUDE.md + .mcp.json ; gère le hors-stack). |
| `/refonte` | Réécrit un legacy sur les standards, avec parité. |
| `/refactor-audit` | Audite un projet vs les standards + plan priorisé. |
| `/setup-precommit` | Met en place pre-commit (config adaptée à la stack + hooks). |
| `/plan-feature` | Mini-PRD + stories + tickets (via `pm-planner`). |
| `/daily` | Standup quotidien : réconcilie git ↔ tickets et propose les mises à jour. |
| `/ship` | Porte de livraison : tests → revue sécu → doc → PR → sync ticket. |
| `/adr` | Crée le prochain *Architecture Decision Record* (journal de décisions). |

## Exemples par commande

Un exemple concret par commande (suite fictive `asset_api` : import d'un Excel de points de
mesure). La sortie est illustrative — le résultat exact dépend de ton projet et de ton tracker.
Version anglaise détaillée : [`claude-code-commands.md`](./claude-code-commands.md). Équivalent
Copilot CLI de chaque commande : [`copilot-cli-commands.fr.md`](./copilot-cli-commands.fr.md).

- **`/new-project forecast-portal`** → pose les questions (monorepo/split, composants, stack,
  infra, tracker) → scaffolde le squelette + pre-commit + `CLAUDE.md`/`.mcp.json` + commit
  initial.
- **`/onboard-project`** (dans un repo existant) → détecte la stack, génère
  `CLAUDE.md`/`.mcp.json`, met en place pre-commit, signale l'ancien `.github/copilot*`. *Hors
  stack (Angular+.NET)* → il **demande** : basculer `/refonte` ou onboard dégradé.
- **`/refonte ~/Sources/legacy/old-django-app`** → `legacy-analyst` produit une spec → ADR des
  décisions → `/new-project` scaffolde → `pm-planner` crée les stories de parité → agents dev
  reconstruisent.
- **`/refactor-audit`** → compare le projet aux standards → écarts classés Critical/High/… avec
  `fichier:ligne` et un correctif → s'arrête pour ton approbation.
- **`/setup-precommit`** → détecte la stack, écrit `.pre-commit-config.yaml` (hygiène +
  detect-secrets + conventional + ruff/bandit + eslint/prettier) + `.secrets.baseline`,
  installe les 2 stages, lance une passe.
- **`/plan-feature Permettre d'uploader un Excel de points de mesure…`** → `pm-planner` fait un
  mini-PRD + des stories (critères d'acceptation, S/M/L) → crée l'epic `ASSET_API-210` + stories
  `ASSET_API-211..214` + ordre de build.
- **`/daily`** → `tracker-sync` croise l'activité git avec les tickets → standup (Done / In
  progress / Next / Blockers) + transitions proposées. **⚠️ Voir l'avertissement ci-dessous.**
- **`/ship ASSET_API-211`** → **gate** qualité : diff → tests + lint → revue sécu → (si vert)
  commit Conventional + PR via `gh` → doc → sync ticket. S'arrête au moindre bloqueur.
- **`/adr Utiliser un worker Celery + Redis pour l'import Excel`** → crée
  `docs/adr/0007-*.md` (format Nygard : Contexte/Décision/Conséquences/Alternatives).

### ⚠️ `/daily` ne sert quasiment à rien sans MCP tracker

Toute la valeur de `/daily` est le **rapprochement git ↔ specs** et la **mise à jour des
statuts**. Par défaut la source est **des specs Markdown locales sous `specs/`** (sans MCP —
il lit/écrit le champ `status:`) ; si le projet suit son travail dans **JIRA**, le MCP
Atlassian est utilisé à la place. **Sans** ni specs ni tracker, `/daily` se réduit à un résumé
des derniers commits/PR… que `git log` et `gh pr list` te donnent déjà — planifie avec
`/plan-feature` pour lui donner un intérêt. À l'inverse, `/ship` n'a besoin de la source que
pour **une seule étape** (la synchro du ticket) ; tout le
reste fonctionne sans.

## Les standards (les règles — source de vérité)

| Standard | Sujet |
|---|---|
| `backend-fastapi` | Conventions backend FastAPI (Clean Archi, exceptions, tests). |
| `frontend-react` | Conventions front : **Tailwind + Fluid DS obligatoires**, TS strict. |
| `documentation` | Doc utilisateur/API **écrite depuis le code réel** (anti-drift) ; périmètre README/API/`docs/`/docstrings. |
| `project-layout` | Les deux organisations : **monorepo** (`back/`+`front/`) et **repos séparés** ; variantes de nommage. |
| `migrations` | Migrations Alembic (async) : autogenerate + **revue manuelle**, `downgrade()` réversible, pas de perte de données silencieuse. |
| `testing` | Stratégie de tests (pyramide, isolation, déterminisme). |
| `security` | Checklist sécurité (secrets, Okta, injections, dépendances, logs). |
| `auth-okta` | Authentification/autorisation **Okta** : vérif JWT (JWKS), autorisation par ressource, câblage front. |
| `api-errors` | Enveloppe d'erreur API canonique + mapping exception→statut (handlers centraux). |
| `pull-request` | *Definition of Done* + template de PR (`.github/pull_request_template.md`). |
| `tracker` | Contrat **specs** : specs Markdown locales (`specs/epic-xx/us-xxx`) par défaut, sinon JIRA. |
| `pre-commit` | Baseline pre-commit (hygiène, detect-secrets, ruff/bandit, eslint/prettier, commit-msg). |
| `api-contract` | **OpenAPI = source de vérité** ; types front générés, jamais écrits à la main. |
| `observability` | Logs JSON structurés, corrélation trace, OpenTelemetry, `/health`+`/ready`. |
| `commits` | **Conventional Commits** (alimente le tag + changelog du pipeline infra). |
| `adr` | Format des *Architecture Decision Records* (décisions structurantes historisées). |
| `async-tasks` | Traitement asynchrone **Celery + Redis** (gros fichiers Excel/CSV, règles métier). |

## Les hooks (automatismes qualité)

| Hook | Effet |
|---|---|
| `format-lint` | Formate/lint le fichier édité (ruff, eslint/prettier) — non bloquant. |
| `block-secrets` | **Bloque** l'écriture de secrets en dur et des vrais `.env`. |

## Glossaire FR ↔ EN

| Terme (EN) | En français |
|---|---|
| **standard** | règle / convention de référence |
| **agent / sub-agent** | agent spécialisé (assistant dédié à un rôle) |
| **skill** | procédure réutilisable, chargée à la demande |
| **command** | workflow déclenché par `/nom` |
| **hook** | automatisme déclenché par un événement |
| **scaffold** | générer le squelette (structure de départ) |
| **layout** | organisation/arborescence du projet |
| **monorepo** | un seul repo contenant back + front |
| **tracker** | source des specs (Markdown local par défaut, sinon JIRA) |
| **standup / daily** | point quotidien d'avancement |
| **ship** | livrer (préparer/pousser la livraison) |
| **parity** | parité (même comportement que l'existant) |
| **drift** | dérive (doc/types qui ne collent plus au code) |
| **onboarding** | intégration (brancher un projet sur le socle) |
| **broker** | courtier de messages (ici Redis, pour Celery) |
| **idempotent** | rejouable sans double effet |

## Périmètre / hors-périmètre

- **Inclus** : tout le cycle dev/PM ci-dessus, sur la stack **FastAPI + React**.
- **Exclu — géré par l'équipe infra** : la **CI/CD** (le pipeline crée le tag + changelog au
  merge) et l'**agrégation des logs** (Splunk / AWS). Le socle s'arrête au **pre-commit** et
  émet des logs structurés ; l'infra prend le relais.
