"""
ドキュメント一括取り込みスクリプト
使い方: uv run python3 ingest.py /path/to/documents/
"""
import sys
from pathlib import Path

# server.py の関数を再利用
sys.path.insert(0, str(Path(__file__).parent))
from server import ingest_directory, list_documents

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("使い方: uv run python3 ingest.py <ディレクトリパス>")
        sys.exit(1)

    target = sys.argv[1]
    print(f"\n取り込み開始: {target}\n")
    result = ingest_directory(target)
    print(result)
    print("\n--- 現在のDB状況 ---")
    print(list_documents())
