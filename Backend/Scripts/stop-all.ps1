# Script para parar o Backend do Sistema de Chamados
# Autor: Sistema de Chamados
# Data: 2025-11-10

Write-Host "🛑 Parando Backend NeuroHelp..." -ForegroundColor Red
Write-Host ""

# Busca processos do Backend
$processes = Get-Process -Name "SistemaChamados" -ErrorAction SilentlyContinue

if ($processes) {
    foreach ($process in $processes) {
        Write-Host "🔸 Encontrado processo PID: $($process.Id)" -ForegroundColor Yellow
        Stop-Process -Id $process.Id -Force
        Write-Host "✅ Processo $($process.Id) encerrado" -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "✅ Backend parado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "ℹ️  Nenhum processo do Backend encontrado" -ForegroundColor Cyan
}

Write-Host ""
