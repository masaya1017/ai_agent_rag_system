# ingest-document

RAGシステムの `input` フォルダ、または指定ファイル・ディレクトリをベクターDBに取り込む。

## 手順

### ケース1: 引数なし → inputフォルダを一括取り込み

`$ARGUMENTS` が空の場合、`/home/masaya/rag/input/` を対象に一括取り込みする：

```bash
cd /home/masaya/rag && uv run python3 - 2>&1 <<'PYEOF'
import sys
from pathlib import Path
sys.path.insert(0, str(Path("/home/masaya/rag")))
from server import ingest_directory, list_documents
print("=== 取り込み開始: input/ ===")
print(ingest_directory("/home/masaya/rag/input"))
print("\n=== 現在のDB状況 ===")
print(list_documents())
PYEOF
```

### ケース2: 引数あり → 指定パスを取り込み

`$ARGUMENTS` にファイルパスまたはディレクトリパスが渡された場合：

- ディレクトリの場合は `ingest_directory` を使う
- ファイルの場合は `ingest_document` を使う

```bash
cd /home/masaya/rag && uv run python3 - 2>&1 <<'PYEOF'
import sys
from pathlib import Path
sys.path.insert(0, str(Path("/home/masaya/rag")))
from server import ingest_document, ingest_directory, list_documents

target = Path("$ARGUMENTS")
if not target.is_absolute():
    target = Path("/home/masaya/rag") / target

print(f"=== 取り込み開始: {target} ===")
if target.is_dir():
    print(ingest_directory(str(target)))
else:
    print(ingest_document(str(target)))

print("\n=== 現在のDB状況 ===")
print(list_documents())
PYEOF
```

## 結果の提示

取り込み結果を以下の形式でまとめる：

- 取り込んだファイル数とチャンク数
- スキップされたファイル（未対応形式）があれば警告
- 現在のDB合計（ファイル数・チャンク数）
