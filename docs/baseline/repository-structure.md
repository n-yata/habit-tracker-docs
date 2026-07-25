# リポジトリ構造定義書 (Repository Structure Document)

> アーキテクチャ設計書（`docs/baseline/architecture.md`）の技術スタック・レイヤー構成を反映した
> 具体的なディレクトリ構造の正本。本プロジェクトは **3つの独立した Git リポジトリ** で構成する。
> Go/Next.js の慣習に合わせ、テンプレート（単一リポ/TS前提）を各リポジトリへ適用する。

## 全体構成（3リポジトリ）

| リポジトリ | 技術 | 役割 |
|---|---|---|
| `habit-tracker-docs`（本リポジトリ） | Markdown / Claude 設定 | ドキュメント・スペック・`.claude`・`.steering` |
| `habit-tracker-backend` | Go | REST API サーバ（chi + sqlc + pgx） |
| `habit-tracker-frontend` | Next.js (TypeScript) | Web UI |

API 契約 `openapi.yaml` は正本を **backend リポジトリ**に置き、frontend はそれを取り込んで TS 型を
生成する（契約の一元管理。取り込み方法は開発ガイドラインで規定）。

---

## 1. docs リポジトリ（本リポジトリ）

```
habit-tracker-docs/
├── CLAUDE.md                       # プロジェクトメモリ
├── docs/                           # 永続ドキュメント
│   ├── baseline/                   # 常に参照する指標（フラット、番号プレフィックスなし）
│   │   ├── ideas/                    # 前段（壁打ち下書き・技術調査メモ）
│   │   │   ├── initial-requirements.md
│   │   │   └── tech-stack.md
│   │   ├── product-requirements.md   # 要件定義（PRD）
│   │   ├── functional-design.md      # 基本設計（機能設計書。重要点＝データモデル/中核アルゴリズム/各種一覧を集約する正本）
│   │   ├── architecture.md           # 基本設計（システム構造・技術選定）
│   │   ├── repository-structure.md   # 詳細設計（本ドキュメント）
│   │   ├── development-guidelines.md # 横断（開発全体の規約）
│   │   └── glossary.md               # 横断（ユビキタス言語）
│   └── specs/                      # 各フェーズで参照・作成する成果物
│       ├── 1_requirements/           # 要件定義工程の顧客提出成果物
│       │   ├── requirements-definition.md      # 要件定義書（FR）
│       │   └── non-functional-requirements.md  # 非機能要件定義書（NFR）
│       ├── 2_basic-design/           # 基本設計の実装詳細（必要な時にだけ参照。一覧・中核仕様は baseline/functional-design.md が正本。直下にフラット配置）
│       │   ├── component-design.md   # レイヤー別インターフェース詳細
│       │   ├── usecase.md            # ユースケースのシーケンス図フル
│       │   ├── api-design.md         # 各APIの入出力詳細・JSON例・エラーレスポンス
│       │   └── screen-design.md      # 画面のレイアウト/項目/イベント
│       ├── 3_detail-design/          # 詳細設計工程の成果物（物理レベル・API単位・画面単位）
│       │   ├── db/
│       │   │   └── table-definition.md     # テーブル定義書（物理スキーマ）
│       │   ├── api/
│       │   │   └── api-XX-*.md             # API単位の詳細設計（8本）
│       │   └── screen/
│       │       └── screen-XX-*.md          # 画面単位の詳細設計（4本）
│       ├── 4_unit-test/              # 単体テスト仕様書（実DB不要、API/画面単位）
│       │   └── test-{api,screen}-XX-*.md   # API 8本 + 画面 4本
│       ├── 5_integration-test/       # 結合テスト仕様書（実PostgreSQL必須、画面単位。APIごとには分割しない）
│       │   └── test-integration-{screen-slug}.md
│       └── _shared/                  # フェーズ横断で参照する実装詳細（特定フェーズに属さない）
│           └── cross-cutting.md        # UI表示仕様・エラーハンドリング・非機能・テスト戦略の詳細
├── .steering/                      # 作業単位ドキュメント（履歴保持）
│   └── [YYYYMMDD]-[task-name]/
│       ├── requirements.md
│       ├── design.md
│       ├── tasklist.md
│       └── retrospective.md
├── .claude/                        # Claude Code 設定
│   ├── skills/                     # スキル（ワークフローの入口 flow-* も含む）
│   ├── agents/
│   └── README.md                   # skill/agent の目次
└── scripts/
    └── start-dev.ps1                 # 3リポジトリ一括起動（PostgreSQL・backend・frontend、env読み込み・ポート後始末込み）
```

**役割**: ドキュメント・スペック管理。実装コードは持たない。`docs/` 配下は `baseline/`（指標。
フラット構成、`ideas/` のみサブディレクトリとして例外的に存在）と
`specs/`（各フェーズの成果物。機能設計書の分割詳細や、フェーズ横断の実装詳細（`_shared/`）もここに置く）
に分ける。`docs/` 直下には実ファイルを置かない。

---

## 2. backend リポジトリ（Go API）

Go の標準的なレイアウト（`cmd/` + `internal/`）を採用し、アーキテクチャのレイヤー
（Handler / Service / Domain / Repository）を `internal/` 配下に反映する。

```
habit-tracker-backend/
├── cmd/
│   └── api/
│       └── main.go                 # エントリポイント（DI組立・サーバ起動）
├── internal/
│   ├── handler/                    # Handler層: HTTP入出力・OpenAPI契約変換
│   │   ├── habit_handler.go
│   │   ├── checkin_handler.go
│   │   └── dashboard_handler.go
│   ├── service/                    # Service層: ユースケース組立
│   │   ├── habit_service.go
│   │   ├── checkin_service.go
│   │   └── dashboard_service.go
│   ├── domain/                     # Domain層: 純粋ロジック（外部依存なし）
│   │   ├── habit.go                # Habit エンティティ・繰り返しルール型
│   │   ├── recurrence.go           # isTargetDate / targetDatesInRange
│   │   ├── streak.go               # calcStreak
│   │   └── achievement.go          # calcAchievementRate / ヒートマップ分類
│   ├── repository/                 # Repository層: 永続化（sqlc生成を利用）
│   │   ├── habit_repository.go
│   │   └── checkin_repository.go
│   ├── db/                         # sqlc 生成コード・接続
│   │   ├── sqlc/                   # sqlc 生成物（queries.sql.go 等）
│   │   └── conn.go                 # pgx コネクション
│   └── api/                        # oapi-codegen 生成の型/サーバインタフェース
│       └── openapi_gen.go
├── db/
│   ├── migrations/                 # golang-migrate の up/down SQL
│   │   ├── 000001_init.up.sql
│   │   └── 000001_init.down.sql
│   └── queries/                    # sqlc 入力の SQL
│       ├── habit.sql
│       └── checkin.sql
├── test/
│   └── integration/                # testcontainers-go を用いたDB結合テスト
│       ├── habit_repository_test.go
│       └── checkin_flow_test.go
├── api/
│   └── openapi.yaml                # API契約の正本
├── sqlc.yaml                       # sqlc 設定
├── go.mod
├── go.sum
├── Makefile                        # 生成・マイグレーション・テストのタスク
├── docker-compose.yml              # ローカル PostgreSQL のみ
└── .env.example                    # DB接続情報のサンプル
```

### レイヤーとディレクトリの対応

各ディレクトリがアーキテクチャのどのレイヤーを実装するかの対応。**責務・依存ルール（許可/禁止）の正本は
[`architecture.md`](architecture.md) の「アーキテクチャパターン」**とし、本書は物理配置に徹する。

| ディレクトリ | 対応レイヤー |
|---|---|
| `internal/handler` | Handler層（HTTP入出力・契約変換） |
| `internal/service` | Service層（ユースケース組立・Tx境界） |
| `internal/domain` | Domain層（純粋ロジック・外部依存なし） |
| `internal/repository` | Repository層（永続化） |
| `internal/db` / `internal/api` | 生成コード（sqlc / oapi-codegen） |

**単体テスト（Go 慣習）**: 実装ファイルと同じパッケージに `*_test.go` を隣接配置する
（例: `internal/domain/streak.go` ↔ `internal/domain/streak_test.go`）。Domain 層のテストを最重視。

**DB結合テスト**: `test/integration/` に配置し、testcontainers-go で PostgreSQL を起動、
`db/migrations` を適用して検証する。

### 命名規則（Go）
識別子・ファイル名の命名規約は [`development-guidelines.md`](development-guidelines.md) の
「コーディング規約 › Go（backend）」を正本とする。構造面の補足のみ: 単体テストは実装と同じパッケージに
`*_test.go` を隣接配置する（上の「レイヤーとディレクトリの対応」直下のテスト方針を参照）。

### 生成物の扱い（コミット方針）
- sqlc 生成コード（`internal/db/sqlc`）・oapi-codegen 生成コード（`internal/api`）は**リポジトリにコミットする**
  （生成コマンドは Makefile に定義）。再生成のタイミング・手編集禁止の原則は
  [`development-guidelines.md`](development-guidelines.md) の「API契約の運用」を正本とする。

---

## 3. frontend リポジトリ（Next.js）

Next.js App Router を採用。API 呼び出しは TanStack Query のフックに集約し、ページ/コンポーネントは
描画に専念する（レイヤー分離をフロントにも適用）。

```
habit-tracker-frontend/
├── src/
│   ├── app/                        # App Router（ルーティング・ページ）
│   │   ├── layout.tsx
│   │   ├── page.tsx                # ダッシュボード（当日）
│   │   ├── habits/
│   │   │   ├── page.tsx            # 習慣一覧・管理
│   │   │   └── [id]/page.tsx       # 習慣詳細
│   │   └── check-in/
│   │       └── page.tsx            # 日付指定チェックイン
│   ├── components/                 # 表示コンポーネント
│   │   ├── ui/                     # shadcn/ui 由来
│   │   ├── HeatmapCalendar.tsx
│   │   ├── StreakBadge.tsx
│   │   └── AchievementRing.tsx
│   ├── features/                   # 機能単位のフック・ロジック
│   │   ├── habits/
│   │   │   ├── useHabits.ts        # TanStack Query フック
│   │   │   └── habitForm.ts        # フォーム/バリデーション
│   │   ├── check-in/
│   │   │   └── useCheckIns.ts
│   │   └── dashboard/
│   │       └── useDashboard.ts
│   ├── lib/
│   │   ├── apiClient.ts            # fetch ラッパ（baseURL・エラー整形）
│   │   └── queryClient.ts          # TanStack Query 設定
│   └── generated/
│       └── api-types.ts            # openapi.yaml から生成した TS 型
├── tests/
│   ├── unit/                       # Vitest + Testing Library
│   │   └── components/
│   └── e2e/                        # Playwright（ブラウザ↔Go API）
│       └── core-flow.spec.ts
├── public/
├── openapi.yaml                    # backend から取り込んだ契約（型生成の入力）
├── package.json
├── package-lock.json
├── tsconfig.json
├── tailwind.config.ts
├── next.config.mjs
└── .env.local.example              # API のベースURL 等
```

### レイヤーとディレクトリの対応

**依存ルール（許可/禁止）の正本は [`architecture.md`](architecture.md) の
「フロントエンド: 画面 + データフック分離」**とし、本書は物理配置に徹する。

| ディレクトリ | 対応レイヤー / 役割 |
|---|---|
| `app/` | ページ（ルーティング・描画） |
| `components/` | 表示専用UI（`ui/` は shadcn/ui 由来） |
| `features/` | データ取得フック・機能ロジック |
| `lib/` | 横断基盤（apiClient / queryClient） |
| `generated/` | 契約由来の型（自動生成・手編集禁止） |

### 命名規則（TS/Next.js）
識別子・ファイル名の命名規約は [`development-guidelines.md`](development-guidelines.md) の
「コーディング規約 › TypeScript / Next.js（frontend）」を正本とする。構造に固有の点のみ補足する:
- ルーティングディレクトリは kebab-case（`check-in/`）。App Router の規約ファイルは `page.tsx` / `layout.tsx` 等。

### 生成物の扱い（コミット方針）
- `src/generated/api-types.ts`（`openapi.yaml` から生成）は**リポジトリにコミットする**。手編集禁止・
  再生成のタイミングは [`development-guidelines.md`](development-guidelines.md) の「API契約の運用」を正本とする。

---

## リポジトリ横断のルール

### API 契約の一元管理
- 契約の正本ファイルは **`backend/api/openapi.yaml`**（配置＝本書の管轄）。frontend はこれを取り込んで TS 型を生成する。
- 取り込み方法・再生成ワークフロー（`openapi.yaml` 更新 → backend/frontend 生成物の再生成をセットで行う）は
  [`development-guidelines.md`](development-guidelines.md) の「API契約の運用」を正本とする。

### 依存方向・ファイルサイズ
- 依存方向（backend: Handler→Service→Domain/Repository、frontend: app→features→lib→generated）の正本は
  [`architecture.md`](architecture.md) の「アーキテクチャパターン」。本書のディレクトリ対応表はその物理マッピング。
- 1ファイルの肥大化を避ける目安（300 行）等のコーディング規約は
  [`development-guidelines.md`](development-guidelines.md) を参照。

---

## 特殊ディレクトリ（docs リポジトリ）

### .steering/
作業単位のドキュメント。`[YYYYMMDD]-[task-name]/` に `requirements.md` / `design.md` /
`tasklist.md` / `retrospective.md` を置く。命名例: `20260712-habit-tracker`。

### .claude/
`skills/` `agents/` と目次 `README.md`。ワークフローの入口（旧 `commands/`）も `skills/` の
`flow-*` に統合済み。skill/agent の追加・削除・リネーム時は `README.md` も同じ変更で更新する。

---

## 除外設定（.gitignore）

各リポジトリの `.gitignore` の主対象は [`development-guidelines.md`](development-guidelines.md) の
「バージョン管理から除外するもの（.gitignore）」を正本とする。生成物のうち**コミットするもの**は本書の
各リポジトリ「生成物の扱い（コミット方針）」を参照。

## 参照ドキュメント
- `docs/baseline/architecture.md` - 技術スタック・レイヤー構成の正本
- `docs/baseline/functional-design.md` - コンポーネント設計・モジュール構成図
- `docs/baseline/development-guidelines.md` - 命名規則・契約取り込み/再生成・Git運用・.gitignore の正本
