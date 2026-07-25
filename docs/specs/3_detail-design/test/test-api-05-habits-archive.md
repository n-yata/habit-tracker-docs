# API-05: 習慣アーカイブ 単体テスト仕様書

> 対象APIの詳細設計は [`api-05-habits-archive.md`](../api/api-05-habits-archive.md)。テスト方針全体は
> [`cross-cutting.md`](../../_shared/cross-cutting.md)「テスト戦略」を正本とする。本書はAPI-05の
> 具体的なテストケースを列挙する。

## テスト対象

| レイヤー | 対象 | テスト種別 |
|---|---|---|
| Service | `HabitService.deleteHabit`（存在確認） | ユニットテスト |
| Repository | `HabitRepository.archive` | 統合テスト |

## テストケース一覧

| No | 観点 | 前提・入力 | 期待結果 | 完了 |
|---|---|---|---|:--:|
| 1 | 正常系 | 存在する `id` をアーカイブ | `204`。アーカイブ後、API-01（一覧）の結果に含まれない | [x] |
| 2 | 正常系 | アーカイブ後 | API-03（詳細取得）で `archived=true` として取得可能（物理削除されていない） | [x] |
| 3 | 正常系 | アーカイブ対象に紐づく `check_ins` レコードが存在する状態でアーカイブ | アーカイブ後も `check_ins` レコードが削除されずに残る（論理削除の確認） | [ ] |
| 4 | 異常系 | 存在しない `id` | `404`「対象の習慣が見つかりません」 | [x] |
| 5 | 境界値 | 既に `archived=true` の `id` に再度 `DELETE` | `204`（冪等に成功する） | [x] |

## 備考

- ケース3はRepository層の統合テストとして、`habits` と `check_ins` を跨いだ整合性を確認する。
