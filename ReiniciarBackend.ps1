# Script para Reiniciar o Backend
# Força o encerramento e reinicia o backend

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Reiniciando Backend" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Parar todos os processos do SistemaChamados
Write-Host "[INFO] Parando processos existentes..." -ForegroundColor Yellow
Get-Process -Name "SistemaChamados" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Verificar se ainda há processos rodando
$processos = Get-Process -Name "SistemaChamados" -ErrorAction SilentlyContinue
if ($processos) {
    Write-Host "[AVISO] Ainda há processos rodando. Tentando forçar..." -ForegroundColor Yellow
    $processos | Stop-Process -Force
    Start-Sleep -Seconds 2
}

# Limpar builds anteriores
Write-Host "[INFO] Limpando builds anteriores..." -ForegroundColor Cyan
cd Backend
dotnet clean --nologo -v q
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERRO] Falha ao limpar projeto" -ForegroundColor Red
    exit 1
}

# Compilar com a nova configuração
Write-Host "[INFO] Compilando com configuração de camelCase..." -ForegroundColor Cyan
dotnet build --nologo -v q
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERRO] Falha ao compilar projeto" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Projeto compilado com sucesso!" -ForegroundColor Green
Write-Host ""

# Executar o backend
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Iniciando Backend" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[INFO] Backend rodando em: http://localhost:5246" -ForegroundColor Yellow
Write-Host "[INFO] Swagger disponível em: http://localhost:5246/swagger" -ForegroundColor Yellow
Write-Host ""
Write-Host "Pressione Ctrl+C para parar o servidor" -ForegroundColor Gray
Write-Host ""

dotnet run --no-build --nologo
