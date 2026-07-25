# 画面: ダッシュボード 単体テスト仕様書

> 対象画面の詳細設計は [`screen-01-dashboard.md`](../3_detail-design/screen/screen-01-dashboard.md)。テスト方針全体は
> [`cross-cutting.md`](../_shared/cross-cutting.md)「テスト戦略」を正本とする。本書はコンポーネント
> 単位（Vitest + Testing Library）の具体的なテストケースを列挙する。

## テスト対象

| コンポーネント | テスト種別 |
|---|---|
| `HabitCheckItem` | ユニットテスト（Vitest + Testing Library） |
| `TodayHabitList` | ユニットテスト |
| `HeatmapCalendar` | ユニットテスト |

## テストケース一覧

| No | 観点 | 前提・操作 | 期待結果 | 完了 |
|---|---|---|---|:--:|
| 1 | 正常系 | `HabitCheckItem` にチェック済み `status="done"` を渡す | チェックボックスが選択状態で表示される | [x] |
| 2 | 正常系 | 未チェックのチェックボックスをクリック | チェックイン記録のmutationが1回呼ばれる（`PUT /habits/{id}/check-ins/{today}` 相当） | [x] |
| 3 | 正常系 | `overdue=true` を渡す | 警告色ハイライトが表示される | [x] |
| 4 | 正常系 | `overdue=false` を渡す | 警告色ハイライトが表示されない | [x] |
| 5 | 正常系 | チェック操作後、mutationが成功する前 | 楽観更新によりチェック状態が即座に反映される | [x] |
| 6 | 異常系 | チェック操作後、mutationが失敗（422）する | 楽観更新がロールバックされ、エラーメッセージが表示される | [x] |
| 7 | 正常系 | `TodayHabitList` にデータ取得中の状態を渡す | ローディング表示（スケルトン／スピナー）になる | [x] |
| 8 | 正常系 | `TodayHabitList` にデータ取得エラーの状態を渡す | エラーメッセージ＋再試行導線が表示される | [x] |
| 9 | 正常系 | `TodayHabitList` に対象習慣0件を渡す | 空状態メッセージ「習慣を登録しましょう」＋導線が表示される | [x] |
| 10 | 正常系 | `HeatmapCalendar` に `state="done"`/`"missed"`/`"unrecorded"`/`"not_target"` の日を混在させて渡す | 各日が `cross-cutting.md`「カラーコーディング」通りの配色クラスで描画される | [x] |

## 備考

- ケース2・6はTanStack Queryのmutationをモック化し、呼び出し引数・楽観更新の反映/ロールバックを検証する。
