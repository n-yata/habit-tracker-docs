# 画面詳細設計書: 習慣詳細

> 画面一覧・ルート・対応コンポーネント・画面遷移の正本は
> [`functional-design.md`](../../../baseline/functional-design.md)「画面設計」。レイアウト・画面項目・
> 画面イベントの外部設計は [`screen-design.md`](../../2_basic-design/screen-design.md)。本書は本画面の
> コンポーネント構成（props/state）・状態管理・詳細な画面遷移/イベント処理フロー・例外表示を記載する。

## 基本情報

| 項目 | 内容 |
|---|---|
| 画面名 | 習慣詳細 |
| ルート(FE) | `/habits/{id}` |
| 対応コンポーネント | `HabitDetailPage` |
| 関連API | `GET /habits/{id}`（API-03）、`GET /dashboard`（API-08） |
| 関連機能 | FR-12, FR-14, FR-15 |

外部設計（レイアウト・画面項目定義・画面イベント一覧）は
[`screen-design.md`](../../2_basic-design/screen-design.md)「画面4: 習慣詳細」を参照。本書は以下の
実装レベル詳細に限定する。

## コンポーネント構成

```
HabitDetailPage
├── HabitHeader                 # 名前/カテゴリ/繰り返しルール要約 + 編集導線
├── StreakSummary
│   ├── StreakBadge (current)
│   ├── StreakBadge (longest)
│   └── AchievementRing
└── HeatmapCalendar              # 月次カレンダーグリッド
```

### props / state 設計

| コンポーネント | props | 内部 state |
|---|---|---|
| `HabitDetailPage` | なし（`useParams` でURLパス `id` を読む） | なし |
| `HabitHeader` | `habit: Habit` | なし |
| `StreakSummary` | `summary: { currentStreak: number; longestStreak: number; achievementRate: number \| null }` | なし |
| `HeatmapCalendar` | `heatmap: { date: string; state: HeatmapState }[]` | 表示月（ローカル state。月送りUIを持つ場合のみ） |

`HeatmapCalendar` は `screen-01-dashboard.md` のダッシュボードと同一コンポーネントを再利用する
（props形状が共通のため）。

## 状態管理（TanStack Query キー設計）

| フック | クエリキー | 対応API |
|---|---|---|
| `useHabit(id)` | `['habits', id]` | API-03 |
| `useDashboard(range)` | `['dashboard', range.from, range.to]` | API-08。取得結果から該当 `habitId` のエントリを抽出して使用 |

- 表示範囲（ヒートマップの期間）は当面「直近数ヶ月」を固定レンジとして `useDashboard` に渡す
  （月送りUIは将来拡張。第一マイルストーンでは固定表示）。

## 画面遷移・イベント処理の詳細フロー

### 初期表示

1. URLパス `id` を取得。
2. `useHabit(id)`（API-03）と `useDashboard(range)`（API-08）を並行して取得。
3. `useDashboard` の結果から `habitId === id` のエントリを抽出し、`StreakSummary` /
   `HeatmapCalendar` に渡す。

### 画面遷移イベント

| 操作 | 遷移先 | 備考 |
|---|---|---|
| 「編集」クリック | `/habits`（`HabitsPage`） | 当該習慣を編集モードで開く状態を引き継ぐ手段は実装時に決定（クエリパラメータ渡し等） |
| 「← 習慣一覧」クリック | `/habits`（`HabitsPage`） | — |

## 例外・エラー表示

| ケース | 表示 |
|---|---|
| API-03 が404（存在しない習慣） | 「対象の習慣が見つかりません」＋「習慣一覧に戻る」導線 |
| API-03/API-08 の取得失敗（5xx） | 画面共通のエラー表示＋再試行導線 |
| 対象日0件（達成率算出不可） | 「対象なし」と表示（0%ではない。`achievementRate: null` に対応） |
