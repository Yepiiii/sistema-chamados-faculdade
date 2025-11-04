# Script de Aplicação de Conformidade 100%
$ErrorActionPreference = "Stop"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "CONFORMIDADE 100% COM REPOSITÓRIO REMOTO" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Ler connection string
try {
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
} catch {
    Write-Host "Erro ao ler appsettings.json!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Confirmação
Write-Host "ATENÇÃO: Este script irá:" -ForegroundColor Yellow
Write-Host "  1. Adicionar Status 'Violado'" -ForegroundColor Gray
Write-Host "  2. Remover Status extras (Resolvido, Cancelado, Em Espera)" -ForegroundColor Gray
Write-Host "  3. Renomear 'Normal' para 'Média' em Prioridades" -ForegroundColor Gray
Write-Host "  4. Remover prioridade 'Urgente'" -ForegroundColor Gray
Write-Host "  5. Renomear 'Acesso/Senha' para 'Acesso/Login' em Categorias" -ForegroundColor Gray
Write-Host "  6. Remover 6 categorias extras" -ForegroundColor Gray
Write-Host "  7. Adicionar usuário admin@helpdesk.com (senha: admin123)" -ForegroundColor Gray
Write-Host ""

$confirmation = Read-Host "Deseja continuar? (S/N)"
if ($confirmation -ne 'S' -and $confirmation -ne 's') {
    Write-Host "Operação cancelada pelo usuário." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Executando ajustes..." -ForegroundColor Yellow
Write-Host ""

# Executar script SQL
try {
    $result = sqlcmd -S $server -d $database -i "Scripts\AjustarConformidade100.sql" -E
    
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "RESULTADO DA EXECUÇÃO:" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host ""
    
    $result | ForEach-Object {
        if ($_ -match "✓") {
            Write-Host $_ -ForegroundColor Green
        } elseif ($_ -match "ERROR|ERRO") {
            Write-Host $_ -ForegroundColor Red
        } elseif ($_ -match "====") {
            Write-Host $_ -ForegroundColor Cyan
        } else {
            Write-Host $_
        }
    }
    
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "CONFORMIDADE 100% APLICADA!" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Próximos passos:" -ForegroundColor Yellow
    Write-Host "  1. Reiniciar o backend (dotnet run)" -ForegroundColor Gray
    Write-Host "  2. Testar login com admin@helpdesk.com / admin123" -ForegroundColor Gray
    Write-Host "  3. Verificar que os dados estão conforme o repositório remoto" -ForegroundColor Gray
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host "ERRO AO EXECUTAR SCRIPT SQL" -ForegroundColor Red
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Erro:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Verifique se:" -ForegroundColor Yellow
    Write-Host "  1. O SQL Server está rodando" -ForegroundColor Gray
    Write-Host "  2. Você tem permissões para modificar o banco" -ForegroundColor Gray
    Write-Host "  3. Não há chamados cadastrados usando os dados que serão removidos" -ForegroundColor Gray
    Write-Host ""
    exit 1
}
