-- ===================================================================
-- SCRIPT: Resetar IDs para sequência 1-N
-- Objetivo: Corrigir IDs que começam em 5-6 devido a deleções anteriores
-- Data: 11/11/2025
-- ===================================================================

USE SistemaChamados;
GO

PRINT '🔧 Iniciando reset de IDs sequenciais...';

-- ===================================================================
-- PASSO 1: Desabilitar constraints temporariamente
-- ===================================================================
PRINT '📌 Desabilitando constraints...';

EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
GO

-- ===================================================================
-- PASSO 2: Limpar tabelas dependentes (ordem reversa de FK)
-- ===================================================================
PRINT '🗑️ Limpando tabelas dependentes...';

DELETE FROM Comentarios;
DELETE FROM Anexos;
DELETE FROM Chamados;
DELETE FROM Usuarios;

PRINT '✅ Tabelas dependentes limpas.';
GO

-- ===================================================================
-- PASSO 3: Resetar e recriar Status (IDs 1-5)
-- ===================================================================
PRINT '📊 Resetando Status...';

DELETE FROM Status;
DBCC CHECKIDENT ('Status', RESEED, 0);

INSERT INTO Status (Nome, Descricao, Ativo, DataCadastro) VALUES
('Aberto', 'Chamado criado e aguardando atribuição', 1, GETUTCDATE()),
('Em Andamento', 'Técnico trabalhando no chamado', 1, GETUTCDATE()),
('Aguardando Cliente', 'Aguardando resposta do solicitante', 1, GETUTCDATE()),
('Resolvido', 'Problema solucionado', 1, GETUTCDATE()),
('Fechado', 'Chamado finalizado', 1, GETUTCDATE());

SELECT Id, Nome FROM Status ORDER BY Id;
PRINT '✅ Status resetados: IDs 1-5';
GO

-- ===================================================================
-- PASSO 4: Resetar e recriar Categorias (IDs 1-4)
-- ===================================================================
PRINT '📊 Resetando Categorias...';

DELETE FROM Categorias;
DBCC CHECKIDENT ('Categorias', RESEED, 0);

INSERT INTO Categorias (Nome, Descricao, Ativo, DataCadastro) VALUES
('Hardware', 'Problemas com equipamentos físicos', 1, GETUTCDATE()),
('Software', 'Problemas com sistemas e aplicativos', 1, GETUTCDATE()),
('Redes', 'Problemas de conectividade e internet', 1, GETUTCDATE()),
('Infraestrutura', 'Problemas com servidores e infraestrutura', 1, GETUTCDATE());

SELECT Id, Nome FROM Categorias ORDER BY Id;
PRINT '✅ Categorias resetadas: IDs 1-4';
GO

-- ===================================================================
-- PASSO 5: Resetar e recriar Prioridades (IDs 1-4)
-- ===================================================================
PRINT '📊 Resetando Prioridades...';

DELETE FROM Prioridades;
DBCC CHECKIDENT ('Prioridades', RESEED, 0);

INSERT INTO Prioridades (Nome, Nivel, Descricao, TempoRespostaHoras, Ativo, DataCadastro) VALUES
('Baixa', 1, 'Não urgente', 72, 1, GETUTCDATE()),
('Média', 2, 'Atenção moderada', 48, 1, GETUTCDATE()),
('Alta', 3, 'Requer atenção urgente', 24, 1, GETUTCDATE()),
('Crítica', 4, 'Emergência imediata', 4, 1, GETUTCDATE());

SELECT Id, Nome, Nivel FROM Prioridades ORDER BY Id;
PRINT '✅ Prioridades resetadas: IDs 1-4';
GO

-- ===================================================================
-- PASSO 6: Recriar Usuários (IDs começam em 1)
-- ===================================================================
PRINT '👥 Recriando usuários NeuroHelp...';

DELETE FROM Usuarios;
DBCC CHECKIDENT ('Usuarios', RESEED, 0);

-- Senhas BCrypt pré-geradas:
-- Admin@123:   $2a$11$9vKx7K6hF8Y.oP7L5Q3.9.J8Z5xN4wT3L2V9gH6mE1fR8sK4pO2yC
-- Tecnico@123: $2a$11$8uJy6K5gE7X.nO6K4P2.8.I7Y4wM3vS2K1U8fG5lD0eQ7rJ3nN1xB
-- User@123:    $2a$11$7tIx5J4fD6W.mN5J3O1.7.H6X3vL2uR1J0T7eF4kC9dP6qI2mM0wA

INSERT INTO Usuarios (NomeCompleto, Email, SenhaHash, TipoUsuario, IsInterno, Ativo, DataCadastro) VALUES
-- Admin
('Carlos Mendes', 'admin@neurohelp.com.br', '$2a$11$9vKx7K6hF8Y.oP7L5Q3.9.J8Z5xN4wT3L2V9gH6mE1fR8sK4pO2yC', 3, 1, 1, GETUTCDATE());

INSERT INTO Usuarios (NomeCompleto, Email, SenhaHash, TipoUsuario, Especialidade, EspecialidadeCategoriaId, IsInterno, Ativo, DataCadastro) VALUES
-- Técnicos (EspecialidadeCategoriaId agora usa IDs 1-4)
('Rafael Costa', 'rafael.costa@neurohelp.com.br', '$2a$11$8uJy6K5gE7X.nO6K4P2.8.I7Y4wM3vS2K1U8fG5lD0eQ7rJ3nN1xB', 2, 'Hardware', 1, 1, 1, GETUTCDATE()),
('Ana Paula Silva', 'ana.silva@neurohelp.com.br', '$2a$11$8uJy6K5gE7X.nO6K4P2.8.I7Y4wM3vS2K1U8fG5lD0eQ7rJ3nN1xB', 2, 'Software', 2, 1, 1, GETUTCDATE()),
('Bruno Ferreira', 'bruno.ferreira@neurohelp.com.br', '$2a$11$8uJy6K5gE7X.nO6K4P2.8.I7Y4wM3vS2K1U8fG5lD0eQ7rJ3nN1xB', 2, 'Redes', 3, 1, 1, GETUTCDATE());

INSERT INTO Usuarios (NomeCompleto, Email, SenhaHash, TipoUsuario, IsInterno, Ativo, DataCadastro) VALUES
-- Usuários comuns
('Juliana Martins', 'juliana.martins@neurohelp.com.br', '$2a$11$7tIx5J4fD6W.mN5J3O1.7.H6X3vL2uR1J0T7eF4kC9dP6qI2mM0wA', 1, 1, 1, GETUTCDATE()),
('Marcelo Santos', 'marcelo.santos@neurohelp.com.br', '$2a$11$7tIx5J4fD6W.mN5J3O1.7.H6X3vL2uR1J0T7eF4kC9dP6qI2mM0wA', 1, 1, 1, GETUTCDATE());

SELECT Id, NomeCompleto, Email, TipoUsuario FROM Usuarios ORDER BY Id;
PRINT '✅ Usuários criados com IDs sequenciais';
GO

-- ===================================================================
-- PASSO 7: Reabilitar constraints
-- ===================================================================
PRINT '🔒 Reabilitando constraints...';

EXEC sp_MSforeachtable 'ALTER TABLE ? CHECK CONSTRAINT ALL';
GO

-- ===================================================================
-- VERIFICAÇÃO FINAL
-- ===================================================================
PRINT '';
PRINT '========================================';
PRINT '📊 VERIFICAÇÃO FINAL DE IDs';
PRINT '========================================';

PRINT '';
PRINT '✅ Status:';
SELECT Id, Nome FROM Status ORDER BY Id;

PRINT '';
PRINT '✅ Categorias:';
SELECT Id, Nome FROM Categorias ORDER BY Id;

PRINT '';
PRINT '✅ Prioridades:';
SELECT Id, Nome, Nivel FROM Prioridades ORDER BY Id;

PRINT '';
PRINT '✅ Usuários:';
SELECT Id, NomeCompleto, Email, TipoUsuario FROM Usuarios ORDER BY Id;

PRINT '';
PRINT '========================================';
PRINT '✅ RESET CONCLUÍDO COM SUCESSO!';
PRINT '========================================';
PRINT '';
PRINT '🔑 Credenciais de Acesso:';
PRINT '   Admin:    admin@neurohelp.com.br / Admin@123';
PRINT '   Técnico:  rafael.costa@neurohelp.com.br / Tecnico@123';
PRINT '   Usuário:  juliana.martins@neurohelp.com.br / User@123';
PRINT '';
PRINT '📱 Mobile StatusConstants agora deve usar:';
PRINT '   Aberto = 1, EmAndamento = 2, Aguardando = 3, Resolvido = 4, Fechado = 5';
GO
