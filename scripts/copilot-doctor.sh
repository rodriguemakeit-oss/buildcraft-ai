#!/usr/bin/env bash
# Check that Copilot CLI is wired to the buildcraft-ai socle. See docs/copilot-cli.md.
set -uo pipefail

AIDP_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_LINK="${HOME}/.agents/skills"
ok=0; ko=0
pass(){ echo "  ✅ $1"; ok=$((ok + 1)); }
fail(){ echo "  ❌ $1"; ko=$((ko + 1)); }

echo "buildcraft-ai → Copilot CLI doctor"
echo "  socle: ${AIDP_HOME}"
echo ""

if command -v copilot >/dev/null 2>&1; then pass "copilot CLI found on PATH"; else fail "copilot CLI not on PATH"; fi
if [ -f "${AIDP_HOME}/AGENTS.md" ]; then pass "AGENTS.md present"; else fail "AGENTS.md missing"; fi
if [ -d "${AIDP_HOME}/.github/instructions" ]; then pass ".github/instructions present"; else fail ".github/instructions missing"; fi

if printenv COPILOT_CUSTOM_INSTRUCTIONS_DIRS 2>/dev/null | grep -q "${AIDP_HOME}"; then
  pass "COPILOT_CUSTOM_INSTRUCTIONS_DIRS includes the socle"
else
  fail "COPILOT_CUSTOM_INSTRUCTIONS_DIRS does not include ${AIDP_HOME} (run copilot-setup.sh)"
fi

if [ -L "${SKILLS_LINK}" ] && [ -e "${SKILLS_LINK}" ]; then
  pass "skills symlink ${SKILLS_LINK} -> $(readlink "${SKILLS_LINK}")"
else
  fail "skills symlink ${SKILLS_LINK} missing or broken (run copilot-setup.sh)"
fi

echo ""
echo "  ${ok} ok, ${ko} problem(s)."
[ "${ko}" -eq 0 ]
