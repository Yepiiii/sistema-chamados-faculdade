-- ============================================
-- Script para Excluir o Banco Antigo
-- ============================================
-- ATENÇÃO: Execute este script APENAS APÓS verificar com o script
--          "verificar-banco-antigo.sql" que não há dados importantes!

USE master;
GO

PRINT '========================================';
PRINT 'EXCLUINDO BANCO: SistemaChamados';
PRINT '========================================';

-- Verifica se o banco existe
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'SistemaChamados')
BEGIN
    PRINT 'Banco encontrado. Iniciando exclusão...';
    PRINT '';
    
    -- Força desconexão de todos os usuários
    PRINT 'Fechando conexões existentes...';
    ALTER DATABASE SistemaChamados SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    
    -- Deleta o banco
    PRINT 'Deletando banco de dados...';
    DROP DATABASE SistemaChamados;
    
    PRINT '';
    PRINT '✓ Banco "SistemaChamados" excluído com sucesso!';
    PRINT '';
    PRINT 'Banco em uso pela aplicação: SistemaChamadosDb';
END
ELSE
BEGIN
    PRINT 'Banco "SistemaChamados" não encontrado.';
    PRINT 'Nada a fazer.';
END

PRINT '========================================';
GO
