# API-03: 習慣詳細取得 詳細設計書

> 基本情報（ID・メソッド・パス）の正本は
> [`functional-design.md`](../../../baseline/functional-design.md)「API一覧」。入出力の要約は
> [`api-design.md`](../../2_basic-design/api-design.md)。本書は本APIのバリデーション制約・処理概要・
> エラー詳細・テスト観点を記載する。

## 基本情報

| 項目 | 内容 |
|---|---|
| ID | API-03 |
| API名 | 習慣詳細取得 |
| メソッド / パス | `GET /habits/{id}` |
| 概要 | 習慣1件の詳細を返す |
| 関連画面 | 習慣管理（編集フォーム初期値）、習慣詳細 |
| 関連レイヤー | Handler → Service（`HabitService` 相当、内部で Repository 直接参照） → Repository（`HabitRepository.findById`） |

## リクエスト仕様

| 項目 | 位置 | 型 | 必須 | 制約 | 備考 |
|---|---|---|:--:|---|---|
| `id` | path | UUID | 必須 | UUID形式 | 習慣ID |

## レスポンス仕様

### 成功時（200 OK）

`Habit`（フィールドは API-01 のレスポンス仕様と同一。`archived=true` の習慣も取得可能＝アーカイブ後の参照用途を許容）。

### エラー時

| ステータス | 条件 | レスポンス例 |
|---|---|---|
| 400 Bad Request | `id` がUUID形式でない | `{"error": "id の形式が不正です"}` |
| 404 Not Found | 対象の習慣が存在しない | `{"error": "対象の習慣が見つかりません"}` |
| 500 Internal Server Error | DB障害等の予期せぬ障害 | — |

## 処理概要

1. Handler: パスパラメータ `id` を取得・形式検証。
2. Repository (`HabitRepository.findById`): `SELECT * FROM habits WHERE id = $1` 相当のクエリを実行。
3. Handler: 該当行があれば200で返却、なければ404を返す。

## テスト観点

- 正常系: 存在する `id` を指定して詳細を取得。
- 正常系: `archived=true` の習慣も取得できること。
- 異常系: 存在しない `id`（UUID形式は正しいが未登録）で404。
- 異常系: UUID形式でない `id` で400。
