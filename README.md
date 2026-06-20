# RAG System

ローカルドキュメントをベクターDBに取り込み、Claude Code から自然言語で検索できる MCP サーバーです。

## 概要

- **対応ファイル形式**: PDF / Word (.docx, .doc) / PowerPoint (.pptx, .ppt) / Markdown / テキスト (.txt)
- **埋め込みモデル**: `intfloat/multilingual-e5-large`（日本語対応）
- **ベクターDB**: ChromaDB（ローカル永続化）
- **インターフェース**: MCP ツール + Claude Code スラッシュコマンド

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

登録後、Claude Code を再起動すると MCP ツールとスラッシュコマンドが使えるようになります。

---

## 使い方

### スラッシュコマンド（推奨）

Claude Code のチャットから以下のコマンドを直接実行できます。

| コマンド | 説明 |
|---|---|
| `/ingest-document` | `input/` フォルダを一括取り込み（引数でファイル/ディレクトリ指定も可） |
| `/list-documents` | DB登録済み一覧と `input/` の未登録ファイルを比較表示 |
| `/delete-document` | 指定ファイルをDBから削除 |
| `/search-personnel` | 人材情報（職務経歴書・プロフィール）を検索 |
| `/search-proposals` | 提案書・見積書を検索 |

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

### ドキュメントの取り込み

**方法 1: `input/` フォルダに置いてスラッシュコマンドで取り込む（推奨）**

`input/` フォルダにファイルを置いて実行:
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

### ドキュメントの検索

Claude Code のチャットで質問すると、取り込み済みドキュメントから関連箇所を検索します。

```
search_documents("契約の解除条件について")
```

特定ファイルに絞って検索:
```
search_documents("予算の内訳", source_filter="report.pdf")
```

---

### 取り込み済みドキュメントの確認

```
/list-documents
```

または MCP ツールで:
```
list_documents()
```

---

### ドキュメントの削除

```
/delete-document report.pdf
```

または MCP ツールで:
```
delete_document("report.pdf")
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
