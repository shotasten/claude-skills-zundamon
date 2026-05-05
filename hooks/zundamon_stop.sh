#!/bin/bash
VOICEVOX_URL="http://localhost:50021"

INPUT=$(cat)

curl -sf "${VOICEVOX_URL}/version" >/dev/null 2>&1 || exit 0

SPEAK_TEXT=$(echo "${INPUT}" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    msg = data.get('last_assistant_message', '')
    first_line = msg.strip().split('\n')[0].strip()
    print(first_line)
except:
    print('')
" 2>/dev/null)

[ -z "${SPEAK_TEXT}" ] && exit 0

SPEAKER=3
SPEED=1.3
for KW in エラー error Error 失敗 failed fail exception Exception 警告 warning Warning; do
  if echo "${SPEAK_TEXT}" | grep -q "${KW}"; then
    SPEAKER=38
    SPEED=1.2
    break
  fi
done

play_audio() {
  local file="$1"
  if [[ "$(uname)" == "Darwin" ]]; then
    pkill afplay 2>/dev/null
    afplay -v 0.5 "$file"
  elif grep -qi microsoft /proc/version 2>/dev/null; then
    local winfile="/mnt/c/Windows/Temp/zundamon.wav"
    cp "$file" "$winfile"
    powershell.exe -c "(New-Object Media.SoundPlayer 'C:\Windows\Temp\zundamon.wav').PlaySync()" 2>/dev/null
  else
    pkill ffplay 2>/dev/null
    ffplay -nodisp -autoexit -loglevel quiet "$file" 2>/dev/null
  fi
}

(
  ENCODED=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "${SPEAK_TEXT}")
  QUERY=$(curl -sf -X POST "${VOICEVOX_URL}/audio_query?text=${ENCODED}&speaker=${SPEAKER}" \
    -H "Content-Type: application/json" | jq --argjson s "${SPEED}" '.speedScale = $s')
  TMPFILE=$(mktemp /tmp/voicevox_XXXXXX)
  curl -sf -X POST "${VOICEVOX_URL}/synthesis?speaker=${SPEAKER}" \
    -H "Content-Type: application/json" -d "${QUERY}" -o "${TMPFILE}"
  play_audio "${TMPFILE}"
  rm -f "${TMPFILE}"
) &
