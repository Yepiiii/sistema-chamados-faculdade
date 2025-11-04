-- Script para recriar dados básicos com encoding correto
-- Data: 04/11/2025

USE SistemaChamados;
GO

-- Limpar e reinserir Prioridades
DELETE FROM Prioridades;
DBCC CHECKIDENT ('Prioridades', RESEED, 0);

INSERT INTO Prioridades (Nome, Nivel, Descricao, DataCadastro, Ativo)
VALUES 
    (N'Baixa', 1, N'Problema não urgente, pode ser resolvido em até 5 dias úteis.', GETUTCDATE(), 1),
    (N'Média', 2, N'Prioridade normal.', GETUTCDATE(), 1),
    (N'Alta', 3, N'Problema impactando produtividade, resolver em até 8 horas.', GETUTCDATE(), 1);

-- Limpar e reinserir Status
DELETE FROM Status;
DBCC CHECKIDENT ('Status', RESEED, 0);

INSERT INTO Status (Nome, Descricao, DataCadastro, Ativo)
VALUES 
    (N'Aberto', N'Chamado recém criado e aguardando atribuição.', GETUTCDATE(), 1),
    (N'Em Andamento', N'Um técnico já está trabalhando no chamado.', GETUTCDATE(), 1),
    (N'Aguardando Resposta', N'Aguardando mais informações do usuário.', GETUTCDATE(), 1),
    (N'Fechado', N'O chamado foi resolvido.', GETUTCDATE(), 1),
    (N'Violado', N'O prazo de resolução (SLA) do chamado foi excedido.', GETUTCDATE(), 1);

-- Limpar e reinserir Categorias
DELETE FROM Categorias;
DBCC CHECKIDENT ('Categorias', RESEED, 0);

INSERT INTO Categorias (Nome, Descricao, DataCadastro, Ativo)
VALUES 
    (N'Hardware', N'Problemas com peças físicas do computador.', GETUTCDATE(), 1),
    (N'Software', N'Problemas com programas e sistemas.', GETUTCDATE(), 1),
    (N'Rede', N'Problemas de conexão com a internet ou rede interna.', GETUTCDATE(), 1),
    (N'Acesso/Login', N'Problemas de senha ou acesso a sistemas.', GETUTCDATE(), 1);

-- Verificar resultados
PRINT '======================================';
PRINT 'PRIORIDADES:';
PRINT '======================================';
SELECT Id, Nome, Nivel, Descricao FROM Prioridades ORDER BY Nivel;

PRINT '';
PRINT '======================================';
PRINT 'STATUS:';
PRINT '======================================';
SELECT Id, Nome, Descricao FROM Status ORDER BY Id;

PRINT '';
PRINT '======================================';
PRINT 'CATEGORIAS:';
PRINT '======================================';
SELECT Id, Nome, Descricao FROM Categorias ORDER BY Id;

PRINT '';
PRINT 'Dados básicos recriados com sucesso!';
GO
