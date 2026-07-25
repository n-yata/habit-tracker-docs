# 画面詳細設計書: 習慣管理

> 画面一覧・ルート・対応コンポーネント・画面遷移の正本は
> [`functional-design.md`](../../../baseline/functional-design.md)「画面設計」。レイアウト・画面項目・
> 画面イベントの外部設計は [`screen-design.md`](../../2_basic-design/screen-design.md)。本書は本画面の
> コンポーネント構成（props/state）・状態管理・詳細な画面遷移/イベント処理フロー・例外表示を記載する。

## 基本情報

| 項目 | 内容 |
|---|---|
| 画面名 | 習慣管理 |
| ルート(FE) | `/habits` |
| 対応コンポーネント | `HabitsPage` |
| 関連API | `GET /habits`（API-01）、`POST /habits`（API-02）、`PUT /habits/{id}`（API-04）、`DELETE /habits/{id}`（API-05） |
| 関連機能 | FR-01〜FR-06 |

外部設計（レイアウト・画面項目定義・画面イベント一覧）は
[`screen-design.md`](../../2_basic-design/screen-design.md)「画面2: 習慣管理」を参照。本書は以下の
実装レベル詳細に限定する。

## コンポーネント構成

```
HabitsPage
├── HabitList                  # 習慣一覧（archived=false）
│   └── HabitListItem[]        # 1習慣分の行（編集/削除ボタンを含む）
└── HabitForm                  # 新規/編集フォーム（モーダル）
    ├── RecurrenceTypeSelector  # 繰り返し種別ラジオ + 種別に応じた付随項目の出し分け
    └── WeekdayPicker           # specific_days 選択時のみ表示
```

### props / state 設計

| コンポーネント | props | 内部 state |
|---|---|---|
| `HabitsPage` | なし | `isFormOpen: boolean`, `editingHabit: Habit \| null`（新規=null／編集=対象Habit） |
| `HabitList` | なし | `useHabits()`（TanStack Query） |
| `HabitListItem` | `habit: Habit`, `onEdit: (habit: Habit) => void`, `onDelete: (id: string) => void` | なし |
| `HabitForm` | `mode: 'create' \| 'edit'`, `initialValue?: Habit`, `onClose: () => void` | フォーム入力値（`react-hook-form` 等でローカル管理）。バリデーションエラーは各フィールドに紐付け |
| `RecurrenceTypeSelector` | `value: RecurrenceType`, `onChange: (v: RecurrenceType) => void` | なし（親フォームの state を参照） |
| `WeekdayPicker` | `value: number[]`, `onChange: (v: number[]) => void` | なし |

**フォームの出し分けロジック**: `recurrenceType` の値に応じて `weeklyTargetCount` 入力欄 /
`WeekdayPicker` の表示・必須切り替えを行う（baseline「データモデル」の繰り返しルール整合表と対応）。
この出し分けはクライアント側の表示制御であり、サーバー側バリデーション（API-02/API-04）と重複させない
（サーバー側が最終防衛）。

## 状態管理（TanStack Query キー設計）

| フック | クエリキー | 対応API |
|---|---|---|
| `useHabits()` | `['habits']` | API-01 |
| `useCreateHabit()`（mutation） | — | API-02。成功時 `['habits']` を invalidate |
| `useUpdateHabit()`（mutation） | — | API-04。成功時 `['habits']`・`['habits', id]` を invalidate |
| `useArchiveHabit()`（mutation） | — | API-05。成功時 `['habits']` を invalidate |

## 画面遷移・イベント処理の詳細フロー

### 新規登録

1. 「＋ 新しい習慣」クリック → `isFormOpen=true`, `editingHabit=null` でフォームを開く（空フォーム）。
2. フォーム入力 → クライアント側で表示制御（種別に応じた項目出し分け）のみ行い、送信時に
   `useCreateHabit()` mutation を発火（`POST /habits`、API-02）。
3. 成功: フォームを閉じ、一覧を再取得（`['habits']` invalidate）。
4. 失敗（400）: レスポンスのフィールド単位エラーをフォームの該当項目にマッピングして表示。

### 編集

1. 「編集」クリック → `isFormOpen=true`, `editingHabit=対象Habit` でフォームを開き、既存値を投入
   （一覧取得済みの `Habit` をそのまま使用。個別に `GET /habits/{id}` を呼ぶ必要はない）。
2. フォーム送信 → `useUpdateHabit()` mutation（`PUT /habits/{id}`、API-04）。
3. 成功: フォームを閉じ、一覧を再取得。
4. 失敗（400/404）: 400はフォームにエラー表示、404は「対象の習慣が見つかりません」を表示しフォームを閉じ一覧を再取得（他端末で削除された場合等を考慮）。

### 削除（アーカイブ）

1. 「削除」クリック → 確認ダイアログを表示。
2. 確認後 `useArchiveHabit()` mutation（`DELETE /habits/{id}`、API-05）を発火。
3. 成功: 一覧から除外（`['habits']` invalidate）。

### 画面遷移イベント

| 操作 | 遷移先 |
|---|---|
| 習慣名クリック | `/habits/{id}`（`HabitDetailPage`） |

## 例外・エラー表示

| ケース | 表示 |
|---|---|
| API-01 の取得失敗 | 画面共通のエラー表示＋再試行導線 |
| API-02/API-04 の400 | フィールド単位のインラインエラー（メッセージは `cross-cutting.md`「エラーハンドリング」準拠） |
| API-04/API-05 の404 | 「対象の習慣が見つかりません」を表示し一覧を再取得 |
| 習慣0件 | 空状態メッセージ＋「＋ 新しい習慣」への導線 |
