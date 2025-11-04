-- Script para corrigir encoding de caracteres especiais
-- Converte de Latin1 mal interpretado para UTF-8 correto
-- Data: 04/11/2025

USE SistemaChamados;
GO

-- Backup das tabelas antes de modificar
SELECT * INTO Prioridades_Backup FROM Prioridades;
SELECT * INTO Status_Backup FROM Status;
SELECT * INTO Categorias_Backup FROM Categorias;

PRINT 'Backup criado com sucesso!';
PRINT '';

-- Limpar dados corrompidos e inserir novos com encoding correto
-- Primeiro, vamos desabilitar temporariamente as restrições
ALTER TABLE Chamados NOCHECK CONSTRAINT ALL;

-- Atualizar Prioridades
TRUNCATE TABLE Prioridades;
SET IDENTITY_INSERT Prioridades ON;

INSERT INTO Prioridades (Id, Nome, Nivel, Descricao, DataCadastro, Ativo)
VALUES 
    (1, N'Baixa', 1, N'Problema não urgente, pode ser resolvido em até 5 dias úteis.', GETUTCDATE(), 1),
    (2, N'Média', 2, N'Prioridade normal.', GETUTCDATE(), 1),
    (3, N'Alta', 3, N'Problema impactando produtividade, resolver em até 8 horas.', GETUTCDATE(), 1);

SET IDENTITY_INSERT Prioridades OFF;

-- Atualizar Status
TRUNCATE TABLE Status;
SET IDENTITY_INSERT Status ON;

INSERT INTO Status (Id, Nome, Descricao, DataCadastro, Ativo)
VALUES 
    (1, N'Aberto', N'Chamado recém criado e aguardando atribuição.', GETUTCDATE(), 1),
    (2, N'Em Andamento', N'Um técnico já está trabalhando no chamado.', GETUTCDATE(), 1),
    (3, N'Aguardando Resposta', N'Aguardando mais informações do usuário.', GETUTCDATE(), 1),
    (5, N'Fechado', N'O chamado foi resolvido.', GETUTCDATE(), 1),
    (8, N'Violado', N'O prazo de resolução (SLA) do chamado foi excedido.', GETUTCDATE(), 1);

SET IDENTITY_INSERT Status OFF;

-- Atualizar Categorias
TRUNCATE TABLE Categorias;
SET IDENTITY_INSERT Categorias ON;

INSERT INTO Categorias (Id, Nome, Descricao, DataCadastro, Ativo)
VALUES 
    (1, N'Hardware', N'Problemas com peças físicas do computador.', GETUTCDATE(), 1),
    (2, N'Software', N'Problemas com programas e sistemas.', GETUTCDATE(), 1),
    (3, N'Rede', N'Problemas de conexão com a internet ou rede interna.', GETUTCDATE(), 1),
    (5, N'Acesso/Login', N'Problemas de senha ou acesso a sistemas.', GETUTCDATE(), 1);

SET IDENTITY_INSERT Categorias OFF;

-- Reabilitar restrições
ALTER TABLE Chamados CHECK CONSTRAINT ALL;

PRINT '';
PRINT '========================================';
PRINT 'Dados corrigidos com sucesso!';
PRINT '========================================';
PRINT '';
PRINT 'PRIORIDADES:';
SELECT Id, Nome, Nivel, Descricao FROM Prioridades ORDER BY Nivel;
PRINT '';
PRINT 'STATUS:';
SELECT Id, Nome, Descricao FROM Status ORDER BY Id;
PRINT '';
PRINT 'CATEGORIAS:';
SELECT Id, Nome, Descricao FROM Categorias ORDER BY Id;

GO
