-- Script para corrigir caracteres especiais no banco de dados
-- Autor: Sistema de Chamados
-- Data: 04/11/2025

USE SistemaChamados;
GO

-- Corrigir Prioridades
UPDATE Prioridades 
SET Descricao = 'Problema não urgente, pode ser resolvido em até 5 dias úteis.'
WHERE Nivel = 1 AND Nome = 'Baixa';

UPDATE Prioridades 
SET Nome = 'Média'
WHERE Nivel = 2 AND Nome LIKE '%M_dia%';

UPDATE Prioridades 
SET Descricao = 'Problema impactando produtividade, resolver em até 8 horas.'
WHERE Nivel = 3 AND Nome = 'Alta';

-- Corrigir Status
UPDATE Status 
SET Descricao = 'Chamado recém criado e aguardando atribuição.'
WHERE Nome = 'Aberto';

UPDATE Status 
SET Descricao = 'Um técnico já está trabalhando no chamado.'
WHERE Nome LIKE '%Em Andamento%';

UPDATE Status 
SET Descricao = 'Aguardando mais informações do usuário.'
WHERE Nome LIKE '%Aguardando%';

-- Corrigir Categorias
UPDATE Categorias 
SET Descricao = 'Problemas com peças físicas do computador.'
WHERE Nome = 'Hardware';

UPDATE Categorias 
SET Descricao = 'Problemas de conexão com a internet ou rede interna.'
WHERE Nome = 'Rede';

-- Verificar resultados
SELECT * FROM Prioridades ORDER BY Nivel;
SELECT * FROM Status ORDER BY Id;
SELECT * FROM Categorias ORDER BY Id;

PRINT 'Caracteres especiais corrigidos com sucesso!';
GO
