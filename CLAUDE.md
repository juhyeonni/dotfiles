# dotfiles

이 레포에만 적용되는 프로젝트 지침. 유저 스코프 지침은 별개 파일이다 —
`claude/.claude/CLAUDE.md`, stow 로 `~/.claude/CLAUDE.md` 에 링크된다.

## 규칙

- **설정 파일 주석은 한국어로 쓴다.** 왜 그 키를, 그 값을 골랐는지가 이 레포의 자산이다.
  전역 지침은 주석 언어를 정하지 않는다 — 커밋 메시지와 식별자는 거기 규칙대로 영어.
- `herdr` 와 `claude` 패키지는 `stow -R --no-folding`. 파일별로 링크가 걸리므로,
  레포에 파일을 새로 추가하면 stow 를 다시 돌리기 전까지는 없는 것과 같다.
- `herdr/.config/herdr/config.toml` 을 고치면 `herdr server reload-config` 를 돌린다.
  herdr 는 파일 변경을 감시하지 않는다. 문법 검사는 `herdr config check`.
- stow 는 심볼릭 링크만 건다. 링크된 파일을 고치면 레포가 바로 바뀌므로,
  홈 디렉토리 쪽 경로로 편집해도 커밋 대상은 레포다.
