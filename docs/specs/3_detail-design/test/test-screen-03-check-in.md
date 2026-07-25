# 画面: 日付指定チェックイン 単体テスト仕様書

> 対象画面の詳細設計は [`screen-03-check-in.md`](../screen/screen-03-check-in.md)。テスト方針全体は
> [`cross-cutting.md`](../../_shared/cross-cutting.md)「テスト戦略」を正本とする。本書はコンポーネント
> 単位（Vitest + Testing Library）の具体的なテストケースを列挙する。

## テスト対象

| コンポーネント | テスト種別 |
|---|---|
| `DatePickerBar` | ユニットテスト（Vitest + Testing Library） |
| `TargetHabitList` / `HabitCheckToggle` | ユニットテスト |

## テストケース一覧

| No | 観点 | 前提・操作 | 期待結果 | 完了 |
|---|---|---|---|:--:|
| 1 | 正常系 | `DatePickerBar` で日付を変更 | URLクエリ `date` が更新される（`replace` でヒストリーに積まれない） | [ ] |
| 2 | 正常系 | URLクエリ `date` の変更 | `TargetHabitList` のクエリキーが変わり、再取得がトリガーされる | [ ] |
| 3 | 正常系 | 選択日が対象の習慣のみを渡す | 対象習慣のみがリストに表示される（非対象は表示されない） | [ ] |
| 4 | 正常系 | `HabitCheckToggle` を操作 | チェックイン記録のmutation（`PUT /habits/{id}/check-ins/{date}` 相当）が1回呼ばれる | [ ] |
| 5 | 正常系 | 選択日に対象習慣が0件 | 「この日が対象でない習慣は表示されません」の注記が表示される（空状態エラーではない） | [ ] |
| 6 | 異常系 | URLクエリ `date` が不正形式（例: `2026-13-40`） | 当日にフォールバックしてリダイレクトされる | [ ] |
| 7 | 正常系 | 「戻る」クリック | `/`（ダッシュボード）への遷移が発火する | [ ] |

## 備考

- ケース1〜2はNext.jsのルーター・TanStack Queryのキー連動を検証するため、`useSearchParams` と
  クエリキーの変化をモック/スパイして確認する。
