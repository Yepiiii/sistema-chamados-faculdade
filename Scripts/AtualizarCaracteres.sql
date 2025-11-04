-- Script para atualizar caracteres especiais existentes
-- Data: 04/11/2025
-- Usando UPDATE para preservar referências

USE SistemaChamados;
GO

-- Atualizar Prioridades com N' prefix para Unicode
UPDATE Prioridades SET Nome = N'Baixa', Descricao = N'Problema não urgente, pode ser resolvido em até 5 dias úteis.' WHERE Id = 1;
UPDATE Prioridades SET Nome = N'Média', Descricao = N'Prioridade normal.' WHERE Id = 2;
UPDATE Prioridades SET Nome = N'Alta', Descricao = N'Problema impactando produtividade, resolver em até 8 horas.' WHERE Id = 3;

-- Atualizar Status com N' prefix para Unicode
UPDATE Status SET Nome = N'Aberto', Descricao = N'Chamado recém criado e aguardando atribuição.' WHERE Id = 1;
UPDATE Status SET Nome = N'Em Andamento', Descricao = N'Um técnico já está trabalhando no chamado.' WHERE Id = 2;
UPDATE Status SET Nome = N'Aguardando Resposta', Descricao = N'Aguardando mais informações do usuário.' WHERE Id = 3;
UPDATE Status SET Nome = N'Fechado', Descricao = N'O chamado foi resolvido.' WHERE Id = 5;
UPDATE Status SET Nome = N'Violado', Descricao = N'O prazo de resolução (SLA) do chamado foi excedido.' WHERE Id = 8;

-- Atualizar Categorias com N' prefix para Unicode
UPDATE Categorias SET Nome = N'Hardware', Descricao = N'Problemas com peças físicas do computador.' WHERE Id = 1;
UPDATE Categorias SET Nome = N'Software', Descricao = N'Problemas com programas e sistemas.' WHERE Id = 2;
UPDATE Categorias SET Nome = N'Rede', Descricao = N'Problemas de conexão com a internet ou rede interna.' WHERE Id = 3;
UPDATE Categorias SET Nome = N'Acesso/Login', Descricao = N'Problemas de senha ou acesso a sistemas.' WHERE Id = 5;

PRINT '========================================';
PRINT 'Caracteres especiais corrigidos!';
PRINT '========================================';
PRINT '';

-- Verificar Prioridades
SELECT Id, Nome, Nivel, Descricao FROM Prioridades ORDER BY Nivel;
PRINT '';

-- Verificar Status  
SELECT Id, Nome, Descricao FROM Status ORDER BY Id;
PRINT '';

-- Verificar Categorias
SELECT Id, Nome, Descricao FROM Categorias ORDER BY Id;

GO
