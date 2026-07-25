# 画面詳細設計書: 日付指定チェックイン

> 画面一覧・ルート・対応コンポーネント・画面遷移の正本は
> [`functional-design.md`](../../../baseline/functional-design.md)「画面設計」。レイアウト・画面項目・
> 画面イベントの外部設計は [`screen-design.md`](../../2_basic-design/screen-design.md)。本書は本画面の
> コンポーネント構成（props/state）・状態管理・詳細な画面遷移/イベント処理フロー・例外表示を記載する。

## 基本情報

| 項目 | 内容 |
|---|---|
| 画面名 | 日付指定チェックイン |
| ルート(FE) | `/check-ins?date=YYYY-MM-DD` |
| 対応コンポーネント | `CheckInPage` |
| 関連API | `GET /check-ins?date=`（API-06）、`PUT /habits/{id}/check-ins/{date}`（API-07） |
| 関連機能 | FR-07, FR-08, FR-09 |

外部設計（レイアウト・画面項目定義・画面イベント一覧）は
[`screen-design.md`](../../2_basic-design/screen-design.md)「画面3: 日付指定チェックイン」を参照。
本書は以下の実装レベル詳細に限定する。

## コンポーネント構成

```
CheckInPage
├── DatePickerBar              # 日付選択（URLクエリと同期）
└── TargetHabitList            # 選択日が対象の習慣リスト
    └── HabitCheckToggle[]     # 完了/未完了トグル
```

### props / state 設計

| コンポーネント | props | 内部 state |
|---|---|---|
| `CheckInPage` | なし（`useSearchParams` でURLクエリ `date` を読む） | なし。日付の正本はURLクエリ（`date` 未指定時は当日にリダイレクト） |
| `DatePickerBar` | `date: string`, `onChange: (date: string) => void` | なし。`onChange` は Next.js router で URLクエリを更新 |
| `TargetHabitList` | `date: string` | `useCheckInsForDate(date)`（TanStack Query。ダッシュボードと同じ hooks を再利用） |
| `HabitCheckToggle` | `habit: Habit`, `date: string`, `status: CheckInStatus \| null` | 楽観更新中フラグ（ローカル state） |

## 状態管理（TanStack Query キー設計）

| フック | クエリキー | 対応API |
|---|---|---|
| `useCheckInsForDate(date)` | `['check-ins', date]` | API-06。`date` はURLクエリ由来（ダッシュボードの `'today'` と同じフックを異なるキーで利用） |
| チェックイン記録（mutation） | — | API-07。成功時 `['check-ins', date]` を invalidate。当日分の場合は `['dashboard', ...]` も invalidate |

## 画面遷移・イベント処理の詳細フロー

### 日付変更

1. `DatePickerBar` で日付を変更 → Next.js router で URLクエリ `date` を更新（`push` ではなく
   `replace` でヒストリーを汚さない）。
2. URLクエリの変更を検知して `useCheckInsForDate(date)` のクエリキーが変わり、自動的に再取得
   （API-06）。
3. 対象習慣リストを差し替え（前の日付の非対象習慣は表示から消える）。

### トグル操作

1. ユーザーが完了/未完了トグルを操作。
2. `PUT /habits/{id}/check-ins/{date}`（API-07）を mutation で発火。楽観更新で即時反映。
3. 成功: `['check-ins', date]` を invalidate。
4. 失敗（422: 非対象日）: **画面設計上、対象外の習慣はそもそもリストに表示されないため通常発生しない**
   （UI側で予防）。発生した場合（データ不整合等）はロールバックしエラー表示。

### 画面遷移イベント

| 操作 | 遷移先 |
|---|---|
| 「戻る」クリック | `/`（`DashboardPage`） |

## 例外・エラー表示

| ケース | 表示 |
|---|---|
| API-06 の取得失敗 | 画面共通のエラー表示＋再試行導線 |
| 選択日に対象習慣が0件 | 「※ この日が対象でない習慣は表示されません」の注記のみ表示（空状態エラーではない） |
| URLクエリ `date` が不正形式 | 当日にフォールバックしてリダイレクト |
