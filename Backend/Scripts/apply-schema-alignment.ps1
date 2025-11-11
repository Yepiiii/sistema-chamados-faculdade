# Script para aplicar o alinhamento de schema no SQL Server
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  APLICANDO SCHEMA ALIGNMENT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptPath = Join-Path $PSScriptRoot "align-db-schema.sql"

if (-not (Test-Path $scriptPath)) {
    Write-Host "ERRO: Script SQL nao encontrado!" -ForegroundColor Red
    Write-Host "Caminho: $scriptPath" -ForegroundColor Yellow
    Read-Host "Pressione ENTER"
    exit
}

Write-Host "Script SQL: $scriptPath" -ForegroundColor Green
Write-Host ""

# Solicitar credenciais do SQL Server
Write-Host "Informe os dados de conexao com o SQL Server:" -ForegroundColor Yellow
Write-Host ""
$servidor = Read-Host "Servidor (ex: localhost ou .\SQLEXPRESS)"
$banco = Read-Host "Banco de dados (ex: SistemaChamadosDb)"
$autenticacao = Read-Host "Usar autenticacao Windows? (s/n)"

if ($autenticacao -eq "s" -or $autenticacao -eq "S") {
    # Windows Authentication
    Write-Host ""
    Write-Host "Executando com Windows Authentication..." -ForegroundColor Green
    
    sqlcmd -S $servidor -d $banco -E -i $scriptPath
} else {
    # SQL Server Authentication
    $usuario = Read-Host "Usuario SQL"
    $senha = Read-Host "Senha" -AsSecureString
    $senhaTexto = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($senha))
    
    Write-Host ""
    Write-Host "Executando com SQL Authentication..." -ForegroundColor Green
    
    sqlcmd -S $servidor -d $banco -U $usuario -P $senhaTexto -i $scriptPath
}

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  SCRIPT APLICADO COM SUCESSO!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Agora voce pode:" -ForegroundColor Yellow
    Write-Host "1. Iniciar o Backend: cd Backend; dotnet run" -ForegroundColor White
    Write-Host "2. Testar o Desktop em localhost:8080" -ForegroundColor White
    Write-Host "3. Instalar o APK no celular" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  ERRO AO APLICAR O SCRIPT!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Execute manualmente no SSMS:" -ForegroundColor Yellow
    Write-Host $scriptPath -ForegroundColor White
}

Write-Host ""
Read-Host "Pressione ENTER para sair"
