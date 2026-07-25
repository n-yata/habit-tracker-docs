---
name: specs-detail-design
description: 詳細設計工程の成果物(docs/specs/3_detail-design/ のテーブル定義書。物理スキーマ=カラム定義・型・物理制約名・索引名)を作成・更新するための詳細ガイドとテンプレート。baseline の機能設計書の概念モデル(ER図・区分値)を正本として、物理レベルまで詳細化する。詳細設計工程の成果物の作成・改訂時にのみ使用。
allowed-tools: Read, Write
---

# 詳細設計工程 成果物作成スキル

このスキルは、詳細設計工程の成果物（`docs/specs/3_detail-design/` 配下）を作成するための詳細ガイドです。
現時点の対象は以下の1ファイル。

| 成果物 | パス | 役割 |
|---|---|---|
| テーブル定義書 | `docs/specs/3_detail-design/db/table-definition.md` | 物理スキーマ（カラム定義・型・NULL可否・デフォルト・物理制約名・索引名）と設計メモ |

## このスキルの位置づけ（baseline-functional-design との違い）

`docs/baseline/functional-design.md`「データモデル」は**このリポジトリの指標＝正本**で、
**概念モデル**（エンティティ・区分値・ドメイン上の制約・ER図）を持つ。これは
`baseline-functional-design` スキルが作る。

本スキルが作る `docs/specs/3_detail-design/db/table-definition.md` は、baseline の概念モデルを
**物理スキーマ（カラム・型・物理制約名・索引名）まで詳細化**したもの。

- **正本（一次情報）は baseline 側**（エンティティ名・区分値・ER図・業務ルール）。
- **本成果物はそれを物理レベルまで具体化**する。**論理・外部から見た設計＝基本設計**
  （baseline の ER図）、**物理・具体＝詳細設計**（本成果物）という境界に対応する
  （プロジェクト CLAUDE.md「基本設計と詳細設計の境界」参照）。
- **齟齬が生じたら baseline を優先**する。エンティティ・区分値・業務ルールはここで再定義しない。
- 論理的なバリデーション規則（例: 区分ごとの入力必須/任意）の正本は要件定義書の該当 FR
  （`docs/specs/1_requirements/requirements-definition.md`）に置き、本成果物は物理 CHECK 制約と
  して対応づけるだけに留める。

## 前提条件

作成を開始する前に、以下が存在することを確認してください。

- `docs/baseline/functional-design.md`（機能設計書）— エンティティ・区分値・ドメイン上の制約・ER図
  の正本

未作成の場合は、先に `baseline-functional-design` スキルで作成する。

## 既存ドキュメントの優先順位

`docs/specs/3_detail-design/` に既存の成果物がある場合、以下の優先順位に従ってください。

1. **既存の table-definition.md** — 最優先。プロジェクト固有のカラム名・制約名を維持する。
2. **このスキルのテンプレートとガイド** — 参考資料。新規作成時、または補足として使用。

**新規作成時**: 本スキルのテンプレートとガイドを参照。
**更新時**: 既存ファイルの構造・命名規則を維持しながら更新する。

## 出力先

```
docs/specs/3_detail-design/
└── db/
    └── table-definition.md   # 物理スキーマ（カラム定義・型・制約・索引）＋設計メモ
```

> `db/` サブディレクトリは、`3_detail-design/` 配下を対象（テーブル定義＝`db/`、API詳細＝`api/`、
> 画面詳細＝`screen/` 等）で区分する構成に合わせたもの。

## テンプレートの参照

| 作成/更新するファイル | 参照するスケルトン |
|---|---|
| `docs/specs/3_detail-design/db/table-definition.md` | [`./templates/table-definition.md`](./templates/table-definition.md) |

## 作成プロセス（要点）

1. **baseline の機能設計書「データモデル」を読む** — エンティティ・区分値・ER図・ドメイン上の
   制約を把握する。ER図の論理名（日本語）とテーブル物理名（snake_case）の対応を確認する
   （例: `recurrenceType` ↔ `recurrence_type`）。
2. **テーブルごとにカラム定義表を書く** — 物理名・論理名・型・NULL可否・デフォルト・説明を列挙する。
3. **制約・インデックスを書く** — PK/FK/CHECK/UNIQUE/INDEX を物理名付きで列挙する。CHECK制約が
   表す論理規則（区分による必須/任意の切り替えなど）は、要件定義書の該当 FR と対応づける
   （規則そのものはそちらが正本、ここでは物理制約として表現するだけ）。
4. **設計メモ（確定事項）を書く** — DBバージョン依存・FK削除挙動・`updated_at`更新方式など、
   後から曖昧にされたくない物理実装判断を列挙する。**「詳細設計で確定」のような先送りをここに
   残さない**（この場で確定させる）。
5. **1ファイルずつユーザーの承認を得る**（プロジェクト CLAUDE.md「ドキュメント作成時」ルール）。

> **小規模プロジェクトの簡略化**: テーブル数が少なく物理DDLがほぼ自明な場合は、本ファイルを作らず
> baseline の `functional-design.md`「データモデル」に物理スキーマまで含めてもよい
> （`baseline-functional-design` スキルの判断に委ねる）。

## 詳細ガイド

さらに詳しい作成手順・品質基準は次のファイルを参照してください: ./guide.md
