# delete-document

RAGシステムのベクターDBから指定ドキュメントを削除する。

## 手順

### ステップ1: 現在の登録済みドキュメント一覧を取得

```bash
cd /home/masaya/rag && uv run python3 - 2>&1 <<'PYEOF'
import sys
from pathlib import Path
sys.path.insert(0, str(Path("/home/masaya/rag")))
from server import list_documents
print(list_documents())
PYEOF
```

### ステップ2: 削除対象を確認

- `$ARGUMENTS` にファイル名が指定されている場合はそれを削除対象とする
- 指定がない場合は一覧を提示してユーザーに削除するファイル名を確認する
- 削除前に「`<ファイル名>` を削除します。よろしいですか？」と確認を取る

### ステップ3: 削除実行

ユーザーが承認したら削除する：

```bash
cd /home/masaya/rag && uv run python3 - 2>&1 <<'PYEOF'
import sys
from pathlib import Path
sys.path.insert(0, str(Path("/home/masaya/rag")))
from server import delete_document, list_documents
print(delete_document("$ARGUMENTS"))
print("\n=== 現在のDB状況 ===")
print(list_documents())
PYEOF
```

## 注意事項

- 削除はベクターDBからの削除のみで、`input/` フォルダのファイルは削除しない
- 削除後に再登録したい場合は `/ingest-document` で再取り込みできる
