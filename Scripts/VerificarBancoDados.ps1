# ===========================================================
# Script de Verificação do Banco de Dados
# Compara estrutura local com repositório remoto
# ===========================================================

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "VERIFICAÇÃO DO BANCO DE DADOS" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Carregar configuração do appsettings.json
$appsettings = Get-Content "appsettings.json" | ConvertFrom-Json
$connectionString = $appsettings.ConnectionStrings.DefaultConnection

Write-Host "Connection String: $connectionString" -ForegroundColor Yellow
Write-Host ""

# Extrair informações da connection string
if ($connectionString -match "Server=([^;]+);.*Database=([^;]+)") {
    $server = $matches[1]
    $database = $matches[2]
    Write-Host "Servidor: $server" -ForegroundColor Green
    Write-Host "Banco de Dados: $database" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "Erro ao extrair informações da connection string!" -ForegroundColor Red
    exit 1
}

# Query SQL para verificar estrutura completa
$sqlQuery = @"
-- 1. Verificar se o banco existe
SELECT DB_NAME() AS BancoAtual;

-- 2. Listar todas as tabelas
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- 3. Estrutura da tabela Status
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Status'
ORDER BY ORDINAL_POSITION;

-- 4. Estrutura da tabela Prioridades
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Prioridades'
ORDER BY ORDINAL_POSITION;

-- 5. Estrutura da tabela Categorias
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Categorias'
ORDER BY ORDINAL_POSITION;

-- 6. Estrutura da tabela Usuarios
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Usuarios'
ORDER BY ORDINAL_POSITION;

-- 7. Estrutura da tabela Chamados
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Chamados'
ORDER BY ORDINAL_POSITION;

-- 8. Estrutura da tabela Comentarios
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Comentarios'
ORDER BY ORDINAL_POSITION;

-- 9. Verificar Foreign Keys
SELECT 
    fk.name AS ForeignKeyName,
    tp.name AS ParentTable,
    cp.name AS ParentColumn,
    tr.name AS ReferencedTable,
    cr.name AS ReferencedColumn,
    fk.delete_referential_action_desc AS DeleteAction
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.tables AS tp ON fkc.parent_object_id = tp.object_id
INNER JOIN sys.columns AS cp ON fkc.parent_object_id = cp.object_id AND fkc.parent_column_id = cp.column_id
INNER JOIN sys.tables AS tr ON fkc.referenced_object_id = tr.object_id
INNER JOIN sys.columns AS cr ON fkc.referenced_object_id = cr.object_id AND fkc.referenced_column_id = cr.column_id
ORDER BY tp.name, fk.name;

-- 10. Contar registros em cada tabela
SELECT 'Status' AS Tabela, COUNT(*) AS TotalRegistros FROM Status
UNION ALL
SELECT 'Prioridades', COUNT(*) FROM Prioridades
UNION ALL
SELECT 'Categorias', COUNT(*) FROM Categorias
UNION ALL
SELECT 'Usuarios', COUNT(*) FROM Usuarios
UNION ALL
SELECT 'Chamados', COUNT(*) FROM Chamados
UNION ALL
SELECT 'Comentarios', COUNT(*) FROM Comentarios;

-- 11. Verificar dados em Status
SELECT Id, Nome, Descricao, Ativo FROM Status ORDER BY Id;

-- 12. Verificar dados em Prioridades
SELECT Id, Nome, Nivel, Descricao, Ativo FROM Prioridades ORDER BY Id;

-- 13. Verificar dados em Categorias
SELECT Id, Nome, Descricao, Ativo FROM Categorias ORDER BY Id;

-- 14. Verificar usuários (sem expor senha)
SELECT Id, NomeCompleto, Email, TipoUsuario, Ativo, EspecialidadeCategoriaId FROM Usuarios ORDER BY Id;

-- 15. Verificar histórico de migrations
SELECT MigrationId, ProductVersion FROM __EFMigrationsHistory ORDER BY MigrationId;
"@

# Salvar query em arquivo temporário
$queryFile = "Scripts\temp_query.sql"
$sqlQuery | Out-File -FilePath $queryFile -Encoding UTF8

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "EXECUTANDO VERIFICAÇÃO..." -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Executar query usando sqlcmd
try {
    $result = sqlcmd -S $server -d $database -i $queryFile -E -W -s "|" -w 1000
    
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "RESULTADO DA VERIFICAÇÃO" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host ""
    
    $result | ForEach-Object {
        if ($_ -match "Affected") {
            # Pular linhas "rows affected"
        } elseif ($_ -match "---") {
            Write-Host $_ -ForegroundColor DarkGray
        } elseif ($_ -match "^\s*$") {
            # Pular linhas vazias
        } else {
            Write-Host $_
        }
    }
    
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "VERIFICAÇÃO CONCLUÍDA!" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    
} catch {
    Write-Host "Erro ao executar query SQL:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Tentando método alternativo com dotnet ef..." -ForegroundColor Yellow
    
    # Método alternativo usando Entity Framework
    Write-Host ""
    Write-Host "Listando migrations aplicadas:" -ForegroundColor Cyan
    dotnet ef migrations list
}

# Limpar arquivo temporário
Remove-Item $queryFile -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "ANÁLISE DE CONFORMIDADE" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Verificando conformidade com repositório remoto..." -ForegroundColor Yellow
Write-Host ""

Write-Host "✓ ESTRUTURA ESPERADA (Repositório Remoto):" -ForegroundColor Green
Write-Host "  - 6 tabelas principais: Status, Prioridades, Categorias, Usuarios, Chamados, Comentarios" -ForegroundColor Gray
Write-Host "  - Status: 5 registros (Aberto, Em Andamento, Aguardando Resposta, Fechado, Violado)" -ForegroundColor Gray
Write-Host "  - Prioridades: 3 registros (Baixa=1, Média=2, Alta=3)" -ForegroundColor Gray
Write-Host "  - Categorias: 4 registros (Hardware, Software, Rede, Acesso/Login)" -ForegroundColor Gray
Write-Host "  - Usuarios: 1 admin (admin@helpdesk.com)" -ForegroundColor Gray
Write-Host "  - Comentarios: SEM coluna IsInterno" -ForegroundColor Gray
Write-Host "  - Chamados: COM coluna SlaDataExpiracao" -ForegroundColor Gray
Write-Host ""

Write-Host "Compare os resultados acima com a estrutura esperada." -ForegroundColor Yellow
Write-Host ""
