# API-08: ダッシュボード集計取得 詳細設計書

> 基本情報（ID・メソッド・パス）の正本は
> [`functional-design.md`](../../../baseline/functional-design.md)「API一覧」。入出力の要約は
> [`api-design.md`](../../2_basic-design/api-design.md)。本書は本APIのバリデーション制約・処理概要・
> エラー詳細・テスト観点を記載する。

## 基本情報

| 項目 | 内容 |
|---|---|
| ID | API-08 |
| API名 | ダッシュボード集計取得 |
| メソッド / パス | `GET /dashboard?from=..&to=..` |
| 概要 | 習慣ごとのストリーク・達成率・ヒートマップを集約して返す |
| 関連画面 | ダッシュボード、習慣詳細 |
| 関連レイヤー | Handler → Service（`DashboardService.getSummary`）→ Domain（`calcStreak` / `calcAchievementRate`）+ Repository（`HabitRepository.listActive` / `CheckInRepository.listByHabitInRange`） |

## リクエスト仕様

| 項目 | 位置 | 型 | 必須 | 制約 | 備考 |
|---|---|---|:--:|---|---|
| `from` | query | string | 必須 | `YYYY-MM-DD` 形式 | 集計期間の開始日 |
| `to` | query | string | 必須 | `YYYY-MM-DD` 形式、`from` 以降 | 集計期間の終了日 |
| `habitId` | query | UUID | 任意 | UUID形式 | 指定時はその習慣のみを対象に集計する。`archived=true` の習慣でも取得可能（習慣詳細画面での過去データ参照用）。省略時は `archived=false` の全習慣が対象 |

## レスポンス仕様

### 成功時（200 OK）

習慣ごとの集約結果のリスト。

| フィールド | 型 | 説明 |
|---|---|---|
| `habitId` | UUID | 習慣ID |
| `currentStreak` | number | 現在のストリーク（`daily`/`specific_days`は日数、`weekly_count`は週数） |
| `longestStreak` | number | 最長ストリーク |
| `achievementRate` | number \| null | 期間内の達成率（0〜1）。対象日/対象週が期間内に0件のときは `null`（「対象なし」） |
| `heatmap` | array | 日ごとの `{ date, state }`。`state` は `done` / `missed` / `unrecorded` / `not_target` |

レスポンス例:
```json
[
  {
    "habitId": "uuid",
    "currentStreak": 5,
    "longestStreak": 21,
    "achievementRate": 0.75,
    "heatmap": [
      { "date": "2026-07-20", "state": "done" },
      { "date": "2026-07-21", "state": "not_target" },
      { "date": "2026-07-22", "state": "missed" }
    ]
  }
]
```

### エラー時

| ステータス | 条件 | レスポンス例 |
|---|---|---|
| 400 Bad Request | `from`/`to` 未指定・不正形式、または `from > to` | `{"error": "from/to の指定が不正です"}` |
| 500 Internal Server Error | DB障害等の予期せぬ障害 | — |

## 処理概要

1. Handler: クエリパラメータ `from`・`to`・`habitId`（任意）を取得・形式検証（`from <= to`）。
2. Service (`DashboardService.getSummary`):
   a. `habitId` が指定されていれば `HabitRepository.findById(habitId)` でその習慣のみ（`archived`
      問わず）を対象とする。未指定なら `HabitRepository.listActive()` でアクティブな習慣を取得。
   b. 習慣ごとに `CheckInRepository.listByHabitInRange(habitId, from, to)` でチェックインを一括取得
      （N+1回避のため期間指定で一括取得し、Domain層でメモリ集計）。
   c. Domain（`calcStreak`）で現在・最長ストリークを算出。
   d. Domain（`calcAchievementRate`）で達成率を算出（分母0のときは `null`）。
   e. ヒートマップ用に、期間内の各日を `isTargetDate` とチェックイン記録から `done` / `missed` /
      `unrecorded` / `not_target` に分類。
3. Handler: 習慣ごとの集約結果をリストとして返却。

## テスト観点

- 正常系: 対象外の日を挟んでもストリークが継続すること（baseline アルゴリズム設計のエッジケース）。
- 正常系: `weekly_count` 習慣の週単位ストリーク・達成率算出。
- 正常系: 期間内に対象日が0件のとき `achievementRate` が `null`（「対象なし」）になること。
- 正常系: 過去の記録を遡って修正した場合、ストリーク・達成率が再計算されること。
- 正常系: ヒートマップの4状態（`done`/`missed`/`unrecorded`/`not_target`）が正しく分類されること。
- 異常系: `from > to` で400。
- 異常系: `from`/`to` が不正形式で400。
