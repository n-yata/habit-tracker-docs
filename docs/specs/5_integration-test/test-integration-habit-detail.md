# 画面: 習慣詳細 結合テスト仕様書

> 対象画面の詳細設計は
> [`screen-04-habit-detail.md`](../3_detail-design/screen/screen-04-habit-detail.md)。
> 使用するAPIの詳細設計は
> [`api-03-habits-get.md`](../3_detail-design/api/api-03-habits-get.md)・
> [`api-08-dashboard-summary.md`](../3_detail-design/api/api-08-dashboard-summary.md)。
> テスト方針全体は [`cross-cutting.md`](../_shared/cross-cutting.md)「テスト戦略」を正本とする。
> 本書は**習慣詳細画面（HabitDetailPage）が呼び出すAPI群を横断した結合テスト**
> （testcontainers-go + 実PostgreSQL必須）を、画面操作の流れに沿ったシナリオ単位で列挙する。
> 実DB不要のユニットテストは [`docs/specs/4_unit-test/`](../4_unit-test/) を参照。ブラウザ経由の
> 真のE2E（Playwright）は `cross-cutting.md`「E2Eテスト」を参照（本書はAPI層までの
> シミュレーションに留める）。

## テスト対象

| 画面 | 使用API | DBテーブル |
|---|---|---|
| 習慣詳細（HabitDetailPage） | `GET /habits/{id}`（API-03）、`GET /dashboard`（API-08） | `habits`, `check_ins` |

## テストケース一覧

| No | シナリオ | 操作の流れ | 期待結果 | 完了 |
|---|---|---|---|:--:|
| 1 | 習慣詳細と集計を組み合わせて画面表示相当のデータが取得できる | 習慣を登録しチェックインを数件記録 → `GET /habits/{id}` と `GET /dashboard?from=&to=` を呼び出す | `GET /habits/{id}` の習慣情報と、`GET /dashboard` の当該 `habitId` に対応する集計（ストリーク・達成率・ヒートマップ）が整合する（同一習慣の実データに基づく） | [x] |
| 2 | アーカイブ済み習慣でも詳細・集計が取得できる | 習慣を登録・記録 → `DELETE /habits/{id}` でアーカイブ → `GET /habits/{id}`・`GET /dashboard?habitId={id}` | 詳細は `archived=true` として200で取得でき、`habitId` クエリ指定時は集計もアーカイブ前の記録を含めて算出される（`habitId` 未指定の通常集計からは除外されることも確認） | [x] |
| 3 | 存在しない習慣IDでは詳細取得が404 | 未登録のUUIDで `GET /habits/{id}` | `404`「対象の習慣が見つかりません」 | [x] |

## 備考

- ケース1・2は [`test-integration-habits.md`](./test-integration-habits.md) ケース5（アーカイブ後の詳細取得）
  と重複しない範囲で、ダッシュボード集計との組み合わせに焦点を当てる。
