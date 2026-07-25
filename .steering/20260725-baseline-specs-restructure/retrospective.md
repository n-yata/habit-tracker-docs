# 実装後の振り返り

## 作業概要

`docs/baseline/` を「プロジェクトの指標」として保つ方針を明確化し、機能設計書の体系とそれを支える
スキル群・カタログを全面的に整合させた。会話駆動（ステアリング未作成）のケースB。主に5点:

1. **機能設計書の baseline/specs 再編**: `docs/baseline/functional-design.md` を、データモデル
   （物理スキーマ含む）・中核アルゴリズム・API/画面/ユースケースの一覧・モジュール構成図といった
   **ぶれてはいけない重要点の正本**に作り直した。JSON入出力例・レイヤー別インターフェース・シーケンス図
   フルなどの実装詳細は `docs/specs/` へ退避。旧 `docs/baseline/functional-design/`（同名サブディレクトリ
   分割）は廃止。
2. **specs 構造の確定**: 機能設計固有の実装詳細は `docs/specs/2_basic-design/`（フラット。
   `component-design.md` / `usecase.md` / `api-design.md`）、フェーズ横断で参照する実装詳細
   （UI表示仕様・エラーハンドリング・非機能・テスト戦略）は `docs/specs/_shared/cross-cutting.md` に配置。
3. **未確定事項の確定**: 「詳細設計で確定」等の曖昧な先送りを baseline から排除するため、TZ/日付境界
   （サーバーローカル時刻基準）・`weekly_count` の週起点（月曜始まり ISO 8601）・非対象日記録の拒否コード
   （422）・リマインド超過判定（当日対象のみ・サーバー時刻基準）・`updated_at` 更新方式（アプリ明示設定）・
   `reminder_time` 型（TIME）をこの会話で確定し、本文へ反映。PRD・glossary の TBD 記述も解消。
4. **CLAUDE.md の刷新**: ディレクトリ構造説明が別プロジェクトの汎用テンプレート（`0_ideas`〜`3_detail-design`
   〜`_shared` の番号ディレクトリ、`story.md` 等）のまま実体と乖離していたので、`baseline/`＋`specs/` の
   実運用に合わせて全面書き直し。「baseline と specs の使い分け」判断基準を明文化。
5. **スキル/カタログの全面追従**: baseline 作成系6スキル（docs-prd / docs-functional-design /
   docs-architecture-design / docs-repository-structure / docs-development-guidelines / docs-glossary）と
   flow-setup-project、および作業系スキル（flow-add-feature / flow-archive-retrospectives /
   flow-review-docs / flow-steering）・flow-grill-with-docs・implementation-validator エージェント・
   `.claude/README.md` の出力先/参照パスを新構成へ更新。docs-functional-design のテンプレートは
   分割ファイルを統廃合（data-model / domain-logic / screen-design を索引テンプレートへ吸収）。

## 実装完了日

2026-07-25

## 計画と実績の差分

ステアリング未作成のため計画 tasklist なし。当初は「baseline/functional-design/ の内容を md に移動」という
軽微な依頼だったが、「baseline は指標＝重要点のみ、実装詳細は specs へ」という設計思想の明確化に発展し、
機能設計書の全面再構成 → 未確定事項の確定 → CLAUDE.md 刷新 → スキル群/カタログの追従 → `_shared/` 追加、
と段階的に拡大した。

## 学んだこと

**設計・ドキュメント体系の学び**:
- **baseline は「指標」＝ぶれてはいけない重要点の正本**。記載漏れ・あいまいな未確定事項（「詳細設計で
  確定」等の先送り）を残さないことが原則。ボリュームの大きい実装詳細は `docs/specs/` に退避し、baseline
  には概要＋参照リンクだけ残す。判断に迷ったら重要点側（baseline）に倒す。
- **specs 内の配置**: 特定フェーズの成果物は番号ディレクトリ（`2_basic-design/` 等）、フェーズに閉じず
  横断参照する実装詳細（UI/エラー/テスト戦略）は `_shared/`。この境界を CLAUDE.md に恒久ルール化した。
- **未確定事項は「先送り」せずその場で確定させる**のが baseline の質を保つ最短路。決めの質問を通じて
  6項目を確定でき、PRD/glossary の TBD も連鎖的に解消できた。

**プロセス上の注意（重要な申し送り）**:
- テンプレート（`.claude/skills/` 配下）・カタログ（`.claude/README.md`）・エージェント定義は、実ドキュメントの
  構造変更から**乖離しやすい**。今回のように docs 構造を変えたら、`grep -rn "docs/1_requirements\|docs/2_basic-design\|..."`
  で全 skill/agent を洗い出し、**同じコミットで一括追従**させると陳腐化を防げる（前回 20260715 の振り返りと
  同じ教訓の再確認）。
- **並行編集への注意**: 作業中、ユーザーが IDE 側で `docs/specs/` の構造を複数回変更していた（`_shared/`
  ディレクトリの新規作成、`2_basic-design/functional-design/` サブディレクトリのフラット化、番号ディレクトリ
  READMEの削除）。いずれも都度 `git status` / `find` で検知し、意図を確認してから追従した。**構造変更の途中は
  こまめに実ファイルの現況を確認**し、サマリーや直前の認識を鵜呑みにしないことが重要。

## 次回への改善提案

- docs 構造を変更する作業では、着手時に「影響する参照元（skill / agent / カタログ / 相互リンク）」を
  先に洗い出してからパス更新に入ると、追従漏れを機械的に潰せる。
- baseline の各ドキュメント冒頭に「重要点の正本／実装詳細は specs 参照」の役割定義を1文で置く運用は、
  今後 baseline が肥大化しないためのガードとして有効。新規 baseline ドキュメントにも踏襲する。
