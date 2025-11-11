-- ============================================
-- Script de Verificação do Banco Antigo
-- ============================================
-- Execute este script para verificar se há dados no banco "SistemaChamados"
-- antes de excluí-lo

USE SistemaChamados;
GO

-- Verifica quantos registros existem em cada tabela
PRINT '========================================';
PRINT 'VERIFICAÇÃO DO BANCO: SistemaChamados';
PRINT '========================================';
PRINT '';

-- Chamados
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Chamados')
BEGIN
    DECLARE @CountChamados INT;
    SELECT @CountChamados = COUNT(*) FROM Chamados;
    PRINT 'Chamados: ' + CAST(@CountChamados AS VARCHAR(10));
END
ELSE
    PRINT 'Tabela Chamados não existe';

-- Usuários
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Usuarios')
BEGIN
    DECLARE @CountUsuarios INT;
    SELECT @CountUsuarios = COUNT(*) FROM Usuarios;
    PRINT 'Usuários: ' + CAST(@CountUsuarios AS VARCHAR(10));
END
ELSE
    PRINT 'Tabela Usuarios não existe';

-- Categorias
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Categorias')
BEGIN
    DECLARE @CountCategorias INT;
    SELECT @CountCategorias = COUNT(*) FROM Categorias;
    PRINT 'Categorias: ' + CAST(@CountCategorias AS VARCHAR(10));
END
ELSE
    PRINT 'Tabela Categorias não existe';

-- Comentários
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Comentarios')
BEGIN
    DECLARE @CountComentarios INT;
    SELECT @CountComentarios = COUNT(*) FROM Comentarios;
    PRINT 'Comentários: ' + CAST(@CountComentarios AS VARCHAR(10));
END
ELSE
    PRINT 'Tabela Comentarios não existe';

PRINT '';
PRINT '========================================';
PRINT 'CONCLUSÃO:';
PRINT '========================================';
PRINT 'Se todos os contadores mostrarem 0 ou "não existe",';
PRINT 'é seguro excluir este banco de dados.';
PRINT '';
PRINT 'Se houver dados importantes, faça backup antes!';
GO
