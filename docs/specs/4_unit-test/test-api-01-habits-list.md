# API-01: 習慣一覧取得 単体テスト仕様書

> 対象APIの詳細設計は [`api-01-habits-list.md`](../3_detail-design/api/api-01-habits-list.md)。テスト方針全体は
> [`cross-cutting.md`](../_shared/cross-cutting.md)「テスト戦略」を正本とする。本書はAPI-01の
> **ユニットテスト**（実DB不要）のケースのみを列挙する。実PostgreSQLを要する結合テストのケースは
> 画面単位の [`test-integration-habits.md`](../5_integration-test/test-integration-habits.md)
> （習慣管理画面）を参照。

## テスト対象

| レイヤー | 対象 | テスト種別 |
|---|---|---|
| Handler | `GET /habits` のエラーマッピング（Repositoryのエラーを500に変換） | ユニットテスト（フェイクServiceを用いたhttptest） |

## テストケース一覧

| No | 観点 | 前提・入力 | 期待結果 | 完了 |
|---|---|---|---|:--:|
| 5 | 異常系 | DB接続不可（Repository/Serviceがエラーを返す） | `500` | [x] |

## 備考

- ケース番号は元の一覧（Repository層の統合テストを含む版）の番号を維持している。ケース1〜4
  （Repository層の実データ検証）は
  [`test-integration-habits.md`](../5_integration-test/test-integration-habits.md) のケース1〜3を参照
  （画面単位のシナリオに再編されている）。
- ケース5はHandler層の異常系テストとして、Serviceが返すエラーを500にマッピングする箇所を
  フェイクServiceで検証する（実DB不要）。
