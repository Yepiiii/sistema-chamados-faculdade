#!/usr/bin/env pwsh
# Script para verificar e corrigir permissões do usuário de teste

Write-Host "`n=== VERIFICAÇÃO DE PERMISSÕES DO USUÁRIO ===" -ForegroundColor Cyan
Write-Host "Este script irá:" -ForegroundColor Yellow
Write-Host "1. Verificar o tipo de usuário do admin@teste.com" -ForegroundColor White
Write-Host "2. Se necessário, promover para Administrador (TipoUsuario = 3)" -ForegroundColor White
Write-Host "3. Testar o endpoint de encerramento`n" -ForegroundColor White

# Verifica se a API está rodando
$apiJob = Get-Job | Where-Object { $_.Name -like "*API*" -or $_.Name -like "*Backend*" }

if (-not $apiJob) {
    Write-Host "❌ API não está rodando!" -ForegroundColor Red
    Write-Host "Execute primeiro: .\IniciarSistema.ps1`n" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ API está rodando (Job ID: $($apiJob.Id))`n" -ForegroundColor Green

# Token de autenticação (você precisará fazer login primeiro ou usar um token válido)
Write-Host "Para verificar as permissões, você precisa:" -ForegroundColor Yellow
Write-Host "1. Fazer login no app mobile com admin@teste.com / Admin123!" -ForegroundColor White
Write-Host "2. Copiar o token JWT do debug log" -ForegroundColor White
Write-Host "3. Ou verificar diretamente no banco de dados`n" -ForegroundColor White

# Verifica no banco (se tiver acesso ao LocalDB)
Write-Host "Tentando acessar o banco de dados LocalDB..." -ForegroundColor Cyan

$connectionString = "(localdb)\mssqllocaldb"
$database = "SistemaChamadosDB"

try {
    # Tenta executar query no SQL Server LocalDB
    $query = @"
SELECT Id, Nome, Email, TipoUsuario, Ativo
FROM Usuarios
WHERE Email = 'admin@teste.com';
"@

    Write-Host "`nExecutando query para verificar usuário..." -ForegroundColor Gray
    Write-Host "ConnectionString: $connectionString" -ForegroundColor Gray
    Write-Host "Database: $database`n" -ForegroundColor Gray

    # Usa sqlcmd se disponível
    $sqlcmdPath = Get-Command sqlcmd -ErrorAction SilentlyContinue
    if ($sqlcmdPath) {
        Write-Host "✓ sqlcmd encontrado: $($sqlcmdPath.Source)" -ForegroundColor Green
        
        $result = & sqlcmd -S "$connectionString" -d "$database" -Q "$query" -W -s"," 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`nRESULTADO DA QUERY:" -ForegroundColor Green
            Write-Host $result
            
            # Verifica se TipoUsuario é 3
            if ($result -match "TipoUsuario.*,\s*3\s*,") {
                Write-Host "`n✓ Usuário admin@teste.com JÁ É ADMINISTRADOR (TipoUsuario = 3)" -ForegroundColor Green
                Write-Host "O usuário tem permissão para encerrar chamados.`n" -ForegroundColor Green
            } elseif ($result -match "TipoUsuario") {
                Write-Host "`n⚠ Usuário admin@teste.com NÃO É ADMINISTRADOR!" -ForegroundColor Yellow
                Write-Host "Atualizando para TipoUsuario = 3...`n" -ForegroundColor Cyan
                
                $updateQuery = @"
UPDATE Usuarios
SET TipoUsuario = 3
WHERE Email = 'admin@teste.com';

SELECT Id, Nome, Email, TipoUsuario, Ativo
FROM Usuarios
WHERE Email = 'admin@teste.com';
"@
                
                $updateResult = & sqlcmd -S "$connectionString" -d "$database" -Q "$updateQuery" -W -s"," 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "✓ Usuário atualizado com sucesso!" -ForegroundColor Green
                    Write-Host $updateResult
                } else {
                    Write-Host "❌ Erro ao atualizar usuário" -ForegroundColor Red
                    Write-Host $updateResult
                }
            }
        } else {
            Write-Host "`n⚠ Não foi possível executar a query" -ForegroundColor Yellow
            Write-Host $result
        }
    } else {
        Write-Host "⚠ sqlcmd não encontrado" -ForegroundColor Yellow
        Write-Host "Você pode:" -ForegroundColor White
        Write-Host "1. Instalar SQL Server Command Line Tools" -ForegroundColor Gray
        Write-Host "2. Verificar manualmente com SQL Server Management Studio" -ForegroundColor Gray
        Write-Host "3. Adicionar manualmente via código na API`n" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Erro ao acessar banco de dados: $_" -ForegroundColor Red
}

Write-Host "`n=== INSTRUÇÕES ALTERNATIVAS ===" -ForegroundColor Cyan
Write-Host "Se não conseguiu verificar/atualizar o banco, você pode:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Abrir SQL Server Management Studio (SSMS)" -ForegroundColor White
Write-Host "   Server: (localdb)\mssqllocaldb" -ForegroundColor Gray
Write-Host "   Database: SistemaChamadosDB" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Executar esta query:" -ForegroundColor White
Write-Host "   UPDATE Usuarios SET TipoUsuario = 3 WHERE Email = 'admin@teste.com';" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Tipos de usuário:" -ForegroundColor White
Write-Host "   1 = Solicitante (usuário comum)" -ForegroundColor Gray
Write-Host "   2 = Técnico" -ForegroundColor Gray
Write-Host "   3 = Administrador (NECESSÁRIO para encerrar)" -ForegroundColor Gray
Write-Host ""

Write-Host "Pressione qualquer tecla para sair..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
