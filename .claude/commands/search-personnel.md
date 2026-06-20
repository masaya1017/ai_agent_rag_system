# search-personnel

RAGシステムに取り込まれた人材情報（職務経歴書・プロフィール資料）から、条件に合う人材情報を抽出して提示する。

## 手順

1. `$ARGUMENTS` を検索キーワードとして使う。未指定の場合はユーザーに「どんなスキルや条件で検索しますか？」と聞く。

2. 以下のコマンドで人材情報を検索する：

```bash
cd /home/masaya/rag && uv run python3 - <<'PYEOF'
import sys
from pathlib import Path
sys.path.insert(0, str(Path("/home/masaya/rag")))
from server import search_documents
query = "$ARGUMENTS" if "$ARGUMENTS" else "人材 スキル 経歴 担当"
results = search_documents(query + " スキル 経歴 担当業務 実績", n_results=8)
print(results)
PYEOF
```

3. 検索結果をもとに以下の形式で人材情報をまとめて提示する：

```
## 氏名
- **所属・役職:**
- **得意分野・スキル:**
- **業務経験:**
- **主な実績・プロジェクト:**
- **出典ファイル:**
```

4. 複数人ヒットした場合は人物ごとにセクションを分けて提示する。
5. 検索結果が少ない場合は別のクエリで追加検索して補完する。
