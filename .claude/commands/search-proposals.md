# search-proposals

RAGシステムに取り込まれた提案書・見積書から、条件に合う情報を抽出して提示する。

## 手順

1. `$ARGUMENTS` を検索キーワードとして使う。未指定の場合はユーザーに「どのような提案内容・対象・テーマで検索しますか？」と聞く。

2. 以下のコマンドで提案書情報を検索する：

```bash
cd /home/masaya/rag && uv run python3 - <<'PYEOF'
import sys
from pathlib import Path
sys.path.insert(0, str(Path("/home/masaya/rag")))
from server import search_documents
query = "$ARGUMENTS" if "$ARGUMENTS" else "提案 支援 サービス 概要"
results = search_documents(query + " 提案 支援内容 ソリューション", n_results=8)
print(results)
PYEOF
```

3. 検索結果をもとに以下の形式でまとめて提示する：

```
## 提案タイトル / 対象企業
- **提案内容の概要:**
- **支援サービス・ソリューション:**
- **期待効果・実績:**
- **担当者・体制:**
- **出典ファイル:**
```

4. 複数の提案書がヒットした場合はファイルごとにセクションを分けて提示する。
5. 見積情報（金額・期間・工数）が含まれている場合は別途「見積概要」として抽出する。
6. 検索結果が少ない場合は別のクエリで追加検索して補完する。
