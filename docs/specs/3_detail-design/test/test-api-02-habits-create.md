# API-02: 習慣登録 単体テスト仕様書

> 対象APIの詳細設計は [`api-02-habits-create.md`](../api/api-02-habits-create.md)。テスト方針全体は
> [`cross-cutting.md`](../../_shared/cross-cutting.md)「テスト戦略」を正本とする。本書はAPI-02の
> 具体的なテストケースを列挙する。

## テスト対象

| レイヤー | 対象 | テスト種別 |
|---|---|---|
| Service | `HabitService.createHabit`（バリデーション・繰り返しルール整合） | ユニットテスト（Go, testify） |
| Repository | `HabitRepository.create` | 統合テスト |
| Handler | バリデーションエラーの400変換 | 統合テスト |

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
| 18 | 異常系 | DB障害（Repository層でエラー発生） | `500` | [x] |

## 備考

- ケース1〜17はService層の `createHabit` バリデーションロジックをユニットテストで網羅する
  （繰り返しルール整合表: baseline「データモデル」参照）。
- ケース18はHandler/Repository境界の統合テストとして実装する。
