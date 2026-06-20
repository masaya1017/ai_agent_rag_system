# list-documents

RAGシステムに登録済みのドキュメント一覧と、`input/` フォルダの未登録ファイルを確認する。

## 手順

### ステップ1: DB登録済みドキュメントを取得

```bash
cd /home/masaya/rag && uv run python3 - 2>&1 <<'PYEOF'
import sys
from pathlib import Path
sys.path.insert(0, str(Path("/home/masaya/rag")))
from server import list_documents
print(list_documents())
PYEOF
```

### ステップ2: inputフォルダの全ファイルを取得

```bash
find /home/masaya/rag/input -type f | sort
```

### ステップ3: 差分を提示

両者を比較して以下の形式でまとめる：

```
## DB登録済み（N ファイル / N チャンク）
  ✅ ファイル名.pdf        (N チャンク)
  ✅ ファイル名.docx       (N チャンク)

## input/ にあるが未登録
  ⚠️  ファイル名.pptx      ← /ingest-document で取り込めます

## 対応外形式（取り込み不可）
  ❌ ファイル名.xlsx       ← PDF/Word/PPTX/TXT/MD のみ対応
```

未登録ファイルがある場合は「`/ingest-document` で一括取り込みできます」と案内する。
