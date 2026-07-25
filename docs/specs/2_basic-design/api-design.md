# API設計（入出力詳細）

> 機能設計書の一部。API名・ID・メソッド・パスの正本は
> [`functional-design.md`](../../../baseline/functional-design.md)「API一覧」。本ファイルは各APIの
> 入出力詳細・リクエスト/レスポンス例・エラーレスポンスのみを置く。
> REST / JSON。`openapi.yaml`（正本は backend リポジトリ）を契約の正本とし、**完全なスキーマ・型はそこで確定**する。
> データ型は baseline の「データモデル」、画面との紐付けは baseline の「モジュール構成図」を参照。
> 第一マイルストーンは単一ユーザー前提のため認証はなし（スコープ外）。

## 各APIの入出力（概要）

完全なスキーマは `openapi.yaml`。ここでは主要な入力・出力を示す（型は baseline の「データモデル」準拠）。

### 習慣（Habit）系

| ID | 入力 | 出力 | 備考 |
|---|---|---|---|
| API-01 | なし | `Habit[]` | `archived=false` のみ返す |
| API-02 | `name`（必須）, `category?`, `recurrenceType`, `weeklyTargetCount?` / `targetWeekdays?`（種別に応じ）, `reminderTime?` | 201: 生成された `Habit` | バリデーションは繰り返しルール整合を含む |
| API-03 | パス `id` | `Habit` | なければ 404 |
| API-04 | パス `id` ＋ API-02 と同じ本文 | 更新後の `Habit` | なければ 404 |
| API-05 | パス `id` | 204 No Content | 物理削除せず `archived=true` |

**例: API-02 習慣登録** `POST /habits`

リクエスト:
```json
{
  "name": "ランニング",
  "category": "運動",
  "recurrenceType": "specific_days",
  "targetWeekdays": [1, 3, 5],
  "reminderTime": "07:00"
}
```

レスポンス (201):
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

### チェックイン（CheckIn）系

| ID | 入力 | 出力 | 備考 |
|---|---|---|---|
| API-06 | クエリ `date`（`YYYY-MM-DD`、必須） | その日が対象の習慣ごとに `{ habit, status: 'done'\|'not_done'\|null, overdue }` のリスト | 対象日判定は baseline の「アルゴリズム設計（ドメインロジック）」 |
| API-07 | パス `id`・`date` ＋ 本文 `{ status: 'done' \| 'not_done' }` | 記録された `CheckIn` | `(habit_id, date)` で upsert。非対象日への記録は **422 Unprocessable Entity** で拒否 |

### 集計系

| ID | 入力 | 出力 | 備考 |
|---|---|---|---|
| API-08 | クエリ `from`, `to`（期間） | 習慣ごとの `{ currentStreak, longestStreak, achievementRate, heatmap[] }` 集約 | 算出ロジックは baseline の「アルゴリズム設計（ドメインロジック）」 |

## エラーレスポンス

- 400 Bad Request: バリデーション違反（name 長さ・N の範囲・曜日未指定・ルールと付随項目の不整合）
- 404 Not Found: 対象 habit が存在しない（API-03/04/05/07）
- 409 Conflict: （必要に応じ）不正な状態遷移
- 422 Unprocessable Entity: 非対象日へのチェックイン記録リクエスト（API-07）
- 500 Internal Server Error: 予期せぬ障害

エラー分類と表示メッセージは [`cross-cutting.md`](../../_shared/cross-cutting.md) の「エラーハンドリング」を参照。

## 詳細設計への申し送り
- ページング・フィルタ等の拡張は必要になった時点で `openapi.yaml` に追加し、
  [`functional-design.md`](../../../baseline/functional-design.md)「API一覧」に ID を採番して追記する。
