# GitHub MCP 가 읽는 토큰. gh keyring 에서 꺼내므로 디스크에 평문이 남지 않는다.
# 로그인이 풀리면 빈 값이 되고 MCP 만 실패한다.

if (( $+commands[gh] )); then
  export GITHUB_PERSONAL_ACCESS_TOKEN="$(gh auth token 2>/dev/null)"
fi
