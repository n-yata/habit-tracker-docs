# API-04: 習慣更新 単体テスト仕様書

> 対象APIの詳細設計は [`api-04-habits-update.md`](../api/api-04-habits-update.md)。テスト方針全体は
> [`cross-cutting.md`](../../_shared/cross-cutting.md)「テスト戦略」を正本とする。本書はAPI-04の
> 具体的なテストケースを列挙する。

## テスト対象

| レイヤー | 対象 | テスト種別 |
|---|---|---|
| Service | `HabitService.updateHabit`（存在確認・バリデーション） | ユニットテスト |
| Repository | `HabitRepository.update` | 統合テスト |

## テストケース一覧

| No | 観点 | 前提・入力 | 期待結果 | 完了 |
|---|---|---|---|:--:|
| 1 | 正常系 | 既存 `daily` 習慣を `weekly_count`（`weeklyTargetCount=3`）へ変更 | `200`、`recurrenceType="weekly_count"`、`targetWeekdays=null` に置き換わる | [ ] |
| 2 | 正常系 | 既存 `weekly_count` 習慣を `specific_days`（`targetWeekdays=[0,6]`）へ変更 | `200`、`weeklyTargetCount=null` に置き換わる | [ ] |
| 3 | 正常系 | 更新実行 | `updatedAt` が更新前より新しい値になる。`createdAt` は不変 | [ ] |
| 4 | 異常系 | 存在しない `id` | `404`「対象の習慣が見つかりません」 | [ ] |
| 5〜17 | 異常系 | API-02（習慣登録）のテストケース7〜17と同一のバリデーション違反パターン | 同一のエラーメッセージで `400` | [ ] |

## 備考

- ケース5〜17は [`test-api-02-habits-create.md`](./test-api-02-habits-create.md) のケース7〜17を
  「更新」コンテキストで再実行する（バリデーションロジックは共通）。重複記載を避けるため参照のみとする。
