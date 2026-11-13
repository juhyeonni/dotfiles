#!/usr/bin/env zsh
# Tests for home/dot_config/zsh/rc.d/40-claude.zsh against a fake HOME and a fake claude.
# Run: zsh tests/claude-accounts.zsh

emulate -L zsh
setopt aliases
repo=${0:A:h:h}
tmp=$(mktemp -d)
trap 'rm -rf $tmp' EXIT

# Resolve jq before HOME moves: a mise shim would install it again under the fake HOME.
jq_bin=$( (( $+commands[mise] )) && mise which jq 2>/dev/null || whence -p jq )
export HOME=$tmp/home
mkdir -p $HOME/.claude $tmp/bin
ln -s $jq_bin $tmp/bin/jq
# The fake claude prints its config dir, then one argument per line.
print -r -- '#!/bin/sh
echo "dir=${CLAUDE_CONFIG_DIR-unset}"
for a in "$@"; do echo "arg=$a"; done' > $tmp/bin/claude
chmod +x $tmp/bin/claude
path=($tmp/bin $path)
unset CLAUDE_CONFIG_DIR

source $repo/home/dot_config/zsh/rc.d/40-claude.zsh
alias cld="claude --dangerously-skip-permissions"

fails=0
expect() {
  local name=$1 want=$2 got=$3
  [[ $got == $want ]] && return
  print -r -- "FAIL $name"$'\n'"  want: ${want//$'\n'/ | }"$'\n'"  got:  ${got//$'\n'/ | }"
  (( fails++ ))
}

A=$HOME/.claude-accounts
mkdir -p $A/work

# AC1
expect AC1 "dir=$A/work"$'\n'"arg=-c" "$(claude @work -c)"
# AC2
expect AC2 "dir=$A/work"$'\n'"arg=--dangerously-skip-permissions" "$(eval 'cld @work')"
# AC3
expect AC3-prompt "dir=unset"$'\n'"arg=-p"$'\n'"arg=@src/app.ts fix" "$(claude -p '@src/app.ts fix')"
expect AC3-file "dir=unset"$'\n'"arg=-p"$'\n'"arg=@README.md" "$(claude -p @README.md)"
expect AC3-missing "dir=unset"$'\n'"arg=@nope" "$(claude @nope)"
[[ ! -e $A/nope ]] || { print FAIL AC3-created; (( fails++ )) }
# only the first @name counts
expect first-only "dir=$A/work"$'\n'"arg=@work" "$(claude @work @work)"
# AC4
expect AC4 "dir=$A/new" "$(claude @new --new)"
[[ -d $A/new ]] || { print FAIL AC4-dir; (( fails++ )) }
# AC7
expect AC7 "dir=unset"$'\n'"arg=-c"$'\n'"arg=hello" "$(claude -c hello)"
expect AC7-env "dir=/keep" "$(CLAUDE_CONFIG_DIR=/keep claude)"

# AC5
src=$HOME/.claude
print '# md' > $src/CLAUDE.md
print '{}' > $src/settings.json
mkdir -p $src/skills $src/plugins $src/projects
print > $src/history.jsonl
print > $src/statusline-command.sh
print '{"oauthAccount":"default","mcpServers":{"gh":{"command":"gh"}}}' > $HOME/.claude.json
mkdir -p $A/m
print '{"own":true}' > $A/m/settings.json
print '{"oauthAccount":"m","userID":"u"}' > $A/m/.claude.json
chmod 600 $A/m/.claude.json

claude @m --mirror > /dev/null
for e in CLAUDE.md skills plugins statusline-command.sh; do
  [[ $(readlink $A/m/$e) == $src/$e ]] || { print FAIL AC5-linked-$e; (( fails++ )) }
done
for e in keybindings.json hooks commands agents rules subagent-statusline.sh projects history.jsonl; do
  [[ ! -e $A/m/$e && ! -L $A/m/$e ]] || { print FAIL AC5-not-linked-$e; (( fails++ )) }
done
[[ ! -L $A/m/settings.json && $(<$A/m/settings.json) == '{"own":true}' ]] || { print FAIL AC5-override; (( fails++ )) }
[[ ! -L $A/m/.claude.json ]] || { print FAIL AC5-claude-json; (( fails++ )) }

rm $A/m/CLAUDE.md
ln -s $tmp/gone $A/m/skills
claude @m --mirror > /dev/null
[[ -L $A/m/CLAUDE.md && -e $A/m/CLAUDE.md ]] || { print FAIL AC5-restore-removed; (( fails++ )) }
[[ $(readlink $A/m/skills) == $src/skills ]] || { print FAIL AC5-restore-broken; (( fails++ )) }

# AC6
expect AC6 '{"oauthAccount":"m","userID":"u","mcpServers":{"gh":{"command":"gh"}}}' \
  "$(jq -c . $A/m/.claude.json)"
expect AC6-mode 600 "$(stat -f %Lp $A/m/.claude.json)"
claude @fresh --new --mirror > /dev/null
expect AC6-new '{"mcpServers":{"gh":{"command":"gh"}}}' "$(jq -c . $A/fresh/.claude.json)"
expect AC6-new-mode 600 "$(stat -f %Lp $A/fresh/.claude.json)"

# Like every rc.d file, it does nothing when its target is missing.
expect no-claude none "$(PATH=/usr/bin:/bin zsh -fc "source $repo/home/dot_config/zsh/rc.d/40-claude.zsh; whence -w claude | cut -d' ' -f2")"

# A second @name that matches is passed on as a prompt.
expect AC1-second "dir=$A/work"$'\n'"arg=@work" "$(claude @work @work)"

(( fails )) && { print "$fails failed"; exit 1 }
print "all passed"
