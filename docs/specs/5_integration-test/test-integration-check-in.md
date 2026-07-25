# 画面: 日付指定チェックイン 結合テスト仕様書

> 対象画面の詳細設計は [`screen-03-check-in.md`](../3_detail-design/screen/screen-03-check-in.md)。
> 使用するAPIの詳細設計は
> [`api-06-checkins-list.md`](../3_detail-design/api/api-06-checkins-list.md)・
> [`api-07-checkins-upsert.md`](../3_detail-design/api/api-07-checkins-upsert.md)。
> テスト方針全体は [`cross-cutting.md`](../_shared/cross-cutting.md)「テスト戦略」を正本とする。
> 本書は**日付指定チェックイン画面（CheckInPage、ダッシュボードの当日チェックインリストも含む）が
> 呼び出すAPI群を横断した結合テスト**（testcontainers-go + 実PostgreSQL必須）を、画面操作の流れに
> 沿ったシナリオ単位で列挙する。実DB不要のユニットテストは
> [`docs/specs/4_unit-test/`](../4_unit-test/) を参照。ブラウザ経由の真のE2E（Playwright）は
> `cross-cutting.md`「E2Eテスト」を参照（本書はAPI層までのシミュレーションに留める）。

## テスト対象

| 画面 | 使用API | DBテーブル |
|---|---|---|
| 日付指定チェックイン（CheckInPage） | `GET /check-ins?date=`（API-06）、`PUT /habits/{id}/check-ins/{date}`（API-07） | `habits`, `check_ins` |

## テストケース一覧

| No | シナリオ | 操作の流れ | 期待結果 | 完了 |
|---|---|---|---|:--:|
| 1 | 対象日の対象習慣一覧が実DBから正しく取得できる | 月水金習慣・毎日習慣・対象外の習慣を実DBに登録 → `GET /check-ins?date=2026-07-20`（月曜） | 対象2件のみ配列に含まれ、対象外は除外される（`listActive`+`isTargetDate`の組み合わせが実データで正しく動く） | [x] |
| 2 | 記録すると同じ日の取得結果に反映される | 対象習慣に `PUT .../check-ins/2026-07-20 {status:"done"}` → 同日で再度 `GET /check-ins?date=2026-07-20` | 当該習慣の `status` が `"done"` として返る | [x] |
| 3 | 同一 `(habit_id, date)` への連続PUTはDB上1行に収束する | 同じ `(habit_id, date)` へ `status="done"` → `status="not_done"` と2回 `PUT` → `check_ins` テーブルを直接確認 | 該当 `(habit_id, date)` の行が1件のみ存在し、`status` は最新の `"not_done"`（`check_ins_habit_date_unique` を競合ターゲットとした `ON CONFLICT` upsert の実DB確認） | [x] |
| 4 | 対象外の日への記録は422 | 月水金習慣の火曜日（例: `2026-07-21`）に `PUT` | `422`「その日はこの習慣の対象ではありません」 | [x] |
| 5 | 過去日の記録を遡って修正できる | 過去日に `done` で記録 → 同日を `not_done` に修正 → `GET /check-ins?date=` で確認 | 修正後の `status` が反映される（`updatedAt` のみ変化し、行は増えない） | [x] |
| 6 | 存在しない習慣への記録は404 | 未登録のUUIDへ `PUT` | `404`「対象の習慣が見つかりません」 | [x] |

## 備考

- ケース1・3はRepository層の実クエリ・実制約（`idx_check_ins_date`・`check_ins_habit_date_unique`）を
  検証するため、フェイクリポジトリでは代替できない。
- ケース2・4・5・6はユニットテストで検証済みのService層ロジック（対象日判定・422分岐・upsert呼び出し）
  が、実DBと組み合わさっても正しく動くことを確認する。
- 当日 `overdue` 判定（`reminderTime` 超過ハイライト）はサーバー時刻に依存するためユニットテスト
  （[`test-api-06-checkins-list.md`](../4_unit-test/test-api-06-checkins-list.md)）で検証済み。
  本書では扱わない。
