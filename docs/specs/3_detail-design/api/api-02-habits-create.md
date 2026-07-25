# API-02: 習慣登録 詳細設計書

> 基本情報（ID・メソッド・パス）の正本は
> [`functional-design.md`](../../../baseline/functional-design.md)「API一覧」。入出力の要約は
> [`api-design.md`](../../2_basic-design/api-design.md)。本書は本APIのバリデーション制約・処理概要・
> エラー詳細・テスト観点を記載する。

## 基本情報

| 項目 | 内容 |
|---|---|
| ID | API-02 |
| API名 | 習慣登録 |
| メソッド / パス | `POST /habits` |
| 概要 | 習慣を新規作成する |
| 関連画面 | 習慣管理 |
| 関連レイヤー | Handler → Service（`HabitService.createHabit`）→ Repository（`HabitRepository.create`） |

## リクエスト仕様

| 項目 | 位置 | 型 | 必須 | 制約 | 備考 |
|---|---|---|:--:|---|---|
| `name` | body | string | 必須 | 1〜100文字（`habits_name_len`） | 習慣名 |
| `category` | body | string | 任意 | 100文字以内 | カテゴリ |
| `recurrenceType` | body | string | 必須 | `daily` \| `weekly_count` \| `specific_days` | 繰り返し種別 |
| `weeklyTargetCount` | body | number | 条件付き必須 | 1〜7 | `recurrenceType=weekly_count` のときのみ必須。それ以外は指定不可（指定時は400） |
| `targetWeekdays` | body | number[] | 条件付き必須 | 1要素以上、各要素0〜6 | `recurrenceType=specific_days` のときのみ必須。それ以外は指定不可（指定時は400） |
| `reminderTime` | body | string | 任意 | `HH:MM` 形式 | 保持のみ（実配信なし） |

**繰り返しルール整合**（`habits_recurrence_consistency` 相当。baseline データモデル参照）:

| `recurrenceType` | `weeklyTargetCount` | `targetWeekdays` |
|---|---|---|
| `daily` | 指定不可（null） | 指定不可（null） |
| `weekly_count` | 必須・1〜7 | 指定不可（null） |
| `specific_days` | 指定不可（null） | 必須・1要素以上、各0〜6 |

リクエスト例:
```json
{
  "name": "ランニング",
  "category": "運動",
  "recurrenceType": "specific_days",
  "targetWeekdays": [1, 3, 5],
  "reminderTime": "07:00"
}
```

## レスポンス仕様

### 成功時（201 Created）

生成された `Habit`（フィールドは API-01 のレスポンス仕様と同一）。

```json
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
```

### エラー時

| ステータス | 条件 | レスポンス例 |
|---|---|---|
| 400 Bad Request | `name` 長さ違反 | `{"error": "name は1〜100文字で入力してください"}` |
| 400 Bad Request | `weeklyTargetCount` 範囲外（1〜7外） | `{"error": "週の回数は1〜7で入力してください"}` |
| 400 Bad Request | `targetWeekdays` 未指定 or 要素0 | `{"error": "特定曜日ルールでは曜日を1つ以上選んでください"}` |
| 400 Bad Request | 繰り返しルールと付随項目の不整合 | `{"error": "繰り返し種別と入力項目が一致していません"}` |
| 500 Internal Server Error | DB障害等の予期せぬ障害 | — |

## 処理概要

1. Handler: リクエストボディを契約の型にデコード。
2. Service (`HabitService.createHabit`):
   a. `name`・`category` の長さバリデーション。
   b. `recurrenceType` の値域チェック。
   c. 繰り返しルール整合チェック（上表）。
   d. バリデーション通過後、Repository に永続化を依頼。
3. Repository (`HabitRepository.create`): `INSERT INTO habits (...)` を実行し、生成された行を返す。
4. Handler: 201 で生成された `Habit` を返却。バリデーションエラーは400・フィールド単位の理由で返す。

## テスト観点

- 正常系: `daily` / `weekly_count` / `specific_days` それぞれの最小構成での登録。
- 正常系: `category` / `reminderTime` 省略時のデフォルト（null）確認。
- 異常系: `name` が0文字・101文字。
- 異常系: `weeklyTargetCount` が0・8（範囲外）。
- 異常系: `specific_days` で `targetWeekdays` が空配列。
- 異常系: `recurrenceType=daily` なのに `weeklyTargetCount` や `targetWeekdays` を指定。
- 異常系: DB障害時に500を返すこと。
