#!/usr/bin/env bash
# Claude Code status line — inspired by nicoulaj zsh theme

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Shorten path: replace $HOME with ~
home="$HOME"
short_cwd="${cwd/#$home/\~}"

# Trim path to last 30 chars (matching PROMPT_PATH_MAX_LENGTH=30)
if [ "${#short_cwd}" -gt 30 ]; then
  short_cwd="..${short_cwd: -28}"
fi

# Git info (skip optional locks)
git_part=""
if git -C "$cwd" rev-parse --git-dir --no-optional-locks > /dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  unstaged=$(git -C "$cwd" diff --no-optional-locks --quiet 2>/dev/null || echo "!")
  staged=$(git -C "$cwd" diff --no-optional-locks --cached --quiet 2>/dev/null || echo "+")
  flags="${unstaged}${staged}"
  if [ -n "$branch" ]; then
    git_part=" ${branch}${flags:+ $flags}"
  fi
fi

# Context usage
ctx_part=""
if [ -n "$remaining" ]; then
  ctx_part=" ctx:${remaining}%"
fi

# Assemble: green path + dim git + dim model + dim ctx
printf '\033[38;5;71m%s\033[0m' "$short_cwd"
[ -n "$git_part" ] && printf '\033[2m%s\033[0m' "$git_part"
[ -n "$model" ]    && printf '\033[2m  %s\033[0m' "$model"
[ -n "$ctx_part" ] && printf '\033[2m%s\033[0m' "$ctx_part"
