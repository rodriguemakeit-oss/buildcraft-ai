#!/usr/bin/env bash
# Wire GitHub Copilot CLI to the buildcraft-ai socle (global, per developer).
# Idempotent. See docs/copilot-cli.md.
set -euo pipefail

AIDP_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_LINK="${HOME}/.agents/skills"

echo "buildcraft-ai → Copilot CLI setup"
echo "  socle (AIDP_HOME): ${AIDP_HOME}"
echo ""

# 1. Skills — Copilot reads ~/.agents/skills
mkdir -p "${HOME}/.agents"
if [ -L "${SKILLS_LINK}" ] && [ "$(readlink "${SKILLS_LINK}")" = "${AIDP_HOME}/skills" ]; then
  echo "  [skills]        ok — ${SKILLS_LINK} already linked"
elif [ -e "${SKILLS_LINK}" ] || [ -L "${SKILLS_LINK}" ]; then
  echo "  [skills]        SKIP — ${SKILLS_LINK} exists and points elsewhere; review it by hand"
else
  ln -s "${AIDP_HOME}/skills" "${SKILLS_LINK}"
  echo "  [skills]        linked ${SKILLS_LINK} -> ${AIDP_HOME}/skills"
fi

# 2. Custom-instructions dir — we DON'T edit your shell profile; we print the line to add
echo ""
if printenv COPILOT_CUSTOM_INSTRUCTIONS_DIRS 2>/dev/null | grep -q "${AIDP_HOME}"; then
  echo "  [instructions]  ok — COPILOT_CUSTOM_INSTRUCTIONS_DIRS already includes the socle"
else
  echo "  [instructions]  add this to your shell profile (~/.zshrc or ~/.bashrc), then restart:"
  echo ""
  echo "      export COPILOT_CUSTOM_INSTRUCTIONS_DIRS=\"${AIDP_HOME}\""
fi

echo ""
echo "Done. Verify with: ${AIDP_HOME}/scripts/copilot-doctor.sh"
