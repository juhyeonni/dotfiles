# Language runtimes — enabled only when installed.
#
# This file is not part of the bootstrap. A new machine starts with shell and editor only,
# and each runtime gets installed when a project actually needs it.
# On a bare machine every line here is a no-op.

# ── Rust (rustup + cargo) ──────────────────────────────────
[[ -d /opt/homebrew/opt/rustup/bin ]] && path=(/opt/homebrew/opt/rustup/bin $path)
[[ -d $HOME/.cargo/bin ]] && path=($HOME/.cargo/bin $path)

# ── Node (fnm) ─────────────────────────────────────────────
# To use corepack shims, put export FNM_COREPACK_ENABLED=1 *before* the eval below.
# (After the eval the environment is already built, so it has no effect.)
if (( $+commands[fnm] )); then
  eval "$(fnm env)"
fi

# ── Deno ───────────────────────────────────────────────────
[[ -d $HOME/.deno/bin ]] && path=($HOME/.deno/bin $path)

# ── Bun ────────────────────────────────────────────────────
if [[ -d $HOME/.bun ]]; then
  export BUN_INSTALL="$HOME/.bun"
  path=($BUN_INSTALL/bin $path)
  [[ -s $HOME/.bun/_bun ]] && source "$HOME/.bun/_bun"
fi
