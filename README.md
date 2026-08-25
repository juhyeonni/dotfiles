# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages

| Package | Config |
|---------|--------|
| zsh | `.zshrc`, `.zprofile`, `.config/zsh/rc.d/` (선택 계층) |
| nvim | `.config/nvim/` (LazyVim) |
| herdr | `.config/herdr/config.toml`, `.config/herdr/scripts/` |
| tmux | `.config/tmux/tmux.conf` (herdr 로 이주 중 — 제거 예정) |
| sesh | `.config/sesh/sesh.toml`, `dev-layout.sh` (프로젝트 = 세션 3-window) |
| ghostty | `.config/ghostty/config` |
| git | `.gitconfig`, `.config/git/ignore` |
| karabiner | `.config/karabiner/karabiner.json` (키 리매핑) |
| hammerspoon | `.hammerspoon/init.lua` (입력 소스 전환) |
| claude | `.claude/CLAUDE.md` (전역 지침 — 미니멀 유지) |

## Bootstrap

```bash
# 1. Homebrew dependencies
brew install stow herdr neovim jq fzf fd ripgrep bat eza lazygit zoxide ghq

# 2. Clone & stow
git clone https://github.com/juhyeonni/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow zsh nvim git ghostty karabiner hammerspoon claude
stow --no-folding herdr   # herdr 는 herdr.sock 을 같은 디렉토리에 쓴다 — 폴딩하면 레포로 들어온다
```

`tmux`/`sesh` 는 herdr 이주 중 롤백용으로 레포에만 남겨두었고 더 이상 stow 하지 않는다.
되돌리려면 `brew install tmux sesh && stow tmux sesh` 후 `.zshrc` 의 auto-attach 를 tmux 로 바꾼다.

stow는 심볼릭 링크만 건다. 각 프로그램의 추가 설치(플러그인 등)는 아래 섹션 참고.
개발 루프(프로젝트 진입 → 코드 → 커밋)는 [WORKFLOW.md](WORKFLOW.md) 참고.

**언어 런타임(Rust·Node·Deno·Bun·JVM·gcloud)은 여기에 포함되지 않는다.** 부트스트랩은
셸·에디터·터미널까지만 세우고, 런타임은 프로젝트가 필요로 할 때 따로 설치한다
([zsh 섹션](#zsh) 참고).

---

## zsh

[Oh My Zsh](https://ohmyz.sh/) + custom 플러그인을 사용한다. stow로는 설치되지 않으므로 따로 clone 한다 (모두 없어도 셸은 에러 없이 뜨지만, 자동완성·하이라이트가 빠진다).

```bash
# Oh My Zsh 본체
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# custom 플러그인 (ZSH_CUSTOM = ~/.oh-my-zsh/custom)
ZC=~/.oh-my-zsh/custom/plugins
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions      $ZC/zsh-autosuggestions
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting  $ZC/zsh-syntax-highlighting
git clone --depth 1 https://github.com/MichaelAquilina/zsh-you-should-use $ZC/you-should-use
git clone --depth 1 https://github.com/fdellwing/zsh-bat                  $ZC/zsh-bat
git clone --depth 1 https://github.com/Aloxaf/fzf-tab                     $ZC/fzf-tab
```

- `git`·`fzf`는 OMZ 내장 플러그인이라 clone 불필요 (`fzf`는 brew 목록에 포함).
- 로드 순서: `fzf-tab`이 `zsh-autosuggestions` 뒤, `zsh-syntax-highlighting` 앞이어야 한다 (`.zshrc` 주석 참고).
- `ls`는 `eza`로 alias (brew 목록에 포함). 없으면 기본 `ls`로 fallback.

### 계층 구조

`.zshrc`(코어)는 셸 자체만 다루고, 있을 수도 없을 수도 있는 것은 바깥으로 뺐다.

| 계층 | 위치 | 로드 조건 |
|------|------|-----------|
| 코어 | `.zshrc` | 항상 |
| 선택 (언어 런타임 등) | `.config/zsh/rc.d/*.zsh` | 파일이 있으면 번호 순으로. 각 파일이 자체 가드 |
| 머신 전용 | `~/.zshrc.local` | 있으면. 레포에 들어가지 않는다 |

`rc.d`의 각 조각은 대상이 설치돼 있을 때만 동작한다 — 예를 들어 `~/.sdkman`이 없으면
`90-sdkman.zsh`는 통째로 no-op이다. **새 머신에서 런타임을 하나도 안 깔면 rc.d 전체가
아무 일도 하지 않는다.** 런타임을 쓰게 되면 그때 설치하면 되고, `.zshrc`는 건드릴 필요 없다.

시작 시간 참고(측정값): 전체 약 190ms 중 oh-my-zsh 130ms, SDKMAN+gcloud 40ms,
나머지 설정 전부 합쳐 10ms 남짓.

## nvim

[LazyVim](https://www.lazyvim.org/) 기반. 플러그인은 첫 실행 시 lazy.nvim이 `lazy-lock.json`대로 자동 설치한다.

```bash
# ghq root를 nvim lazy dev.path(~/.ghq/github.com)와 맞춤
git config --global ghq.root '~/.ghq'
```

추가 요구사항은 `.config/nvim/REQUIREMENTS.md` 참고.

## herdr

[herdr](https://herdr.dev) — 에이전트 상태를 인지하는 터미널 멀티플렉서. tmux 를 대체한다.
계층은 **workspace(= 프로젝트) > tab > pane**.

- prefix 는 `ctrl+a` (tmux 시절 유지). Ghostty 의 `cmd+t`/`ctrl+tab`/`ctrl+shift+tab` 이
  `\x01` 시퀀스로 이 prefix 를 때린다.
- `prefix+S` — 프로젝트 진입점. zoxide 후보를 fzf 로 고르면 workspace 를 열거나 만든다.
  중복 판정은 생성 시 새겨둔 metadata 토큰 `ws_root`(원본 절대경로)로 한다.
  `alt+s`/`ctrl+alt+s` 로도 열리지만 **한글 입력 상태에서는 직접 바인딩이 안 먹는다** —
  `switch_ascii_input_source_in_prefix` 는 prefix 모드에서만 ASCII 로 전환하기 때문이다.
- `prefix+alt+g` lazygit · `prefix+ctrl+c` Claude · `prefix+alt+t` 스크래치 셸 (전부 팝업)
- `prefix+o` — 알림이 뜬 pane 으로 점프. **알림을 클릭하면 터미널 앱이 활성화될 뿐
  해당 pane 으로 가지 않는다.**
- 에이전트 상태(blocked/working/done/idle)를 사이드바에 띄우려면 훅 설치가 필요하다:

```bash
herdr integration install claude
herdr config check                  # config.toml 문법 검사
herdr server reload-config          # 실행 중인 서버에 config 재적용 (파일 감시 안 함)
```

brew 로 깔면 brew 가 버전을 관리하고, herdr.dev 의 standalone 설치본을 쓰면
`herdr update` 가 스스로 갱신한다 (이 머신은 후자 — `~/.local/bin/herdr`).

세션 복원은 내장이다(tmux-resurrect/continuum 불필요). 서버가 재시작돼도 레이아웃을
복구하고, `[session] resume_agents_on_restore` 로 에이전트 대화까지 되살린다.

## tmux

- **TPM(플러그인 매니저)**: 첫 tmux 실행 시 `tmux.conf`의 auto-install 블록이 자동으로 clone/설치.
- **extrakto**: python3 필요 (macOS 기본 포함).

주요 키: `prefix+g` 스크래치 팝업 · `prefix+C-c` Claude 팝업 · `prefix+G` lazygit · `prefix+S` sesh 세션 스위처 · `prefix+tab` extrakto

## sesh

`sesh.toml`로 세션을 정의하고 `dev-layout.sh`가 프로젝트당 3-window 레이아웃을 구성한다. tmux에서 `prefix+S`로 세션 스위처를 띄운다. zoxide 히스토리를 활용하므로 `zoxide`(brew 목록 포함) 필요.

## ghostty

- **폰트**: `MuxJK` 폰트 사용 — 별도 설치 필요.

## git

`.gitconfig`(전역 설정)와 `.config/git/ignore`(전역 gitignore). 별도 의존성 없음.

## 입력 소스 전환 (karabiner + hammerspoon)

한/영/일 전환은 **두 프로그램이 나눠 맡는다.** Karabiner가 물리 키를 신호로 바꾸고,
Hammerspoon이 그 신호를 입력 소스 전환으로 해석한다.

| 키 | Karabiner 매핑 | Hammerspoon 동작 |
|----|----------------|------------------|
| `caps lock` | → `f19` | 한국어 ↔ 영어 |
| `right option` | → `f17` | 한국어 ↔ 일본어 |
| `shift+cmd+space` | — | 한국어 ↔ 일본어 |

`caps_lock → f19` 매핑은 프로파일 최상위와 **`devices[]` 안 개별 키보드 항목 양쪽에**
들어 있다. 하나만 지우면 다른 쪽이 남아서 동작한다 — 바꿀 때 둘 다 확인할 것.

### Karabiner 단독 구성을 시도했다가 되돌린 기록

Hammerspoon을 없애고 Karabiner의 `select_input_source`로 직접 전환하는 구성을
시험했으나 정상 동작하지 않아 되돌렸다. 이 API는 macOS의 deprecated Carbon API를
쓰고, 한국어·일본어처럼 `input_mode_id`를 가진 CJK 입력 소스에서 불안정하다는
보고가 공식 문서와 이슈 트래커에 있다. 같은 시도를 반복하지 말 것.

- [to.select_input_source](https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to/select-input-source/) — CJK 실패 가능성 명시
- [Issue #1602](https://github.com/pqrs-org/Karabiner-Elements/issues/1602) — CJKV 전환 이슈

### 알아둘 것

- Karabiner는 입력 모니터링, Hammerspoon은 손쉬운 사용 권한이 필요하다(둘 다 수동).
- `devices[]`에 `ignore: true`로 제외된 키보드가 있다(vendor 1133 / product 49312).
  그 키보드에서는 어떤 Karabiner 규칙도 적용되지 않는다.

## claude

Claude Code 전역 지침 `~/.claude/CLAUDE.md` (미니멀 유지).

---

## Restow (after changes)

```bash
cd ~/dotfiles
stow -R <package>
```
