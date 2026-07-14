# 技術仕様書 (Architecture Design Document)

> システム構造とテクノロジースタックの正本。PRD（`docs/1_requirements/product-requirements.md`）と
> 機能設計書（`docs/2_basic-design/functional-design.md`。詳細は `functional-design/` に分割）を技術的に実現するための設計を定義する。
> 技術スタックの検討経緯は `docs/0_ideas/tech-stack.md` を参照。第一マイルストーン（単一ユーザー）対象。

## システム全体像

3つの独立した Git リポジトリで構成する。

| リポジトリ | 役割 |
|---|---|
| `docs`（本リポジトリ） | ドキュメント・Claude 設定・スペック |
| `backend` | Go 製 REST API サーバ |
| `frontend` | Next.js 製 Web UI |

ブラウザ（Next.js が配信する UI）から `backend` の REST API を直接呼ぶ。Next.js は BFF を持たず
UI レンダリングに専念する。`backend` は PostgreSQL を単一のデータストアとして使う。API 契約は
`openapi.yaml` を正本とし、Go サーバ型と TS クライアント型を生成して整合を保つ。

```
[Browser] ──REST(openapi.yaml)──▶ [backend: Go API] ──▶ [PostgreSQL]
    ▲                                     │
[Next.js: UIレンダリング]         [golang-migrate でスキーマ管理]
```

## テクノロジースタック

### 言語・ランタイム

| 技術 | バージョン | 備考 |
|------|-----------|------|
| Go | 1.23 以降（安定版） | backend。`net/http` の 1.22+ ルーティング前提 |
| Node.js | アクティブ LTS（22.x 系想定） | frontend ビルド/実行 |
| TypeScript | 5.x | frontend |
| PostgreSQL | 16 以降 | データストア |

### バックエンド（backend リポジトリ）

| 技術 | 用途 | 選定理由 |
|------|------|----------|
| Go 1.23+ | 実装言語 | 堅い静的型と明示的な設計により、ドメインロジック（繰り返し判定・ストリーク計算・集計）とテスト設計が映える。並行処理・単一バイナリ配布に強い |
| chi | HTTPルーター | `net/http` 互換の薄いルーター。標準ライブラリからの乖離が小さく学習・保守しやすい |
| oapi-codegen | OpenAPI からサーバ型/スタブ生成 | `openapi.yaml` を契約の正本とし、ハンドラの型を自動生成して契約不一致を防ぐ |
| sqlc | SQL から型安全な Go コード生成 | SQL を自分で書くため集計/ストリーク用クエリが可視化され、ORM の隠蔽を避けドメイン層をクリーンに保てる |
| pgx | PostgreSQL ドライバ | 高性能なネイティブドライバ。sqlc と組み合わせて利用 |
| golang-migrate | DBマイグレーション | up/down SQL をバージョン管理。sqlc（SQL中心）と相性が良い |
| testify | 単体テスト補助 | アサーション/モックの定番 |
| testcontainers-go | DB結合テスト | 本物の PostgreSQL をコンテナ起動し本番に近い契約検証を行う |

### フロントエンド（frontend リポジトリ）

| 技術 | 用途 | 選定理由 |
|------|------|----------|
| Next.js (React + TypeScript) | UIフレームワーク | React ベースの定番。ただし BFF にせずクライアントから Go API を直接叩く構成で、frontend/backend の境界を明確に保つ |
| TanStack Query | サーバ状態管理 | キャッシュ・再取得・楽観更新を宣言的に扱え、チェックインの即時反映に適する |
| Tailwind CSS | スタイリング | ユーティリティファーストで実装速度・一貫性が高い |
| shadcn/ui | UIコンポーネント | コピーして使うコンポーネント群。カスタマイズ性が高く学習価値も高い |
| OpenAPI TS 型生成 | API型 | `openapi.yaml` からクライアント型を生成し、Go 側と型を揃える |
| Vitest + Testing Library | フロント単体テスト | 高速なコンポーネント/フック単体テスト |

### 横断・開発ツール

| 技術 | 用途 | 選定理由 |
|------|------|----------|
| OpenAPI (openapi.yaml) | API契約 | Go/TS 両方の型の正本。設計工程の成果物であり結合テストの基準 |
| Playwright | E2E結合テスト | ブラウザ↔Go API のコアユースケースを検証 |
| Docker Compose | ローカル PostgreSQL | ローカル開発では Postgres のみコンテナ起動（backend/frontend はネイティブ起動） |

## アーキテクチャパターン

### バックエンド: レイヤードアーキテクチャ

依存方向は上から下への一方向。**Domain 層は外部（DB・HTTP）に依存しない**ことを不変条件とする。

```
┌─────────────────────────────┐
│  Handler層 (chi + 生成型)     │ ← HTTP入出力、OpenAPI契約との変換
├─────────────────────────────┤
│  Service層 (ユースケース)      │ ← ユースケース組立・トランザクション境界
├──────────────┬──────────────┤
│ Domain層      │ Repository層  │
│ (純粋ロジック) │ (sqlc+pgx)   │ ← 集計/判定 は Domain、永続化は Repository
└──────────────┴──────────────┘
              │
        [PostgreSQL]
```

#### Handler層
- **責務**: HTTP リクエストの受付、OpenAPI 契約型との相互変換、Service 呼び出し、エラーの HTTP 変換。
- **許可**: Service層の呼び出し。
- **禁止**: Repository/DB への直接アクセス、ビジネスロジックの実装。

#### Service層
- **責務**: ユースケースの組み立て、トランザクション境界の管理、Domain と Repository の協調。
- **許可**: Domain層・Repository層の呼び出し。
- **禁止**: HTTP への依存。

#### Domain層
- **責務**: 繰り返し判定・ストリーク計算・達成率/ヒートマップ集計といった純粋ロジック。
- **許可**: Go 標準ライブラリのみ。
- **禁止**: DB・HTTP・時刻取得の暗黙依存（`today` 等は引数で受け取り、テスト可能に保つ）。

#### Repository層
- **責務**: Habit・CheckIn の永続化と取得（sqlc 生成コード + pgx）。
- **許可**: PostgreSQL へのアクセス。
- **禁止**: ビジネスロジックの実装。

### フロントエンド: 画面 + データフック分離
- ページ/表示コンポーネントは描画に専念し、API 呼び出しは TanStack Query のカスタムフックに集約する。
- API 型は OpenAPI 生成型を単一の情報源とする。

## データ永続化戦略

### ストレージ方式

| データ種別 | ストレージ | 理由 |
|-----------|----------|------|
| 習慣（Habit） | PostgreSQL テーブル | 一意制約・インデックス・将来のユーザー分離に対応 |
| チェックイン（CheckIn） | PostgreSQL テーブル | `(habit_id, date)` 一意制約と期間集計に適する |

### スキーマ管理・マイグレーション
- `golang-migrate` の up/down SQL でスキーマをバージョン管理する。
- テスト（testcontainers-go）でも同じマイグレーションを適用し、本番と同一スキーマを検証する。
- 論理削除（`archived`）を採用し、過去チェックインの整合性を保つ。

### バックアップ戦略
- 第一マイルストーンはローカル運用のため運用バックアップは範囲外。
- データの真実は PostgreSQL にあり、マイグレーションとシードで再現可能とする。
- 将来の本番運用時に定期ダンプ（`pg_dump`）を導入する余地を残す。

## パフォーマンス要件

### レスポンスタイム

| 操作 | 目標時間 | 測定環境 |
|------|---------|---------|
| ダッシュボード集計 API（ストリーク/達成率/ヒートマップ） | p95 300ms 以内 | ローカル、習慣50件・チェックイン1年分規模のシード |
| チェックイン記録（書き込み〜画面反映） | 200ms 以内 | ローカル |

### 最適化方針
- 集計はチェックインを期間指定で一括取得し Domain 層でメモリ集計（N+1 回避）。
- `(habit_id, date)` にインデックスを張り、期間フィルタを高速化する。
- フロントは TanStack Query のキャッシュ＋楽観更新で体感速度を確保。

## セキュリティアーキテクチャ

### 入力検証
- サーバー側で繰り返しルール整合・N（1〜7）範囲・曜日指定・日付形式・名前長を検証し、不正入力を 400 で拒否。
- SQL は sqlc 生成のパラメータ化クエリを使用し、文字列連結を排除。

### データ保護・機密管理
- DB 接続情報は環境変数で管理し、コードにハードコードしない。
- 第一マイルストーンは単一ユーザー・ローカル前提で認証を持たない（スコープ外）。将来のユーザー分離に
  備え、データモデルに `user_id` を後付けできる設計余地を残す。

## スケーラビリティ設計

### データ増加への対応
- 想定規模: 単一ユーザーの数年分（数千〜数万チェックイン）。インデックスと期間集計で実用速度を保つ。

### 機能拡張性
- **認証・マルチユーザー化**: PostgreSQL 採用済み。テーブルへの `user_id` 追加とクエリ条件付与で拡張。
- **リマインド実配信**: `reminderTime` を保持済み。将来スケジューラ/通知基盤を別コンポーネントで追加。
- **API 拡張**: `openapi.yaml` にエンドポイントを追加し、Go/TS 型を再生成する運用で拡張する。

## テスト戦略

### ユニットテスト（主眼）
- **フレームワーク**: Go 標準 testing + testify。
- **対象**: Domain 層（`isTargetDate` / `calcStreak` / `calcAchievementRate` / ヒートマップ分類）。
- **カバレッジ目標**: ドメインロジックでステートメントカバレッジ 90% 以上。

### 統合テスト
- **方法**: testcontainers-go で本物の PostgreSQL を起動し、マイグレーション適用後に検証。
- **対象**: Repository の一意制約・CRUD・期間取得、Service ユースケース（登録→記録→集計）のDB込み。

### E2Eテスト
- **ツール**: Playwright（ブラウザ↔Go API）。
- **シナリオ**: 登録→当日チェックイン→ダッシュボード反映、過去日の遡り修正、リマインド超過ハイライト。

### フロント単体テスト
- Vitest + Testing Library でコンポーネント/データフックを検証。

## 技術的制約

### 環境要件
- **OS**: 開発は Windows/macOS/Linux（Go・Node・Docker が動作する環境）。
- **必要な外部依存**: Docker（ローカル PostgreSQL 用）、Go ツールチェーン、Node.js LTS。

### 制約
- ローカル PostgreSQL はコンテナ前提（Docker 必須）。
- backend/frontend はネイティブ起動（`go run` / `npm run dev`）とし、Compose は Postgres のみに限定する。
- API 契約変更時は `openapi.yaml` を先に更新し、Go/TS の型再生成をセットで行う（契約ドリフト防止）。

## 依存関係管理

| エコシステム | 方針 |
|-----------|------|
| Go modules（backend） | `go.mod` でバージョン固定。更新は明示的に `go get` で行う |
| npm（frontend） | `package-lock.json` で固定。安定版は `^`（マイナー許可）、破壊的変更リスクのあるものは完全固定 |
| コード生成物（sqlc / oapi-codegen / OpenAPI TS） | 生成コマンドを定義し、契約・SQL 変更時に再生成。生成物のコミット方針はリポジトリ構造定義書で規定 |

## 参照ドキュメント
- `docs/1_requirements/product-requirements.md` - PRD
- `docs/2_basic-design/functional-design.md` - 機能設計書（索引。詳細は `functional-design/` に分割）
- `docs/3_detail-design/repository-structure.md` - リポジトリ構造定義書（本書のスタックを反映）
- `docs/_shared/development-guidelines.md` - 開発ガイドライン
