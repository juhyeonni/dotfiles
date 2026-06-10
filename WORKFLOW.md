# 개발 워크플로우

흩어진 도구(ghq · sesh · tmux · LazyVim · lazygit · Claude Code)를 하나의 루프로 묶는다.
핵심 규칙: **프로젝트 = tmux 세션 = 3-window(editor / agent / git)**.

## A. 프로젝트 진입 (sesh 중심)

```bash
ghq get <owner>/<repo>     # ~/.ghq/github.com/... 로 클론 (lazy dev.path 와 일치)
```

- `prefix + S` → sesh 세션 스위처(zoxide 기반 퍼지 점프). 프로젝트 디렉토리를 고르면
  `dev-layout.sh` 가 **editor / agent / git** 3-window 를 자동 구성한다.
- 재접속해도 윈도우는 중복 생성되지 않고, nvim 도 이미 떠 있으면 다시 띄우지 않는다.
- 고정 세션은 `~/.config/sesh/sesh.toml` 의 `[[session]]` 에 추가한다.

## B. 코드 루프 (nvim ↔ Claude)

| 행동 | 키 |
|---|---|
| Claude 에 선택/파일 보내 질문·리팩터 | `<leader>ca` (n/v) |
| Claude Code 창 토글 | `<C-\><C-\>` |
| 진단 순회 / 목록 | `]d` `[d` · `;e`(telescope) · `<leader>Q`(loclist) |
| 코드 탐색 | `gd`(정의) · `<leader>cs`(outline) · `s`(flash 점프) |
| inlay hint 토글 | `<leader>i` |

루프: nvim 작성 → 막히면 `<leader>ca` 로 Claude 질의 → 진단 정리 → 다음.

## C. 커밋·리뷰 루프 (git)

- **변경 단위로 자주 커밋**. `prefix + G`(lazygit)에서 hunk 단위 stage → 커밋.
- nvim 안 리뷰: `<leader>hs`/`<leader>hp`(gitsigns hunk) · `<leader>gd`(diffview).
- 커밋 메시지는 **conventional commits**(`feat:` `fix:` `docs:` `refactor:` `chore:`).
- 완료 선언 전 **테스트 / 빌드 / 린트 실행**해서 검증한다(전역 지침).

## D. 자동화로 굳히기

- 프로젝트별 `CLAUDE.md` 에 테스트·빌드 명령을 박아두면 Claude 가 자동 검증한다.
- lint/format 을 강제하려면 git pre-commit 훅을 추가한다(현재는 수동).

## 자주 쓰는 tmux 키

`prefix + g` 스크래치 팝업 · `prefix + C-c` Claude 팝업 · `prefix + G` lazygit ·
`prefix + S` sesh · `prefix + tab` extrakto · `C-h/j/k/l` nvim↔tmux pane 이동
