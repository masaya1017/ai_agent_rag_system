#!/bin/bash
# PostToolUse: Write
# output/ へのファイル書き込みをヒストリーログに記録する

OUTPUT_DIR="/home/masaya/rag/output"
LOG_DIR="/home/masaya/rag/log"

python3 - <<'PYEOF'
import sys, json, os
from datetime import datetime

tool_input = json.loads(os.environ.get('CLAUDE_TOOL_INPUT', '{}'))
file_path = tool_input.get('file_path', '')
output_dir = os.environ.get('OUTPUT_DIR', '/home/masaya/rag/output')
log_dir = os.environ.get('LOG_DIR', '/home/masaya/rag/log')

if not file_path.startswith(output_dir):
    sys.exit(0)

log_file = os.path.join(log_dir, 'output_history.log')
timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
with open(log_file, 'a') as f:
    f.write(f"[{timestamp}] {file_path}\n")
PYEOF
