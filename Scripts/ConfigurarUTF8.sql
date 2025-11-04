-- Script para recriar banco com UTF-8 nativo
-- Data: 04/11/2025

USE master;
GO

-- Verificar collation atual
SELECT name, collation_name 
FROM sys.databases 
WHERE name = 'SistemaChamados';
GO

-- Alterar collation do banco para suportar UTF-8
ALTER DATABASE SistemaChamados 
COLLATE Latin1_General_100_CI_AS_SC_UTF8;
GO

USE SistemaChamados;
GO

PRINT 'Database collation alterado para UTF-8!';
PRINT '';

-- Alterar collation das colunas de texto
ALTER TABLE Prioridades 
ALTER COLUMN Nome NVARCHAR(50) COLLATE Latin1_General_100_CI_AS_SC_UTF8 NOT NULL;

ALTER TABLE Prioridades 
ALTER COLUMN Descricao NVARCHAR(500) COLLATE Latin1_General_100_CI_AS_SC_UTF8 NULL;

ALTER TABLE Status 
ALTER COLUMN Nome NVARCHAR(50) COLLATE Latin1_General_100_CI_AS_SC_UTF8 NOT NULL;

ALTER TABLE Status 
ALTER COLUMN Descricao NVARCHAR(500) COLLATE Latin1_General_100_CI_AS_SC_UTF8 NULL;

ALTER TABLE Categorias 
ALTER COLUMN Nome NVARCHAR(100) COLLATE Latin1_General_100_CI_AS_SC_UTF8 NOT NULL;

ALTER TABLE Categorias 
ALTER COLUMN Descricao NVARCHAR(500) COLLATE Latin1_General_100_CI_AS_SC_UTF8 NULL;

PRINT 'Collation das colunas alterado para UTF-8!';
PRINT '';

-- Limpar e reinserir com UTF-8
ALTER TABLE Chamados NOCHECK CONSTRAINT ALL;
ALTER TABLE Usuarios NOCHECK CONSTRAINT ALL;

DELETE FROM Prioridades;
DELETE FROM Status;

SET IDENTITY_INSERT Prioridades ON;
INSERT INTO Prioridades (Id, Nome, Nivel, Descricao, DataCadastro, Ativo) VALUES
(1, N'Baixa', 1, N'Problema não urgente, pode ser resolvido em até 5 dias úteis.', GETUTCDATE(), 1),
(2, N'Média', 2, N'Prioridade normal.', GETUTCDATE(), 1),
(3, N'Alta', 3, N'Problema impactando produtividade, resolver em até 8 horas.', GETUTCDATE(), 1);
SET IDENTITY_INSERT Prioridades OFF;

SET IDENTITY_INSERT Status ON;
INSERT INTO Status (Id, Nome, Descricao, DataCadastro, Ativo) VALUES
(1, N'Aberto', N'Chamado recém criado e aguardando atribuição.', GETUTCDATE(), 1),
(2, N'Em Andamento', N'Um técnico já está trabalhando no chamado.', GETUTCDATE(), 1),
(3, N'Aguardando Resposta', N'Aguardando mais informações do usuário.', GETUTCDATE(), 1),
(5, N'Fechado', N'O chamado foi resolvido.', GETUTCDATE(), 1),
(8, N'Violado', N'O prazo de resolução (SLA) do chamado foi excedido.', GETUTCDATE(), 1);
SET IDENTITY_INSERT Status OFF;

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

ALTER TABLE Chamados CHECK CONSTRAINT ALL;
ALTER TABLE Usuarios CHECK CONSTRAINT ALL;

PRINT '';
PRINT '========================================';
PRINT 'BANCO RECONFIGURADO PARA UTF-8!';
PRINT '========================================';
PRINT '';

SELECT 'Prioridades' AS Tabela, COUNT(*) AS Total FROM Prioridades
UNION ALL
SELECT 'Status', COUNT(*) FROM Status
UNION ALL
SELECT 'Categorias', COUNT(*) FROM Categorias;

GO
