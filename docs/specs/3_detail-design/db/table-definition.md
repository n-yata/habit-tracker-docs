# テーブル定義書（物理スキーマ）

> 詳細設計工程の成果物。**概念モデル（エンティティ・区分値・ドメイン上の制約・ER図）の正本**は
> [`functional-design.md`](../../../baseline/functional-design.md)「データモデル」。本ファイルは
> **物理スキーマ**（カラム定義・型・NULL可否・デフォルト・物理制約名・索引名）と、それに伴う
> 設計メモ（確定事項）を置く。物理DDL（`golang-migrate` の up/down SQL）は本表を基に、
> マイグレーション実装のタイミングで生成する（`sqlc` はそのDDLを入力に型安全な Go コードを生成）。
> 概念モデルの camelCase フィールドは、テーブルでは snake_case カラムに対応する
> （例: `recurrenceType` ↔ `recurrence_type`）。

## habits テーブル（論理名: 習慣）

| カラム（物理名） | 論理名 | 型 | NULL | デフォルト | 説明 |
|---|---|---|:--:|---|---|
| `id` | 習慣ID | UUID | 不可 | `gen_random_uuid()` | 主キー |
| `name` | 習慣名 | VARCHAR(100) | 不可 | — | 1〜100文字 |
| `category` | カテゴリ | VARCHAR(100) | 可 | — | 任意カテゴリ |
| `recurrence_type` | 繰り返し種別 | TEXT | 不可 | — | `daily` / `weekly_count` / `specific_days` |
| `weekly_target_count` | 週間目標回数 | SMALLINT | 可 | — | `weekly_count` 時のみ 1〜7 |
| `target_weekdays` | 対象曜日 | SMALLINT[] | 可 | — | `specific_days` 時のみ。要素は 0(日)〜6(土) |
| `reminder_time` | リマインド時刻 | TIME | 可 | — | `HH:MM` 相当。保持のみ（実配信なし） |
| `archived` | アーカイブ済フラグ | BOOLEAN | 不可 | `FALSE` | 論理削除フラグ |
| `created_at` | 作成日時 | TIMESTAMPTZ | 不可 | `now()` | 作成日時 |
| `updated_at` | 更新日時 | TIMESTAMPTZ | 不可 | `now()` | 更新時に更新 |

**制約・インデックス**

| 名前 | 種別 | 内容 |
|---|---|---|
| （主キー） | PK | `id` |
| `habits_name_len` | CHECK | `name` は 1〜100 文字 |
| `habits_recurrence_type_valid` | CHECK | `recurrence_type` ∈ { `daily`, `weekly_count`, `specific_days` } |
| `habits_recurrence_consistency` | CHECK | 繰り返しルールと付随項目の整合（下表） |

繰り返しルール整合（`habits_recurrence_consistency` の内容。論理的な規則は要件定義書 FR-06 と対応）:

| `recurrence_type` | `weekly_target_count` | `target_weekdays` |
|---|---|---|
| `daily` | NULL | NULL |
| `weekly_count` | 1〜7（必須） | NULL |
| `specific_days` | NULL | 1要素以上・各要素 0〜6（必須） |

## check_ins テーブル（論理名: チェックイン記録）

| カラム（物理名） | 論理名 | 型 | NULL | デフォルト | 説明 |
|---|---|---|:--:|---|---|
| `id` | チェックインID | UUID | 不可 | `gen_random_uuid()` | 主キー |
| `habit_id` | 習慣ID | UUID | 不可 | — | `habits(id)` への外部キー |
| `date` | 対象日 | DATE | 不可 | — | 記録対象の日付（時刻は持たない） |
| `status` | 状態 | TEXT | 不可 | — | `done` / `not_done` |
| `created_at` | 作成日時 | TIMESTAMPTZ | 不可 | `now()` | 作成日時 |
| `updated_at` | 更新日時 | TIMESTAMPTZ | 不可 | `now()` | 更新日時 |

**制約・インデックス**

| 名前 | 種別 | 内容 |
|---|---|---|
| （主キー） | PK | `id` |
| `check_ins_habit_id_fkey` | FK | `habit_id` → `habits(id)`（`ON DELETE CASCADE`） |
| `check_ins_status_valid` | CHECK | `status` ∈ { `done`, `not_done` } |
| `check_ins_habit_date_unique` | UNIQUE | (`habit_id`, `date`)。同一習慣・同一日で重複不可。upsert の競合ターゲット |
| `idx_check_ins_date` | INDEX | (`date`)。日付起点の取得（`listByDate`）用 |

## 設計メモ（確定事項）

- 日付・時刻は**サーバーローカル時刻基準**で扱う（第一マイルストーンは単一ユーザー・ローカル前提のため
  ユーザーTZは持たない。概念レベルの確定事項は baseline「データモデル」にも記載）。
- `gen_random_uuid()` は PostgreSQL 13+ で組み込み（本プロジェクトは 16 以降を想定）。
- `UNIQUE (habit_id, date)` が張る索引を `listByHabitInRange`（習慣×期間）と upsert の競合判定に利用。
  日付起点の取得には別途 `idx_check_ins_date` を用いる。
- `habits` は論理削除（`archived`）を基本とするため物理削除は通常発生しないが、FK は
  `ON DELETE CASCADE` とし、万一の物理削除時も孤児レコードを残さない。
- `updated_at` は**アプリケーション側（Service層のUPDATEクエリ）で明示的に `now()` を設定する**
  （DBトリガーは使わない。sqlc でクエリを明示的に書く方針と一貫させる）。
- `reminder_time` の型は **`TIME`** で確定。当日ダッシュボードの超過ハイライトは、
  **当日の対象習慣のみを対象に、サーバー時刻基準**（`reminder_time` < 現在のサーバー時刻）で判定する
  （過去日は対象外）。

## 詳細設計への申し送り

- 物理DDL（`golang-migrate` の up/down SQL）は本ファイルを基に、マイグレーション実装のタイミングで
  生成する。
- テーブル・カラムを追加・変更したら、まず baseline「データモデル」の概念モデル（ER図・区分値）を
  更新し、本ファイルを追随させる（正本は baseline の概念モデル、物理詳細は本ファイル）。
