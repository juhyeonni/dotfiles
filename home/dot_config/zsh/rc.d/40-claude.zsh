# claude @name: run Claude Code as another subscription account.
#
# Claude Code keys its Keychain login to CLAUDE_CONFIG_DIR, so each ~/.claude-accounts/<name>
# keeps its own /login and accounts run side by side. `@name` may sit anywhere in the
# arguments (the cld alias puts its flag first); only the first one counts. It counts only when
# the account directory exists or --new is given, so `-p @README.md` stays a prompt and a typo
# does not create an account.
#
#   claude @x --new --mirror   create an account that shares ~/.claude's config, then /login
#   claude @x --new            create an independent account
#   claude @x                  open a session as x
#   claude @x --mirror         restore the account's links after ~/.claude gains an entry

(( $+commands[claude] )) || return 0

claude() {
  local root=$HOME/.claude-accounts arg name new
  (( ${argv[(Ie)--new]} )) && new=1
  for arg in "$@"; do
    [[ $arg =~ '^@[A-Za-z0-9_-]+$' ]] || continue
    [[ -n $new || -d $root/${arg#@} ]] || continue
    name=${arg#@}
    break
  done
  [[ -z $name ]] && { command claude "$@"; return }

  local dir=$root/$name mirror
  local -a rest
  local skipped
  for arg in "$@"; do
    case $arg in
      --new) ;;
      --mirror) mirror=1 ;;
      @$name) [[ -n $skipped ]] && rest+=("$arg"); skipped=1 ;;
      *) rest+=("$arg") ;;
    esac
  done

  [[ -n $new ]] && mkdir -p -m 700 "$dir"
  [[ -n $mirror ]] && _claude_mirror "$dir"
  CLAUDE_CONFIG_DIR=$dir command claude "${rest[@]}"
}

# Link the shared config of ~/.claude into an account. A real file already there is the
# account's own override and stays. projects/, history.jsonl and .claude.json are never linked:
# history is per account, and .claude.json holds the account's login and caches.
_claude_mirror() {
  local dir=$1 src=$HOME/.claude entry
  for entry in CLAUDE.md settings.json keybindings.json skills hooks plugins commands agents \
               rules statusline-command.sh subagent-statusline.sh; do
    [[ -e $src/$entry ]] || continue
    [[ -e $dir/$entry && ! -L $dir/$entry ]] && continue
    ln -sfn "$src/$entry" "$dir/$entry"
  done

  # Copy only mcpServers, rewriting in place so the file keeps its 600 mode.
  [[ -f $HOME/.claude.json ]] || return 0
  local acc=$dir/.claude.json json
  [[ -f $acc ]] || (umask 077; print '{}' > "$acc")
  json=$(jq --slurpfile src "$HOME/.claude.json" '.mcpServers = ($src[0].mcpServers // {})' "$acc") \
    && print -r -- "$json" > "$acc"
}
