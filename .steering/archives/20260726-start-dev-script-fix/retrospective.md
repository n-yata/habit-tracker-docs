# 振り返り: start-dev.ps1 起動失敗の解消とCORS対応

## 概要

`scripts/start-dev.ps1` 実行時に発生した2段階のエラー（`DATABASE_URL is not set` →
CORSエラー）を順に解消した。実装は habit-tracker-docs（スクリプト）と
habit-tracker-backend（CORS対応）の2リポジトリにまたがる。あわせて
habit-tracker-backend / habit-tracker-frontend の GitHub リモート初期設定も行った。

## 学び・申し送り

### 1. 「動くようになった」ことで次の不具合が見えるのは正常な進行

`DATABASE_URL is not set` で backend が起動できていなかった間は、CORS未対応という
別の不具合が一度も表面化していなかった。スクリプト修正後にbackendが起動できるように
なって初めて「frontend→backendのfetchがCORSでブロックされる」問題が発覚した。

**Why**: ユーザーから「スクリプトが余計なことをしたのでは」と疑われた場面があった。
起動失敗が連鎖している場合、直前の修正が新しいエラーの「原因」ではなく「発見のきっかけ」
であることが多い。

**How to apply**: 次のエラーが出ても、直前の変更を疑う前に「このエラーは前から潜在
していて、今回初めて到達できるようになっただけではないか」を先に確認する
（`grep`で関連実装の有無を確認するなど）。

### 2. Go は `.env` を自動で読み込まない

`habit-tracker-backend/cmd/api/main.go` は `os.Getenv("DATABASE_URL")` で直接環境変数を
読んでおり、godotenv 等のライブラリは使っていない。`.env` ファイルに値があっても、
`go run` を素で実行するプロセスの環境変数にはならない。

**How to apply**: このプロジェクトで `.env` を使うGoアプリを新たに増やす場合、
「`.env`を書けば動く」という前提を置かない。起動スクリプト側で明示的に環境変数へ
展開するか、godotenv 導入を検討する。今回は前者（start-dev.ps1側で読み込み）を採用。

### 3. PowerShellで `.env` の値をコマンド文字列に埋め込むとインジェクションになりうる

初版の実装は `$commands += "`$env:$key = '$escapedValue'"` のように、環境変数のキー名を
無検証のままコマンド文字列に連結していた。値側はシングルクォートエスケープ済みで
安全だったが、**キー側**（例: `a; calc #`）を経由したコマンドインジェクションが
成立する余地があった（クルトワ=security-engineerエージェントのレビューで検出）。

**Why**: 「値だけエスケープすれば安全」と思い込みがちだが、正規表現 `^([^=]+)=(.*)$`
の`[^=]+`は`;`や空白を許容してしまい、キー側は無防備だった。

**How to apply**: `.env`のようなユーザー管理ファイルの中身を新規プロセスへの
コマンド文字列として組み立てる実装は避ける。`Set-Item -Path "Env:$key" -Value $value`
で親プロセスの環境変数として設定し、`Start-Process`に自然継承させる方式に変更した
（コマンドライン引数へのシークレット露出も同時に解消）。加えてキー名を
`^[A-Za-z_][A-Za-z0-9_]*$` で検証し、不正な形式はスキップするようにした。

### 4. ポート占有プロセスの自動killは対象プロセス名を絞る

`Stop-StaleProcessOnPort` は当初、ポート3000を掴んでいるプロセスを無条件で
`Stop-Process -Force` していた。ローカル開発限定とはいえ、無関係な正当プロセスを
確認なしで強制終了するリスクがあるとレビューで指摘され、`ProcessName -eq "node"`
の場合のみkillし、それ以外は警告のみに留める実装に変更した。

**How to apply**: 「ローカル開発用だから」を理由に無条件killを正当化しない。
対象プロセス名を絞る／確認を挟む、のどちらかを最低限入れる。

### 5. backend/frontend リポジトリはGitHubリモートが未設定だった

`habit-tracker-backend` / `habit-tracker-frontend` はローカルにコミットはあったが
`git remote` が一つも設定されておらず、GitHub上にもリポジトリ自体が存在しなかった。
`gh repo create --private --source=. --remote=origin` で新規作成してpushした
（habit-tracker-docsはPublic、backend/frontendはユーザー指定でPrivate、と可視性が
リポジトリ間で不揃いになっている）。

**How to apply**: 3リポジトリ構成（docs/backend/frontend）で「pushして」と言われた
ときは、各リポジトリの `git remote -v` を先に確認する。存在しない場合は
新規作成か既存前提かをユーザーに確認してから進める。可視性（Public/Private）を
揃えるかどうかは今回未確認のまま進めたので、気になる場合は次回確認する。

## 今回のコミット/変更対象

- `habit-tracker-docs`: `scripts/start-dev.ps1`（新規追加、コミット済み・push済み）
- `habit-tracker-backend`: `cmd/api/main.go` CORS対応、`.env`/`.env.example`に
  `FRONTEND_ORIGIN`追加、`go.mod`/`go.sum`に`github.com/go-chi/cors`追加
  （**この振り返り作成時点でコミット未実施** — クルトワのセキュリティレビュー結果を
  確認してからコミットすること）
