---
name: baseline-functional-design
description: 機能設計書(docs/baseline/functional-design.md。データモデル・中核アルゴリズム・API/画面/ユースケースの一覧など、プロジェクトの指標としてぶれてはいけない重要点の正本。実装詳細は docs/specs/2_basic-design/ と docs/specs/_shared/ に分割)を作成・更新するための詳細ガイドとテンプレート。PRDの要件を技術的にどう実現するかを設計する。機能設計書の作成・改訂時にのみ使用。
allowed-tools: Read, Write
---

# 機能設計書作成スキル

このスキルは、高品質な機能設計書を作成するための詳細ガイドです。

## 前提条件

機能設計書作成を開始する前に、以下を確認してください:

### docs/baseline/product-requirements.md が作成されている

**必須**: PRDが以下の場所に存在する必要があります:

**ファイルパス**: `docs/baseline/product-requirements.md`

機能設計書は、PRDで定義された要件を技術的に実現する方法を詳細化します。

## 既存ドキュメントの優先順位

**重要**: `docs/baseline/functional-design.md`（プロジェクトの指標。実装詳細は
`docs/specs/2_basic-design/` と `docs/specs/_shared/` に分割）に
既存の機能設計書がある場合、以下の優先順位に従ってください:

1. **既存の機能設計書 (`docs/baseline/functional-design.md` ＋ `docs/specs/2_basic-design/` ＋ `docs/specs/_shared/`)** - 最優先
   - プロジェクト固有の設計が記載されている
   - このスキルのガイドより優先する

2. **このスキルのガイド** - 参考資料
   - 汎用的なテンプレートと例
   - 既存設計書がない場合、または補足として使用

**新規作成時**: このスキルのテンプレートとガイドを参照
**更新時**: 既存設計書の構造と内容を維持しながら更新

## 出力先

機能設計書は **`docs/baseline/functional-design.md`（重要点の正本）＋ 実装詳細を分割した
`docs/specs/2_basic-design/` と `docs/specs/_shared/`** で構成します。

```
docs/baseline/
└── functional-design.md          # 重要点の正本（下記「baseline に書く内容」）
docs/specs/2_basic-design/       # この機能設計固有の実装詳細
├── component-design.md            # レイヤー別インターフェース詳細
├── usecase.md                     # ユースケースのシーケンス図フル
└── api-design.md                  # 各APIの入出力詳細・JSON例・エラーレスポンス
docs/specs/_shared/
└── cross-cutting.md              # フェーズ横断で参照する実装詳細（UI表示仕様・非機能・テスト戦略）
```

**baseline に書く内容（`functional-design.md`）**: システム構成図・技術スタック・データモデル
（物理スキーマ表を含む）・アルゴリズム設計（中核ロジック）・API一覧（カタログ表）・画面設計
（一覧＋遷移図）・ユースケース一覧（表）・モジュール構成図。**記載漏れやあいまいな未確定事項
（「詳細設計で確定」等の曖昧な先送り）を残してはいけない。**

**specs に書く内容**: JSON入出力例、レイヤー別の擬似インターフェース、シーケンス図のフル表記、
UI表示仕様やテスト戦略の詳細など、**必要な時にだけ参照すればよい実装レベルの記述**。この機能設計
固有のものは `docs/specs/2_basic-design/`、特定フェーズに閉じずフェーズ横断で
参照する内容（UI/エラー/テスト戦略など）は `docs/specs/_shared/` へ。

> 分割の判断基準（迷ったときの原則）は `CLAUDE.md`「baseline と specs の使い分け」を参照。
> **既存の構成がある場合はそれを維持**し、新規セクションは適切なファイルへ追記する。
> プロジェクト規模が小さい場合は、specs 側のファイルを作らず baseline の `functional-design.md`
> 1枚に集約してもよい。

## テンプレートの参照

テンプレートは `./templates/` 配下に用意している。新規作成時はすべて、個別ファイルの更新時は
該当スケルトンのみを参照する。

| 作成/更新するファイル | 参照するスケルトン |
|---|---|
| `docs/baseline/functional-design.md`（重要点の正本） | [`./templates/functional-design.md`](./templates/functional-design.md) |
| `docs/specs/2_basic-design/component-design.md` | [`./templates/component-design.md`](./templates/component-design.md) |
| `docs/specs/2_basic-design/usecase.md` | [`./templates/usecase.md`](./templates/usecase.md) |
| `docs/specs/2_basic-design/api-design.md` | [`./templates/api-design.md`](./templates/api-design.md) |
| `docs/specs/_shared/cross-cutting.md` | [`./templates/cross-cutting.md`](./templates/cross-cutting.md) |

> **ファイル単位の更新**: プロジェクト進行に伴い特定のファイルだけを更新する場合は、
> 対応するスケルトンの構成に沿って追記・修正する（全体を作り直す必要はない）。

## 詳細ガイド

さらに詳しい作成ガイドは次のファイルを参照してください: ./guide.md
