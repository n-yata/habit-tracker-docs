# コンポーネント設計（レイヤー別インターフェース詳細）

> 機能設計書の一部。親・モジュール構成図（画面×API×バックエンド）の正本は
> [`functional-design.md`](../../../baseline/functional-design.md)。本ファイルはレイヤー別
> （Handler / Service / Domain / Repository / Frontend）の責務・インターフェース（擬似コード）・
> 依存関係の詳細のみを置く。
> データモデルは baseline の「データモデル」、アルゴリズムは baseline の「アルゴリズム設計（ドメインロジック）」を参照。

## Domain層（backend / 外部依存なし・テストの主対象）

**責務**:
- ある日付が習慣の対象日かを判定する（繰り返しルール解釈）。
- チェックイン記録列からストリーク（現在・最長）を算出する。
- 週次・月次の達成率とヒートマップ用データを集計する。

**インターフェース（擬似）**:
```typescript
// 繰り返し判定
function isTargetDate(habit: Habit, date: string): boolean;

// 期間内の対象日一覧
function targetDatesInRange(habit: Habit, from: string, to: string): string[];

// ストリーク算出（対象外の日は連続を途切れさせない／対象日の未達成で途切れる）
function calcStreak(habit: Habit, checkIns: CheckIn[], today: string): {
  current: number;
  longest: number;
};

// 達成率（対象日に対する done の割合）
function calcAchievementRate(habit: Habit, checkIns: CheckIn[], from: string, to: string): number;
```

**依存関係**: なし（Go の標準ライブラリのみ）。ロジックの詳細は baseline の「アルゴリズム設計（ドメインロジック）」。

## Repository層（backend）

**責務**: Habit・CheckIn の永続化と取得（sqlc 生成コード + pgx）。

**インターフェース（擬似）**:
```typescript
interface HabitRepository {
  create(h: Habit): Habit;
  update(h: Habit): Habit;
  archive(id: string): void;
  findById(id: string): Habit | null;
  listActive(): Habit[];
}

interface CheckInRepository {
  upsert(c: CheckIn): CheckIn;                       // (habitId,date) で upsert
  listByHabitInRange(habitId: string, from: string, to: string): CheckIn[];
  listByDate(date: string): CheckIn[];
}
```

**依存関係**: PostgreSQL（pgx コネクション）。

## Service層（backend）

**責務**: ユースケースの組み立て。Domain層で判定・計算し、Repository で永続化する。

**主なユースケース**:
```typescript
interface HabitService {
  createHabit(input): Habit;              // バリデーション→保存
  updateHabit(id, input): Habit;
  deleteHabit(id): void;                  // archive
  listHabits(): Habit[];
}

interface CheckInService {
  // 指定日の対象習慣＋現在の記録状態を返す（ダッシュボード/チェックイン画面用）
  getCheckInsForDate(date): { habit: Habit; status: CheckInStatus | null; overdue: boolean }[];
  // 完了/未完了を記録（対象日判定→upsert→関連集計の再計算はGET側で都度算出）
  recordCheckIn(habitId, date, status): CheckIn;
}

interface DashboardService {
  // 習慣ごとのストリーク・達成率・ヒートマップを集約
  getSummary(range): DashboardSummary;
}
```

## Handler層（backend）

**責務**: OpenAPI 契約から生成した型で HTTP 入出力を受け、Service に委譲。バリデーションエラー・
NotFound を HTTP ステータスに変換する。エンドポイント仕様は [`api-design.md`](./api-design.md)。

## フロントエンド（frontend / Next.js）

**責務**: 画面描画とユーザー操作。TanStack Query で Go API を呼び、キャッシュ・楽観更新を行う。
OpenAPI から生成した TS クライアント型を用いる。

**主なコンポーネント**:
- ページコンポーネント（`DashboardPage` / `HabitsPage` / `CheckInPage` / `HabitDetailPage`）。
  各ページの目的・ルート・扱うデータの一覧は baseline の「画面設計」の画面一覧を正本とする。
- `HeatmapCalendar`・`StreakBadge`・`AchievementRing` などの表示コンポーネント。

画面一覧・画面遷移は baseline の「画面設計」、ユースケースの流れは [`usecase.md`](./usecase.md)、
UI 表示仕様は [`cross-cutting.md`](../../_shared/cross-cutting.md) を参照。モジュール構成図（画面×API×バックエンド）は
[`functional-design.md`](../../../baseline/functional-design.md)「モジュール構成図」を参照。
