# 振り返り: 3_detail-design（api/screen/test）の作成とスキル拡張

## やったこと

- `docs/specs/3_detail-design/api/`（API-01〜08、8ファイル）・`screen/`（画面4本）・
  `test/`（`api/`・`screen/`と1対1、計12ファイル）を新規作成。
- 既存の `db/table-definition.md`（シャビが並行作業で作成済み）を `db/` サブディレクトリへ移動し、
  `api/`・`screen/`と並びを揃えた。
- `.claude/skills/specs-detail-design/` を、db専用スキルから db/api/screen/test 4区分対応のスキルへ拡張
  （SKILL.md・guide.md・テンプレート4種を追加）。

## 学び・申し送り

### 1. `docs/specs/3_detail-design/` の当初想定と実際のギャップ

CLAUDE.mdの当初記述は「詳細設計の残り・テスト設計・実装・結合テストは `.steering/` が担う」だったが、
実際にはプロジェクト規模的に「API単位・画面単位で1ファイルずつの詳細設計書」を持つ運用の方が
シャビの要望に合っていた。**ディレクトリ構成の意図は事前に決め打ちせず、都度シャビに確認する**のが
正解だった（`db/`要否・`api/`/`screen/`の粒度・単体テスト仕様書の要否、すべて対話で確定）。

### 2. 相対リンクの深さを数え間違えやすい

`docs/specs/3_detail-design/api/*.md` から baseline へのリンクは `../../../baseline/...`
（3階層上）だが、既存の `docs/specs/2_basic-design/*.md` 内のリンクは誤って `../../../baseline/...`
になっていた（正しくは `../../baseline/...`。2階層上）。**ディレクトリを新設・移動したら、
`ls <相対パス>` で実際に解決できるか必ずコマンドで検証してから書く**（目視でのディレクトリ階層
カウントは間違えやすい）。今回は2_basic-design側の既存の壊れたリンクは指摘のみでスコープ外とした
（次回そちらを触る際に修正する）。

### 3. baseline とシャビの並行作業がコンフリクトしうる

作業中、シャビが別ブランチ（`docs/20260725-table-definition-split`）で `CLAUDE.md`・
`docs/baseline/functional-design.md`・`docs/specs/3_detail-design/table-definition.md` を
並行して更新し、`main` にマージ済みだった。**セッション引き継ぎ・並行作業の可能性がある場合は、
「前回はこうだったはず」で進めず、都度 `git status`/`git log`/実ファイルで現況を確認する**
（プロジェクトCLAUDE.mdの「セッション引き継ぎ時の作業原則」と同じ教訓）。

### 4. 単体テスト仕様書の「完了」チェック欄

シャビの要望で、テストケース一覧の各行末に `完了` 列（`[ ]`）を追加した。GitHub Flavored Markdown の
タスクリスト記法（`- [ ]`）はテーブルセル内では正しく動作しない（インタラクティブなチェックボックスに
ならない）ため、テキストとしての `[ ]`/`[x]` を手動で書き換える運用とした。今後も表内で進捗管理したい
場合はこの方式を踏襲する。
