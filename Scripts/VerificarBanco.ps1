# Script simples de verificação do banco de dados
$ErrorActionPreference = "Continue"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "VERIFICACAO DO BANCO DE DADOS" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Ler connection string
$appsettings = Get-Content "appsettings.json" | ConvertFrom-Json
$connectionString = $appsettings.ConnectionStrings.DefaultConnection

if ($connectionString -match "Server=([^;]+);.*Database=([^;]+)") {
    $server = $matches[1]
    $database = $matches[2]
    Write-Host "Servidor: $server" -ForegroundColor Green
    Write-Host "Banco: $database" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "Erro ao extrair connection string!" -ForegroundColor Red
    exit 1
}

# Executar query SQL
Write-Host "Executando verificacao..." -ForegroundColor Yellow
Write-Host ""

try {
    sqlcmd -S $server -d $database -i "Scripts\verificar_estrutura.sql" -E
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "VERIFICACAO CONCLUIDA COM SUCESSO" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
} catch {
    Write-Host "Erro ao executar SQL:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Tentando metodo alternativo..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Migrations aplicadas:" -ForegroundColor Cyan
    dotnet ef migrations list
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "ESTRUTURA ESPERADA (REMOTO):" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Tabelas: Status, Prioridades, Categorias, Usuarios, Chamados, Comentarios" -ForegroundColor Gray
Write-Host "Status: 5 registros" -ForegroundColor Gray
Write-Host "Prioridades: 3 registros com Nivel" -ForegroundColor Gray
Write-Host "Categorias: 4 registros" -ForegroundColor Gray
Write-Host "Usuarios: Deve ter admin@helpdesk.com" -ForegroundColor Gray
Write-Host "Comentarios: SEM coluna IsInterno" -ForegroundColor Gray
Write-Host "Chamados: COM coluna SlaDataExpiracao" -ForegroundColor Gray
Write-Host ""
