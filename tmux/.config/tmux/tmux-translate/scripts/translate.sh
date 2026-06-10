#!/usr/bin/env bash
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$CURRENT_DIR")"

# Read plugin options
get_tmux_option() {
  local option="$1"
  local default="$2"
  local value
  value=$(tmux show-option -gqv "$option")
  echo "${value:-$default}"
}

API_PROVIDER=$(get_tmux_option "@translate-provider" "gemini")
API_MODEL=$(get_tmux_option "@translate-model" "gemini-2.5-flash-lite")
KEYCHAIN_SERVICE=$(get_tmux_option "@translate-keychain-service" "gemini-api-key")
POPUP_WIDTH=$(get_tmux_option "@translate-popup-width" "60%")
POPUP_HEIGHT=$(get_tmux_option "@translate-popup-height" "40%")

# Get selected text from tmux buffer
TEXT=$(tmux save-buffer -)

if [[ -z "$TEXT" ]]; then
  echo "No text selected"
  read -rsn1
  exit 1
fi

# Get API key from macOS Keychain
API_KEY=$(security find-generic-password -a "$USER" -s "$KEYCHAIN_SERVICE" -w 2>/dev/null) || true

if [[ -z "$API_KEY" ]]; then
  echo "Error: API key not found in Keychain"
  echo "Run: security add-generic-password -a \"\$USER\" -s \"$KEYCHAIN_SERVICE\" -w \"YOUR_KEY\""
  read -rsn1
  exit 1
fi

# Auto-detect: if text contains Korean → translate to English, otherwise → Korean
if echo "$TEXT" | grep -Pq '[\x{AC00}-\x{D7AF}\x{1100}-\x{11FF}\x{3130}-\x{318F}]' 2>/dev/null ||
  echo "$TEXT" | grep -q '[가-힣ㄱ-ㅎㅏ-ㅣ]' 2>/dev/null; then
  DIRECTION="Korean → English"
  LANG_INSTRUCTION="Translate the following Korean text to natural English."
else
  DIRECTION="English → Korean"
  LANG_INSTRUCTION="Translate the following English text to natural Korean."
fi

# Build API request
PAYLOAD=$(jq -n \
  --arg instruction "$LANG_INSTRUCTION" \
  --arg text "$TEXT" \
  '{
    contents: [{
      parts: [{
        text: ($instruction + "\n\nText:\n" + $text + "\n\nProvide only the translation, no explanations.")
      }]
    }],
    generationConfig: {
      temperature: 0.1
    }
  }')

RESPONSE=$(curl -s --max-time 15 \
  "https://generativelanguage.googleapis.com/v1beta/models/${API_MODEL}:generateContent?key=${API_KEY}" \
  -H 'Content-Type: application/json' \
  -d "$PAYLOAD")

# Extract translated text
TRANSLATED=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text // empty' 2>/dev/null)

if [[ -z "$TRANSLATED" ]]; then
  ERROR=$(echo "$RESPONSE" | jq -r '.error.message // "Unknown error"' 2>/dev/null)
  echo "Translation failed: $ERROR"
  read -rsn1
  exit 1
fi

# Display result
echo "[$DIRECTION]"
echo "─────────────────────"
echo "$TRANSLATED"
echo ""
echo "─────────────────────"
echo "[c] copy  [any] close"
read -rsn1 KEY
if [[ "$KEY" == "c" ]]; then
  printf '%s' "$TRANSLATED" | pbcopy
  echo "Copied!"
  sleep 0.5
fi
