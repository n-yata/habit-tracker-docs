# 振り返り: 画面設計書の追加とスキルの責務分割（baseline-functional-design / specs-basic-design）

- 作業日: 2026-07-25
- ブランチ: `docs/20260725-screen-design`
- 種別: ドキュメント成果物の追加＋スキルの責務再分割（学びがあるため retrospective のみ残す）

## やったこと

1. `docs/specs/2_basic-design/screen-design.md` を新規作成（4画面のレイアウト・項目定義・イベント）
2. `docs/baseline/functional-design.md`「画面設計」に screen-design.md への参照リンクを追記
3. スキルの責務を分割
   - `baseline-functional-design`: `docs/baseline/functional-design.md`（重要点の正本）＋
     `docs/specs/_shared/cross-cutting.md`（フェーズ横断の実装詳細）のみを作る形に縮小
   - `specs-basic-design`（新設）: `docs/specs/2_basic-design/` の4本
     （component-design.md・usecase.md・screen-design.md・api-design.md）を作る
   - 既存テンプレ3本を `git mv` で移設、screen-design テンプレは新規作成

## 学び・申し送り

### 1. 「既存で表現済みか」を先に確認してから新規ドキュメントを作る（RTM の教訓の再適用）
- 2_basic-design の棚卸しで、システム構成図・DB設計（ER・物理スキーマ）は既に baseline に
  正本があるため作らず、**画面設計書だけが欠けている**と判断してから着手した。
- 申し送り: 「基本設計として何が足りないか」を問われたら、先に baseline と既存 specs を全部読んで
  カバレッジ表を作ってから答える。空欄を無闇に埋めない。

### 2. 1スキルが肥大化したら「誰が何を作るか」で割る判断基準
- `baseline-functional-design` は元々 baseline（重要点の正本）と `2_basic-design`（実装詳細）を
  同時に作っていた。ユーザーから「2_のドキュメントを作らない形にして、別スキルを新設して」との
  指示で分割。判断基準は「baseline に書く内容（一覧・カタログ・正本表・中核ロジック）」と
  「specs に書く内容（JSON例・擬似インターフェース・シーケンス図フル・画面レイアウトなどの
  実装レベル）」の性質の違い。**1スキルが両方を持つと、更新時にどちらの粒度で編集すべきか
  曖昧になる**ため、性質が異なる成果物は別スキルに割った方が保守しやすい。
- 一方で `_shared/cross-cutting.md`（UI/エラー/テスト戦略、フェーズ横断）は分割の対象にしなかった。
  ユーザーの指示スコープが「2_のドキュメント」に限定されていたため、_shared は
  `baseline-functional-design` に残した。指示範囲を超えて分割しすぎないことも大事な判断。

### 3. スキルを分割・改名したら、参照している全箇所を洗い出す
- `baseline-functional-design` の SKILL.md/guide.md/templates だけでなく、
  `.claude/README.md`（カタログ）、`flow-setup-project`（初回セットアップの完了メッセージに
  「実装詳細は 2_basic-design に分割」という古い記述が残っており、修正しないと**初回セットアップで
  2_basic-design を作らなくなったにもかかわらず「作成した」と誤報告する**バグになるところだった）。
- 申し送り: スキルの責務変更時は、`grep -rl` で影響ファイルを機械的に洗い出し、「事実の記述
  （ディレクトリの中身の説明）」と「所有権の主張（このスキルが作る、という記述）」を区別して
  直す。事実の記述はそのまま残してよい場合が多いが、完了メッセージや前提条件のような
  **フロー制御に関わる記述は必ず確認する**（内容が古いと動作の矛盾を生む）。

## 次への注意
- `3_detail-design` に進む際も、baseline / specs の役割分担が既に確立しているので
  （baseline=指標・正本、specs=顧客提出成果物または実装詳細）、同じ原則で「新規スキルが要るか、
  既存スキルの拡張で足りるか」を先に見極めてから着手する。
- DB のマイグレーションSQL（golang-migrate の up/down）は baseline の物理スキーマ表を正本として、
  詳細設計／実装フェーズで生成する（現時点では未着手であり、これは意図的なスコープ外）。
