-- ============================================
-- Script para Renomear Banco de Dados
-- ============================================
-- Renomeia: SistemaChamadosDb → SistemaChamados
-- ATENÇÃO: Certifique-se de que a aplicação está PARADA antes de executar!

USE master;
GO

PRINT '========================================';
PRINT 'RENOMEANDO BANCO DE DADOS';
PRINT '========================================';
PRINT 'De: SistemaChamadosDb';
PRINT 'Para: SistemaChamados';
PRINT '';

-- Verifica se o banco de origem existe
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'SistemaChamadosDb')
BEGIN
    PRINT 'ERRO: Banco "SistemaChamadosDb" não encontrado!';
    PRINT 'Abortando operação.';
    RETURN;
END

-- Verifica se o banco de destino já existe
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'SistemaChamados')
BEGIN
    PRINT 'AVISO: Banco "SistemaChamados" já existe!';
    PRINT 'Será necessário excluí-lo primeiro.';
    PRINT '';
    PRINT 'Fechando conexões do banco antigo...';
    ALTER DATABASE SistemaChamados SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    
    PRINT 'Excluindo banco antigo "SistemaChamados"...';
    DROP DATABASE SistemaChamados;
    PRINT '✓ Banco antigo excluído.';
    PRINT '';
END

-- Fecha todas as conexões com o banco atual
PRINT 'Fechando conexões com "SistemaChamadosDb"...';
ALTER DATABASE SistemaChamadosDb SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

-- Renomeia o banco
PRINT 'Renomeando banco de dados...';
ALTER DATABASE SistemaChamadosDb MODIFY NAME = SistemaChamados;

-- Permite múltiplas conexões novamente
PRINT 'Liberando acesso ao banco...';
ALTER DATABASE SistemaChamados SET MULTI_USER;

PRINT '';
PRINT '========================================';
PRINT '✓ RENOMEAÇÃO CONCLUÍDA COM SUCESSO!';
PRINT '========================================';
PRINT 'Banco renomeado: SistemaChamados';
PRINT '';
PRINT 'PRÓXIMOS PASSOS:';
PRINT '1. Atualize o appsettings.json';
PRINT '2. Reinicie a aplicação';
PRINT '========================================';
GO
