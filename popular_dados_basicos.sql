-- ========================================
-- SCRIPT PARA POPULAR DADOS BÁSICOS
-- ========================================
-- Execute este script para criar os dados mínimos necessários
-- para o funcionamento do sistema de chamados

-- Inserir Status
INSERT INTO Status (Nome, Descricao, Ativo) VALUES 
('Aberto', 'Chamado recém criado', 1),
('Em Andamento', 'Chamado sendo atendido', 1),
('Aguardando', 'Aguardando resposta do solicitante', 1),
('Resolvido', 'Chamado resolvido', 1),
('Fechado', 'Chamado finalizado', 1);

-- Inserir Prioridades
INSERT INTO Prioridades (Nome, Nivel, Descricao, Ativo) VALUES 
('Baixa', 1, 'Prioridade baixa', 1),
('Média', 2, 'Prioridade média', 1),
('Alta', 3, 'Prioridade alta', 1),
('Crítica', 4, 'Prioridade crítica', 1);

-- Inserir Categorias
INSERT INTO Categorias (Nome, Descricao, Ativo) VALUES 
('Suporte Técnico', 'Problemas técnicos gerais', 1),
('Hardware', 'Problemas relacionados a hardware', 1),
('Software', 'Problemas relacionados a software', 1),
('Rede', 'Problemas de conectividade e rede', 1),
('Impressora', 'Problemas com impressoras', 1),
('Email', 'Problemas relacionados a email', 1),
('Sistema', 'Problemas no sistema acadêmico', 1),
('Outros', 'Outros tipos de solicitação', 1);

-- Verificar se os dados foram inseridos
SELECT 'Status inseridos:' as Tabela;
SELECT Id, Nome, Descricao FROM Status;

SELECT 'Prioridades inseridas:' as Tabela;
SELECT Id, Nome, Nivel, Descricao FROM Prioridades;

SELECT 'Categorias inseridas:' as Tabela;
SELECT Id, Nome, Descricao FROM Categorias;