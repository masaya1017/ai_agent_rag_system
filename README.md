# RAG System

ローカルドキュメントをベクターDBに取り込み、Claude Code から自然言語で検索できる MCP サーバーです。
検索系コマンドはサブエージェントに委譲するマルチエージェント構成になっています。

## 概要

- **対応ファイル形式**: PDF / Word (.docx, .doc) / PowerPoint (.pptx, .ppt) / Markdown / テキスト (.txt)
- **埋め込みモデル**: `intfloat/multilingual-e5-large`（日本語対応）
- **ベクターDB**: ChromaDB（ローカル永続化）
- **インターフェース**: MCP ツール + Claude Code スラッシュコマンド + サブエージェント

---

## アーキテクチャ

```
ユーザー
  │
  ├─ /ingest-document, /list-documents, /delete-document
  │       └─ 親エージェント（Claude Code）が直接処理
  │
  └─ /search-personnel <クエリ>
     /search-proposals <クエリ>
             │
             └─ 親エージェントがサブエージェントを起動
                     │
                     ├─ RAGシステム（ChromaDB）を検索
                     ├─ 結果を整形
                     ├─ output/ にMarkdownファイルとして保存
                     └─ [DONE] 通知を親エージェントへ返却
```

検索系コマンドは専用サブエージェントに委譲されるため、親エージェントは検索処理をブロックせず、
完了通知を受け取ったらファイルパスをユーザーに報告します。

---

## セットアップ

### 1. 依存パッケージのインストール

```bash
uv sync
```

### 2. Claude Code に MCP サーバーを登録

```bash
claude mcp add rag -- uv run python3 /home/masaya/rag/server.py
```

登録後、Claude Code を再起動すると MCP ツール・スラッシュコマンド・サブエージェントが使えるようになります。

---

## スラッシュコマンド

Claude Code のチャットから以下のコマンドを直接実行できます。

| コマンド | 処理主体 | 説明 |
|---|---|---|
| `/ingest-document` | 親エージェント | `input/` フォルダを一括取り込み（引数でファイル/ディレクトリ指定も可） |
| `/list-documents` | 親エージェント | DB登録済み一覧と `input/` の未登録ファイルを比較表示 |
| `/delete-document` | 親エージェント | 指定ファイルをDBから削除 |
| `/search-personnel` | **サブエージェント** | 人材情報を検索 → `output/personnel_*.md` に保存 |
| `/search-proposals` | **サブエージェント** | 提案書・見積書を検索 → `output/proposals_*.md` に保存 |

**例:**

```
/ingest-document
/ingest-document /path/to/specific/file.pdf
/list-documents
/delete-document report.pdf
/search-personnel Pythonエンジニア
/search-proposals DX支援
```

---

## サブエージェント

`.claude/agents/` に定義されたサブエージェントが検索処理を担います。

### search-personnel

人材情報（職務経歴書・プロフィール資料）を検索するエージェント。

- **入力**: 検索クエリ（スキル・経験・役職など）
- **処理**: RAGシステムで検索 → 人物ごとに整形
- **出力**: `output/personnel_YYYYMMDD_HHMMSS.md`
- **通知**: `[DONE] 人材検索が完了しました。` + ファイルパスを親エージェントへ返却

出力フォーマット：

```markdown
## 氏名
- **所属・役職:**
- **得意分野・スキル:**
- **業務経験:**
- **主な実績・プロジェクト:**
- **出典ファイル:**
```

### search-proposals

提案書・見積書を検索するエージェント。

- **入力**: 検索クエリ（業種・サービス・テーマなど）
- **処理**: RAGシステムで検索 → 提案書ごとに整形
- **出力**: `output/proposals_YYYYMMDD_HHMMSS.md`
- **通知**: `[DONE] 提案書検索が完了しました。` + ファイルパスを親エージェントへ返却

出力フォーマット：

```markdown
## 提案タイトル / 対象企業
- **提案内容の概要:**
- **支援サービス・ソリューション:**
- **期待効果・実績:**
- **担当者・体制:**
- **出典ファイル:**

### 見積概要（金額情報がある場合）
```

---

## ディレクトリ構成

```
rag/
├── input/          # 取り込み対象ファイルを置く場所
├── output/         # サブエージェントの検索結果が保存される
├── db/             # ChromaDB のデータ（自動生成）
├── server.py       # MCP サーバー本体
├── ingest.py       # CLIインジェスト用スクリプト
└── .claude/
    ├── agents/
    │   ├── search-personnel.md   # 人材検索サブエージェント定義
    │   └── search-proposals.md  # 提案書検索サブエージェント定義
    └── commands/
        ├── ingest-document.md
        ├── list-documents.md
        ├── delete-document.md
        ├── search-personnel.md
        └── search-proposals.md
```

---

## ドキュメントの取り込み

**方法 1: `input/` フォルダに置いてスラッシュコマンドで取り込む（推奨）**

```
/ingest-document
```

**方法 2: CLI スクリプト（ディレクトリ一括）**

```bash
uv run python3 ingest.py /path/to/documents/
```

**方法 3: MCP ツールで直接取り込む**

```
ingest_document("/path/to/file.pdf")
ingest_directory("/path/to/documents/")
```

---

## MCP ツール一覧

| ツール名 | 説明 | 主な引数 |
|---|---|---|
| `ingest_document` | 単一ファイルを取り込む | `file_path` |
| `ingest_directory` | ディレクトリを一括取り込み | `directory_path`, `recursive` |
| `search_documents` | セマンティック検索 | `query`, `n_results`, `source_filter` |
| `list_documents` | 取り込み済み一覧を表示 | なし |
| `delete_document` | ドキュメントをDBから削除 | `filename` |

---

## 設定

`server.py` の冒頭で変更できます。

| 設定項目 | デフォルト | 説明 |
|---|---|---|
| `DB_PATH` | `./db` | ChromaDB の保存先 |
| `MODEL_NAME` | `intfloat/multilingual-e5-large` | 埋め込みモデル |
| `CHUNK_SIZE` | `500` | チャンクあたりの文字数 |
| `CHUNK_OVERLAP` | `50` | チャンク間のオーバーラップ文字数 |

---

## 仕組み

1. ファイルからテキストを抽出し、500 文字（50 文字オーバーラップ）のチャンクに分割
2. `multilingual-e5-large` で各チャンクをベクトル化して ChromaDB に保存
3. 検索時はクエリをベクトル化し、コサイン類似度で上位チャンクを返す
4. 同一ファイルを再取り込みすると既存チャンクを自動で上書き
5. 検索系コマンドはサブエージェントが非同期で処理し、完了時に親エージェントへ通知
