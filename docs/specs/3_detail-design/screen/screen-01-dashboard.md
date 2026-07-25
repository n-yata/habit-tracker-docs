# 画面詳細設計書: ダッシュボード

> 画面一覧・ルート・対応コンポーネント・画面遷移の正本は
> [`functional-design.md`](../../../baseline/functional-design.md)「画面設計」。レイアウト・画面項目・
> 画面イベントの外部設計は [`screen-design.md`](../../2_basic-design/screen-design.md)。本書は本画面の
> コンポーネント構成（props/state）・状態管理・詳細な画面遷移/イベント処理フロー・例外表示を記載する。

## 基本情報

| 項目 | 内容 |
|---|---|
| 画面名 | ダッシュボード |
| ルート(FE) | `/` |
| 対応コンポーネント | `DashboardPage` |
| 関連API | `GET /check-ins?date=today`（API-06）、`GET /dashboard`（API-08） |
| 関連機能 | FR-07, FR-08, FR-10, FR-12, FR-14, FR-15, FR-16 |

外部設計（レイアウト・画面項目定義・画面イベント一覧）は
[`screen-design.md`](../../2_basic-design/screen-design.md)「画面1: ダッシュボード」を参照。本書は
以下の実装レベル詳細に限定する。

## コンポーネント構成

```
DashboardPage
├── TodayHabitList            # 当日対象習慣リスト（チェックボックス操作を含む）
│   └── HabitCheckItem[]      # 1習慣分の行（チェックボックス・カテゴリ・ストリークバッジ・超過ハイライト）
├── SummaryPanel               # 週次/月次達成率
│   └── AchievementRing[]
└── HeatmapCalendar             # ヒートマップ（直近数週）
```

### props / state 設計

| コンポーネント | props | 内部 state |
|---|---|---|
| `DashboardPage` | なし（ルートページ） | なし（データ取得は子コンポーネントの hooks に委譲） |
| `TodayHabitList` | なし | `useCheckInsForDate('today')`（TanStack Query） |
| `HabitCheckItem` | `habit: Habit`, `status: CheckInStatus \| null`, `overdue: boolean` | 楽観更新中フラグ（ローカル state。`useCheckInsForDate` の mutation 中のみ使用） |
| `SummaryPanel` | `range: { from: string; to: string }`（週次/月次それぞれ算出して渡す） | `useDashboard(range)`（TanStack Query） |
| `HeatmapCalendar` | `heatmap: { date: string; state: HeatmapState }[]` | なし（表示専用） |

## 状態管理（TanStack Query キー設計）

| フック | クエリキー | 対応API |
|---|---|---|
| `useCheckInsForDate(date)` | `['check-ins', date]` | API-06 |
| `useDashboard(range)` | `['dashboard', range.from, range.to]` | API-08 |

- チェックイン操作（`HabitCheckItem` のチェックボックス切替）は `useMutation` で楽観更新を行い、
  成功/失敗に関わらず `['check-ins', 'today']` と `['dashboard', ...]` を invalidate して再取得する
  （ストリーク・達成率の整合性を保つため）。
- ローディング・エラー・空状態の表示仕様は
  [`cross-cutting.md`](../../_shared/cross-cutting.md)「UI設計」の画面共通状態を参照。

## 画面遷移・イベント処理の詳細フロー

### チェックボックス切替（完了/未完了トグル）

1. ユーザーがチェックボックスをクリック。
2. `HabitCheckItem` が `useCheckInsForDate` の mutation（`PUT /habits/{id}/check-ins/{today}`、API-07）を発火。
3. 楽観更新でチェック状態を即座に反映（ローカル state で仮表示）。
4. API呼び出し成功時: `['check-ins', 'today']`・`['dashboard', ...]` を invalidate して再取得し、
   ストリーク・達成率・ヒートマップを最新化。
5. API呼び出し失敗時（422等）: 楽観更新をロールバックし、エラーメッセージを表示
   （メッセージ内容は `cross-cutting.md`「エラーハンドリング」参照）。

### 画面遷移イベント

| 操作 | 遷移先 | 備考 |
|---|---|---|
| 「習慣管理」クリック | `/habits`（`HabitsPage`） | Next.js `Link` によるクライアントサイド遷移 |
| 「日付を選んで記録」クリック | `/check-ins?date=...`（`CheckInPage`） | デフォルトは当日をクエリに付与 |
| 習慣名クリック | `/habits/{id}`（`HabitDetailPage`） | — |

## 例外・エラー表示

| ケース | 表示 |
|---|---|
| API-06/API-08 の取得失敗 | 画面共通のエラー表示＋再試行導線（`cross-cutting.md` 参照） |
| チェックイン記録の422（非対象日への記録） | 通常発生しない（当日のみ操作するため）。発生時はトースト等で「その日はこの習慣の対象ではありません」を表示しロールバック |
| 対象習慣0件 | 空状態メッセージ「習慣を登録しましょう」＋「習慣管理」への導線 |
