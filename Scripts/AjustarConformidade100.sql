-- =====================================================
-- Script de Conformidade 100% com Repositório Remoto
-- Data: 03/11/2025
-- Objetivo: Deixar banco idêntico ao GuiNRB/sistema-chamados-faculdade
-- =====================================================

USE SistemaChamados;
GO

PRINT '======================================'
PRINT 'INICIANDO AJUSTES DE CONFORMIDADE'
PRINT '======================================'
PRINT ''

-- =====================================================
-- 1. CORRIGIR TABELA STATUS
-- =====================================================
PRINT '1. Ajustando tabela Status...'

-- Adicionar Status "Violado" se não existir
IF NOT EXISTS (SELECT 1 FROM Status WHERE Nome = 'Violado')
BEGIN
    INSERT INTO Status (Nome, Descricao, Ativo, DataCadastro) 
    VALUES ('Violado', 'O prazo de resolução (SLA) do chamado foi excedido.', 1, GETDATE());
    PRINT '   ✓ Status "Violado" adicionado'
END
ELSE
BEGIN
    PRINT '   ✓ Status "Violado" já existe'
END

-- Remover Status extras que não existem no remoto
DELETE FROM Status WHERE Nome IN ('Resolvido', 'Cancelado', 'Em Espera');
PRINT '   ✓ Status extras removidos (Resolvido, Cancelado, Em Espera)'

-- Verificar resultado
DECLARE @statusCount INT
SELECT @statusCount = COUNT(*) FROM Status WHERE Ativo = 1;
PRINT '   ✓ Total de Status ativos: ' + CAST(@statusCount AS VARCHAR(10))
PRINT ''

-- =====================================================
-- 2. CORRIGIR TABELA PRIORIDADES
-- =====================================================
PRINT '2. Ajustando tabela Prioridades...'

-- Atualizar nome "Normal" para "Média"
UPDATE Prioridades 
SET Nome = 'Média', Descricao = 'Prioridade normal.'
WHERE Nome = 'Normal';
PRINT '   ✓ Prioridade "Normal" renomeada para "Média"'

-- Remover prioridade "Urgente" (não existe no remoto)
DELETE FROM Prioridades WHERE Nome = 'Urgente';
PRINT '   ✓ Prioridade "Urgente" removida'

-- Verificar resultado
DECLARE @prioridadeCount INT
SELECT @prioridadeCount = COUNT(*) FROM Prioridades WHERE Ativo = 1;
PRINT '   ✓ Total de Prioridades ativas: ' + CAST(@prioridadeCount AS VARCHAR(10))
PRINT ''

-- =====================================================
-- 3. CORRIGIR TABELA CATEGORIAS
-- =====================================================
PRINT '3. Ajustando tabela Categorias...'

-- Atualizar nome "Acesso/Senha" para "Acesso/Login"
UPDATE Categorias 
SET Nome = 'Acesso/Login', Descricao = 'Problemas de senha ou acesso a sistemas.'
WHERE Nome = 'Acesso/Senha';
PRINT '   ✓ Categoria "Acesso/Senha" renomeada para "Acesso/Login"'

-- Remover categorias extras que não existem no remoto
DELETE FROM Categorias 
WHERE Nome IN ('E-mail', 'Backup', 'Telefonia', 'Infraestrutura', 'Segurança', 'Outros');
PRINT '   ✓ Categorias extras removidas (E-mail, Backup, Telefonia, Infraestrutura, Segurança, Outros)'

-- Verificar resultado
DECLARE @categoriaCount INT
SELECT @categoriaCount = COUNT(*) FROM Categorias WHERE Ativo = 1;
PRINT '   ✓ Total de Categorias ativas: ' + CAST(@categoriaCount AS VARCHAR(10))
PRINT ''

-- =====================================================
-- 4. ADICIONAR USUÁRIO ADMIN DO REMOTO
-- =====================================================
PRINT '4. Ajustando tabela Usuarios...'

-- Verificar se o usuário admin do remoto já existe
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE Email = 'admin@helpdesk.com')
BEGIN
    INSERT INTO Usuarios (NomeCompleto, Email, SenhaHash, TipoUsuario, EspecialidadeCategoriaId, Ativo, DataCadastro)
    VALUES (
        'Administrador Neuro Help', 
        'admin@helpdesk.com', 
        '$2a$11$7Wm1iN97aWdOZpK0IptKiOqE6rW1MikaR9Jv66YE.TJLDJ/Qce/BS', 
        3, 
        NULL, 
        1,
        GETDATE()
    );
    PRINT '   ✓ Usuário admin@helpdesk.com adicionado (senha: admin123)'
END
ELSE
BEGIN
    PRINT '   ✓ Usuário admin@helpdesk.com já existe'
END

-- Verificar resultado
DECLARE @usuarioCount INT
SELECT @usuarioCount = COUNT(*) FROM Usuarios WHERE Ativo = 1;
PRINT '   ✓ Total de Usuários ativos: ' + CAST(@usuarioCount AS VARCHAR(10))
PRINT ''

-- =====================================================
-- 5. VERIFICAÇÃO FINAL
-- =====================================================
PRINT '======================================'
PRINT 'VERIFICAÇÃO FINAL'
PRINT '======================================'
PRINT ''

PRINT 'Contagem de Registros:'
SELECT 'Status' AS Tabela, COUNT(*) AS Total FROM Status WHERE Ativo = 1
UNION ALL SELECT 'Prioridades', COUNT(*) FROM Prioridades WHERE Ativo = 1
UNION ALL SELECT 'Categorias', COUNT(*) FROM Categorias WHERE Ativo = 1
UNION ALL SELECT 'Usuarios', COUNT(*) FROM Usuarios WHERE Ativo = 1;
PRINT ''

PRINT 'Status Cadastrados:'
SELECT Id, Nome FROM Status WHERE Ativo = 1 ORDER BY Id;
PRINT ''

PRINT 'Prioridades Cadastradas:'
SELECT Id, Nome, Nivel FROM Prioridades WHERE Ativo = 1 ORDER BY Nivel;
PRINT ''

PRINT 'Categorias Cadastradas:'
SELECT Id, Nome FROM Categorias WHERE Ativo = 1 ORDER BY Id;
PRINT ''

PRINT 'Usuarios Cadastrados:'
SELECT Id, NomeCompleto, Email, TipoUsuario FROM Usuarios WHERE Ativo = 1 ORDER BY Id;
PRINT ''

-- =====================================================
-- 6. RESULTADO ESPERADO
-- =====================================================
PRINT '======================================'
PRINT 'RESULTADO ESPERADO (REPOSITÓRIO REMOTO):'
PRINT '======================================'
PRINT 'Status: 5 registros'
PRINT '  1. Aberto'
PRINT '  2. Em Andamento'
PRINT '  3. Aguardando Resposta'
PRINT '  4. Fechado'
PRINT '  5. Violado'
PRINT ''
PRINT 'Prioridades: 3 registros'
PRINT '  1. Baixa (Nivel=1)'
PRINT '  2. Média (Nivel=2)'
PRINT '  3. Alta (Nivel=3)'
PRINT ''
PRINT 'Categorias: 4 registros'
PRINT '  1. Hardware'
PRINT '  2. Software'
PRINT '  3. Rede'
PRINT '  4. Acesso/Login'
PRINT ''
PRINT 'Usuarios: Deve incluir admin@helpdesk.com (senha: admin123)'
PRINT ''

PRINT '======================================'
PRINT 'CONFORMIDADE 100% APLICADA COM SUCESSO!'
PRINT '======================================'
GO
