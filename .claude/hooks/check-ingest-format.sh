#!/bin/bash
# PreToolUse: mcp__rag__ingest_document
# 対応外ファイル形式の取り込みをブロックする

python3 - <<'PYEOF'
import sys, json, os

tool_input = json.loads(os.environ.get('CLAUDE_TOOL_INPUT', '{}'))
path = tool_input.get('file_path', '')
ext = os.path.splitext(path)[1].lower()
allowed = {'.pdf', '.docx', '.doc', '.pptx', '.ppt', '.md', '.txt'}

if not ext:
    print(f"ERROR: ファイル拡張子が不明です: {path}", file=sys.stderr)
    sys.exit(1)

if ext not in allowed:
    allowed_str = ', '.join(sorted(allowed))
    print(f"ERROR: 対応外ファイル形式です: {ext}", file=sys.stderr)
    print(f"対応形式: {allowed_str}", file=sys.stderr)
    sys.exit(1)
PYEOF
