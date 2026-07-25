<#
.SYNOPSIS
    HabitOS のローカル開発環境（PostgreSQL・backend・frontend）を一括起動する。

.DESCRIPTION
    habit-tracker-docs と兄弟ディレクトリに配置された habit-tracker-backend / habit-tracker-frontend を
    前提とする（docs/baseline/repository-structure.md 準拠）。
    1. docker compose で PostgreSQL を起動
    2. golang-migrate でマイグレーションを適用
    3. backend（go run ./cmd/api）を新規ウィンドウで起動
    4. frontend（npm run dev）を新規ウィンドウで起動

.PARAMETER SkipDb
    PostgreSQL の起動・マイグレーションをスキップする（既に起動済みの場合等）。

.EXAMPLE
    ./scripts/start-dev.ps1
    ./scripts/start-dev.ps1 -SkipDb
#>

[CmdletBinding()]
param(
    [switch]$SkipDb
)

$ErrorActionPreference = "Stop"

$docsRoot = Split-Path -Parent $PSScriptRoot
$workspaceRoot = Split-Path -Parent $docsRoot
$backendPath = Join-Path $workspaceRoot "habit-tracker-backend"
$frontendPath = Join-Path $workspaceRoot "habit-tracker-frontend"

function Assert-DirectoryExists {
    param([string]$Path, [string]$Label)
    if (-not (Test-Path $Path)) {
        throw "$Label が見つかりません: $Path`n habit-tracker-docs と兄弟ディレクトリに配置してください。"
    }
}

Assert-DirectoryExists -Path $backendPath -Label "habit-tracker-backend"
Assert-DirectoryExists -Path $frontendPath -Label "habit-tracker-frontend"

function Initialize-EnvFile {
    param([string]$RepoPath, [string]$EnvFileName, [string]$ExampleFileName)
    $envFile = Join-Path $RepoPath $EnvFileName
    $exampleFile = Join-Path $RepoPath $ExampleFileName
    if (-not (Test-Path $envFile)) {
        if (Test-Path $exampleFile) {
            Copy-Item $exampleFile $envFile
            Write-Host "[setup] $EnvFileName が無かったので $ExampleFileName からコピーしました: $RepoPath" -ForegroundColor Yellow
        } else {
            Write-Host "[warn] $ExampleFileName が見つかりません: $RepoPath" -ForegroundColor Yellow
        }
    }
}

Initialize-EnvFile -RepoPath $backendPath -EnvFileName ".env" -ExampleFileName ".env.example"
Initialize-EnvFile -RepoPath $frontendPath -EnvFileName ".env.local" -ExampleFileName ".env.local.example"

if (-not $SkipDb) {
    Write-Host "[1/3] PostgreSQL を起動しています..." -ForegroundColor Cyan
    Push-Location $backendPath
    try {
        docker compose up -d
        if ($LASTEXITCODE -ne 0) { throw "docker compose up に失敗しました" }

        Write-Host "[1/3] PostgreSQL の起動待機中..." -ForegroundColor Cyan
        $maxRetries = 30
        $ready = $false
        for ($i = 0; $i -lt $maxRetries; $i++) {
            docker compose exec -T postgres pg_isready -U habit 2>$null | Out-Null
            if ($LASTEXITCODE -eq 0) { $ready = $true; break }
            Start-Sleep -Seconds 1
        }
        if (-not $ready) {
            Write-Host "[warn] PostgreSQL の起動確認がタイムアウトしました。手動で確認してください。" -ForegroundColor Yellow
        }

        $migrateCmd = Get-Command migrate -ErrorAction SilentlyContinue
        if ($migrateCmd) {
            Write-Host "[1/3] マイグレーションを適用しています..." -ForegroundColor Cyan
            $envContent = Get-Content (Join-Path $backendPath ".env") -Raw
            if ($envContent -match "DATABASE_URL=(.+)") {
                $databaseUrl = $Matches[1].Trim()
                migrate -path db/migrations -database "$databaseUrl" up
            } else {
                Write-Host "[warn] .env に DATABASE_URL が見つからないため、マイグレーションをスキップしました。" -ForegroundColor Yellow
            }
        } else {
            Write-Host "[warn] migrate CLI が見つからないため、マイグレーションをスキップしました（手動で 'make migrate-up' を実行してください）。" -ForegroundColor Yellow
        }
    } finally {
        Pop-Location
    }
} else {
    Write-Host "[1/3] -SkipDb 指定のため PostgreSQL 起動をスキップします。" -ForegroundColor DarkGray
}

function Set-EnvVarsFromFile {
    param([string]$EnvFilePath)
    if (-not (Test-Path $EnvFilePath)) {
        return
    }
    foreach ($line in Get-Content $EnvFilePath) {
        $trimmed = $line.Trim()
        if ($trimmed -eq "" -or $trimmed.StartsWith("#")) { continue }
        if ($trimmed -match "^([^=]+)=(.*)$") {
            $key = $Matches[1].Trim()
            $value = $Matches[2].Trim()
            if ($key -notmatch '^[A-Za-z_][A-Za-z0-9_]*$') {
                Write-Host "[warn] 不正な環境変数名をスキップしました: $key" -ForegroundColor Yellow
                continue
            }
            Set-Item -Path "Env:$key" -Value $value
        }
    }
}

Write-Host "[2/3] backend（go run ./cmd/api）を新規ウィンドウで起動します..." -ForegroundColor Cyan
Set-EnvVarsFromFile -EnvFilePath (Join-Path $backendPath ".env")
Start-Process powershell -ArgumentList @(
    "-NoExit", "-Command",
    "Set-Location '$backendPath'; go run ./cmd/api"
)

function Stop-StaleProcessOnPort {
    param([int]$Port)
    $conns = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
    if (-not $conns) { return }
    $processIds = $conns | Select-Object -ExpandProperty OwningProcess -Unique
    foreach ($processId in $processIds) {
        $proc = Get-Process -Id $processId -ErrorAction SilentlyContinue
        if (-not $proc) { continue }
        if ($proc.ProcessName -in @("node")) {
            Write-Host "[warn] ポート $Port は残留プロセス（PID $processId, $($proc.ProcessName)）が使用中のため強制終了します。" -ForegroundColor Yellow
            Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
        } else {
            Write-Host "[warn] ポート $Port を想定外のプロセス（PID $processId, $($proc.ProcessName)）が使用中です。手動で確認してください。" -ForegroundColor Yellow
        }
    }
}

Write-Host "[3/3] frontend（npm run dev）を新規ウィンドウで起動します..." -ForegroundColor Cyan
Stop-StaleProcessOnPort -Port 3000
Start-Process powershell -ArgumentList @(
    "-NoExit", "-Command",
    "Set-Location '$frontendPath'; npm run dev"
)

Write-Host ""
Write-Host "起動処理を開始しました。" -ForegroundColor Green
Write-Host "  backend:  http://localhost:8080"
Write-Host "  frontend: http://localhost:3000"
Write-Host "各ウィンドウで Ctrl+C すると個別に停止できます。PostgreSQLコンテナは"
Write-Host "  cd habit-tracker-backend; docker compose down"
Write-Host "で停止してください。"
