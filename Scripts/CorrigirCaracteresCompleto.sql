-- Script FINAL para corrigir caracteres especiais
-- Usa DELETE em vez de TRUNCATE e mantém IDs originais
-- Data: 04/11/2025

USE SistemaChamados;
GO

PRINT 'Iniciando correção de caracteres especiais...';
PRINT '';

-- Desabilitar constraints temporariamente
ALTER TABLE Chamados NOCHECK CONSTRAINT FK_Chamados_Prioridades;
ALTER TABLE Chamados NOCHECK CONSTRAINT FK_Chamados_Status;
ALTER TABLE Chamados NOCHECK CONSTRAINT FK_Chamados_Categorias;

-- PRIORIDADES
DELETE FROM Prioridades;
DBCC CHECKIDENT ('Prioridades', RESEED, 0);

SET IDENTITY_INSERT Prioridades ON;
INSERT INTO Prioridades (Id, Nome, Nivel, Descricao, DataCadastro, Ativo) VALUES
    (1, 'Baixa', 1, 'Problema não urgente, pode ser resolvido em até 5 dias úteis.', GETUTCDATE(), 1),
    (2, 'Média', 2, 'Prioridade normal.', GETUTCDATE(), 1),
    (3, 'Alta', 3, 'Problema impactando produtividade, resolver em até 8 horas.', GETUTCDATE(), 1);
SET IDENTITY_INSERT Prioridades OFF;

PRINT 'Prioridades corrigidas!';

-- STATUS  
DELETE FROM Status;
DBCC CHECKIDENT ('Status', RESEED, 0);

SET IDENTITY_INSERT Status ON;
INSERT INTO Status (Id, Nome, Descricao, DataCadastro, Ativo) VALUES
    (1, 'Aberto', 'Chamado recém criado e aguardando atribuição.', GETUTCDATE(), 1),
    (2, 'Em Andamento', 'Um técnico já está trabalhando no chamado.', GETUTCDATE(), 1),
    (3, 'Aguardando Resposta', 'Aguardando mais informações do usuário.', GETUTCDATE(), 1),
    (5, 'Fechado', 'O chamado foi resolvido.', GETUTCDATE(), 1),
    (8, 'Violado', 'O prazo de resolução (SLA) do chamado foi excedido.', GETUTCDATE(), 1);
SET IDENTITY_INSERT Status OFF;

PRINT 'Status corrigidos!';

-- CATEGORIAS
DELETE FROM Categorias;
DBCC CHECKIDENT ('Categorias', RESEED, 0);

SET IDENTITY_INSERT Categorias ON;
INSERT INTO Categorias (Id, Nome, Descricao, DataCadastro, Ativo) VALUES
    (1, 'Hardware', 'Problemas com peças físicas do computador.', GETUTCDATE(), 1),
    (2, 'Software', 'Problemas com programas e sistemas.', GETUTCDATE(), 1),
    (3, 'Rede', 'Problemas de conexão com a internet ou rede interna.', GETUTCDATE(), 1),
    (5, 'Acesso/Login', 'Problemas de senha ou acesso a sistemas.', GETUTCDATE(), 1);
SET IDENTITY_INSERT Categorias OFF;

PRINT 'Categorias corrigidas!';
PRINT '';

-- Reabilitar constraints
ALTER TABLE Chamados CHECK CONSTRAINT FK_Chamados_Prioridades;
ALTER TABLE Chamados CHECK CONSTRAINT FK_Chamados_Status;
ALTER TABLE Chamados CHECK CONSTRAINT FK_Chamados_Categorias;

PRINT '========================================';
PRINT 'CORREÇÃO CONCLUÍDA COM SUCESSO!';
PRINT '========================================';
PRINT '';

-- Verificar resultados (sem usar SELECT para evitar problema de encoding no console)
PRINT 'Verificando dados...';
EXEC sp_executesql N'SELECT COUNT(*) AS TotalPrioridades FROM Prioridades';
EXEC sp_executesql N'SELECT COUNT(*) AS TotalStatus FROM Status';
EXEC sp_executesql N'SELECT COUNT(*) AS TotalCategorias FROM Categorias';

PRINT '';
PRINT 'Dados corrigidos! Verifique no aplicativo mobile.';

GO
