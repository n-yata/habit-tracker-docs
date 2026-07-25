# API-08: ダッシュボード集計取得 単体テスト仕様書

> 対象APIの詳細設計は [`api-08-dashboard-summary.md`](../api/api-08-dashboard-summary.md)。テスト方針
> 全体は [`cross-cutting.md`](../../_shared/cross-cutting.md)「テスト戦略」を正本とする。本書はAPI-08の
> 具体的なテストケース、および本APIが依存する Domain層 `calcStreak` / `calcAchievementRate` の
> テストケースを列挙する（baseline「アルゴリズム設計」のアルゴリズム2・3）。

## テスト対象

| レイヤー | 対象 | テスト種別 |
|---|---|---|
| Domain | `calcStreak(habit, checkIns, today)` | ユニットテスト — 主眼 |
| Domain | `calcAchievementRate(habit, checkIns, from, to)` | ユニットテスト — 主眼 |
| Domain | ヒートマップ用 state 分類 | ユニットテスト |
| Service | `DashboardService.getSummary`（習慣ごとの集約・N+1回避の一括取得） | ユニットテスト |

## テストケース一覧: Domain `calcStreak`

| No | 観点 | 前提・入力 | 期待結果 | 完了 |
|---|---|---|---|:--:|
| 1 | 正常系 | 月水金習慣（`specific_days`）、火曜・木曜を挟んで月水金すべて `done` | 対象外日を挟んでも `current` が途切れず継続する | [x] |
| 2 | 正常系 | 対象日（月）が `not_done` | その日で `current` が0にリセットされる | [x] |
| 3 | 正常系 | `today` が対象日だが未記録 | 未達成による途切れとみなさない（中立扱い。直前までの `current` を維持） | [x] |
| 4 | 正常系 | 過去の記録を `not_done`→`done` に修正 | 修正後、`current`/`longest` が再計算された値になる | [x] |
| 5 | 正常系 | `weekly_count` 習慣（`weeklyTargetCount=3`）、ある週の `done` が3件以上 | その週が達成週としてカウントされる | [x] |
| 6 | 正常系 | `weekly_count` 習慣、今週（進行中）が未達成 | 今週の未達成では `current` を途切れさせない（進行中のため） | [x] |

## テストケース一覧: Domain `calcAchievementRate`

| No | 観点 | 前提・入力 | 期待結果 | 完了 |
|---|---|---|---|:--:|
| 7 | 正常系 | 月水金習慣、期間内対象日12日中9日 `done` | `0.75`（75%） | [x] |
| 8 | 境界値 | 期間内に対象日が0件 | `null`（「対象なし」。`0` ではない） | [x] |
| 9 | 正常系 | `weekly_count` 習慣、期間内対象週4週中3週達成 | `0.75` | [x] |

## テストケース一覧: ヒートマップ state 分類

| No | 観点 | 前提・入力 | 期待結果 | 完了 |
|---|---|---|---|:--:|
| 10 | 正常系 | 対象日かつ `done` | `state="done"` | [x] |
| 11 | 正常系 | 対象日かつ `not_done` | `state="missed"` | [x] |
| 12 | 正常系 | 対象日かつ未記録 | `state="unrecorded"` | [x] |
| 13 | 正常系 | 非対象日 | `state="not_target"` | [x] |

## テストケース一覧: API-08（`GET /dashboard?from=&to=`）

| No | 観点 | 前提・入力 | 期待結果 | 完了 |
|---|---|---|---|:--:|
| 14 | 正常系 | 複数の習慣が登録済み | 習慣ごとに集約結果（`currentStreak`/`longestStreak`/`achievementRate`/`heatmap`）が返る | [x] |
| 15 | 異常系 | `from > to` | `400`「from/to の指定が不正です」 | [x] |
| 16 | 異常系 | `from`/`to` が不正形式 | `400` | [x] |

## 備考

- ケース1〜13は本アプリの中核アルゴリズムであり、最優先で実装・網羅する
  （baseline「アルゴリズム設計」のエッジケース一覧と対応）。
- ケース14はService層のユニットテストとして、Repositoryをモック化しN+1が発生しないこと
  （`listByHabitInRange` が習慣ごとに1回だけ呼ばれること）も併せて検証する。
