# 画面: 習慣管理 結合テスト仕様書

> 対象画面の詳細設計は [`screen-02-habits.md`](../3_detail-design/screen/screen-02-habits.md)。
> 使用するAPIの詳細設計は
> [`api-01-habits-list.md`](../3_detail-design/api/api-01-habits-list.md)・
> [`api-02-habits-create.md`](../3_detail-design/api/api-02-habits-create.md)・
> [`api-03-habits-get.md`](../3_detail-design/api/api-03-habits-get.md)・
> [`api-04-habits-update.md`](../3_detail-design/api/api-04-habits-update.md)・
> [`api-05-habits-archive.md`](../3_detail-design/api/api-05-habits-archive.md)。
> テスト方針全体は [`cross-cutting.md`](../_shared/cross-cutting.md)「テスト戦略」を正本とする。
> 本書は**習慣管理画面（HabitsPage）が呼び出すAPI群を横断した結合テスト**（testcontainers-go +
> 実PostgreSQL必須）を、画面操作の流れに沿ったシナリオ単位で列挙する。実DB不要のユニットテストは
> [`docs/specs/4_unit-test/`](../4_unit-test/) を参照。ブラウザ経由の真のE2E（Playwright）は
> `cross-cutting.md`「E2Eテスト」を参照（本書はAPI層までのシミュレーションに留め、実際のDOM操作は
> 検証しない）。

## テスト対象

| 画面 | 使用API | DBテーブル |
|---|---|---|
| 習慣管理（HabitsPage） | `GET /habits`（API-01）、`POST /habits`（API-02）、`GET /habits/{id}`（API-03）、`PUT /habits/{id}`（API-04）、`DELETE /habits/{id}`（API-05） | `habits`, `check_ins` |

## テストケース一覧

| No | シナリオ | 操作の流れ | 期待結果 | 完了 |
|---|---|---|---|:--:|
| 1 | 新規登録が一覧に反映される | `POST /habits` で `daily`/`weekly_count`/`specific_days` を1件ずつ登録 → `GET /habits` | 3件とも配列に含まれ、各習慣の `weeklyTargetCount`/`targetWeekdays` が種別に応じて実DB上で正しく `null`/値を持つ | [ ] |
| 2 | 一覧は `archived=false` のみを実DBのフィルタで返す | `archived=false` 2件 + `archived=true` 1件を実DBに投入 → `GET /habits` | `archived=false` の2件のみ返る（実際の `WHERE archived = false` の正しさを確認） | [ ] |
| 3 | 一覧が空のときは空配列 | `habits` テーブルが空の状態で `GET /habits` | `200`、空配列 `[]` | [ ] |
| 4 | 編集が一覧・詳細に反映される | 習慣を登録 → `PUT /habits/{id}` で `recurrenceType` を変更 → `GET /habits`・`GET /habits/{id}` | 一覧・詳細の両方で変更後の内容が返り、`updatedAt` が更新されている（実DBのUPDATE確認） | [ ] |
| 5 | アーカイブ後は一覧から消えるが詳細取得は可能 | 習慣を登録 → `DELETE /habits/{id}` → `GET /habits`・`GET /habits/{id}` | 一覧には含まれない。詳細取得では `archived=true` として200で取得できる（物理削除されていない） | [ ] |
| 6 | アーカイブしても関連チェックインは残る | 習慣を登録 → `check_ins` に数件記録 → `DELETE /habits/{id}` → `check_ins` を直接確認 | アーカイブ後も該当 `check_ins` レコードが削除されずに残っている（`habits`と`check_ins`を跨いだ整合性の確認） | [ ] |
| 7 | 存在しないIDでの操作は404 | 未登録のUUIDで `GET /habits/{id}`・`PUT /habits/{id}`・`DELETE /habits/{id}` | いずれも `404`「対象の習慣が見つかりません」 | [ ] |
| 8 | DB接続不可時は一覧取得が500 | testcontainers停止等でDB接続不可の状態で `GET /habits` | `500` | [ ] |

## 備考

- ケース1〜3・6はRepository層の実クエリ・実データを検証するため、フェイクリポジトリでは代替できない
  （[`test-api-01-habits-list.md`](../4_unit-test/test-api-01-habits-list.md) 等のユニットテストでは
  ロジックのみ検証済み）。
- ケース4〜5・7はHandler/Service/Repositoryを実DBで通しで検証する（ユニットテストで検証済みの
  Service層ロジックが、実際のSQLと組み合わさっても正しく動くことの確認）。
- 未実装（testcontainers-go導入時に実装予定）。
