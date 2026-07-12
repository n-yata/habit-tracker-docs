---
description: 初回セットアップ: 6つの永続ドキュメントを対話的に作成する
---

# 初回プロジェクトセットアップ

このコマンドは、プロジェクトの6つの永続ドキュメントを対話的に作成します。

## 実行方法

```bash
claude
> /setup-project
```

## 実行前の確認

`docs/0_ideas/` ディレクトリ内のファイルを確認します。
```bash
# 確認
ls docs/0_ideas/

# ファイルが存在する場合
✅ docs/0_ideas/initial-requirements.md が見つかりました
   この内容を元にPRDを作成します

# ファイルが存在しない場合
⚠️  docs/0_ideas/ にファイルがありません
   対話形式でPRDを作成します
```

## 手順

### ステップ0: インプットの読み込み

1. `docs/0_ideas/` 内のマークダウンファイルを全て読む
2. 内容を理解し、PRD作成の参考にする

### ステップ1: プロダクト要求定義書の作成

1. **docs-prdスキル**をロード
2. `docs/0_ideas/`の内容を元に`docs/1_requirements/product-requirements.md`を作成
3. 壁打ちで出たアイデアを具体化：
   - 詳細なユーザーストーリー
   - 受け入れ条件
   - 非機能要件
   - 成功指標
4. ユーザーに確認を求め、**承認されるまで待機**

**以降のステップはプロダクト要求定義書の内容を元にするため、自動的に作成する**

### ステップ2: 機能設計書の作成

1. **docs-functional-designスキル**をロード
1. `docs/1_requirements/product-requirements.md`を読む
3. スキルのテンプレートとガイドに従って`docs/2_basic-design/functional-design.md`を作成

### ステップ3: アーキテクチャ設計書の作成

1. **docs-architecture-designスキル**をロード
2. 既存のドキュメントを読む
3. スキルのテンプレートとガイドに従って`docs/2_basic-design/architecture.md`を作成

### ステップ4: リポジトリ構造定義書の作成

1. **docs-repository-structureスキル**をロード
2. 既存のドキュメントを読む
3. スキルのテンプレートに従って`docs/3_detail-design/repository-structure.md`を作成

### ステップ5: 開発ガイドラインの作成

1. **docs-development-guidelinesスキル**をロード
2. 既存のドキュメントを読む
3. スキルのテンプレートに従って`docs/_shared/development-guidelines.md`を作成

### ステップ6: 用語集の作成

1. **docs-glossaryスキル**をロード
2. 既存のドキュメントを読む
3. スキルのテンプレートに従って`docs/_shared/glossary.md`を作成

## 完了条件

- 6つの永続ドキュメントが全て作成されていること

完了時のメッセージ:
```
「初回セットアップが完了しました!

作成したドキュメント:
✅ docs/1_requirements/product-requirements.md
✅ docs/2_basic-design/functional-design.md
✅ docs/2_basic-design/architecture.md
✅ docs/3_detail-design/repository-structure.md
✅ docs/_shared/development-guidelines.md
✅ docs/_shared/glossary.md

これで開発を開始する準備が整いました。

今後の使い方:
- ドキュメントの編集: 普通に会話で依頼してください
  例: 「PRDに新機能を追加して」「architecture.mdを見直して」

- 機能の追加: /add-feature [機能名] を実行してください
  例: /add-feature ユーザー認証

- ドキュメントレビュー: /review-docs [パス] を実行してください
  例: /review-docs docs/1_requirements/product-requirements.md
」
```