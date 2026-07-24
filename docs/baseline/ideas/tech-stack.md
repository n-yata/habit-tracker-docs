# 技術スタック検討メモ

> `initial-requirements.md` の「技術スタック: 未確定」を埋めるための壁打ちメモ。
> 最終的に architecture.md / repository-structure.md の入力とする。
> 前提: 単一ユーザー・ローカル運用（第一マイルストーン）／3リポジトリ構成（docs・backend・frontend）
> ／将来の認証・マルチユーザー化を視野。

## 確定した決定（フルスタック）

| 領域 | 決定 | 理由 |
| --- | --- | --- |
| 言語構成 | **Go backend + TypeScript frontend** | 堅い型と明示的な設計が「設計・テスト設計が映える」題材目的に合致 |
| データベース | **PostgreSQL**（ローカルは Docker Compose） | 日付/期間集計クエリが強い。将来の認証・マルチユーザー化にそのまま拡張できる |
| Go ライブラリ構成 | **chi + sqlc + pgx** | 薄い型安全層。SQLが見えて集計/ストリークのクエリ設計が映え、ドメイン層をクリーンに保てる |
| DBマイグレーション | **golang-migrate** | up/down SQL をバージョン管理。sqlc と相性良し（ともにSQL） |
| フロントフレームワーク | **Next.js**（React + TypeScript） | React ベースの定番。ただし後述のとおり UI レンダリングに専念させる |
| Next.js の役割 | **クライアントから直接 Go API を叩く**（BFFにしない） | frontend/backend の境界を明確に保ち、Go API を唯一のバックエンドとする。結合テストも frontend↔Go API で完結 |
| フロント補助 | **TanStack Query + Tailwind CSS + shadcn/ui** | サーバ状態はTanStack Query（キャッシュ/再取得/楽観更新）、スタイルはTailwind、UIはshadcn/ui |
| API スタイル | **REST + OpenAPI 契約駆動** | `openapi.yaml` を契約の正本とし、Go側は型/スタブ（oapi-codegen 等）、TS側はクライアント型を生成。設計工程が映え、結合テストの基準になる |
| テスト（Go単体） | **標準 testing + testify** | ドメインロジック（繰り返し/ストリーク/集計）の単体テストに注力 |
| テスト（Go結合） | **testcontainers-go** で本物の Postgres を起動 | 本番に近い契約検証。マイグレーション適用済みDBに対して結合テスト |
| テスト（フロント単体） | **Vitest + Testing Library** | フロントのコンポーネント/フック単体 |
| テスト（クロスリポ結合/E2E） | **Playwright**（ブラウザ↔Go API） | コアユースケース（登録→チェックイン→可視化）をブラウザ経由で通す |
| ローカル開発オーケストレーション | **Docker Compose は Postgres のみ** / backend・frontend は各リポでネイティブ起動（`go run` / `npm run dev`） | 3リポ分離と相性が良く、ホットリロードも速い |

## 構成イメージ

```
Browser ──(REST, openapi.yaml 契約)──▶ Go API (chi + sqlc + pgx) ──▶ PostgreSQL
   ▲                                        │
   └── Next.js (UIレンダリング専念)          └── golang-migrate でスキーマ管理

契約: openapi.yaml → Go(サーバ型/スタブ) + TS(クライアント型) を生成
テスト: Go単体(testify) / Go結合(testcontainers+本物PG) / FE単体(Vitest) / E2E(Playwright)
ローカル: compose=Postgresのみ、backend=go run、frontend=npm run dev
```

## バージョン方針（デフォルト。architecture.md で確定）

- Go: 最新安定版（1.23 系以降を想定、`net/http` の 1.22+ ルーティング前提）
- Node.js: アクティブ LTS
- PostgreSQL: 16 系以降

## 残る未確定の論点（詳細設計へ持ち越し）

これらは技術スタックではなく仕様/詳細設計の論点。`initial-requirements.md` にも記載済み。

- タイムゾーン・日付境界の扱い（サーバー時刻基準か/ユーザーTZか）
- 「特定曜日」ルールでのストリーク継続仕様の詳細（対象外の日をどう跨ぐか）
- リマインド時刻超過ハイライトの判定基準（当日のみ／サーバー時刻基準）
- 認証／通知実配信を後続マイルストーンで追加する際の区切り
