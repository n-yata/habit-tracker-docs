# API-04: 習慣更新 詳細設計書

> 基本情報（ID・メソッド・パス）の正本は
> [`functional-design.md`](../../../baseline/functional-design.md)「API一覧」。入出力の要約は
> [`api-design.md`](../../2_basic-design/api-design.md)。本書は本APIのバリデーション制約・処理概要・
> エラー詳細・テスト観点を記載する。

## 基本情報

| 項目 | 内容 |
|---|---|
| ID | API-04 |
| API名 | 習慣更新 |
| メソッド / パス | `PUT /habits/{id}` |
| 概要 | 習慣を編集する（全項目置き換え） |
| 関連画面 | 習慣管理 |
| 関連レイヤー | Handler → Service（`HabitService.updateHabit`）→ Repository（`HabitRepository.update`） |

## リクエスト仕様

| 項目 | 位置 | 型 | 必須 | 制約 | 備考 |
|---|---|---|:--:|---|---|
| `id` | path | UUID | 必須 | UUID形式 | 対象の習慣ID |
| `name` | body | string | 必須 | 1〜100文字 | API-02 と同一制約 |
| `category` | body | string | 任意 | 100文字以内 | 同上 |
| `recurrenceType` | body | string | 必須 | `daily` \| `weekly_count` \| `specific_days` | 同上 |
| `weeklyTargetCount` | body | number | 条件付き必須 | 1〜7 | API-02 と同一の整合ルール |
| `targetWeekdays` | body | number[] | 条件付き必須 | 1要素以上、各0〜6 | API-02 と同一の整合ルール |
| `reminderTime` | body | string | 任意 | `HH:MM` 形式 | 同上 |

バリデーション・繰り返しルール整合は API-02（習慣登録）と同一。本APIは全項目を置き換える
（部分更新ではない）。

## レスポンス仕様

### 成功時（200 OK）

更新後の `Habit`（フィールドは API-01 のレスポンス仕様と同一。`updatedAt` が更新される）。

### エラー時

| ステータス | 条件 | レスポンス例 |
|---|---|---|
| 400 Bad Request | バリデーション違反（API-02と同一の項目） | `{"error": "..."}` |
| 404 Not Found | 対象の習慣が存在しない | `{"error": "対象の習慣が見つかりません"}` |
| 500 Internal Server Error | DB障害等の予期せぬ障害 | — |

## 処理概要

1. Handler: パスパラメータ `id` とリクエストボディを取得。
2. Service (`HabitService.updateHabit`):
   a. `id` の存在確認（存在しなければ404）。
   b. API-02 と同一のバリデーション（長さ・値域・繰り返しルール整合）。
   c. Repository に更新を依頼。
3. Repository (`HabitRepository.update`): `UPDATE habits SET ..., updated_at = now() WHERE id = $1` 相当を実行。
4. Handler: 200で更新後の `Habit` を返却。

## テスト観点

- 正常系: 各繰り返し種別への切り替え（`daily`→`weekly_count` 等）で付随項目が正しく置き換わること。
- 正常系: `updatedAt` が更新されること。
- 異常系: 存在しない `id` で404。
- 異常系: API-02 と同一のバリデーションエラー全パターン。
