#!/usr/bin/env bash
# Reports the role an agent is playing to herdr as the pane token `role` ("<icon> <name>"),
# so the sidebar and workspace-jump can show it. The role comes from the skill or subagent
# about to run (PreToolUse on Skill and Agent); SessionStart clears it.
# Icons are Nerd Font glyphs, which MuxJK already has.
# Never blocks Claude: every path exits 0.

[[ -n ${HERDR_PANE_ID:-} ]] || exit 0
command -v jq >/dev/null && command -v herdr >/dev/null || exit 0

report() {
  herdr pane report-metadata "$HERDR_PANE_ID" --source agent-role "$@" >/dev/null 2>&1
}

if [[ ${1:-} == clear ]]; then
  report --clear-token role
  exit 0
fi

name="$(jq -r '.tool_input.skill // .tool_input.subagent_type // empty' 2>/dev/null)"
# Plugin skills and agents are "plugin:name"; the table matches the name alone.
case "${name##*:}" in
grilling | spec | triage | ui-placement | goal | prototype | domain-modeling | codebase-design | Plan)
  role="󰏫 plan" ;;
research | deep-research | Explore | claude-code-guide)
  role="󰍉 research" ;;
implement | open-pr | execute-run | tdd | commit | commit-push-pr)
  role="󰣪 build" ;;
verify | verifier | security-review | security-reviewer | code-review | red-team | red-teamer | simplify | ponytail-review)
  role="󰕥 review" ;;
*) exit 0 ;;
esac
report --token "role=$role"
exit 0
