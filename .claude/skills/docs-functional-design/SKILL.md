---
name: docs-functional-design
description: 機能設計書(docs/2_basic-design/functional-design.md が索引。詳細は functional-design/ に分割)を作成・更新するための詳細ガイドとテンプレート。PRDの要件を技術的にどう実現するかを設計する。機能設計書の作成・改訂時にのみ使用。
allowed-tools: Read, Write
---

# 機能設計書作成スキル

このスキルは、高品質な機能設計書を作成するための詳細ガイドです。

## 前提条件

機能設計書作成を開始する前に、以下を確認してください:

### docs/1_requirements/product-requirements.md が作成されている

**必須**: PRDが以下の場所に存在する必要があります:

**ファイルパス**: `docs/1_requirements/product-requirements.md`

機能設計書は、PRDで定義された要件を技術的に実現する方法を詳細化します。

## 既存ドキュメントの優先順位

**重要**: `docs/2_basic-design/functional-design.md`（索引。詳細は `functional-design/` に分割）に既存の機能設計書がある場合、
以下の優先順位に従ってください:

1. **既存の機能設計書 (`docs/2_basic-design/functional-design.md` ＋ `functional-design/`)** - 最優先
   - プロジェクト固有の設計が記載されている
   - このスキルのガイドより優先する

2. **このスキルのガイド** - 参考資料
   - 汎用的なテンプレートと例
   - 既存設計書がない場合、または補足として使用

**新規作成時**: このスキルのテンプレートとガイドを参照
**更新時**: 既存設計書の構造と内容を維持しながら更新

## 出力先

機能設計書は**索引 `functional-design.md`（`2_basic-design/` 直下）＋関心事ごとに分割した詳細ファイル群
（同名ディレクトリ `functional-design/`）**で構成します。索引に全体像（システム構成図・技術スタック）と
各詳細ファイルへのリンクを置きます。

```
docs/2_basic-design/
├── functional-design.md        # 索引・システム構成図・技術スタック
├── functional-design/          # 関心事ごとに分割した詳細
│   ├── data-model.md           # データモデル・ER図・制約
│   ├── component-design.md     # レイヤー別コンポーネント設計＋モジュール構成図
│   ├── usecase.md              # ユースケース図（シーケンス）
│   ├── screen-design.md        # 画面一覧・画面遷移図
│   ├── api-design.md           # API設計（API一覧）
│   ├── domain-logic.md         # アルゴリズム設計（中核）
│   └── cross-cutting.md        # UI・エラー・非機能・テスト戦略
└── architecture.md
```

> 分割の粒度はプロジェクト規模に応じて調整してよい（小規模なら索引 `functional-design.md` 1枚に集約も可）。
> **既存の構成がある場合はそれを維持**し、新規セクションは適切なファイルへ追記する。

## テンプレートの参照

テンプレートは**分割ファイルごとのスケルトン**として `./templates/` 配下に用意している。
新規作成時はすべて、個別ファイルの更新時は該当スケルトンのみを参照する。

| 作成/更新するファイル | 参照するスケルトン |
|---|---|
| `docs/2_basic-design/functional-design.md`（索引） | [`./templates/functional-design.md`](./templates/functional-design.md) |
| `functional-design/data-model.md` | [`./templates/data-model.md`](./templates/data-model.md) |
| `functional-design/component-design.md`（モジュール構成図を含む） | [`./templates/component-design.md`](./templates/component-design.md) |
| `functional-design/usecase.md` | [`./templates/usecase.md`](./templates/usecase.md) |
| `functional-design/screen-design.md` | [`./templates/screen-design.md`](./templates/screen-design.md) |
| `functional-design/api-design.md` | [`./templates/api-design.md`](./templates/api-design.md) |
| `functional-design/domain-logic.md` | [`./templates/domain-logic.md`](./templates/domain-logic.md) |
| `functional-design/cross-cutting.md` | [`./templates/cross-cutting.md`](./templates/cross-cutting.md) |

> **ファイル単位の更新**: プロジェクト進行に伴い特定の分割ファイルだけを更新する場合は、
> 対応するスケルトンの構成に沿って追記・修正する（全体を作り直す必要はない）。

## 詳細ガイド

さらに詳しい作成ガイドは次のファイルを参照してください: ./guide.md