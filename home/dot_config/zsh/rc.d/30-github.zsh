# The token the GitHub MCP server reads. It comes from the gh keyring, so no plaintext hits disk.
# If the login lapses this goes empty and only the MCP server fails.

if (( $+commands[gh] )); then
  export GITHUB_PERSONAL_ACCESS_TOKEN="$(gh auth token 2>/dev/null)"
fi
