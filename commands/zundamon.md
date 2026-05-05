---
description: ずんだもんに読み上げさせる
---

## モード判定

テキストの内容や文脈から自動でモードを選ぶ：

- **通常モード**：作業完了・お知らせ・中立的な内容
  - SPEAKER=3（ノーマル）、speedScale=1.3
- **ネガティブモード**：エラー・失敗・警告・ネガティブな内容
  - SPEAKER=38（ヒソヒソ）、speedScale=1.2

## 引数ありの場合（`/zundamon テキスト`）

引数のテキストをそのまま読み上げる。セリフの加工・追加は一切しない。
テキストの内容からモードを判定する。

## 引数なしの場合（`/zundamon`）

直前の作業を振り返り、以下のルールでずんだもんの報告セリフを1〜2文で作る：
- 語尾は「〜なのだ」「〜のだ」で終わる
- 明るく元気なトーン（通常時）またはひそひそした落ち着いたトーン（ネガティブ時）
- 具体的に何をしたか触れる
- 80文字以内

文脈からモードを判定する。

---

モードが決まったら、Bash ツールで以下を実行してください（`TEXT`・`SPEAKER`・`SPEED` を適切に設定）：

```bash
TEXT="ここにテキストを入れる"
SPEAKER=3      # 通常: 3（ノーマル）/ ネガティブ: 38（ヒソヒソ）
SPEED=1.3      # 通常: 1.3 / ネガティブ: 1.2
VOICEVOX_URL="http://localhost:50021"

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
  ENCODED=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$TEXT")
  QUERY=$(curl -sf -X POST "$VOICEVOX_URL/audio_query?text=$ENCODED&speaker=$SPEAKER" \
    -H "Content-Type: application/json" | jq --argjson s "$SPEED" '.speedScale = $s')
  TMPFILE=$(mktemp /tmp/voicevox_XXXXXX)
  curl -sf -X POST "$VOICEVOX_URL/synthesis?speaker=$SPEAKER" \
    -H "Content-Type: application/json" -d "$QUERY" -o "$TMPFILE"
  play_audio "$TMPFILE"
  rm -f "$TMPFILE"
) &
```

実行後、読み上げたテキストとモード（通常/ネガティブ）を出力してください。
