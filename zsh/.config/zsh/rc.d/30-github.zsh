# GitHub CLI 토큰 브리지 — gh 가 설치돼 있을 때만.
#
# GitHub MCP 서버가 GITHUB_PERSONAL_ACCESS_TOKEN 환경변수를 읽는다. 토큰을 파일에
# 적어두는 대신 gh 의 keyring 에서 매번 꺼내므로 디스크에 평문 토큰이 남지 않는다.
#
# 비용: 셸 시작마다 gh 서브프로세스 1회. 로그인이 풀려 있으면 빈 값이 되고
# (2>/dev/null 로 에러도 삼킨다) MCP 쪽에서만 실패한다 — 셸은 영향받지 않는다.

if (( $+commands[gh] )); then
  export GITHUB_PERSONAL_ACCESS_TOKEN="$(gh auth token 2>/dev/null)"
fi
