-- Script para limpar dados antigos e popular com dados da NeuroHelp
USE SistemaChamados;
GO

-- Desabilita constraints temporariamente
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
GO

-- Limpa todas as tabelas
DELETE FROM dbo.Comentarios;
DELETE FROM dbo.Anexos;
DELETE FROM dbo.Chamados;
DELETE FROM dbo.Usuarios;
DELETE FROM dbo.Categorias;
DELETE FROM dbo.Prioridades;
DELETE FROM dbo.Status;
GO

-- Reabilita constraints
EXEC sp_MSforeachtable 'ALTER TABLE ? CHECK CONSTRAINT ALL'
GO

-- Reseta os IDs
DBCC CHECKIDENT ('dbo.Categorias', RESEED, 0);
DBCC CHECKIDENT ('dbo.Prioridades', RESEED, 0);
DBCC CHECKIDENT ('dbo.Status', RESEED, 0);
DBCC CHECKIDENT ('dbo.Usuarios', RESEED, 0);
DBCC CHECKIDENT ('dbo.Chamados', RESEED, 0);
DBCC CHECKIDENT ('dbo.Comentarios', RESEED, 0);
DBCC CHECKIDENT ('dbo.Anexos', RESEED, 0);
GO

-- Popula Categorias
INSERT INTO dbo.Categorias (Nome, Descricao, Ativo, DataCadastro)
VALUES 
    ('Hardware', 'Problemas com equipamentos físicos', 1, GETDATE()),
    ('Software', 'Problemas com sistemas e aplicativos', 1, GETDATE()),
    ('Redes', 'Problemas de conectividade e internet', 1, GETDATE()),
    ('Infraestrutura', 'Problemas com servidores e infraestrutura', 1, GETDATE());
GO

-- Popula Prioridades
INSERT INTO dbo.Prioridades (Nome, Nivel, Descricao, TempoRespostaHoras, Ativo, DataCadastro)
VALUES 
    ('Baixa', 1, 'Não urgente', 72, 1, GETDATE()),
    ('Média', 2, 'Atenção moderada', 48, 1, GETDATE()),
    ('Alta', 3, 'Requer atenção urgente', 24, 1, GETDATE()),
    ('Crítica', 4, 'Emergência imediata', 4, 1, GETDATE());
GO

-- Popula Status
INSERT INTO dbo.Status (Nome, Descricao, Ativo, DataCadastro)
VALUES 
    ('Aberto', 'Chamado criado e aguardando atribuição', 1, GETDATE()),
    ('Em Andamento', 'Técnico trabalhando no chamado', 1, GETDATE()),
    ('Aguardando Cliente', 'Aguardando resposta do solicitante', 1, GETDATE()),
    ('Resolvido', 'Problema solucionado', 1, GETDATE()),
    ('Fechado', 'Chamado finalizado', 1, GETDATE());
GO

-- Popula Usuários (com senhas hasheadas - você precisará gerar os hashes corretos)
-- Admin: admin@neurohelp.com.br / Admin@123
INSERT INTO dbo.Usuarios (NomeCompleto, Email, SenhaHash, TipoUsuario, IsInterno, Ativo, DataCadastro)
VALUES ('Carlos Mendes', 'admin@neurohelp.com.br', 'HASH_AQUI', 3, 1, 1, GETDATE());

-- Técnico Hardware: rafael.costa@neurohelp.com.br / Tecnico@123
INSERT INTO dbo.Usuarios (NomeCompleto, Email, SenhaHash, TipoUsuario, IsInterno, Especialidade, EspecialidadeCategoriaId, Ativo, DataCadastro)
VALUES ('Rafael Costa', 'rafael.costa@neurohelp.com.br', 'HASH_AQUI', 2, 1, 'Hardware', 1, 1, GETDATE());

-- Técnico Software: ana.silva@neurohelp.com.br / Tecnico@123
INSERT INTO dbo.Usuarios (NomeCompleto, Email, SenhaHash, TipoUsuario, IsInterno, Especialidade, EspecialidadeCategoriaId, Ativo, DataCadastro)
VALUES ('Ana Paula Silva', 'ana.silva@neurohelp.com.br', 'HASH_AQUI', 2, 1, 'Software', 2, 1, GETDATE());

-- Técnico Redes: bruno.ferreira@neurohelp.com.br / Tecnico@123
INSERT INTO dbo.Usuarios (NomeCompleto, Email, SenhaHash, TipoUsuario, IsInterno, Especialidade, EspecialidadeCategoriaId, Ativo, DataCadastro)
VALUES ('Bruno Ferreira', 'bruno.ferreira@neurohelp.com.br', 'HASH_AQUI', 2, 1, 'Redes', 3, 1, GETDATE());

-- Usuário Financeiro: juliana.martins@neurohelp.com.br / User@123
INSERT INTO dbo.Usuarios (NomeCompleto, Email, SenhaHash, TipoUsuario, IsInterno, Ativo, DataCadastro)
VALUES ('Juliana Martins', 'juliana.martins@neurohelp.com.br', 'HASH_AQUI', 1, 0, 1, GETDATE());

-- Usuário RH: marcelo.santos@neurohelp.com.br / User@123
INSERT INTO dbo.Usuarios (NomeCompleto, Email, SenhaHash, TipoUsuario, IsInterno, Ativo, DataCadastro)
VALUES ('Marcelo Santos', 'marcelo.santos@neurohelp.com.br', 'HASH_AQUI', 1, 0, 1, GETDATE());
GO

PRINT '✅ Banco de dados limpo e populado com dados da NeuroHelp!';
GO
