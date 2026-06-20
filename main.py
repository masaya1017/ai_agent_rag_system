import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent / "src"))
from server import mcp

if __name__ == "__main__":
    print("[RAG] MCPサーバー起動", file=sys.stderr)
    mcp.run()
