# 振り返り: テスト仕様書の工程分離（3_detail-design/test → 4_unit-test / 5_integration-test）

## 何が起きたか

`docs/specs/3_detail-design/test/test-api-{ID}-{slug}.md` は「単体テスト仕様書」という名称にも
関わらず、テンプレート自体が「テスト種別: {ユニットテスト/統合テスト}」を許容する作りになっており、
実際に8ファイル中5ファイルでRepository層の統合テスト（testcontainers-go + 実PostgreSQL前提）の
ケースが混在していた。シャビの指摘で発覚。

最初の対応として `test-api-{ID}-{slug}.md`（単体）と `test-api-{ID}-{slug}-integration.md`（統合）を
API単位でペア化する案を実装したが、続けて2点の指摘を受けて設計をやり直した。

1. **CLAUDE.mdの既存ルールとの矛盾**: CLAUDE.mdには「詳細設計の残り・テスト設計・実装・結合テストは
   baselineではなく.steeringが担当する」という記述があり、そもそも「4_」のような追加の工程
   ディレクトリを`docs/specs/`配下に設ける想定が明文化されていなかった。
2. **結合テストの粒度の誤り**: 結合テストをAPI単位のファイルに分割すると、「画面が複数のAPIを
   呼び出して一連の操作を完結させる」という結合テスト本来の目的（画面込みの検証）を表現できない。

最終的にシャビの判断で、`docs/specs/` に新たな工程ディレクトリ `4_unit-test/`（単体）・
`5_integration-test/`（結合、画面単位）を追加する方針で確定した。

## 最終構成

```
docs/specs/
  3_detail-design/    # db/api/screen のみ（テストケース一覧は含まない）
  4_unit-test/         # test-api-{ID}-{slug}.md・test-screen-{ID}-{slug}.md（API/画面単位、実DB不要）
  5_integration-test/  # test-integration-{screen-slug}.md（画面単位、実PostgreSQL必須。API単位には分割しない）
```

- `specs-detail-design` スキルからテスト関連の記述を全て除去し、db/api/screenの3区分に戻した。
- `specs-unit-test`・`specs-integration-test` の2スキルを新設し、それぞれ`4_unit-test/`・
  `5_integration-test/`の作成を担当させた。
- 既存17ファイル（単体8+4画面、統合5）を新構成に移動し、相対リンクを全て再計算した。
  結合テストは画面単位（4ファイル）に再編し、元のAPI単位のケースを画面のシナリオへ統合した。
- CLAUDE.mdのディレクトリ構造図・「baselineとの使い分け」の重要事項を更新し、テストケース仕様の
  永続的な置き場所が`specs/4,5`であることを明記（実装・テスト実施そのものは引き続き`.steering/`）。

## 学び・申し送り

- **テンプレート自体がスコープを緩く許容していると、実ファイルもスコープが曖昧になる。**
  ドキュメント種別が名前で意味を持つ場合は、テンプレートの時点で種別ごとにファイルを分離しておく。
- **CLAUDE.mdの既存ルールと矛盾しないか、着手前に確認する。** 今回は「4_」ディレクトリを作る前に
  CLAUDE.mdの明文化されたルール（テスト設計は.steering担当）を見落としたまま作業を進めてしまい、
  1往復無駄にした。ドキュメント構造を変更する提案をする前に、必ずCLAUDE.mdの該当セクションを
  読み直す。
- **「結合テスト」は境界（画面・ユースケース）で分割し、「単体テスト」の分割単位（API/コンポーネント）
  をそのまま使い回さない。** 結合テストの目的は複数コンポーネントを跨ぐ振る舞いの検証であり、
  分割単位を誤ると本来の目的を表現できなくなる。
- 判定基準（今回採用したもの）: Domain純粋関数・フェイクRepository/フェイクServiceで検証できる
  ケース → 単体（`4_unit-test/`、API/画面ごとに1ファイル）。実SQL・DB制約（UNIQUE/CHECK/FK）・
  画面操作からAPI・DBまでの一連の流れ → 結合（`5_integration-test/`、画面ごとに1ファイル）。
  ブラウザでの実DOM操作 → E2E（`cross-cutting.md`側、Playwright、本工程の対象外）。
