# claude-skills-zundamon

Claude Code の作業進捗をずんだもん（VOICEVOX）が読み上げるツール。

対応OS: macOS / WSL / Linux

## インストール

### 1. VOICEVOX を起動

```bash
docker compose up -d
```

### 2. コマンドをコピー

```bash
cp commands/zundamon.md ~/.claude/commands/
cp commands/zundamon-stop.md ~/.claude/commands/
```

### 3. Stop hook をセット

```bash
mkdir -p ~/.claude/hooks
cp hooks/zundamon_stop.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/zundamon_stop.sh
```

`~/.claude/settings.json` に追加（`command` はフルパスで指定）：

```json
{
  "hooks": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "/home/yourname/.claude/hooks/zundamon_stop.sh"
        }
      ]
    }
  ]
}
```

### 4. CLAUDE.md に追記（任意）

各フェーズで Claude が自発的にずんだもんを呼ぶようになる。

```bash
cat claude-md-snippet.md >> ~/.claude/CLAUDE.md
```

## 使い方

| コマンド | 動作 |
|---|---|
| `/zundamon` | 直前の作業をずんだもん口調で要約して読み上げ |
| `/zundamon テキスト` | 指定テキストをそのまま読み上げ |
| `/zundamon-stop` | 読み上げを止める |

Stop hook は Claude が止まるたびに自動で発火し、最後のメッセージの1行目を読み上げる。

## 音声モード

| モード | キャラ | 速度 | 発動条件 |
|---|---|---|---|
| 通常 | ずんだもん ノーマル（ID: 3） | 1.3 | デフォルト |
| ネガティブ | ずんだもん ヒソヒソ（ID: 38） | 1.0 | エラー・失敗・警告を含む場合 |

## OS 別の再生コマンド

| OS | 再生コマンド | 備考 |
|---|---|---|
| macOS | `afplay` | 標準搭載 |
| WSL | `powershell.exe` + `SoundPlayer` | 追加インストール不要 |
| Linux | `ffplay` | ffmpeg が必要 |
