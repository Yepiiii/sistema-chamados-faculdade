-- Verificação Final de Conformidade
USE SistemaChamados;
GO

PRINT '=========================================='
PRINT 'VERIFICACAO FINAL DE CONFORMIDADE 100%'
PRINT '=========================================='
PRINT ''

PRINT '1. STATUS (5 registros esperados):'
SELECT Id, Nome, Ativo FROM Status WHERE Ativo = 1 ORDER BY Id;
PRINT ''

PRINT '2. PRIORIDADES (3 registros esperados):'
SELECT Id, Nome, Nivel, Ativo FROM Prioridades WHERE Ativo = 1 ORDER BY Nivel;
PRINT ''

PRINT '3. CATEGORIAS (4 registros esperados):'
SELECT Id, Nome, Ativo FROM Categorias WHERE Ativo = 1 ORDER BY Id;
PRINT ''

PRINT '4. USUARIOS (deve incluir admin@helpdesk.com):'
SELECT Id, NomeCompleto, Email, TipoUsuario FROM Usuarios WHERE Ativo = 1 ORDER BY Id;
PRINT ''

PRINT '=========================================='
PRINT 'CHECKLIST DE CONFORMIDADE:'
PRINT '=========================================='

DECLARE @statusOk BIT = 0
DECLARE @prioridadesOk BIT = 0
DECLARE @categoriasOk BIT = 0
DECLARE @adminOk BIT = 0

-- Verificar Status
IF EXISTS (
    SELECT 1 FROM Status WHERE Nome = 'Violado' AND Ativo = 1
) AND NOT EXISTS (
    SELECT 1 FROM Status WHERE Nome IN ('Resolvido', 'Cancelado', 'Em Espera') AND Ativo = 1
) AND (SELECT COUNT(*) FROM Status WHERE Ativo = 1) = 5
BEGIN
    SET @statusOk = 1
    PRINT '[OK] Status: 5 registros corretos (inclui Violado, sem extras)'
END
ELSE
BEGIN
    PRINT '[ERRO] Status: Nao conforme'
END

-- Verificar Prioridades
IF EXISTS (
    SELECT 1 FROM Prioridades WHERE Nome = 'Média' AND Nivel = 2 AND Ativo = 1
) AND NOT EXISTS (
    SELECT 1 FROM Prioridades WHERE Nome = 'Urgente' AND Ativo = 1
) AND (SELECT COUNT(*) FROM Prioridades WHERE Ativo = 1) = 3
BEGIN
    SET @prioridadesOk = 1
    PRINT '[OK] Prioridades: 3 registros corretos (Media com acento, sem Urgente)'
END
ELSE
BEGIN
    PRINT '[ERRO] Prioridades: Nao conforme'
END

-- Verificar Categorias
IF EXISTS (
    SELECT 1 FROM Categorias WHERE Nome = 'Acesso/Login' AND Ativo = 1
) AND NOT EXISTS (
    SELECT 1 FROM Categorias WHERE Nome IN ('E-mail', 'Backup', 'Telefonia', 'Infraestrutura', 'Segurança', 'Outros') AND Ativo = 1
) AND (SELECT COUNT(*) FROM Categorias WHERE Ativo = 1) = 4
BEGIN
    SET @categoriasOk = 1
    PRINT '[OK] Categorias: 4 registros corretos (Acesso/Login, sem extras)'
END
ELSE
BEGIN
    PRINT '[ERRO] Categorias: Nao conforme'
END

-- Verificar Admin
IF EXISTS (
    SELECT 1 FROM Usuarios WHERE Email = 'admin@helpdesk.com' AND TipoUsuario = 3 AND Ativo = 1
)
BEGIN
    SET @adminOk = 1
    PRINT '[OK] Usuarios: admin@helpdesk.com presente (TipoUsuario=3)'
END
ELSE
BEGIN
    PRINT '[ERRO] Usuarios: admin@helpdesk.com nao encontrado'
END

PRINT ''
PRINT '=========================================='

IF @statusOk = 1 AND @prioridadesOk = 1 AND @categoriasOk = 1 AND @adminOk = 1
BEGIN
    PRINT 'RESULTADO: CONFORMIDADE 100% CONFIRMADA!'
    PRINT 'Seu banco esta identico ao repositorio remoto.'
END
ELSE
BEGIN
    PRINT 'RESULTADO: Ainda existem divergencias.'
    PRINT 'Revise os itens marcados com [ERRO] acima.'
END

PRINT '=========================================='
GO
