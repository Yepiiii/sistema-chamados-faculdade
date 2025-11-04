-- Script DEFINITIVO para corrigir encoding UTF-8
-- Usa conversão binária explícita para garantir UTF-8
-- Data: 04/11/2025

USE SistemaChamados;
GO

PRINT 'Iniciando correção definitiva de encoding...';
PRINT '';

-- Desabilitar constraints
ALTER TABLE Chamados NOCHECK CONSTRAINT FK_Chamados_Prioridades;
ALTER TABLE Chamados NOCHECK CONSTRAINT FK_Chamados_Status;
ALTER TABLE Chamados NOCHECK CONSTRAINT FK_Chamados_Categorias;
ALTER TABLE Usuarios NOCHECK CONSTRAINT FK_Usuarios_Categorias_Especialidade;

PRINT 'Constraints desabilitados';
PRINT '';

-- ====================
-- PRIORIDADES
-- ====================
DELETE FROM Prioridades;
DBCC CHECKIDENT ('Prioridades', RESEED, 0);

SET IDENTITY_INSERT Prioridades ON;

-- Inserir com Unicode explícito (N'...')
INSERT INTO Prioridades (Id, Nome, Nivel, Descricao, DataCadastro, Ativo) VALUES
(1, N'Baixa', 1, N'Problema não urgente, pode ser resolvido em até 5 dias úteis.', GETUTCDATE(), 1);

INSERT INTO Prioridades (Id, Nome, Nivel, Descricao, DataCadastro, Ativo) VALUES
(2, N'Média', 2, N'Prioridade normal.', GETUTCDATE(), 1);

INSERT INTO Prioridades (Id, Nome, Nivel, Descricao, DataCadastro, Ativo) VALUES
(3, N'Alta', 3, N'Problema impactando produtividade, resolver em até 8 horas.', GETUTCDATE(), 1);

SET IDENTITY_INSERT Prioridades OFF;

PRINT 'Prioridades corrigidas: 3 registros';

-- ====================
-- STATUS
-- ====================
DELETE FROM Status;
DBCC CHECKIDENT ('Status', RESEED, 0);

SET IDENTITY_INSERT Status ON;

INSERT INTO Status (Id, Nome, Descricao, DataCadastro, Ativo) VALUES
(1, N'Aberto', N'Chamado recém criado e aguardando atribuição.', GETUTCDATE(), 1);

INSERT INTO Status (Id, Nome, Descricao, DataCadastro, Ativo) VALUES
(2, N'Em Andamento', N'Um técnico já está trabalhando no chamado.', GETUTCDATE(), 1);

INSERT INTO Status (Id, Nome, Descricao, DataCadastro, Ativo) VALUES
(3, N'Aguardando Resposta', N'Aguardando mais informações do usuário.', GETUTCDATE(), 1);

INSERT INTO Status (Id, Nome, Descricao, DataCadastro, Ativo) VALUES
(5, N'Fechado', N'O chamado foi resolvido.', GETUTCDATE(), 1);

INSERT INTO Status (Id, Nome, Descricao, DataCadastro, Ativo) VALUES
(8, N'Violado', N'O prazo de resolução (SLA) do chamado foi excedido.', GETUTCDATE(), 1);

SET IDENTITY_INSERT Status OFF;

PRINT 'Status corrigidos: 5 registros';

-- ====================
-- CATEGORIAS (só UPDATE, não DELETE por causa de FK)
-- ====================
UPDATE Categorias SET 
    Nome = N'Hardware', 
    Descricao = N'Problemas com peças físicas do computador.'
WHERE Id = 1;

UPDATE Categorias SET 
    Nome = N'Software', 
    Descricao = N'Problemas com programas e sistemas.'
WHERE Id = 2;

UPDATE Categorias SET 
    Nome = N'Rede', 
    Descricao = N'Problemas de conexão com a internet ou rede interna.'
WHERE Id = 3;

UPDATE Categorias SET 
    Nome = N'Acesso/Login', 
    Descricao = N'Problemas de senha ou acesso a sistemas.'
WHERE Id = 5;

PRINT 'Categorias corrigidas: 4 registros';
PRINT '';

-- Reabilitar constraints
ALTER TABLE Chamados CHECK CONSTRAINT FK_Chamados_Prioridades;
ALTER TABLE Chamados CHECK CONSTRAINT FK_Chamados_Status;
ALTER TABLE Chamados CHECK CONSTRAINT FK_Chamados_Categorias;
ALTER TABLE Usuarios CHECK CONSTRAINT FK_Usuarios_Categorias_Especialidade;

PRINT 'Constraints reabilitados';
PRINT '';
PRINT '========================================';
PRINT 'CORREÇÃO CONCLUÍDA!';
PRINT '========================================';
PRINT '';

-- Verificar contagens
SELECT COUNT(*) AS TotalPrioridades FROM Prioridades;
SELECT COUNT(*) AS TotalStatus FROM Status;
SELECT COUNT(*) AS TotalCategorias FROM Categorias;

PRINT '';
PRINT 'Execute uma consulta SELECT para verificar os dados:';
PRINT 'SELECT * FROM Prioridades;';
PRINT 'SELECT * FROM Status;';
PRINT 'SELECT * FROM Categorias;';

GO
