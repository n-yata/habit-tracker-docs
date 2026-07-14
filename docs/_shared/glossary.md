# プロジェクト用語集 (Glossary)

## 概要

HabitOS プロジェクトで使用する用語（ユビキタス言語）の正本。全ドキュメント・実装・テストで
本用語集の定義に従う。用語を追加・変更したら本ファイルを更新する。

**更新日**: 2026-07-14

## ドメイン用語

| 用語（英語表記） | 定義 | 説明・補足 | 関連用語 |
|---|---|---|---|
| 習慣<br>(Habit) | ユーザーが継続したい行動を、繰り返しルールとともに登録した単位。 | 名前・カテゴリ・繰り返しルール・任意のリマインド時刻を持つ。削除は物理削除ではなくアーカイブ（`archived=true`）で行い、過去のチェックイン記録との整合を保つ。<br>例:「毎日ストレッチ」「週3回ランニング」「月・水・金の英語学習」 | 繰り返しルール / チェックイン / ストリーク / 達成率 |
| チェックイン<br>(Check-in / CheckIn) | ある習慣について、特定の日付における「完了／未完了」を記録したもの。 | `(習慣, 日付)` に対して一意（同一日で重複しない。修正は upsert）。過去日への遡り記録・修正が可能。ストリーク・達成率はチェックイン記録から決定論的に算出される。 | 対象日 / ストリーク / 達成率 |
| 繰り返しルール<br>(Recurrence Rule / RecurrenceType) | 習慣がどの日を対象とするかを定める規則。 | 3種類ある。<br>・**毎日 (daily)**: すべての日が対象。<br>・**週N回 (weekly_count)**: 週あたり N 回（N=1〜7）達成を目標とする。曜日は問わず週単位で達成判定する。<br>・**特定曜日 (specific_days)**: 指定した曜日（1つ以上）のみが対象。 | 対象日 / 対象週 |
| 対象日<br>(Target Date) | 繰り返しルール上、その習慣を実施すべき日。 | `daily` は全日、`specific_days` は指定曜日が対象日。`weekly_count` は日単位ではなく**対象週**の概念で扱う（その週内の任意の日でカウント可）。対象日でない日（非対象日）はストリークの連続を途切れさせない。 | 繰り返しルール / 非対象日 / ストリーク |
| ストリーク<br>(Streak / current streak / longest streak) | 対象日の達成が途切れずに続いている連続数。現在ストリークと最長ストリークがある。 | **非対象日は連続を途切れさせない／対象日の未達成（未完了または未記録）で途切れる**。基準日（today）が対象日でまだ未記録の場合は「未達成による途切れ」とはみなさず中立に扱う。`weekly_count` では週単位（達成週の連続数）で数える。 | 対象日 / 達成率 / ストリーク算出 |
| 達成率<br>(Achievement Rate) | 期間内の対象日に対する完了日の割合。 | `達成率 = 期間内の対象日のうち done の数 / 期間内の対象日の総数`。週次・月次で算出する。分母が 0（期間内に対象日なし）のときは「対象なし」として率を表示しない。`weekly_count` は対象週数に対する達成週数で算出する。 | 対象日 / ヒートマップ |
| ヒートマップ<br>(Heatmap / HeatmapCalendar) | 期間内の各日の達成状況をカレンダー状のグリッドで色分け表示したもの。 | 各日の状態は `done`（完了）/ `missed`（対象日だが未達成）/ `unrecorded`（対象日だが未記録）/ `not_target`（非対象日）に分類され、UI で色分けされる（→ ヒートマップ状態）。 | 達成率 / チェックイン状態 |
| リマインド時刻<br>(Reminder Time) | 習慣に任意で設定する通知想定時刻（`HH:MM`）。 | 第一マイルストーンでは**保持のみで実配信は行わない**。当日ダッシュボードで、この時刻を過ぎた未完了の習慣をハイライト表示する用途に使う（超過判定の厳密仕様は詳細設計で確定）。 | ダッシュボード / リマインド超過ハイライト |
| ダッシュボード<br>(Dashboard) | 当日の対象習慣・チェックイン・ストリーク・達成率・ヒートマップを集約表示する画面。 | ユーザーの主要な入口。リマインド超過の未完了を強調表示する。 | チェックイン / ストリーク / 達成率 / ヒートマップ |

## 技術用語

| 用語 | 定義 | 本プロジェクトでの用途 | 備考 |
|---|---|---|---|
| Go | 静的型付けのコンパイル言語。 | backend（REST API）の実装言語。堅い型と明示的設計でドメインロジックとテスト設計を明快にする。 | バージョン 1.23 以降 |
| chi | `net/http` 互換の軽量 HTTP ルーター。 | backend のルーティング（Handler層）。 | — |
| sqlc | SQL から型安全な Go コードを生成するツール。 | Repository 層のクエリを SQL で書き、型安全な Go コードを生成する。集計/ストリーク用クエリを可視化する。 | — |
| pgx | PostgreSQL 用の高性能 Go ドライバ。 | sqlc 生成コードと組み合わせた DB アクセス。 | — |
| golang-migrate | up/down SQL でスキーマをバージョン管理するマイグレーションツール。 | `db/migrations` のスキーマ管理。テスト時も同一マイグレーションを適用。 | — |
| Next.js | React ベースの Web フレームワーク。 | frontend の UI。ただし BFF にはせず、クライアントから Go API を直接叩く（UI レンダリングに専念）。 | — |
| TanStack Query | サーバ状態管理ライブラリ（キャッシュ・再取得・楽観更新）。 | frontend の API データ取得とチェックインの即時反映。 | — |
| testcontainers-go | テスト中に Docker コンテナ（本物の依存）を起動するライブラリ。 | DB結合テストで本物の PostgreSQL を起動する。 | — |
| Playwright | ブラウザ自動化による E2E テストツール。 | ブラウザ↔Go API のコアユースケース検証。 | — |

## 略語・頭字語

| 略語 | 正式名称 | 意味 | 本プロジェクトでの使用 |
|---|---|---|---|
| PRD | Product Requirements Document | プロダクト要求定義書。 | `docs/1_requirements/product-requirements.md`。 |
| MVP | Minimum Viable Product | 実用最小限のプロダクト。 | 第一マイルストーンのコア機能（登録→チェックイン→可視化）を指す。 |
| CRUD | Create, Read, Update, Delete | データの生成・取得・更新・削除。 | 習慣の管理機能。 |
| BFF | Backend For Frontend | フロントエンド専用の中間バックエンド層。 | **採用しない**方針の説明で使う（Next.js を BFF にせず Go API を直接叩く）。 |
| API | Application Programming Interface | アプリケーション間の連携インタフェース。 | backend が提供する REST API（契約は `openapi.yaml`）。 |

## アーキテクチャ用語

| 用語（英語表記） | 定義 | 本プロジェクトでの適用 | 関連コンポーネント |
|---|---|---|---|
| レイヤードアーキテクチャ (Layered Architecture) | 責務ごとに層を分け、依存を上位から下位への一方向に保つ設計。 | backend を Handler → Service →（Domain / Repository）に分割。Domain 層は外部（DB・HTTP）に依存しない。 | Handler層 / Service層 / Domain層 / Repository層 |
| Domain層 (Domain Layer) | ビジネスの純粋ロジックを置く層。外部依存を持たない。 | 繰り返し判定・ストリーク計算・達成率/ヒートマップ集計。単体テストの主対象。 | `internal/domain`（recurrence / streak / achievement） |
| OpenAPI 契約駆動 (Contract-first) | API 仕様（`openapi.yaml`）を正本とし、そこからサーバ/クライアントの型を生成する開発手法。 | `openapi.yaml` から Go（oapi-codegen）と TS の型を生成し、契約不一致を防ぐ。 | `openapi.yaml` |

レイヤードアーキテクチャの依存方向:

```
Handler → Service → Domain / Repository → PostgreSQL
```

## ステータス・状態

### チェックイン状態 (CheckIn Status)

| ステータス | 意味 | 備考 |
|----------|------|------|
| done | 完了 | 対象日を達成した |
| not_done | 未完了 | 明示的に未達成として記録 |
| （未記録） | レコードなし | 対象日だが未入力。集計では未達成側として扱う |

### ヒートマップ状態 (Heatmap State)

| 状態 | 意味 | 表示 |
|----|------|------|
| done | 対象日・完了 | 緑 |
| missed | 対象日・未達成 | 赤/灰の弱い表現 |
| unrecorded | 対象日・未記録 | 薄い枠のみ |
| not_target | 非対象日 | 無色 |

## データモデル用語

### Habit（習慣エンティティ）

習慣を表す永続エンティティ。

| フィールド | 説明 |
|---|---|
| `id` | UUID |
| `name` | 名前（1〜100文字） |
| `category` | カテゴリ（任意） |
| `recurrenceType` | 繰り返し種別（daily / weekly_count / specific_days） |
| `weeklyTargetCount` | 週N回の N（weekly_count 時、1〜7） |
| `targetWeekdays` | 対象曜日集合（specific_days 時） |
| `reminderTime` | リマインド時刻（任意、HH:MM） |
| `archived` | アーカイブ済みか |

**関連エンティティ**: CheckIn ／ **制約**: 繰り返し種別と付随項目の整合（詳細は機能設計書のデータモデル制約）

### CheckIn（チェックインエンティティ）

ある習慣の特定日付の記録。

| フィールド | 説明 |
|---|---|
| `id` | UUID |
| `habitId` | Habit への参照 |
| `date` | 対象日（YYYY-MM-DD） |
| `status` | done / not_done |

**関連エンティティ**: Habit ／ **制約**: `(habitId, date)` に一意制約

## エラー・例外

| エラー | 発生条件 | 対処方法 | 例（Go） |
|---|---|---|---|
| バリデーションエラー | 名前長・繰り返しルール整合・N の範囲・曜日未指定・日付形式などの入力不正。 | HTTP 400 でフィールド単位の理由を返す。ユーザーは入力を修正する。 | `return nil, fmt.Errorf("weekly target must be 1..7: %w", ErrInvalidRecurrence)` |
| 習慣が見つからない (ErrHabitNotFound) | 存在しない習慣 ID への取得・更新・削除。 | HTTP 404 を返す。 | `var ErrHabitNotFound = errors.New("habit not found")` |

## 計算・アルゴリズム

| アルゴリズム | 要点／計算式 | 実装箇所 |
|---|---|---|
| ストリーク算出 (Calc Streak) | 繰り返しルールと記録列から現在・最長ストリークを求める。非対象日は連続を途切れさせない／対象日の未達成で途切れる／today 未記録は中立。`weekly_count` は達成週の連続数。 | `backend: internal/domain/streak.go` |
| 達成率算出 (Calc Achievement Rate) | `達成率 = 期間内の対象日のうち done の数 / 期間内の対象日の総数`<br>例: 月水金習慣・期間内対象日 12 日・うち done 9 日 → 75% | `backend: internal/domain/achievement.go` |

## 参照ドキュメント
- `docs/1_requirements/product-requirements.md`
- `docs/2_basic-design/functional-design.md`（機能設計書の索引。詳細は `functional-design/` に分割）
- `docs/2_basic-design/architecture.md`
- `docs/3_detail-design/repository-structure.md`
- `docs/_shared/development-guidelines.md`
