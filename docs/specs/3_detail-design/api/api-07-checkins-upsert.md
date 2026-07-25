# API-07: チェックイン記録 詳細設計書

> 基本情報（ID・メソッド・パス）の正本は
> [`functional-design.md`](../../../baseline/functional-design.md)「API一覧」。入出力の要約は
> [`api-design.md`](../../2_basic-design/api-design.md)。本書は本APIのバリデーション制約・処理概要・
> エラー詳細・テスト観点を記載する。

## 基本情報

| 項目 | 内容 |
|---|---|
| ID | API-07 |
| API名 | チェックイン記録 |
| メソッド / パス | `PUT /habits/{id}/check-ins/{date}` |
| 概要 | 指定日の完了/未完了を記録・修正する（upsert） |
| 関連画面 | ダッシュボード、日付指定チェックイン |
| 関連レイヤー | Handler → Service（`CheckInService.recordCheckIn`）→ Domain（`isTargetDate`）+ Repository（`CheckInRepository.upsert`） |

## リクエスト仕様

| 項目 | 位置 | 型 | 必須 | 制約 | 備考 |
|---|---|---|:--:|---|---|
| `id` | path | UUID | 必須 | UUID形式 | 習慣ID |
| `date` | path | string | 必須 | `YYYY-MM-DD` 形式 | 対象日 |
| `status` | body | string | 必須 | `"done"` \| `"not_done"` | 記録する状態 |

リクエスト例:
```json
{ "status": "done" }
```

## レスポンス仕様

### 成功時（200 OK）

記録された `CheckIn`。

| フィールド | 型 | 説明 |
|---|---|---|
| `id` | UUID | チェックインID |
| `habitId` | UUID | 習慣ID |
| `date` | string | 対象日 |
| `status` | `"done"` \| `"not_done"` | 記録された状態 |
| `createdAt` / `updatedAt` | string (ISO8601) | 作成/更新日時（初回はcreatedAt=updatedAt、更新時はupdatedAtのみ変化） |

### エラー時

| ステータス | 条件 | レスポンス例 |
|---|---|---|
| 400 Bad Request | `status` が `done`/`not_done` 以外、`date` が不正形式 | `{"error": "status は done または not_done を指定してください"}` |
| 404 Not Found | 対象の習慣が存在しない | `{"error": "対象の習慣が見つかりません"}` |
| 422 Unprocessable Entity | `date` がその習慣の対象日でない | `{"error": "その日はこの習慣の対象ではありません"}` |
| 500 Internal Server Error | DB障害等の予期せぬ障害 | — |

## 処理概要

1. Handler: パスパラメータ `id`・`date` とリクエストボディ `status` を取得・形式検証。
2. Service (`CheckInService.recordCheckIn`):
   a. `HabitRepository.findById(id)` で習慣の存在確認（なければ404）。
   b. Domain（`isTargetDate(habit, date)`）で `date` が対象日かを判定。対象外なら **422** を返す
      （構文上は正しいがビジネスルール上処理不可のため）。
   c. `CheckInRepository.upsert({habitId, date, status})` を呼ぶ。`(habit_id, date)` のUNIQUE制約
      （`check_ins_habit_date_unique`）を競合ターゲットとした upsert（既存レコードがあれば `status` と
      `updated_at` のみ更新）。
3. Handler: 200で記録された `CheckIn` を返却。

## テスト観点

- 正常系: 未記録の対象日への初回記録（`done`/`not_done` それぞれ）。
- 正常系: 既存記録の修正（`done`→`not_done` の遡り修正含む）。
- 正常系: 修正後、API-08（ダッシュボード集計）のストリーク・達成率が再計算されること。
- 異常系: 存在しない `id` で404。
- 異常系: 対象外の日（例: 月水金習慣の火曜日）への記録で422。
- 異常系: `status` が不正な値（例: `"maybe"`）で400。
- 異常系: 同一 `(habit_id, date)` への連続リクエストが正しく upsert されること（重複レコードが作られない）。
