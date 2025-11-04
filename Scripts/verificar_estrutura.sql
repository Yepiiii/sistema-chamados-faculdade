-- ===========================================================
-- Script de Verificação da Estrutura do Banco de Dados
-- ===========================================================

PRINT '======================================'
PRINT 'VERIFICAÇÃO DO BANCO DE DADOS'
PRINT '======================================'
PRINT ''

-- 1. Banco atual
PRINT '1. BANCO DE DADOS ATUAL:'
SELECT DB_NAME() AS BancoAtual;
PRINT ''

-- 2. Listar todas as tabelas
PRINT '2. TABELAS EXISTENTES:'
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME != '__EFMigrationsHistory'
ORDER BY TABLE_NAME;
PRINT ''

-- 3. Estrutura Status
PRINT '3. ESTRUTURA DA TABELA Status:'
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Status'
ORDER BY ORDINAL_POSITION;
PRINT ''

-- 4. Estrutura Prioridades
PRINT '4. ESTRUTURA DA TABELA Prioridades:'
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Prioridades'
ORDER BY ORDINAL_POSITION;
PRINT ''

-- 5. Estrutura Categorias
PRINT '5. ESTRUTURA DA TABELA Categorias:'
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Categorias'
ORDER BY ORDINAL_POSITION;
PRINT ''

-- 6. Estrutura Usuarios
PRINT '6. ESTRUTURA DA TABELA Usuarios:'
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Usuarios'
ORDER BY ORDINAL_POSITION;
PRINT ''

-- 7. Estrutura Chamados
PRINT '7. ESTRUTURA DA TABELA Chamados:'
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Chamados'
ORDER BY ORDINAL_POSITION;
PRINT ''

-- 8. Estrutura Comentarios
PRINT '8. ESTRUTURA DA TABELA Comentarios:'
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Comentarios'
ORDER BY ORDINAL_POSITION;
PRINT ''

-- 9. Contar registros
PRINT '9. CONTAGEM DE REGISTROS:'
SELECT 'Status' AS Tabela, COUNT(*) AS TotalRegistros FROM Status
UNION ALL SELECT 'Prioridades', COUNT(*) FROM Prioridades
UNION ALL SELECT 'Categorias', COUNT(*) FROM Categorias
UNION ALL SELECT 'Usuarios', COUNT(*) FROM Usuarios
UNION ALL SELECT 'Chamados', COUNT(*) FROM Chamados
UNION ALL SELECT 'Comentarios', COUNT(*) FROM Comentarios;
PRINT ''

-- 10. Dados em Status
PRINT '10. DADOS EM Status:'
SELECT Id, Nome, Ativo FROM Status ORDER BY Id;
PRINT ''

-- 11. Dados em Prioridades
PRINT '11. DADOS EM Prioridades:'
SELECT Id, Nome, Nivel, Ativo FROM Prioridades ORDER BY Id;
PRINT ''

-- 12. Dados em Categorias
PRINT '12. DADOS EM Categorias:'
SELECT Id, Nome, Ativo FROM Categorias ORDER BY Id;
PRINT ''

-- 13. Dados em Usuarios
PRINT '13. DADOS EM Usuarios (sem senhas):'
SELECT Id, NomeCompleto, Email, TipoUsuario, Ativo, EspecialidadeCategoriaId FROM Usuarios ORDER BY Id;
PRINT ''

-- 14. Verificar Foreign Keys
PRINT '14. FOREIGN KEYS:'
SELECT 
    OBJECT_NAME(fk.parent_object_id) AS TabelaPai,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS ColunaPai,
    OBJECT_NAME(fk.referenced_object_id) AS TabelaReferenciada,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS ColunaReferenciada,
    fk.delete_referential_action_desc AS AcaoDelete
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fkc ON fk.object_id = fkc.constraint_object_id
ORDER BY OBJECT_NAME(fk.parent_object_id);
PRINT ''

-- 15. Migrations aplicadas
PRINT '15. MIGRATIONS APLICADAS:'
SELECT MigrationId, ProductVersion FROM __EFMigrationsHistory ORDER BY MigrationId;
PRINT ''

PRINT '======================================'
PRINT 'VERIFICAÇÃO CONCLUÍDA'
PRINT '======================================'
