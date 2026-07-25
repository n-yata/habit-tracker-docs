# API-05: 習慣アーカイブ 単体テスト仕様書

> 対象APIの詳細設計は [`api-05-habits-archive.md`](../3_detail-design/api/api-05-habits-archive.md)。テスト方針全体は
> [`cross-cutting.md`](../_shared/cross-cutting.md)「テスト戦略」を正本とする。本書はAPI-05の
> **ユニットテスト**（実DB不要）のケースのみを列挙する。実PostgreSQLを要する結合テストのケースは
> 画面単位の [`test-integration-habits.md`](../5_integration-test/test-integration-habits.md)
> （習慣管理画面）を参照。

## テスト対象

| レイヤー | 対象 | テスト種別 |
|---|---|---|
| Service | `HabitService.deleteHabit`（存在確認） | ユニットテスト |

## テストケース一覧

| No | 観点 | 前提・入力 | 期待結果 | 完了 |
|---|---|---|---|:--:|
| 1 | 正常系 | 存在する `id` をアーカイブ | `204`。アーカイブ後、`ListHabits` の結果に含まれない | [x] |
| 2 | 正常系 | アーカイブ後 | `GetHabit` で `archived=true` として取得可能（物理削除されていない） | [x] |
| 4 | 異常系 | 存在しない `id` | `404`「対象の習慣が見つかりません」 | [x] |
| 5 | 境界値 | 既に `archived=true` の `id` に再度 `DELETE` | `204`（冪等に成功する） | [x] |

## 備考

- ケース番号は元の一覧の番号を維持している。ケース3（アーカイブ後もcheck_insが残る、実DB確認）は
  [`test-integration-habits.md`](../5_integration-test/test-integration-habits.md) ケース6を参照。
- ケース1・2はフェイクRepositoryを用いてServiceのオーケストレーション（archive呼び出し・
  取得可能性）を検証する。実際のSQL `WHERE archived = false` フィルタの正しさは
  [`test-integration-habits.md`](../5_integration-test/test-integration-habits.md) ケース2で検証する。
