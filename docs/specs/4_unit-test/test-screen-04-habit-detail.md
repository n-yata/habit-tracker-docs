# 画面: 習慣詳細 単体テスト仕様書

> 対象画面の詳細設計は [`screen-04-habit-detail.md`](../3_detail-design/screen/screen-04-habit-detail.md)。テスト方針
> 全体は [`cross-cutting.md`](../_shared/cross-cutting.md)「テスト戦略」を正本とする。本書は
> コンポーネント単位（Vitest + Testing Library）の具体的なテストケースを列挙する。

## テスト対象

| コンポーネント | テスト種別 |
|---|---|
| `HabitHeader` / `StreakSummary` | ユニットテスト（Vitest + Testing Library） |
| `HabitDetailPage`（データ結合ロジック） | ユニットテスト |

## テストケース一覧

| No | 観点 | 前提・操作 | 期待結果 | 完了 |
|---|---|---|---|:--:|
| 1 | 正常系 | 存在する `id` でページを開く | `HabitHeader` に習慣名・カテゴリ・ルール要約が表示される | [x] |
| 2 | 異常系 | API-03（詳細取得）が `404` を返す | 「対象の習慣が見つかりません」＋「習慣一覧に戻る」導線が表示される | [x] |
| 3 | 異常系 | API-03/API-08 のいずれかが `5xx` を返す | 画面共通のエラー表示＋再試行導線が表示される | [x] |
| 4 | 正常系 | `StreakSummary` に `currentStreak=5`, `longestStreak=21` を渡す | 「🔥 5日」「🏆 21日」が表示される | [x] |
| 5 | 正常系 | `StreakSummary` に `achievementRate=0.75` を渡す | 「75%」がリング表示される | [x] |
| 6 | 境界値 | `StreakSummary` に `achievementRate=null` を渡す | 「対象なし」と表示される（`0%` ではない） | [x] |
| 7 | 正常系 | `HabitDetailPage` がAPI-08の集約結果から `habitId` 一致のエントリを抽出 | 対象習慣以外のエントリが混在していても、正しく自分の習慣のデータのみ表示に使われる | [x] |

## 備考

- ケース7はダッシュボード集計API（API-08）が複数習慣分の結果を返す仕様のため、
  抽出ロジックの単体テストとして独立して検証する。
