# API-03: 習慣詳細取得 単体テスト仕様書

> 対象APIの詳細設計は [`api-03-habits-get.md`](../3_detail-design/api/api-03-habits-get.md)。テスト方針全体は
> [`cross-cutting.md`](../_shared/cross-cutting.md)「テスト戦略」を正本とする。本書はAPI-03の
> **ユニットテスト**（実DB不要）のケースのみを列挙する。実PostgreSQLを要する結合テストのケースは
> 画面単位の [`test-integration-habits.md`](../5_integration-test/test-integration-habits.md)
> （習慣管理画面）・[`test-integration-habit-detail.md`](../5_integration-test/test-integration-habit-detail.md)
> （習慣詳細画面）を参照。

## テスト対象

| レイヤー | 対象 | テスト種別 |
|---|---|---|
| Handler | パスパラメータ検証（UUID形式）・404変換 | ユニットテスト（フェイクServiceを用いたhttptest） |

## テストケース一覧

| No | 観点 | 前提・入力 | 期待結果 | 完了 |
|---|---|---|---|:--:|
| 3 | 異常系 | UUID形式は正しいが未登録の `id`（Serviceが未検出エラーを返す） | `404`「対象の習慣が見つかりません」 | [x] |
| 4 | 異常系 | UUID形式でない `id`（例: `"abc"`） | `400`「id の形式が不正です」 | [x] |

## 備考

- ケース番号は元の一覧の番号を維持している。ケース1〜2（実データでの archived=false/true 取得）は
  [`test-integration-habits.md`](../5_integration-test/test-integration-habits.md) ケース5を参照
  （画面単位のシナリオに再編されている）。
- ケース3はHandler層の404変換を、フェイクServiceが `ErrHabitNotFound` を返すケースとして検証する
  （実際の「未登録」判定自体はRepository/DBの責務）。
