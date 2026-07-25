# API-06: チェックイン取得 詳細設計書

> 基本情報（ID・メソッド・パス）の正本は
> [`functional-design.md`](../../../baseline/functional-design.md)「API一覧」。入出力の要約は
> [`api-design.md`](../../2_basic-design/api-design.md)。本書は本APIのバリデーション制約・処理概要・
> エラー詳細・テスト観点を記載する。

## 基本情報

| 項目 | 内容 |
|---|---|
| ID | API-06 |
| API名 | チェックイン取得 |
| メソッド / パス | `GET /check-ins?date=YYYY-MM-DD` |
| 概要 | 指定日が対象の習慣一覧と、それぞれの記録状態を返す |
| 関連画面 | ダッシュボード、日付指定チェックイン |
| 関連レイヤー | Handler → Service（`CheckInService.getCheckInsForDate`）→ Domain（`isTargetDate`）+ Repository（`HabitRepository.listActive` / `CheckInRepository.listByDate`） |

## リクエスト仕様

| 項目 | 位置 | 型 | 必須 | 制約 | 備考 |
|---|---|---|:--:|---|---|
| `date` | query | string | 必須 | `YYYY-MM-DD` 形式 | 対象日。省略・不正形式は400 |

## レスポンス仕様

### 成功時（200 OK）

`date` が対象日（`isTargetDate` が真）の習慣のみを含むリスト。

| フィールド | 型 | 説明 |
|---|---|---|
| `habit` | `Habit` | API-01 のレスポンス仕様と同一 |
| `status` | `"done"` \| `"not_done"` \| `null` | `null` は未記録 |
| `overdue` | boolean | `date` が当日かつ未完了かつ `reminderTime` をサーバー時刻で超過している場合のみ `true`。過去日は常に `false` |

レスポンス例:
```json
[
  {
    "habit": { "id": "uuid", "name": "ランニング", "...": "..." },
    "status": null,
    "overdue": true
  },
  {
    "habit": { "id": "uuid", "name": "読書", "...": "..." },
    "status": "done",
    "overdue": false
  }
]
```

### エラー時

| ステータス | 条件 | レスポンス例 |
|---|---|---|
| 400 Bad Request | `date` 未指定、または `YYYY-MM-DD` 形式でない | `{"error": "date は YYYY-MM-DD 形式で指定してください"}` |
| 500 Internal Server Error | DB障害等の予期せぬ障害 | — |

## 処理概要

1. Handler: クエリパラメータ `date` を取得・形式検証。
2. Service (`CheckInService.getCheckInsForDate`):
   a. `HabitRepository.listActive()` でアクティブな習慣を取得。
   b. 各習慣に対し Domain（`isTargetDate(habit, date)`）で `date` が対象日かを判定し、対象外は結果から除外。
   c. `CheckInRepository.listByDate(date)` で当日の記録を取得し、対象habitに紐付け。
   d. `date` が当日かつ未記録/未完了の場合のみ、`reminderTime` とサーバー時刻を比較して `overdue` を算出（過去日は常に `false`）。
3. Handler: 結果をリストとして返却。

## テスト観点

- 正常系: `daily` / `specific_days` / `weekly_count` それぞれの対象日判定（Domain の `isTargetDate` を参照）。
- 正常系: 対象外の習慣が結果に含まれないこと。
- 正常系: 記録済み（`done`/`not_done`）・未記録（`null`）の両方が正しく反映されること。
- 正常系: `overdue` が当日かつ `reminderTime` 超過時のみ `true` になること。過去日は常に `false`。
- 異常系: `date` 未指定・不正形式（`2026/07/25` 等）で400。
