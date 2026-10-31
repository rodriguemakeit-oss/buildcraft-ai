# Utiliser le socle depuis GitHub Copilot CLI — Guide de lecture (FR)

> **Aide à la lecture pour les non-anglophones.** Le fichier canonique est
> [`docs/copilot-cli.md`](./copilot-cli.md) (en anglais) ; il fait autorité. Ce guide explique
> la même chose en français — il ne traduit pas et ne fait pas autorité. En cas de doute, le
> fichier anglais prime.

## L'idée en une phrase

Le socle est **Claude-natif**, mais l'équipe est **mixte** : certains devs utilisent **Claude
Code**, d'autres **GitHub Copilot CLI**. Le contrat :

> **Une source unique, deux cibles.** Les règles vivent **uniquement** dans
> [`standards/`](../standards). Une seule évolution d'un standard atteint les deux outils —
> personne ne maintient deux copies.

C'est acté par l'**ADR-0007**.

> **⚠️ Utilise le Copilot CLI, pas l'extension VSCode.** Tout le câblage repose sur
> `COPILOT_CUSTOM_INSTRUCTIONS_DIRS`, une variable que **seule la CLI lit**. L'extension VSCode
> l'ignore, ne voit pas les `*.instructions.md` du socle et ne peut pas ouvrir les `standards/*.md`
> qu'ils référencent — elle génère donc avec **zéro** standard chargé (archi non respectée, CSS à
> la place de Tailwind/Fluid, commentaires décoratifs…). Si tu utilises Copilot, lance `copilot`
> dans le terminal après le setup ci-dessous. L'extension VSCode **n'est pas supportée** par ce socle.

## Comment le socle se projette sur chaque outil

| Brique | Claude Code | Copilot CLI |
|---|---|---|
| Règles (vérité) | `standards/*.md` | **les mêmes** `standards/*.md` |
| Instructions | `agents/*.md` + `CLAUDE.md` | `AGENTS.md` + `.github/instructions/*.instructions.md` |
| Procédures | `skills/*/SKILL.md` | **les mêmes** `SKILL.md` (Copilot lit `~/.agents/skills`) |
| Enforcement | hooks + pre-commit | **pre-commit** (Copilot n'a pas de moteur de hooks) |
| Workflows | `/ship`, `/daily`, `/adr`… | un prompt par commande — voir [`copilot-cli-commands.fr.md`](./copilot-cli-commands.fr.md) |

Les fichiers côté Copilot (`AGENTS.md`, les `*.instructions.md`) **ne contiennent aucune règle** —
ils **pointent** vers `standards/`. C'est ce qui garde les deux cibles synchronisées : modifier un
standard suffit.

> Claude Code **ignore** aujourd'hui `AGENTS.md` et `.github/instructions/` (il lit `CLAUDE.md`) :
> ces fichiers sont donc inertes pour les devs Claude — ils ne peuvent pas les induire en erreur.
> Et par construction ils ne peuvent pas contredire les standards, puisqu'ils ne font qu'y renvoyer.

### Quels agents sont couverts

Copilot reçoit les personas **d'édition de fichiers** via `AGENTS.md` + les instructions ciblées,
chacune pointant vers son standard :

| Agent Claude | Surface Copilot (`applyTo`) | Standard |
|---|---|---|
| `backend-fastapi` | `**/*.py` | `backend-fastapi.md` |
| `frontend-react` | `**/*.{ts,tsx,jsx}` | `frontend-react.md` |
| `doc-writer` | `**/*.md` | `documentation.md` |
| `qa-tester` | fichiers de test | `testing.md` |
| `db-migration` | `**/alembic/**`, `**/migrations/**` | `migrations.md` |
| `security-reviewer` | — (skill **`security-review`** partagé) | `security.md` |

Les agents **workflow / PM** (`pm-planner`, `tracker-sync`, `legacy-analyst`) **n'ont aucun**
mapping ciblé — ils sont en forme de commande, pas d'édition de fichier. On les rejoue à la main
en suivant le standard correspondant (ex. `standards/tracker.md`).

## Modèle de distribution — global, par développeur (ADR-0007)

Claude Code distribue le socle comme un **plugin** (installé une fois, dispo dans tous les
projets). Copilot CLI **n'a pas de mécanisme de plugin** : le socle est donc câblé **globalement
sur la machine de chaque dev** et **n'est pas commité dans les repos projets**. Les dépôts projets
restent propres ; le socle vit dans un clone local que tous les projets de la machine lisent.

Compromis assumés (cf. ADR-0007) : chaque dev configure sa machine une fois, et chaque dev
rafraîchit le socle avec `git pull` (la version est par-dev, pas figée par projet).

## Installation (une fois par dev)

1. **Cloner le socle** à un endroit stable (hors d'un projet) :

   ```bash
   git clone https://github.com/rodriguemakeit-oss/buildcraft-ai.git ~/buildcraft-ai
   ```

2. **Lancer l'assistant de setup** (idempotent — crée le symlink des skills, affiche la ligne
   d'environnement à ajouter) :

   ```bash
   ~/buildcraft-ai/scripts/copilot-setup.sh
   ```

   Équivalent manuel :
   - **Instructions** — pointer Copilot sur le clone (dans `~/.zshrc`/`~/.bashrc`) :
     `export COPILOT_CUSTOM_INSTRUCTIONS_DIRS="$HOME/buildcraft-ai"`
   - **Skills** — `mkdir -p ~/.agents && ln -s ~/buildcraft-ai/skills ~/.agents/skills`
   - **MCP** (optionnel) — déclarer les serveurs partagés dans `~/.copilot/mcp-config.json`.

3. **Vérifier** : `~/buildcraft-ai/scripts/copilot-doctor.sh`

## Au quotidien (exemple concret)

Dans un projet, on lance `copilot`. Au démarrage il charge `AGENTS.md` + les instructions ciblées
depuis le clone. Quand on demande un nouvel endpoint :

1. `AGENTS.md` (déjà en contexte) dit : applique `standards/backend-fastapi.md`.
2. L'instruction backend se déclenche car on touche un fichier `**/*.py`.
3. Copilot **ouvre** `standards/backend-fastapi.md` dans le clone et lit les règles
   (Router→Service→Repository, snake_case, ≤100 lignes, profondeur ≤2…).
4. Il écrit le code **dans ton projet**, en respectant ces règles.

Le code généré atterrit dans le projet ; les règles ont été lues dans le clone du socle — les deux
sont sur ta machine. C'est le même principe qu'un agent Claude qui lit `standards/*.md` depuis le
plugin installé.

## Mises à jour / évolutivité

Une évolution de règle = **une seule modification** dans `standards/` en amont. Chacun rafraîchit :

```bash
# Côté Copilot
cd ~/buildcraft-ai && git pull

# Côté Claude Code
claude plugin marketplace update renewable-flex-internal && claude plugin update buildcraft-ai@renewable-flex-internal
```

On ne touche **ni** `AGENTS.md` **ni** les `*.instructions.md` pour une évolution de règle — ils ne
font que pointer. On ne les touche que pour **ajouter** un nouveau standard/skill (câbler les deux
index, cf. `CONTRIBUTING.md`).

## Enforcement (pas de hooks côté Copilot)

Copilot CLI n'a pas d'équivalent des hooks qualité de Claude. La barrière commune aux **deux**
outils est **pre-commit** (`standards/pre-commit.md`) : ruff (`N`, `PLR0915`), ESLint
(`naming-convention`, `max-lines-per-function`), detect-secrets, conventional-commits.

## Limites de ce modèle

- Un dev qui zappe le setup n'a **aucun** standard via Copilot, silencieusement → relancer
  `copilot-doctor`.
- Version par-dev : deux devs peuvent diverger tant que les deux n'ont pas fait `git pull`.
- Le socle n'est pas visible dans les repos projets / la CI. Pour l'avoir figé et visible par
  projet, il faudrait l'autre modèle (commité-par-projet), **volontairement non retenu** ici — voir
  l'ADR-0007 pour le pourquoi.
