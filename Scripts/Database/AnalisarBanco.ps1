# ==============================================================================
# Script: AnalisarBanco.ps1
# Descricao: Analisa o banco de dados do Sistema de Chamados
# Autor: Sistema
# Data: 23/10/2025
# ==============================================================================

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    ANALISE DO BANCO DE DADOS - Sistema de Chamados" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# Verifica se sqlcmd esta disponivel
$sqlcmd = Get-Command sqlcmd -ErrorAction SilentlyContinue

if (-not $sqlcmd) {
    Write-Host "[!] sqlcmd nao encontrado" -ForegroundColor Yellow
    Write-Host "[*] Usando Entity Framework para analise..." -ForegroundColor Yellow
    Write-Host ""
    
    # Listar migrations aplicadas
    Write-Host "Migrations aplicadas:" -ForegroundColor Cyan
    $migrations = dotnet ef migrations list --project SistemaChamados.csproj 2>&1
    Write-Host $migrations
    Write-Host ""
    exit 0
}

Write-Host "[*] Conectando ao banco de dados..." -ForegroundColor Yellow

# Query SQL simples e robusta
$query = @"
USE SistemaChamados;

SELECT 'Usuarios' as Tabela, COUNT(*) as Total FROM Usuarios
UNION ALL
SELECT 'ColaboradorPerfis', COUNT(*) FROM ColaboradorPerfis
UNION ALL
SELECT 'TecnicoTIPerfis', COUNT(*) FROM TecnicoTIPerfis
UNION ALL
SELECT 'Chamados', COUNT(*) FROM Chamados  
UNION ALL
SELECT 'Categorias', COUNT(*) FROM Categorias
UNION ALL
SELECT 'Prioridades', COUNT(*) FROM Prioridades
UNION ALL
SELECT 'Status', COUNT(*) FROM Status
ORDER BY Tabela;
"@

# Salvar query em arquivo temporario
$tempFile = Join-Path $env:TEMP "analise_$(Get-Random).sql"
Set-Content -Path $tempFile -Value $query -Encoding UTF8

try {
    # Executar query
    $result = & sqlcmd -S "(localdb)\mssqllocaldb" -i $tempFile -h -1 -W -w 500 2>&1 | Out-String
    
    if ($result -match "Invalid") {
        Write-Host "[!] Banco existe mas schema esta diferente" -ForegroundColor Yellow
        Write-Host "[*] Listando tabelas..." -ForegroundColor Yellow
        Write-Host ""
        
        # Listar tabelas do banco
        $queryTabelas = "USE SistemaChamados; SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME;"
        Set-Content -Path $tempFile -Value $queryTabelas -Encoding UTF8
        $tabelas = & sqlcmd -S "(localdb)\mssqllocaldb" -i $tempFile -h -1 -W 2>&1 | Out-String
        
        Write-Host "Tabelas encontradas:" -ForegroundColor Cyan
        $tabelas -split "`n" | Where-Object { $_ -and $_.Trim() -and $_ -notmatch "^---" } | ForEach-Object {
            Write-Host "  - $($_.Trim())" -ForegroundColor White
        }
    }
    elseif ($result -match "Cannot open database") {
        Write-Host "[X] Banco de dados nao existe!" -ForegroundColor Red
        Write-Host "[*] Execute: .\Scripts\Database\InicializarBanco.ps1" -ForegroundColor Cyan
    }
    else {
        Write-Host "[OK] Banco conectado!" -ForegroundColor Green
        Write-Host ""
        Write-Host "==================================================================" -ForegroundColor Cyan
        Write-Host "    ESTATISTICAS" -ForegroundColor Yellow  
        Write-Host "==================================================================" -ForegroundColor Cyan
        Write-Host ""
        
        # Processar resultado
        $result -split "`n" | Where-Object { $_ -and $_.Trim() -and $_ -notmatch "^---" } | ForEach-Object {
            $linha = $_.Trim()
            if ($linha -match '^(\w+)\s+(\d+)') {
                $tabela = $matches[1].PadRight(20)
                $count = $matches[2]
                Write-Host "  $tabela : $count registros" -ForegroundColor White
            }
        }
        
        Write-Host ""
        Write-Host "==================================================================" -ForegroundColor Green
        Write-Host "    ANALISE CONCLUIDA!" -ForegroundColor Green
        Write-Host "==================================================================" -ForegroundColor Green
    }
}
catch {
    Write-Host "[X] ERRO:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}
finally {
    # Limpar arquivo temporario
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
    }
}

Write-Host ""

