# 언어 런타임 — 설치돼 있을 때만 활성화된다.
#
# 이 파일은 부트스트랩의 일부가 아니다. 새 머신은 셸·에디터만 갖춘 상태로
# 시작하고, 프로젝트가 필요로 할 때 각 런타임을 따로 설치한다.
# 아무것도 없는 머신에서 이 파일은 전부 no-op 이다.

# ── Rust (rustup + cargo) ──────────────────────────────────
[[ -d /opt/homebrew/opt/rustup/bin ]] && path=(/opt/homebrew/opt/rustup/bin $path)
[[ -d $HOME/.cargo/bin ]] && path=($HOME/.cargo/bin $path)

# ── Node (fnm) ─────────────────────────────────────────────
# corepack 심을 쓰려면 아래 eval *앞*에 export FNM_COREPACK_ENABLED=1 을 둘 것.
# (eval 뒤에 두면 이미 환경이 생성된 뒤라 반영되지 않는다.)
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
