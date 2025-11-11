# ============================================
# Script PowerShell para Renomear Banco
# ============================================
# Renomeia: SistemaChamadosDb → SistemaChamados
# Atualiza: appsettings.json automaticamente

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RENOMEANDO BANCO DE DADOS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verifica se o backend está rodando
Write-Host "⚠️  ATENÇÃO: Certifique-se de que o BACKEND está PARADO!" -ForegroundColor Yellow
Write-Host ""
$continuar = Read-Host "Deseja continuar? (S/N)"

if ($continuar -ne "S" -and $continuar -ne "s") {
    Write-Host "Operação cancelada pelo usuário." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "1. Executando script SQL..." -ForegroundColor Green

# 2. Executa o script SQL
$scriptPath = "$PSScriptRoot\renomear-banco.sql"

try {
    sqlcmd -S localhost -E -i $scriptPath
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✓ Banco renomeado com sucesso!" -ForegroundColor Green
        Write-Host ""
        Write-Host "2. appsettings.json já foi atualizado!" -ForegroundColor Green
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "  PRÓXIMOS PASSOS:" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "1. Reinicie o Backend" -ForegroundColor White
        Write-Host "2. Verifique se está usando o banco 'SistemaChamados'" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "❌ Erro ao executar script SQL!" -ForegroundColor Red
        Write-Host "Verifique se o SQL Server está rodando e acessível." -ForegroundColor Red
    }
} catch {
    Write-Host ""
    Write-Host "❌ Erro: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Pressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
