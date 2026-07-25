# 開発ガイドライン (Development Guidelines)

> 本プロジェクト（HabitOS / 3リポジトリ: docs・backend(Go)・frontend(Next.js)）のコーディング規約と
> 開発プロセスの正本。技術スタックは `docs/baseline/architecture.md`、ディレクトリ構造は
> `docs/baseline/repository-structure.md` を前提とする。
> Git 運用は本プロジェクト固有ルール（`CLAUDE.md`）に従う（一般的な Git Flow ではない点に注意）。

## コーディング規約

### 共通原則
- **Domain層（backend）は純粋に保つ**: 時刻・DB・HTTP に暗黙依存しない。`today` 等は引数で受け取り、
  テスト可能性を最優先にする（本プロジェクトの主眼）。
- 1ファイルの肥大化を避ける（目安 300 行、超えたら責務で分割）。
- 契約（`openapi.yaml`）を正本とし、型は手書きでなく生成物を使う。

### Go（backend）

**命名規則**:
- パッケージ: 小文字・単数（`handler`, `service`, `domain`, `repository`）。
- ファイル: `snake_case.go`（例 `habit_service.go`）。
- 公開識別子: PascalCase、非公開: camelCase。
- インターフェースは利用側で定義し、実装側は具体型を返す（Go 慣習）。

**エラーハンドリング**:
```go
// センチネル/独自エラーで分類し、上位で errors.Is / errors.As で判定する
var ErrHabitNotFound = errors.New("habit not found")

func (s *HabitService) Get(ctx context.Context, id string) (*domain.Habit, error) {
    h, err := s.repo.FindByID(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("find habit %s: %w", id, err) // %w でラップし文脈を付与
    }
    if h == nil {
        return nil, ErrHabitNotFound
    }
    return h, nil
}
```
- エラーは握り潰さない。ラップして文脈（何をしていたか）を付ける。
- Handler層で独自エラー→HTTPステータスへ変換する（`ErrHabitNotFound`→404、バリデーション→400）。

**フォーマット/静的解析**:
- `gofmt`（`go fmt`）と `go vet` を必須。lint は golangci-lint を推奨。
- インデントはタブ（gofmt 準拠）。

**ドキュメンテーションコメント**:
```go
// CalcStreak は繰り返しルールと記録列から現在・最長ストリークを算出する。
// 対象外の日は連続を途切れさせず、対象日の未達成で途切れる。today は判定基準日。
func CalcStreak(h Habit, checkIns []CheckIn, today string) Streak { ... }
```

### TypeScript / Next.js（frontend）

**命名規則**:
- 変数: camelCase（名詞）／関数: camelCase（動詞始まり）／定数: UPPER_SNAKE_CASE。
- Boolean: `is` / `has` / `should` 始まり。
- コンポーネント: PascalCase（`HeatmapCalendar.tsx`）／フック: `useXxx`（`useHabits.ts`）。
- 型/インターフェース: PascalCase（I接頭辞は付けない）。

**フォーマット/静的解析**:
- Prettier + ESLint を必須。インデント 2 スペース、行長 100 目安。
- `any` を避け、生成型（`src/generated/api-types.ts`）を使う。

**データ取得**:
- API 呼び出しは `features/**/useXxx.ts`（TanStack Query）に集約し、コンポーネントから直接 fetch しない。
- 変更系はサーバ状態を楽観更新→再取得で整合させる。

**コメント原則（共通）**:
- 「何を」ではなく「なぜ」を書く。コードで自明なことはコメントしない。

## Git運用ルール（プロジェクト固有・必須）

> 一般的な Git Flow ではなく、`CLAUDE.md` のルールに従う。**実装・修正は今いるブランチでそのまま行う。**
> 作業ごとに専用の作業ディレクトリやブランチを新規に切る必要はない。ただし `main` への直接コミットは避ける。

### ワークフロー
1. **作業開始**: 現在のブランチで作業を開始する（必要に応じて `git pull` で最新化）。
2. **作業完了**（順序厳守）:
   1. コミット前に振り返り `retrospective.md` を作成（学びがあれば）。実装一式と**同じコミット**に含める。
   2. コミット前に **security-engineer によるセキュリティレビュー**を実施。
   3. 変更一式（実装 + `retrospective.md`）をコミット。
   4. 必要に応じて push → `gh pr create` で PR 作成。`main` へマージする場合は **Merge commit**。

### コミットメッセージ（Conventional Commits）
```
<type>(<scope>): <subject>

<body>

<footer>
```
- Type: `feat` / `fix` / `docs` / `style` / `refactor` / `test` / `chore`。
- scope 例（backend）: `habit`, `checkin`, `streak`, `api`。（frontend）: `dashboard`, `habits`。
- 例:
  ```
  feat(streak): 特定曜日ルールのストリーク計算を実装

  対象外の日を跨いでも連続とみなし、対象日の未達成で途切れる仕様。
  today 未記録日は中立扱いとする。単体テストでエッジケースを網羅。
  ```

### PRプロセス
**作成前チェック**:
- [ ] 全テストがパス（Go: `go test ./...` / frontend: 単体・必要なら E2E）
- [ ] Lint / 型チェックがパス（`go vet`・golangci-lint / ESLint・tsc）
- [ ] `main` を取り込み済みでコンフリクトなし
- [ ] セキュリティレビュー実施済み

**PRテンプレート**:
```markdown
## 概要
[変更内容の簡潔な説明]

## 変更理由
[なぜ必要か / 対応するスペック]

## 変更内容
- [変更点1]

## テスト
- [ ] 単体テスト追加/更新
- [ ] 結合/E2E（該当時）
- [ ] 手動確認

## 関連
- スペック: .steering/[YYYYMMDD]-[task]/
```

## バージョン管理から除外するもの（.gitignore）

各リポジトリでコミットしないファイルの主対象。生成物のうち**コミットするもの**（sqlc / oapi-codegen 生成コード等）は
リポジトリ構造定義書（`docs/baseline/repository-structure.md`）の「生成物の扱い」を参照。

**backend**
```
/bin/
*.exe
.env
coverage.out
```

**frontend**
```
node_modules/
.next/
dist/
.env.local
coverage/
```

**docs**
```
# .steering/ は履歴として保持する方針
*.log
.DS_Store
```

## API契約の運用（リポジトリ横断）
- 正本は `backend/api/openapi.yaml`。**契約変更は必ず openapi.yaml を先に更新**する。
- 変更後は「backend の生成物（oapi-codegen / sqlc は SQL 起点）再生成 → frontend の TS 型再生成」を
  同一変更のセットで行い、契約ドリフトを防ぐ。
- 生成物は手編集しない（`internal/api`・`internal/db/sqlc`・`src/generated`）。

## テスト戦略

テストピラミッド: **単体（多）→ 統合（中）→ E2E（少）**。本プロジェクトはドメインロジックの
単体テストを最重要視する。

### 単体テスト
- **backend（主眼）**: Go 標準 testing + testify。対象は Domain 層
  （`isTargetDate` / `calcStreak` / `calcAchievementRate` / ヒートマップ分類）。
  カバレッジ目標: ドメインロジックで **ステートメント 90% 以上**。
  ```go
  func TestCalcStreak_未対象日を跨いでも継続(t *testing.T) {
      h := domain.Habit{RecurrenceType: domain.SpecificDays, TargetWeekdays: []int{1, 3, 5}}
      // 月水金を連続達成、火木は対象外 → ストリーク継続
      got := domain.CalcStreak(h, checkIns, "2026-07-13")
      require.Equal(t, 3, got.Current)
  }
  ```
- **frontend**: Vitest + Testing Library（コンポーネント/フック）。

### 統合テスト（backend）
- testcontainers-go で本物の PostgreSQL を起動し、`db/migrations` 適用後に検証。
- 対象: Repository の `(habit_id, date)` 一意制約・CRUD・期間取得、Service ユースケース（登録→記録→集計）。

### E2Eテスト
- Playwright（ブラウザ↔Go API）。コアユースケース: 登録→当日チェックイン→ダッシュボード反映、
  過去日の遡り修正、リマインド超過ハイライト。

### テスト命名規則
- ファイル名: Go は `*_test.go`（実装と同じパッケージに隣接配置）。TS は単体 `*.test.ts(x)` / E2E `*.spec.ts`。
- Go: `Test<対象>_<条件>_<期待>`（日本語の説明的名も可）。
- TS: `describe/it` で「対象 / 条件 / 期待結果」を明示。`it('test1')` のような無意味名は禁止。

### モック方針
- 外部依存（DB・HTTP）は境界でモック/コンテナ化。ビジネスロジック（Domain）は実装を使う。

## コードレビュー基準
- **機能性**: 要件・受け入れ条件を満たすか、エッジケース（ストリークの境界）を考慮しているか。
- **可読性**: 命名が明確か、なぜを説明するコメントか。
- **保守性**: 重複がないか、レイヤー責務が守られているか（Domain に DB/HTTP 依存が漏れていないか）。
- **パフォーマンス**: N+1 を避けているか、集計クエリが妥当か。
- **セキュリティ**: サーバ側入力検証、パラメータ化クエリ、機密のハードコードなし。

レビューコメントは優先度を明示: `[必須]` / `[推奨]` / `[提案]` / `[質問]`。建設的に理由とともに書く。

## 開発環境セットアップ

### 必要なツール

| ツール | バージョン | 用途 |
|--------|-----------|------|
| Go | 1.23+ | backend |
| Node.js | LTS (22.x 想定) | frontend |
| Docker / Docker Compose | 最新 | ローカル PostgreSQL |
| golang-migrate CLI | 最新 | マイグレーション適用 |
| sqlc / oapi-codegen | 最新 | コード生成（backend） |

### backend セットアップ手順
```bash
git clone <backend-url> && cd habit-tracker-backend
cp .env.example .env                 # DB接続情報・FRONTEND_ORIGIN を設定
docker compose up -d                 # PostgreSQL 起動（Postgres のみ）
migrate -path db/migrations -database "$DATABASE_URL" up   # マイグレーション
go run ./cmd/api                     # API サーバ起動
go test ./...                        # テスト
```
> **注意**: Go アプリは `.env` を自動読み込みしない（godotenv 等は未導入）。`.env` を書くだけでは
> `os.Getenv` に値は渡らないため、`.env` の内容を明示的にシェルの環境変数へ展開してから
> `go run` を実行する必要がある（下記 `scripts/start-dev.ps1` はこれを自動化する）。

### frontend セットアップ手順
```bash
git clone <frontend-url> && cd habit-tracker-frontend
cp .env.local.example .env.local     # API のベースURL を設定
npm ci                               # 依存インストール
# openapi.yaml を取り込み TS 型を生成（生成コマンドは package.json scripts に定義）
npm run dev                          # 開発サーバ
npm test                             # Vitest
```

### 3リポジトリ一括起動（推奨）
`habit-tracker-docs` と兄弟ディレクトリに backend・frontend を配置している場合、
`habit-tracker-docs/scripts/start-dev.ps1` で PostgreSQL・backend・frontend を一括起動できる。
`.env` の環境変数展開（上記の注意点への対応）とポート3000の残留プロセス後始末を自動で行うため、
手動セットアップより優先して使う。

### 推奨開発ツール
- backend: golangci-lint、air（ホットリロード、任意）。
- frontend: ESLint / Prettier の IDE 連携。

## 参照ドキュメント
- `docs/baseline/architecture.md` - 技術スタック・レイヤー構成
- `docs/baseline/repository-structure.md` - ディレクトリ構造
- `CLAUDE.md` - Git 運用・スペック駆動開発の原則（正本）
