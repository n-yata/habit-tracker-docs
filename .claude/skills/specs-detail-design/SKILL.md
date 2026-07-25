---
name: specs-detail-design
description: 詳細設計工程の成果物(docs/specs/3_detail-design/ のテーブル定義書・API詳細設計書・画面詳細設計書・単体テスト仕様書)を作成・更新するための詳細ガイドとテンプレート。baseline の機能設計書と2_basic-designの実装詳細を正本として、物理レベル・API単位・画面単位・テストケース単位まで詳細化する。詳細設計工程の成果物の作成・改訂時にのみ使用。
allowed-tools: Read, Write
---

# 詳細設計工程 成果物作成スキル

このスキルは、詳細設計工程の成果物（`docs/specs/3_detail-design/` 配下）を作成するための詳細ガイドです。
`db/` `api/` `screen/` `test/` の4区分で構成する。

| 成果物 | パス | 役割 |
|---|---|---|
| テーブル定義書 | `docs/specs/3_detail-design/db/table-definition.md` | 物理スキーマ（カラム定義・型・NULL可否・デフォルト・物理制約名・索引名）と設計メモ |
| API詳細設計書 | `docs/specs/3_detail-design/api/api-{ID}-{slug}.md`（API1件=1ファイル） | 当該APIのリクエスト/レスポンス仕様（型・必須・制約・バリデーション）・処理概要（レイヤー別フロー）・テスト観点 |
| 画面詳細設計書 | `docs/specs/3_detail-design/screen/screen-{ID}-{slug}.md`（画面1件=1ファイル） | 当該画面のコンポーネント構成（props/state）・状態管理（クエリキー設計）・詳細な画面遷移/イベント処理フロー・例外表示 |
| 単体テスト仕様書 | `docs/specs/3_detail-design/test/test-api-{ID}-{slug}.md`、`test/test-screen-{ID}-{slug}.md`（API/画面1件=1ファイル、上記api/screenと1対1対応） | 当該API/画面の具体的なテストケース一覧（前提・入力・期待結果・完了チェック欄） |

## このスキルの位置づけ（baseline / 2_basic-design との違い）

- `docs/baseline/functional-design.md` は**このリポジトリの指標＝正本**。エンティティ・区分値・
  ER図（概念モデル）、API一覧・画面一覧（ID・名称・概要のカタログ）、中核アルゴリズムを持つ。
- `docs/specs/2_basic-design/` は baseline のカタログを**実装レベルまで詳細化**したもの
  （全APIまとめて `api-design.md`、全画面まとめて `screen-design.md` の1ファイルずつ）。
- 本スキルが作る `docs/specs/3_detail-design/` は、**API/画面を1件ずつ独立したファイルに分割**し、
  さらに実装直前の粒度（バリデーション制約の全項目・コンポーネントのprops/state・具体的な
  テストケース）まで踏み込む。`db/` はデータモデルの物理スキーマを同様に詳細化する。

正本の順序: **baseline（概念・カタログ）→ 2_basic-design（API/画面まとめた実装詳細）→
3_detail-design（API/画面単位・物理単位・テストケース単位の最終詳細）**。齟齬が生じたら
上位（baseline側）を優先し、本成果物で概念・カタログを再定義しない。

## 前提条件

作成を開始する前に、以下が存在することを確認してください。

- `docs/baseline/functional-design.md`（機能設計書）— エンティティ・区分値・ER図・API一覧・画面一覧・
  中核アルゴリズムの正本
- `docs/specs/2_basic-design/api-design.md`・`screen-design.md`・`component-design.md` — API/画面の
  実装詳細（本成果物はこれをAPI/画面単位に分割・詳細化する）
- `docs/specs/_shared/cross-cutting.md` — テスト戦略・エラーハンドリング・UI表示仕様の正本
  （単体テスト仕様書の作成時に参照）

未作成の場合は、先に `baseline-functional-design` → `specs-basic-design` スキルで作成する。

## 既存ドキュメントの優先順位

`docs/specs/3_detail-design/` に既存の成果物がある場合、以下の優先順位に従ってください。

1. **既存のファイル群** — 最優先。プロジェクト固有の命名・粒度を維持する。
2. **このスキルのテンプレートとガイド** — 参考資料。新規作成時、または補足として使用。

**新規作成時**: 本スキルのテンプレートとガイドを参照。
**更新時**: 既存ファイルの構造・命名規則を維持しながら更新する。API/画面/テストは新規追加分のみ
ファイルを追加すればよく、既存ファイル群を作り直す必要はない。

## 出力先

```
docs/specs/3_detail-design/
├── db/
│   └── table-definition.md          # 物理スキーマ（カラム定義・型・制約・索引）＋設計メモ
├── api/
│   └── api-{ID}-{slug}.md            # API 1件ごとの詳細設計（baseline の API一覧の ID と対応）
├── screen/
│   └── screen-{ID}-{slug}.md         # 画面 1件ごとの詳細設計（baseline の画面一覧の名称と対応）
└── test/
    ├── test-api-{ID}-{slug}.md       # api/ と1対1対応する単体テスト仕様書
    └── test-screen-{ID}-{slug}.md    # screen/ と1対1対応する単体テスト仕様書
```

ファイル名の `{ID}` は baseline の API一覧（`API-01`等）・画面一覧の並び順に対応させる。
`{slug}` は内容が分かる英語スラッグ（例: `api-02-habits-create.md`、`screen-01-dashboard.md`）。

## テンプレートの参照

| 作成/更新するファイル | 参照するスケルトン |
|---|---|
| `docs/specs/3_detail-design/db/table-definition.md` | [`./templates/table-definition.md`](./templates/table-definition.md) |
| `docs/specs/3_detail-design/api/api-{ID}-{slug}.md` | [`./templates/api-detail.md`](./templates/api-detail.md) |
| `docs/specs/3_detail-design/screen/screen-{ID}-{slug}.md` | [`./templates/screen-detail.md`](./templates/screen-detail.md) |
| `docs/specs/3_detail-design/test/test-api-{ID}-{slug}.md` | [`./templates/test-api.md`](./templates/test-api.md) |
| `docs/specs/3_detail-design/test/test-screen-{ID}-{slug}.md` | [`./templates/test-screen.md`](./templates/test-screen.md) |

## 作成プロセス（要点）

### db/（テーブル定義書）
1. baseline の機能設計書「データモデル」を読み、エンティティ・区分値・ER図・ドメイン上の制約を把握する。
2. テーブルごとにカラム定義表（物理名・論理名・型・NULL可否・デフォルト・説明）を書く。
3. 制約・インデックスを物理名付きで列挙する。
4. 設計メモ（確定事項）を書く。「詳細設計で確定」のような先送りをここに残さない。

### api/（API詳細設計書、API単位）
1. `docs/specs/2_basic-design/api-design.md` の該当API概要と、baseline「API一覧」のIDを読む。
2. リクエスト仕様（全パラメータの型・必須・制約・バリデーションルール）を表にする。
3. レスポンス仕様（成功時全フィールド・エラー時のステータス別レスポンス例）を書く。
4. 処理概要（Handler→Service→Domain/Repositoryの処理フロー、呼び出す関数名）を箇条書きにする。
5. テスト観点（正常系・異常系・境界値の概要）を書く（詳細なケース一覧は `test/` 側）。

### screen/（画面詳細設計書、画面単位）
1. `docs/specs/2_basic-design/screen-design.md` の該当画面レイアウト・項目・イベントと、
   `component-design.md` のフロントエンド責務を読む。
2. コンポーネント構成（ツリー）とprops/state設計を書く。screen-design.mdの「詳細設計への申し送り」
   で委譲されているコンポーネント分割・状態管理（TanStack Queryのキー設計等）はここで確定させる。
3. 画面遷移・イベント処理の詳細フロー（操作→API呼び出し→状態更新の手順）を書く。
4. 例外・エラー表示のケースを書く。

### test/（単体テスト仕様書、api/screenと1対1）
1. 対応する `api/`・`screen/` ファイルとbaseline/cross-cuttingのテスト戦略を読む。
2. テスト対象（レイヤー・関数名・テスト種別）を表にする。
3. テストケース一覧を書く。**具体的な入力値と期待結果を書く**（「正しく動作すること」のような
   曖昧な記述は禁止。プロジェクトCLAUDE.mdの「テストコード作成時の注意事項」に準拠）。
   境界値・異常系を必ず含める。
4. 各テストケース行に「完了」チェック欄（`[ ]`）を付ける。実施後に `[x]` へ手動で書き換えて
   進捗管理する。
5. Domain層など複数APIから参照される中核アルゴリズムのテストケースは、最初に参照するAPIの
   test ファイルにまとめ、他ファイルからは「〜を参照」で重複を避ける。

### 共通
- **1ファイルずつユーザーの承認を得る**（プロジェクト CLAUDE.md「ドキュメント作成時」ルール）。
  ただし db/api/screen/test のように大量の同種ファイルを作る場合は、先にテンプレート・記載粒度を
  ユーザーと合意してから一括作成し、まとめてレビューを受ける運用でもよい（実運用ではこの合意形成
  ステップが重要）。
- 相対リンクのパス階層に注意する（`3_detail-design/api/*.md` から baseline へは `../../../baseline/...`、
  `2_basic-design/` へは `../../2_basic-design/...`）。

> **小規模プロジェクトの簡略化**: API数・画面数が少ない場合は、api/screen/testをAPI/画面単位に
> 分割せず、2_basic-designの4ファイルにテスト観点を書き足すだけで済ませてもよい
> （`specs-basic-design` スキルの判断に委ねる）。

## 詳細ガイド

さらに詳しい作成手順・品質基準は次のファイルを参照してください: ./guide.md
