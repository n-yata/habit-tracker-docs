# API設計

> 【分割テンプレート】このファイルは `docs/2_basic-design/functional-design/api-design.md` に配置する。
> 機能設計書の一部。親: [`functional-design.md`](../functional-design.md)。
> API契約の正本がある場合（例: `openapi.yaml`）はそれを正本とし、本ファイルは骨子を示す。
> データ型は [`data-model.md`](./data-model.md) を参照。

## エンドポイント一覧

| メソッド | パス | 概要 |
|---|---|---|
| GET | `/[resource]` | [説明] |
| POST | `/[resource]` | [説明] |
| PUT | `/[resource]/{id}` | [説明] |
| DELETE | `/[resource]/{id}` | [説明] |

## 例: [エンドポイント名]

```
POST /[resource]
```

**リクエスト**:
```json
{
  "[field]": "[value]"
}
```

**レスポンス (201)**:
```json
{
  "id": "uuid",
  "[field]": "[value]"
}
```

## エラーレスポンス

- 400 Bad Request: [条件（バリデーション違反など）]
- 404 Not Found: [条件]
- 409 Conflict: [条件]
- 500 Internal Server Error: [条件]

> エラー分類・表示メッセージは [`cross-cutting.md`](./cross-cutting.md) の「エラーハンドリング」と対応させる。
