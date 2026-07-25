# 画面: 習慣管理 単体テスト仕様書

> 対象画面の詳細設計は [`screen-02-habits.md`](../screen/screen-02-habits.md)。テスト方針全体は
> [`cross-cutting.md`](../../_shared/cross-cutting.md)「テスト戦略」を正本とする。本書はコンポーネント
> 単位（Vitest + Testing Library）の具体的なテストケースを列挙する。

## テスト対象

| コンポーネント | テスト種別 |
|---|---|
| `HabitForm` / `RecurrenceTypeSelector` / `WeekdayPicker` | ユニットテスト（Vitest + Testing Library） |
| `HabitList` / `HabitListItem` | ユニットテスト |

## テストケース一覧

| No | 観点 | 前提・操作 | 期待結果 | 完了 |
|---|---|---|---|:--:|
| 1 | 正常系 | `recurrenceType` を `daily` から `weekly_count` に切り替え | 週間目標回数の入力欄が表示され、必須マークが付く | [ ] |
| 2 | 正常系 | `recurrenceType` を `weekly_count` から `specific_days` に切り替え | 週間目標回数欄が非表示になり、`WeekdayPicker` が表示される | [ ] |
| 3 | 正常系 | `recurrenceType="daily"` のまま | 週間目標回数欄・曜日選択欄どちらも非表示 | [ ] |
| 4 | 正常系 | 新規モードでフォームを開く | 全項目が空（初期値）で表示される | [ ] |
| 5 | 正常系 | 編集モードでフォームを開く（既存 `Habit` を渡す） | 既存値がフォームに投入される | [ ] |
| 6 | 異常系 | フォーム送信後、APIから `400`（フィールド単位エラー）が返る | 該当フィールドの直下にインラインエラーメッセージが表示される | [ ] |
| 7 | 正常系 | フォーム送信が成功する | フォームが閉じ、一覧が再取得される | [ ] |
| 8 | 正常系 | 「削除」クリック | 確認ダイアログが表示される | [ ] |
| 9 | 正常系 | 確認ダイアログで「キャンセル」 | 削除mutationが呼ばれない | [ ] |
| 10 | 正常系 | 確認ダイアログで「OK」 | 削除mutation（`DELETE /habits/{id}` 相当）が1回呼ばれる | [ ] |
| 11 | 正常系 | `HabitList` に `archived=false` の習慣のみ渡す | 全件が一覧に表示される | [ ] |
| 12 | 正常系 | `HabitListItem` に `recurrenceType="specific_days"`, `targetWeekdays=[1,3,5]` を渡す | 「月・水・金」の要約表示になる | [ ] |

## 備考

- ケース1〜3は繰り返しルールの出し分けロジック（baseline「データモデル」の整合表と対応）を
  クライアント側の表示制御として検証するもので、サーバー側バリデーション（API-02/04の単体テスト）とは
  独立して行う。
