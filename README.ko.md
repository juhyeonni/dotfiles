# dotfiles

> 한국어판. 영어판은 [README.md](README.md).

macOS 개발 환경. 터미널은 Ghostty, 멀티플렉서는 herdr, 에디터는 nvim 이고, Claude Code 와 pi 를
herdr pane 에 띄워 쓴다. [chezmoi](https://www.chezmoi.io/) 로 관리한다.

## 구성

| 영역 | 도구 | 설정 (`home/` 아래) | 문서 |
|------|------|---------------------|------|
| 터미널 | Ghostty | `dot_config/ghostty/config` | — |
| 멀티플렉서 | herdr (tmux 대신) | `dot_config/herdr/` | [herdr](docs/herdr.md) |
| 셸 | zsh + Oh My Zsh | `dot_zshrc`, `dot_config/zsh/rc.d/` | [zsh](docs/zsh.md) |
| 에디터 | nvim 0.12 (`vim.pack`) | `dot_config/nvim/` | [nvim](home/dot_config/nvim/README.md) |
| 입력 소스 | Karabiner + Hammerspoon | `dot_config/karabiner/`, `dot_hammerspoon/` | [input-source](docs/input-source.md) |
| 에이전트 | Claude Code · pi | `dot_claude/` · pi 는 관리 안 함 | [claude](docs/claude-code.md) · [pi](docs/pi.md) |
| git | git | `dot_gitconfig.tmpl`, `dot_config/git/ignore` | — |
| 패키지 | Homebrew (Intel 은 mise) | `Brewfile`, `dot_config/mise/` | — |
| 브라우저 | Vimium 링크 힌트 CSS | `vimium/` (repo 루트, 배포 안 함) | [vimium](docs/vimium.md) |

`.chezmoiroot` 가 `home/` 을 가리켜서 그 아래만 배포된다. `dot_` 는 맨 앞 `.`, `executable_` 은
실행 비트가 된다. `docs/` 는 영어로만 쓴다.

## 쓰는 방식

- 프로젝트마다 herdr workspace 를 하나씩 쓴다. `alt+s` 로 workspace-jump 를 띄워 열린 workspace·최근
  연 곳·zoxide·ghq 에서 골라 연다. 오른쪽 창에 그 workspace 의 agent 와 하는 일이 보이고, `→` 로
  agent 목록을 열어 `enter` 로 바로 이동한다.
- 사이드바에 workspace 별 agent 상태(blocked · working · done · idle)와 Claude 가 지금 하는
  작업 제목이 뜬다.
- Ghostty 가 macOS 단축키 `cmd+t` 새 탭, `cmd+w` workspace 닫기, `ctrl+tab` 다음 탭을 herdr
  prefix(`ctrl+a`) 시퀀스로 바꿔 보낸다.
- 입력 소스는 `caps lock` 이 한/영, `right option` 이 한/일을 전환한다.
- zsh 는 깔린 런타임만 켠다. `rc.d/` 의 각 파일은 대상이 없으면 아무 일도 하지 않는다.

## 새 머신

```bash
brew install chezmoi                       # Homebrew 먼저: https://brew.sh
git clone https://github.com/juhyeonni/dotfiles.git ~/dotfiles
chezmoi init --source ~/dotfiles --apply   # git 이름·이메일을 한 번 묻고, Brewfile 설치
```

chezmoi 가 하지 않는 일. 순서대로:

1. Oh My Zsh 와 zsh 플러그인 5개를 clone 한다 ([명령](docs/zsh.md#install)).
2. `herdr integration install claude` 를 실행한다 (pi 를 쓰면 `pi` 도). 설치기가
   `~/.claude/settings.json` 에 SessionStart hook 을 하나 더 넣는다. `chezmoi diff` 로 보고
   기존 것과 겹치면 되돌린다.
3. nvim 을 한 번 열어 플러그인을 깔고, `:MasonInstall …` 을 실행한다
   ([목록](home/dot_config/nvim/REQUIREMENTS.md)).
4. Ghostty 가 쓰는 `MuxJK` 폰트를 설치한다.
5. Karabiner 에 입력 모니터링, Hammerspoon 에 손쉬운 사용 권한을 준다.
6. `vimium/link-hints.css` 를 Vimium 옵션 페이지에 붙여넣는다 ([vimium](docs/vimium.md)).

Intel Mac 은 CLI 도구를 Homebrew 대신 [mise](https://mise.jdx.dev) 로 깐다. mise 를 먼저
설치한다. 언어 런타임은 프로젝트가 필요로 할 때 깐다.

## 평소

```bash
chezmoi diff     # repo 와 홈 디렉토리의 차이
chezmoi re-add   # 홈에서 고친 내용을 repo 로 가져오기
chezmoi apply    # repo 상태를 홈에 쓰기
```

파일은 링크가 아니라 복사본이다. 홈 경로에서 고쳤으면 `chezmoi re-add` 를 한다. 프로그램이 스스로
고쳐 쓰는 `karabiner.json`, Claude Code 의 `settings.json` 은 특히 그렇다. `chezmoi apply` 전에
`chezmoi diff` 를 본다.
