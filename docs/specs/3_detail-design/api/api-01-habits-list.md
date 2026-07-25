# API-01: 習慣一覧取得 詳細設計書

> 基本情報（ID・メソッド・パス）の正本は
> [`functional-design.md`](../../../baseline/functional-design.md)「API一覧」。入出力の要約は
> [`api-design.md`](../../2_basic-design/api-design.md)。本書は本APIのバリデーション制約・処理概要・
> エラー詳細・テスト観点を記載する。

## 基本情報

| 項目 | 内容 |
|---|---|
| ID | API-01 |
| API名 | 習慣一覧取得 |
| メソッド / パス | `GET /habits` |
| 概要 | アクティブな習慣（`archived=false`）の一覧を返す |
| 関連画面 | ダッシュボード、習慣管理 |
| 関連レイヤー | Handler → Service（`HabitService.listHabits`）→ Repository（`HabitRepository.listActive`） |

## リクエスト仕様

パラメータなし。

## レスポンス仕様

### 成功時（200 OK）

`Habit[]`（`archived=false` のみ）。

| フィールド | 型 | 説明 |
|---|---|---|
| `id` | UUID | 習慣ID |
| `name` | string | 習慣名 |
| `category` | string \| null | カテゴリ |
| `recurrenceType` | `"daily"` \| `"weekly_count"` \| `"specific_days"` | 繰り返し種別 |
| `weeklyTargetCount` | number \| null | `weekly_count` 時のみ非null |
| `targetWeekdays` | number[] \| null | `specific_days` 時のみ非null（0=日〜6=土） |
| `reminderTime` | string \| null | `HH:MM` |
| `archived` | boolean | 常に `false` |
| `createdAt` / `updatedAt` | string (ISO8601) | 作成/更新日時 |

レスポンス例:
```json
[
  {
    "id": "uuid",
    "name": "ランニング",
    "category": "運動",
    "recurrenceType": "specific_days",
    "targetWeekdays": [1, 3, 5],
    "weeklyTargetCount": null,
    "reminderTime": "07:00",
    "archived": false,
    "createdAt": "2026-07-14T00:00:00Z",
    "updatedAt": "2026-07-14T00:00:00Z"
  }
]
```

### エラー時

| ステータス | 条件 |
|---|---|
| 500 Internal Server Error | DB障害等の予期せぬ障害 |

## 処理概要

1. Handler: リクエストを受理（パラメータなし）。
2. Service (`HabitService.listHabits`): Repository を呼び出すのみ（追加のドメインロジックなし）。
3. Repository (`HabitRepository.listActive`): `SELECT * FROM habits WHERE archived = false` 相当のクエリを実行。
4. Handler: 結果を `Habit[]` として整形して返却。

## テスト観点

- 正常系: 習慣が0件／1件／複数件のときの一覧取得。
- 正常系: `archived=true` の習慣が結果に含まれないこと。
- 異常系: DB接続エラー時に500を返すこと。
