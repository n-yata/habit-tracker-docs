# リポジトリ構造定義書 (Repository Structure Document)

> アーキテクチャ設計書（`docs/2_basic-design/architecture.md`）の技術スタック・レイヤー構成を反映した
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
│   ├── 0_ideas/                    # 壁打ち下書き
│   │   ├── initial-requirements.md
│   │   └── tech-stack.md
│   ├── 1_requirements/             # 要件定義
│   │   └── product-requirements.md
│   ├── 2_basic-design/             # 基本設計
│   │   ├── functional-design.md     # 機能設計書の索引・システム構成図・技術スタック
│   │   ├── functional-design/       # 機能設計書（関心事ごとに分割した詳細）
│   │   │   ├── data-model.md
│   │   │   ├── component-design.md
│   │   │   ├── usecase.md
│   │   │   ├── screen-design.md
│   │   │   ├── api-design.md
│   │   │   ├── domain-logic.md
│   │   │   └── cross-cutting.md
│   │   └── architecture.md
│   ├── 3_detail-design/            # 詳細設計（永続分）
│   │   └── repository-structure.md # 本ドキュメント
│   └── _shared/                    # 横断（工程非依存）
│       ├── development-guidelines.md
│       └── glossary.md
├── .steering/                      # 作業単位ドキュメント（履歴保持）
│   └── [YYYYMMDD]-[task-name]/
│       ├── requirements.md
│       ├── design.md
│       ├── tasklist.md
│       └── retrospective.md
└── .claude/                        # Claude Code 設定
    ├── commands/
    ├── skills/
    ├── agents/
    └── README.md                   # command/skill/agent の目次
```

**役割**: ドキュメント・スペック管理。実装コードは持たない。`docs/` 直下には実ファイルを置かず、
工程別の番号付きディレクトリに格納する。

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

### レイヤーの役割・依存

| ディレクトリ | 役割 | 依存可能 | 依存禁止 |
|---|---|---|---|
| `internal/handler` | HTTP入出力・契約変換 | service, api（生成型） | repository, db |
| `internal/service` | ユースケース組立・Tx境界 | domain, repository | handler |
| `internal/domain` | 純粋ロジック（判定/集計） | Go標準ライブラリのみ | handler, service, repository, db |
| `internal/repository` | 永続化 | db（sqlc生成）, domain（型） | handler, service |

**単体テスト（Go 慣習）**: 実装ファイルと同じパッケージに `*_test.go` を隣接配置する
（例: `internal/domain/streak.go` ↔ `internal/domain/streak_test.go`）。Domain 層のテストを最重視。

**DB結合テスト**: `test/integration/` に配置し、testcontainers-go で PostgreSQL を起動、
`db/migrations` を適用して検証する。

### 命名規則（Go）
- パッケージ名: 小文字・単数（`handler`, `service`, `domain`, `repository`）。
- ファイル名: `snake_case.go`（例: `habit_service.go`）。
- 型・エクスポート関数: PascalCase。非公開: camelCase。
- テスト: `*_test.go`。

### 生成物の扱い
- sqlc 生成コード（`internal/db/sqlc`）・oapi-codegen 生成コード（`internal/api`）はコミットする
  （生成コマンドは Makefile に定義。SQL/契約変更時に再生成）。

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

### ディレクトリの役割・依存

| ディレクトリ | 役割 | 依存可能 | 依存禁止 |
|---|---|---|---|
| `app/` | ルーティング・ページ描画 | components, features | lib の直接 fetch（features 経由にする） |
| `components/` | 表示専用UI | ui, generated（型） | features のロジック実体 |
| `features/` | データ取得フック・機能ロジック | lib, generated | app への逆依存 |
| `lib/` | 横断基盤（apiClient 等） | generated | features, app |
| `generated/` | 契約由来の型（自動生成） | — | 手編集禁止 |

### 命名規則（TS/Next.js）
- コンポーネントファイル: PascalCase（`HeatmapCalendar.tsx`）。
- フック/関数ファイル: camelCase（`useHabits.ts`, `apiClient.ts`）。
- ルーティングディレクトリ: kebab-case（`check-in/`）。App Router の規約ファイルは `page.tsx` 等。
- テスト: `*.test.ts(x)`（単体） / `*.spec.ts`（E2E）。

### 生成物の扱い
- `src/generated/api-types.ts` は `openapi.yaml` から生成。手編集禁止。契約更新時に再生成する。

---

## リポジトリ横断のルール

### API 契約の一元管理
- 正本は `backend/api/openapi.yaml`。frontend はこれを取り込み（コピー/サブモジュール等、
  開発ガイドラインで規定）、TS 型を生成する。
- 契約変更は「`openapi.yaml` 更新 → backend 生成物再生成 → frontend 型再生成」をセットで行う。

### 依存方向（各リポジトリ共通の原則）
- backend: Handler → Service → (Domain / Repository)。Domain は最下層で誰にも依存しない。
- frontend: app → features → lib → generated。逆方向・循環依存を禁止。

### ファイルサイズの目安
- 1ファイルの肥大化を避ける（目安 300 行）。責務ごとに分割する。

---

## 特殊ディレクトリ（docs リポジトリ）

### .steering/
作業単位のドキュメント。`[YYYYMMDD]-[task-name]/` に `requirements.md` / `design.md` /
`tasklist.md` / `retrospective.md` を置く。命名例: `20260712-habit-tracker`。

### .claude/
`commands/` `skills/` `agents/` と目次 `README.md`。command/skill/agent の追加・削除・リネーム時は
`README.md` も同じ変更で更新する。

---

## 除外設定（.gitignore の主対象）

### backend
```
/bin/
*.exe
.env
coverage.out
```

### frontend
```
node_modules/
.next/
dist/
.env.local
coverage/
```

### docs
```
# .steering/ は履歴として保持する方針（プロジェクト運用に従う）
*.log
.DS_Store
```

## 参照ドキュメント
- `docs/2_basic-design/architecture.md` - 技術スタック・レイヤー構成の正本
- `docs/2_basic-design/functional-design/component-design.md` - コンポーネント設計
- `docs/_shared/development-guidelines.md` - 契約取り込み・生成・Git運用の詳細
