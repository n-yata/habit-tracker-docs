# ユースケース図（シーケンス詳細）

> 機能設計書の一部。ユースケース一覧（ID・アクター・目的・関連画面）の正本は
> [`functional-design.md`](../../../baseline/functional-design.md)「ユースケース一覧」。
> 本ファイルは各ユースケースのレイヤー横断シーケンス（システム挙動）の詳細のみを置く。
> 画面一覧・画面遷移は baseline の「画面設計」、各層の責務は [`component-design.md`](./component-design.md)、
> 集計アルゴリズムは baseline の「アルゴリズム設計（ドメインロジック）」を参照。

## ユースケース: 日次チェックイン（UC-01）

```mermaid
sequenceDiagram
    participant User as ユーザー(ブラウザ)
    participant FE as Next.js
    participant H as Handler
    participant S as CheckInService
    participant D as Domain
    participant R as Repository
    participant DB as PostgreSQL

    User->>FE: 当日ダッシュボードを開く
    FE->>H: GET /check-ins?date=today
    H->>S: getCheckInsForDate(today)
    S->>R: listActive() / listByDate(today)
    R->>DB: SELECT habits / checkins
    DB-->>R: rows
    R-->>S: habits, checkins
    S->>D: isTargetDate(habit, today) で対象を抽出
    D-->>S: 対象習慣 + overdue 判定
    S-->>H: 対象習慣と記録状態
    H-->>FE: 200 (対象習慣リスト)
    FE-->>User: 当日対象＋リマインド超過ハイライト表示

    User->>FE: ある習慣を「完了」にする
    FE->>H: PUT /habits/{id}/check-ins/{date} {status:"done"}
    H->>S: recordCheckIn(id, date, done)
    S->>D: isTargetDate(habit, date) で妥当性確認
    S->>R: upsert(checkin)
    R->>DB: INSERT ... ON CONFLICT UPDATE
    DB-->>R: ok
    S-->>H: CheckIn
    H-->>FE: 200
    FE-->>User: 楽観更新でチェック反映＋ストリーク再取得
```

## ユースケース: 可視化（ダッシュボード集計）（UC-02）

```mermaid
sequenceDiagram
    participant FE as Next.js
    participant H as Handler
    participant S as DashboardService
    participant D as Domain
    participant R as Repository

    FE->>H: GET /dashboard?from=..&to=..
    H->>S: getSummary(range)
    S->>R: listActive() / listByHabitInRange(...)
    R-->>S: habits, checkins
    S->>D: calcStreak / calcAchievementRate / ヒートマップ生成
    D-->>S: 集計結果
    S-->>H: DashboardSummary
    H-->>FE: 200 (ストリーク/達成率/ヒートマップ)
```

集計アルゴリズムの詳細は [`functional-design.md`](../../../baseline/functional-design.md)「アルゴリズム設計（ドメインロジック）」を参照。
