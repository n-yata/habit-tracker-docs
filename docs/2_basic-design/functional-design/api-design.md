# API設計

> 機能設計書の一部。親: [`functional-design.md`](../functional-design.md)。
> REST / JSON。`openapi.yaml`（正本は backend リポジトリ）を契約の正本とし、**完全なスキーマ・型はそこで確定**する。
> 本ファイルは **API一覧（カタログ）** と主要な入出力の概要を管理する。データ型は [`data-model.md`](./data-model.md)、
> 画面との紐付けは [`component-design.md`](./component-design.md) の「モジュール構成図」を参照。
> 第一マイルストーンは単一ユーザー前提のため認証はなし（スコープ外）。

## API一覧

API名・ID は本一覧を正本とする（他資料からは ID で参照する）。

| ID | API名 | メソッド | パス | 概要 |
|---|---|---|---|---|
| API-01 | 習慣一覧取得 | GET | `/habits` | アクティブな習慣の一覧 |
| API-02 | 習慣登録 | POST | `/habits` | 習慣を新規作成 |
| API-03 | 習慣詳細取得 | GET | `/habits/{id}` | 習慣1件の詳細 |
| API-04 | 習慣更新 | PUT | `/habits/{id}` | 習慣を編集 |
| API-05 | 習慣アーカイブ | DELETE | `/habits/{id}` | 習慣を論理削除（`archived=true`） |
| API-06 | チェックイン取得 | GET | `/check-ins?date=YYYY-MM-DD` | 指定日の対象習慣＋記録状態 |
| API-07 | チェックイン記録 | PUT | `/habits/{id}/check-ins/{date}` | 指定日の完了/未完了を記録・修正（upsert） |
| API-08 | ダッシュボード集計取得 | GET | `/dashboard?from=..&to=..` | ストリーク・達成率・ヒートマップの集約 |

## 各APIの入出力（概要）

完全なスキーマは `openapi.yaml`。ここでは主要な入力・出力を示す（型は [`data-model.md`](./data-model.md) 準拠）。

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
| API-06 | クエリ `date`（`YYYY-MM-DD`、必須） | その日が対象の習慣ごとに `{ habit, status: 'done'\|'not_done'\|null, overdue }` のリスト | 対象日判定は [`domain-logic.md`](./domain-logic.md) |
| API-07 | パス `id`・`date` ＋ 本文 `{ status: 'done' \| 'not_done' }` | 記録された `CheckIn` | `(habit_id, date)` で upsert。非対象日への記録は拒否（コードは詳細設計で確定） |

### 集計系

| ID | 入力 | 出力 | 備考 |
|---|---|---|---|
| API-08 | クエリ `from`, `to`（期間） | 習慣ごとの `{ currentStreak, longestStreak, achievementRate, heatmap[] }` 集約 | 算出ロジックは [`domain-logic.md`](./domain-logic.md) |

## エラーレスポンス

- 400 Bad Request: バリデーション違反（name 長さ・N の範囲・曜日未指定・ルールと付随項目の不整合）
- 404 Not Found: 対象 habit が存在しない（API-03/04/05/07）
- 409 Conflict: （必要に応じ）不正な状態遷移
- 422/400（詳細設計で確定）: 非対象日へのチェックイン記録リクエスト（API-07）
- 500 Internal Server Error: 予期せぬ障害

エラー分類と表示メッセージは [`cross-cutting.md`](./cross-cutting.md) の「エラーハンドリング」を参照。

## 詳細設計への申し送り
- 非対象日への記録リクエストの扱い（拒否コード 422 か 400 か）は詳細設計で確定する。
- ページング・フィルタ等の拡張は必要になった時点で `openapi.yaml` に追加し、本一覧に ID を採番して追記する。
- API名・ID の採番は本一覧を正本とし、追加時は連番（API-09…）で付与する。
