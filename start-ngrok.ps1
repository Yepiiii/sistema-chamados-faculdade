# start-ngrok.ps1
# Script para iniciar Backend + ngrok automaticamente

param(
    [string]$NgrokPath = "C:\ngrok\ngrok.exe"
)

Write-Host "🚀 Iniciando Sistema de Chamados com ngrok..." -ForegroundColor Cyan

# 1. Verificar se ngrok existe
if (-not (Test-Path $NgrokPath)) {
    Write-Host "❌ ngrok não encontrado em: $NgrokPath" -ForegroundColor Red
    Write-Host "   Baixe em: https://ngrok.com/download" -ForegroundColor Yellow
    exit 1
}

# 2. Verificar SQL Server
Write-Host "`n📊 Verificando SQL Server..." -ForegroundColor Yellow
$sqlService = Get-Service -Name "MSSQL*" -ErrorAction SilentlyContinue
if ($sqlService -and $sqlService.Status -ne 'Running') {
    Write-Host "   Iniciando SQL Server..." -ForegroundColor Yellow
    Start-Service $sqlService.Name
    Start-Sleep -Seconds 2
}

# 3. Iniciar Backend em background
Write-Host "`n🔧 Iniciando Backend..." -ForegroundColor Yellow
$backendJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD\Backend
    dotnet run
}

Write-Host "   Aguardando Backend inicializar..." -ForegroundColor Gray
Start-Sleep -Seconds 5

# 4. Iniciar ngrok
Write-Host "`n🌐 Iniciando ngrok..." -ForegroundColor Yellow
Write-Host "   Pressione Ctrl+C para parar tudo" -ForegroundColor Gray
Write-Host ""

& $NgrokPath http 5246

# Cleanup quando pressionar Ctrl+C
Write-Host "`n🛑 Parando serviços..." -ForegroundColor Red
Stop-Job -Job $backendJob
Remove-Job -Job $backendJob
Write-Host "✅ Tudo parado!" -ForegroundColor Green
