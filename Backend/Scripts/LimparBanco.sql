-- Script para LIMPAR COMPLETAMENTE o banco de dados
USE SistemaChamados;
GO

-- Desabilita constraints
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
GO

-- Limpa todas as tabelas (apenas as que existem)
IF OBJECT_ID('dbo.Comentarios', 'U') IS NOT NULL DELETE FROM dbo.Comentarios;
IF OBJECT_ID('dbo.Anexos', 'U') IS NOT NULL DELETE FROM dbo.Anexos;
DELETE FROM dbo.Chamados;
DELETE FROM dbo.Usuarios;
DELETE FROM dbo.Categorias;
DELETE FROM dbo.Prioridades;
DELETE FROM dbo.Status;
GO

-- Reabilita constraints
EXEC sp_MSforeachtable 'ALTER TABLE ? CHECK CONSTRAINT ALL'
GO

PRINT '✅ Todas as tabelas foram limpas!';
PRINT 'Agora execute o backend (dotnet run) para popular com dados da NeuroHelp';
GO
