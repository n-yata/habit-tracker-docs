# .claude カタログ

このディレクトリに置かれた **skills / agents** の目次です。
「何があるか」を素早く見渡すための案内板であり、各項目の正本は
それぞれの `SKILL.md` の frontmatter `description` です（カタログはそれを要約します）。

> **メンテナンスのルール**: `.claude/` 配下に skill / agent を
> **追加・削除・リネームしたら、この README.md も必ず同じ変更で更新する**こと。
> 詳細はプロジェクトの `CLAUDE.md`「.claude カタログの維持」を参照。

> **注**: 以前あった `commands/` は廃止し、ワークフローの入口もすべて `skills/` に統合済み。
> ユーザーが `/name` とタイプして始めるワークフロー（旧コマンド）は `flow-*` スキルとして提供する。

---

## Skills（description により自動ロード／`/name` でも起動）

状況に応じて自動的にロードされる知識・手順・テンプレート。`/name` での明示起動も可能。
スキルはプレフィックスでグループ分けしている（`baseline-*` = `docs/baseline/`（指標＝正本）を作る系、`specs-*` = `docs/specs/`（各工程の顧客提出成果物）を作る系、`flow-*` = 開発ワークフロー〔workflow：進め方〕を支援する系）。

### `baseline-*`（指標ドキュメント作成系。`docs/baseline/` の指標＝正本を作る）

| skill | 概要 | 成果物 |
|---|---|---|
| **baseline-prd** | プロダクト要求定義書(PRD)を作成・更新する。プロダクトビジョン・ペルソナ・KPI・機能/非機能要件を定義する。 | `docs/baseline/product-requirements.md` |
| **baseline-functional-design** | 機能設計書を作成・更新する。PRD の要件を技術的にどう実現するかを設計する。 | `docs/baseline/functional-design.md`（重要点の正本。実装詳細は `docs/specs/2_basic-design/` と `docs/specs/_shared/`） |
| **baseline-architecture-design** | アーキテクチャ設計書を作成・更新する。システム構造・技術選定（テクノロジースタック）を定義する。 | `docs/baseline/architecture.md` |
| **baseline-repository-structure** | リポジトリ構造定義書を作成・更新する。技術スタックを反映した具体的なディレクトリ構造を定義する。 | `docs/baseline/repository-structure.md` |
| **baseline-development-guidelines** | 開発ガイドラインを作成・更新する。コーディング規約・命名規則・Git運用・テスト戦略の参照元でもある。 | `docs/baseline/development-guidelines.md` |
| **baseline-glossary** | 用語集を作成・更新する。プロジェクト固有の用語・ユビキタス言語を体系的に定義する。 | `docs/baseline/glossary.md` |

### `specs-*`（工程成果物作成系。`docs/specs/` の各工程の顧客提出成果物を作る）

| skill | 概要 | 成果物 |
|---|---|---|
| **specs-requirements** | 要件定義工程の顧客提出成果物（要件定義書・非機能要件定義書）を作成・更新する。baseline の PRD/機能設計を正本に FR/NFR を採番し、顧客提出レベルに体系化する。 | `docs/specs/1_requirements/`（`requirements-definition.md`・`non-functional-requirements.md`） |

### `flow-*`（ワークフロー系。開発の進め方＝アイデアを練る・作業を計画/実装/振り返る といったプロセスを支援する）

`/name` で明示起動するワークフローの入口（旧 `commands/`）も、この `flow-*` に含む。

| skill | 概要 | 起動 |
|---|---|---|
| **flow-setup-project** | 初回セットアップ。`docs/baseline/ideas/` を入力に、永続ドキュメント6種（PRD・機能設計・アーキテクチャ・リポジトリ構造・開発ガイドライン・用語集）を対話的に作成する。 | `/flow-setup-project` |
| **flow-add-feature** | 引数の有無で2モードに分岐する。**引数なし**は planモードで要求を対話的に練り `.steering/[日付]-[タイトル]/requirements.md` を作成して停止（実装には進まない）。**引数あり**は `requirements.md`（あれば尊重）を起点に、設計（design.md / tasklist.md 生成）→ 実装ループ → 実装検証（implementation-validator）→ テスト → 振り返りまでを無停止で自動実行する。 | `/flow-add-feature`（企画）／`/flow-add-feature [機能名]`（実装） |
| **flow-review-docs** | doc-reviewer サブエージェントを起動し、指定ドキュメントを完全性・明確性・一貫性・実装可能性・測定可能性の観点で詳細レビューする。 | `/flow-review-docs [ドキュメントパス]` |
| **flow-grill-with-docs** | 永続ドキュメント作成の前段として、アイデアをインタビュー形式の壁打ちで掘り下げ `docs/baseline/ideas/` に書き出す。固めた内容が PRD 等の入力になる。 | 会話で起動 |
| **flow-steering** | 作業単位の計画・実装・振り返りを `.steering/` に記録する。モード1（ステアリングファイル作成）／モード2（実装と tasklist.md の進捗管理）／モード3（振り返り retrospective.md の作成）を持つ。 | 会話・他スキルから起動 |
| **flow-archive-retrospectives** | `.steering/` 配下の振り返り（retrospective.md）を棚卸しし、`docs/` へ昇格すべき学びを承認制で反映したうえで、処理済みディレクトリを `.steering/archives/` へアーカイブする。 | 会話で起動 |

---

## Agents（サブエージェント）

独立したコンテキストで動作する専門エージェント。主にスキルから起動される。

| agent | 概要 | 主な起動元 | model |
|---|---|---|---|
| **doc-reviewer** | ドキュメントの品質を完全性・明確性・一貫性・実装可能性・測定可能性の5観点で評価し、優先度別に改善提案を行う。 | `/flow-review-docs` | sonnet |
| **implementation-validator** | 実装コードをスペック準拠・コード品質・テストカバレッジ・セキュリティ・パフォーマンスの5観点で検証する。 | `/flow-add-feature` | sonnet |

> ※ 設計・テスト・インフラ・セキュリティの専門チームメンバー
> （architecture-designer / test-engineer / devops-engineer / security-engineer）は
> ユーザーグローバル（`~/.claude/agents/`）に定義されており、本カタログの対象外。
