# API-01: 習慣一覧取得 単体テスト仕様書

> 対象APIの詳細設計は [`api-01-habits-list.md`](../api/api-01-habits-list.md)。テスト方針全体は
> [`cross-cutting.md`](../../_shared/cross-cutting.md)「テスト戦略」を正本とする。本書はAPI-01の
> 具体的なテストケースを列挙する。

## テスト対象

| レイヤー | 対象 | テスト種別 |
|---|---|---|
| Repository | `HabitRepository.listActive` | 統合テスト（testcontainers-go + PostgreSQL） |
| Handler | `GET /habits` のレスポンス整形 | 統合テスト |

## テストケース一覧

| No | 観点 | 前提・入力 | 期待結果 | 完了 |
|---|---|---|---|:--:|
| 1 | 正常系 | `habits` テーブルが空 | `200`、空配列 `[]` | [ ] |
| 2 | 正常系 | `archived=false` の習慣が3件登録済み | `200`、3件すべてが配列に含まれる | [ ] |
| 3 | 正常系 | `archived=false` 2件 + `archived=true` 1件が混在 | `200`、`archived=false` の2件のみ返る（`archived=true` は除外） | [ ] |
| 4 | 正常系 | `recurrenceType` が `daily`/`weekly_count`/`specific_days` の習慣が混在 | 各習慣の `weeklyTargetCount`/`targetWeekdays` が種別に応じて正しく `null`/値を持つ | [ ] |
| 5 | 異常系 | DB接続不可（testcontainers停止等でシミュレート） | `500` | [x] |

## 備考

- ケース1〜4はRepository層の統合テスト（実DBに対するSELECT結果を検証）として実装する。
- ケース5はHandler層の異常系テストとして、Repositoryのエラーを500にマッピングする箇所を検証する。
