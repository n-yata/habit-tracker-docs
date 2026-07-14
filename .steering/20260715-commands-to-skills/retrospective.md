# 振り返り: commands を廃止し skills に統合

## 実装完了日

2026-07-15

## 作業概要

`.claude/commands/` を廃止し、ワークフローの入口を含めてすべて `.claude/skills/` に統合した。
あわせて、直前の作業で `plan-feature` を `add-feature`（引数なし=企画モード）に統合済み。

- 旧 `commands/add-feature.md` → `skills/flow-add-feature/SKILL.md`
- 旧 `commands/review-docs.md` → `skills/flow-review-docs/SKILL.md`
- 旧 `commands/setup-project.md` → `skills/flow-setup-project/SKILL.md`
- 旧 `commands/plan-feature.md` → 廃止（add-feature の企画モードへ吸収済み）

命名は README のプレフィックス規約に合わせ `flow-*` に統一。起動名も `/flow-add-feature` 等に変わった。

## 計画と実績の差分

- 当初はコマンド名を据え置く案も検討したが、README の `docs-*`/`flow-*` グループ分け規約との
  一貫性を優先し、`flow-*` へのリネームを選択（ユーザー合意済み）。
- リネームに伴い、起動名の参照を全ドキュメントで更新する必要が生じた（下記「学び」）。

## 学んだこと・申し送り

- **skill は `/name` でも起動できる**ため、command を skill 化しても明示起動の使い勝手は維持される。
  command 固有機能（frontmatter の `description` のみ）は skill の frontmatter に素直に移せる。
- **リネーム時の参照更新は広範囲に及ぶ**。今回の実際の波及先:
  - `CLAUDE.md`（起動例・工程表・「.claude カタログの維持」節・初回セットアップ手順）
  - `.claude/README.md`（Commands 節の撤去、`flow-*` 表への統合、Agents 表の起動元列）
  - 他 skill 内の相互参照（`flow-grill-with-docs` の `/setup-project` 参照）
  - `docs/3_detail-design/repository-structure.md`（`.claude/` ツリー図と説明の `commands/`）
  - チェック方法: `grep -rn "/add-feature\b\|/review-docs\b\|/setup-project\b"` で残存ゼロを確認。
    `docs-repository-structure` 配下の `commands/` はユーザーアプリの例示なので対象外（誤検知に注意）。
- **skill 化による自動ロードの副作用**: skill は description マッチで自動ロードされ得る。
  特に `flow-add-feature` は無停止実装まで走る重いワークフローのため、description は
  「新機能の実装・機能追加を依頼されたとき」に絞った。将来 skill を足す際も、重い自律ワークフローは
  トリガー文言を明示起動寄りに絞ること。

## 次回への改善提案

- `.claude/` の構成変更（追加・リネーム）を行ったら、`CLAUDE.md` /「.claude/README.md」/
  `repository-structure.md` の3点セットを更新チェックリストとして固定化するとよい。
- 参照更新の最終確認は grep で機械的に residual ゼロを担保する運用を定着させる。
