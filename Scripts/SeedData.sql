-- ======================================
-- Script de População de Dados Básicos
-- Sistema de Chamados - Faculdade
-- ======================================

USE SistemaChamados;
GO

-- ======================================
-- 1. CATEGORIAS
-- ======================================
IF NOT EXISTS (SELECT 1 FROM Categorias)
BEGIN
    INSERT INTO Categorias (Nome, Descricao, Ativo, DataCadastro) VALUES
    ('Hardware', 'Problemas com equipamentos, computadores, impressoras', 1, GETDATE()),
    ('Software', 'Instalação e problemas com programas', 1, GETDATE()),
    ('Rede', 'Conectividade, internet, Wi-Fi', 1, GETDATE()),
    ('Sistema', 'Problemas com sistemas acadêmicos', 1, GETDATE()),
    ('Email', 'Problemas com e-mail institucional', 1, GETDATE()),
    ('Laboratório', 'Questões relacionadas aos laboratórios', 1, GETDATE()),
    ('Biblioteca', 'Sistema de biblioteca e acervo', 1, GETDATE()),
    ('Matrícula', 'Problemas com matrícula e rematrícula', 1, GETDATE()),
    ('Nota/Frequência', 'Questões sobre notas e frequência', 1, GETDATE()),
    ('Outros', 'Outras solicitações', 1, GETDATE());
    
    PRINT 'Categorias inseridas com sucesso!';
END
ELSE
BEGIN
    PRINT 'Categorias já existem no banco.';
END
GO

-- ======================================
-- 2. PRIORIDADES
-- ======================================
IF NOT EXISTS (SELECT 1 FROM Prioridades)
BEGIN
    INSERT INTO Prioridades (Nome, Descricao, Nivel, Ativo, DataCadastro) VALUES
    ('Baixa', 'Atendimento em até 5 dias úteis', 1, 1, GETDATE()),
    ('Normal', 'Atendimento em até 3 dias úteis', 2, 1, GETDATE()),
    ('Alta', 'Atendimento em até 1 dia útil', 3, 1, GETDATE()),
    ('Urgente', 'Atendimento imediato', 4, 1, GETDATE());
    
    PRINT 'Prioridades inseridas com sucesso!';
END
ELSE
BEGIN
    PRINT 'Prioridades já existem no banco.';
END
GO

-- ======================================
-- 3. STATUS
-- ======================================
IF NOT EXISTS (SELECT 1 FROM Status)
BEGIN
    INSERT INTO Status (Nome, Descricao, Ativo, DataCadastro) VALUES
    ('Aberto', 'Chamado recém-aberto, aguardando análise', 1, GETDATE()),
    ('Em Análise', 'Chamado sendo analisado pelo técnico', 1, GETDATE()),
    ('Em Andamento', 'Chamado em processo de resolução', 1, GETDATE()),
    ('Aguardando Usuário', 'Aguardando resposta ou ação do usuário', 1, GETDATE()),
    ('Resolvido', 'Chamado resolvido, aguardando confirmação', 1, GETDATE()),
    ('Fechado', 'Chamado finalizado', 1, GETDATE()),
    ('Cancelado', 'Chamado cancelado pelo solicitante', 1, GETDATE());
    
    PRINT 'Status inseridos com sucesso!';
END
ELSE
BEGIN
    PRINT 'Status já existem no banco.';
END
GO

-- ======================================
-- 4. Verificação dos Dados
-- ======================================
PRINT '';
PRINT '======================================';
PRINT 'RESUMO DOS DADOS INSERIDOS';
PRINT '======================================';
PRINT 'Categorias: ' + CAST((SELECT COUNT(*) FROM Categorias) AS VARCHAR(10));
PRINT 'Prioridades: ' + CAST((SELECT COUNT(*) FROM Prioridades) AS VARCHAR(10));
PRINT 'Status: ' + CAST((SELECT COUNT(*) FROM Status) AS VARCHAR(10));
PRINT 'Usuários: ' + CAST((SELECT COUNT(*) FROM Usuarios) AS VARCHAR(10));
PRINT '======================================';
GO
