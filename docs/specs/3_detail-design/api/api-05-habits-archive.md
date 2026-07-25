# API-05: 習慣アーカイブ 詳細設計書

> 基本情報（ID・メソッド・パス）の正本は
> [`functional-design.md`](../../../baseline/functional-design.md)「API一覧」。入出力の要約は
> [`api-design.md`](../../2_basic-design/api-design.md)。本書は本APIのバリデーション制約・処理概要・
> エラー詳細・テスト観点を記載する。

## 基本情報

| 項目 | 内容 |
|---|---|
| ID | API-05 |
| API名 | 習慣アーカイブ |
| メソッド / パス | `DELETE /habits/{id}` |
| 概要 | 習慣を論理削除する（`archived=true`）。物理削除は行わない |
| 関連画面 | 習慣管理 |
| 関連レイヤー | Handler → Service（`HabitService.deleteHabit`）→ Repository（`HabitRepository.archive`） |

## リクエスト仕様

| 項目 | 位置 | 型 | 必須 | 制約 | 備考 |
|---|---|---|:--:|---|---|
| `id` | path | UUID | 必須 | UUID形式 | 対象の習慣ID |

## レスポンス仕様

### 成功時（204 No Content）

ボディなし。

### エラー時

| ステータス | 条件 | レスポンス例 |
|---|---|---|
| 400 Bad Request | `id` がUUID形式でない | `{"error": "id の形式が不正です"}` |
| 404 Not Found | 対象の習慣が存在しない | `{"error": "対象の習慣が見つかりません"}` |
| 500 Internal Server Error | DB障害等の予期せぬ障害 | — |

## 処理概要

1. Handler: パスパラメータ `id` を取得・形式検証。
2. Service (`HabitService.deleteHabit`): `id` の存在確認（存在しなければ404）。
3. Repository (`HabitRepository.archive`): `UPDATE habits SET archived = true, updated_at = now() WHERE id = $1` 相当を実行。**物理削除（`DELETE FROM`）は行わない**（過去のチェックイン記録との整合を保つため）。
4. Handler: 204を返却。

## テスト観点

- 正常系: アーカイブ後、API-01（一覧）に含まれなくなること。
- 正常系: アーカイブ後も API-03（詳細取得）では取得可能であること（`archived=true`）。
- 正常系: アーカイブ後も関連する `check_ins` レコードが削除されないこと（論理削除の確認）。
- 異常系: 存在しない `id` で404。
- 異常系: 既にアーカイブ済みの `id` に再度リクエストした場合の挙動（冪等に204を返す想定）。
