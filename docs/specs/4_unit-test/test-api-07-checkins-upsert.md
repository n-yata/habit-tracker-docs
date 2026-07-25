# API-07: チェックイン記録 単体テスト仕様書

> 対象APIの詳細設計は [`api-07-checkins-upsert.md`](../3_detail-design/api/api-07-checkins-upsert.md)。テスト方針全体は
> [`cross-cutting.md`](../_shared/cross-cutting.md)「テスト戦略」を正本とする。本書はAPI-07の
> **ユニットテスト**（実DB不要）のケースのみを列挙する。実PostgreSQLを要する結合テストのケースは
> 画面単位の [`test-integration-check-in.md`](../5_integration-test/test-integration-check-in.md)
> （日付指定チェックイン画面）を参照。

## テスト対象

| レイヤー | 対象 | テスト種別 |
|---|---|---|
| Service | `CheckInService.recordCheckIn`（存在確認・対象日判定・422分岐） | ユニットテスト |

## テストケース一覧

| No | 観点 | 前提・入力 | 期待結果 | 完了 |
|---|---|---|---|:--:|
| 1 | 正常系 | 未記録の対象日に `status="done"` で記録 | `200`、新規 `CheckIn` が作成される | [x] |
| 2 | 正常系 | 既存記録（`done`）を `status="not_done"` で修正 | `200`、既存レコードの `status` と `updatedAt` のみ更新（新規行が増えない） | [x] |
| 3 | 異常系 | 存在しない `id` | `404`「対象の習慣が見つかりません」 | [x] |
| 4 | 異常系 | 月水金習慣（`specific_days`, `targetWeekdays=[1,3,5]`）の火曜日に記録 | `422`「その日はこの習慣の対象ではありません」 | [x] |
| 5 | 異常系 | `status="maybe"`（不正な値） | `400`「status は done または not_done を指定してください」 | [x] |
| 6 | 異常系 | `date` が `YYYY-MM-DD` 形式でない | `400` | [x] |

## 備考

- ケース番号は元の一覧の番号を維持している。ケース7（実DBでのUNIQUE制約upsert確認）は
  [`test-integration-check-in.md`](../5_integration-test/test-integration-check-in.md) ケース3を参照。
- ケース1・2はフェイクRepositoryを用いてServiceのupsert呼び出しロジックを検証する
  （実際の `(habit_id, date)` UNIQUE制約による衝突解決はRepository/DBの責務）。
- ケース5・6はHandler層（JSONデコード・oapi-codegenのパラメータバインド）で検証する。
