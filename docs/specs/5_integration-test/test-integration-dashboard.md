# 画面: ダッシュボード 結合テスト仕様書

> 対象画面の詳細設計は [`screen-01-dashboard.md`](../3_detail-design/screen/screen-01-dashboard.md)。
> 使用するAPIの詳細設計は
> [`api-06-checkins-list.md`](../3_detail-design/api/api-06-checkins-list.md)・
> [`api-08-dashboard-summary.md`](../3_detail-design/api/api-08-dashboard-summary.md)。
> テスト方針全体は [`cross-cutting.md`](../_shared/cross-cutting.md)「テスト戦略」を正本とする。
> 本書は**ダッシュボード画面（DashboardPage）が呼び出すAPI群を横断した結合テスト**
> （testcontainers-go + 実PostgreSQL必須）を、画面操作の流れに沿ったシナリオ単位で列挙する。
> 実DB不要のユニットテストは [`docs/specs/4_unit-test/`](../4_unit-test/) を参照。ブラウザ経由の
> 真のE2E（Playwright）は `cross-cutting.md`「E2Eテスト」を参照（本書はAPI層までの
> シミュレーションに留める）。

## テスト対象

| 画面 | 使用API | DBテーブル |
|---|---|---|
| ダッシュボード（DashboardPage） | `GET /check-ins?date=today`（API-06）、`GET /dashboard`（API-08） | `habits`, `check_ins` |

## テストケース一覧

| No | シナリオ | 操作の流れ | 期待結果 | 完了 |
|---|---|---|---|:--:|
| 1 | チェックイン記録がダッシュボード集計に反映される | 月水金習慣を登録 → 数日分 `PUT` で記録 → `GET /dashboard?from=&to=` | 実DBから取得したチェックイン列を元に `currentStreak`/`longestStreak`/`achievementRate`/`heatmap` が正しく算出される（Domain層のアルゴリズムをユニットテストで検証済み。ここでは実データ経路での接続を確認） | [ ] |
| 2 | 複数習慣を横断して習慣ごとに集計される | `daily`/`weekly_count`/`specific_days` の習慣を複数登録し、それぞれにチェックインを記録 → `GET /dashboard` | 習慣ごとに独立した集計結果が配列で返る（N+1回避自体はユニットテストで検証済み。ここでは実DBに対する `listByHabitInRange` の実クエリ結果が正しいことを確認） | [ ] |
| 3 | リマインド超過ハイライトが当日チェックインリストに反映される | `reminderTime` を過去時刻に設定した未完了の対象習慣を登録 → `GET /check-ins?date=today` | `overdue=true` が返る（サーバー時刻とDB上の `reminder_time` を突き合わせた実データでの確認） | [ ] |
| 4 | 期間内に対象日が0件のとき `achievementRate` は `null` | 特定曜日習慣で、指定期間にその曜日が含まれないよう `from`/`to` を指定 → `GET /dashboard` | `achievementRate` が `null`（「対象なし」。`0` ではない） | [ ] |
| 5 | 過去の記録を遡って修正すると集計が再計算される | チェックインを `not_done` で記録 → `GET /dashboard` で確認 → 同日を `done` に修正 → 再度 `GET /dashboard` | ストリーク・達成率が修正後の値に更新される | [ ] |

## 備考

- ストリーク・達成率・ヒートマップの算出アルゴリズム自体（対象外日を跨ぐ継続・today中立扱い・
  weekly_countの週単位判定等）はDomain層のユニットテストで網羅済み
  （[`test-api-08-dashboard-summary.md`](../4_unit-test/test-api-08-dashboard-summary.md)）。
  本書は実DBに対する `listActive`/`listByHabitInRange` の実クエリ結果を組み合わせた際に
  同じ結果が得られることを確認する。
- 未実装（testcontainers-go導入時に実装予定）。
