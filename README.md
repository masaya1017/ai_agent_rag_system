# RAG System

ローカルドキュメントをベクターDBに取り込み、Claude Code から自然言語で検索できる MCP サーバーです。

## 概要

- **対応ファイル形式**: PDF / Word (.docx, .doc) / Markdown / テキスト (.txt)
- **埋め込みモデル**: `intfloat/multilingual-e5-large`（日本語対応）
- **ベクターDB**: ChromaDB（ローカル永続化）
- **インターフェース**: MCP ツール（Claude Code から直接呼び出し）

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

登録後、Claude Code を再起動すると以下のツールが使えるようになります。

---

## 使い方

### ドキュメントの取り込み

**方法 1: CLI スクリプト（ディレクトリ一括）**

```bash
uv run python3 ingest.py /path/to/documents/
```

サブディレクトリも含めて、対応形式のファイルをすべて取り込みます。

**方法 2: Claude Code から MCP ツールで取り込む**

単一ファイル:
```
ingest_document("/path/to/file.pdf")
```

ディレクトリ一括:
```
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
list_documents()
```

ファイル名とチャンク数の一覧が表示されます。

---

### ドキュメントの削除

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
| `delete_document` | ドキュメントを削除 | `filename` |

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
