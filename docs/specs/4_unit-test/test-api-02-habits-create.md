# API-02: 習慣登録 単体テスト仕様書

> 対象APIの詳細設計は [`api-02-habits-create.md`](../3_detail-design/api/api-02-habits-create.md)。テスト方針全体は
> [`cross-cutting.md`](../_shared/cross-cutting.md)「テスト戦略」を正本とする。本書はAPI-02の
> **ユニットテスト**（実DB不要）のケースのみを列挙する。実PostgreSQLを要する結合テストのケースは
> 画面単位の [`test-integration-habits.md`](../5_integration-test/test-integration-habits.md)
> （習慣管理画面）を参照。

## テスト対象

| レイヤー | 対象 | テスト種別 |
|---|---|---|
| Service | `HabitService.createHabit`（バリデーション・繰り返しルール整合） | ユニットテスト（Go, testify） |

## テストケース一覧

| No | 観点 | 入力 | 期待結果 | 完了 |
|---|---|---|---|:--:|
| 1 | 正常系 | `recurrenceType="daily"`, `name="ランニング"` | `201`、`weeklyTargetCount=null`、`targetWeekdays=null` | [x] |
| 2 | 正常系 | `recurrenceType="weekly_count"`, `weeklyTargetCount=3` | `201`、`targetWeekdays=null` | [x] |
| 3 | 正常系 | `recurrenceType="specific_days"`, `targetWeekdays=[1,3,5]` | `201`、`weeklyTargetCount=null` | [x] |
| 4 | 正常系 | `category`・`reminderTime` を省略 | `201`、両方とも `null` | [x] |
| 5 | 境界値 | `name` が1文字 | `201` | [x] |
| 6 | 境界値 | `name` が100文字 | `201` | [x] |
| 7 | 異常系 | `name` が0文字（空文字） | `400`「name は1〜100文字で入力してください」 | [x] |
| 8 | 異常系 | `name` が101文字 | `400`「name は1〜100文字で入力してください」 | [x] |
| 9 | 境界値 | `recurrenceType="weekly_count"`, `weeklyTargetCount=1` | `201` | [x] |
| 10 | 境界値 | `recurrenceType="weekly_count"`, `weeklyTargetCount=7` | `201` | [x] |
| 11 | 異常系 | `recurrenceType="weekly_count"`, `weeklyTargetCount=0` | `400`「週の回数は1〜7で入力してください」 | [x] |
| 12 | 異常系 | `recurrenceType="weekly_count"`, `weeklyTargetCount=8` | `400`「週の回数は1〜7で入力してください」 | [x] |
| 13 | 異常系 | `recurrenceType="specific_days"`, `targetWeekdays=[]` | `400`「特定曜日ルールでは曜日を1つ以上選んでください」 | [x] |
| 14 | 異常系 | `recurrenceType="daily"` かつ `weeklyTargetCount=3` を指定 | `400`「繰り返し種別と入力項目が一致していません」 | [x] |
| 15 | 異常系 | `recurrenceType="daily"` かつ `targetWeekdays=[1]` を指定 | `400`「繰り返し種別と入力項目が一致していません」 | [x] |
| 16 | 異常系 | `recurrenceType="weekly_count"` かつ `weeklyTargetCount` 未指定 | `400`「週の回数は1〜7で入力してください」 | [x] |
| 17 | 異常系 | `recurrenceType="specific_days"` かつ `targetWeekdays` 未指定 | `400`「特定曜日ルールでは曜日を1つ以上選んでください」 | [x] |

## 備考

- ケース1〜17はService層の `createHabit` バリデーションロジックをユニットテストで網羅する
  （繰り返しルール整合表: baseline「データモデル」参照）。
- ケース18（DB障害時のエラー伝播）は
  [`test-integration-habits.md`](../5_integration-test/test-integration-habits.md) ケース8
  （習慣管理画面の結合テスト）を参照。Service層でのエラー伝播自体はフェイクRepositoryによる
  ユニットテストで検証済みだが、Handler/Repository境界を実DBで検証する結合テストは別途実施する。
