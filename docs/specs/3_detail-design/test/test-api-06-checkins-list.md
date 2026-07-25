# API-06: チェックイン取得 単体テスト仕様書

> 対象APIの詳細設計は [`api-06-checkins-list.md`](../api/api-06-checkins-list.md)。テスト方針全体は
> [`cross-cutting.md`](../../_shared/cross-cutting.md)「テスト戦略」を正本とする。本書はAPI-06の
> 具体的なテストケース、および本APIが依存する Domain層 `isTargetDate` のテストケースを列挙する
> （`isTargetDate` は baseline「アルゴリズム設計」のアルゴリズム1）。

## テスト対象

| レイヤー | 対象 | テスト種別 |
|---|---|---|
| Domain | `isTargetDate(habit, date)` | ユニットテスト（Go, testify）— 主眼 |
| Service | `CheckInService.getCheckInsForDate`（対象日フィルタ・overdue算出） | ユニットテスト |
| Repository | `CheckInRepository.listByDate` | 統合テスト |

## テストケース一覧: Domain `isTargetDate`

| No | 観点 | 入力 | 期待結果 | 完了 |
|---|---|---|---|:--:|
| 1 | 正常系 | `recurrenceType="daily"`、任意の日付 | `true`（常に対象） | [x] |
| 2 | 正常系 | `recurrenceType="specific_days"`, `targetWeekdays=[1,3,5]`、`date`=月曜(1) | `true` | [x] |
| 3 | 正常系 | 同上、`date`=火曜(2) | `false` | [x] |
| 4 | 正常系 | `recurrenceType="weekly_count"`、任意の日付 | `true`（週単位で候補日として扱う） | [x] |

## テストケース一覧: API-06（`GET /check-ins?date=`）

| No | 観点 | 前提・入力 | 期待結果 | 完了 |
|---|---|---|---|:--:|
| 5 | 正常系 | `date`=当日。対象習慣2件（うち1件対象外の習慣も別途登録） | `200`、対象2件のみ配列に含まれる（対象外は除外） | [x] |
| 6 | 正常系 | 対象習慣のうち1件が記録済み（`done`）、1件が未記録 | `status` がそれぞれ `"done"`／`null` | [x] |
| 7 | 正常系 | `date`=当日、対象習慣が未完了かつ `reminderTime` をサーバー時刻が超過 | `overdue=true` | [x] |
| 8 | 正常系 | `date`=当日、対象習慣が完了済み | `reminderTime` を超過していても `overdue=false` | [x] |
| 9 | 正常系 | `date`=過去日 | `reminderTime` 超過条件に関わらず `overdue=false` | [x] |
| 10 | 異常系 | `date` 未指定 | `400`「date は YYYY-MM-DD 形式で指定してください」 | [x] |
| 11 | 異常系 | `date="2026/07/25"`（不正形式） | `400`「date は YYYY-MM-DD 形式で指定してください」 | [x] |

## 備考

- ケース1〜4はDomain層の純粋関数テストとして最優先で実装する（本アプリの中核ロジック）。
- ケース5〜9はService層でDomainの判定結果とRepositoryの取得結果を組み合わせるロジックを検証する。
