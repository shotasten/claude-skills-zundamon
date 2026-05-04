---
description: ずんだもんの読み上げを止める
---

Bash ツールで以下を実行してください：

```bash
if [[ "$(uname)" == "Darwin" ]]; then
  pkill afplay 2>/dev/null
else
  pkill ffplay 2>/dev/null
fi
```

実行後、「読み上げを止めたのだ」とテキストで出力してください。
