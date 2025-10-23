-- =============================================
-- Script: Seed Data Inicial - GuiNRB
-- Descrição: Dados básicos para o sistema de chamados
-- =============================================

USE SistemaChamados;
GO

-- =============================================
-- 1. CATEGORIAS
-- =============================================
PRINT 'Inserindo Categorias...';

IF NOT EXISTS (SELECT 1 FROM Categorias WHERE Nome = 'Infraestrutura')
BEGIN
    INSERT INTO Categorias (Nome, Descricao)
    VALUES ('Infraestrutura', 'Equipamentos, rede e hardware');
END

IF NOT EXISTS (SELECT 1 FROM Categorias WHERE Nome = 'Sistemas Acadêmicos')
BEGIN
    INSERT INTO Categorias (Nome, Descricao)
    VALUES ('Sistemas Acadêmicos', 'Erro ou acesso em portais e sistemas');
END

IF NOT EXISTS (SELECT 1 FROM Categorias WHERE Nome = 'Conta e Acesso')
BEGIN
    INSERT INTO Categorias (Nome, Descricao)
    VALUES ('Conta e Acesso', 'Senha, e-mail institucional e autenticação');
END

PRINT 'Categorias inseridas: ' + CAST(@@ROWCOUNT AS VARCHAR);
GO

-- =============================================
-- 2. PRIORIDADES
-- =============================================
PRINT 'Inserindo Prioridades...';

IF NOT EXISTS (SELECT 1 FROM Prioridades WHERE Nome = 'Baixa')
BEGIN
    INSERT INTO Prioridades (Nome, Descricao, Nivel)
    VALUES ('Baixa', 'Impacto mínimo, pode aguardar', 1);
END

IF NOT EXISTS (SELECT 1 FROM Prioridades WHERE Nome = 'Média')
BEGIN
    INSERT INTO Prioridades (Nome, Descricao, Nivel)
    VALUES ('Média', 'Impacto moderado, resolver em breve', 2);
END

IF NOT EXISTS (SELECT 1 FROM Prioridades WHERE Nome = 'Alta')
BEGIN
    INSERT INTO Prioridades (Nome, Descricao, Nivel)
    VALUES ('Alta', 'Impacto crítico, resolver imediatamente', 3);
END

PRINT 'Prioridades inseridas: ' + CAST(@@ROWCOUNT AS VARCHAR);
GO

-- =============================================
-- 3. STATUS
-- =============================================
PRINT 'Inserindo Status...';

IF NOT EXISTS (SELECT 1 FROM Status WHERE Nome = 'Aberto')
BEGIN
    INSERT INTO Status (Nome, Descricao)
    VALUES ('Aberto', 'Chamado recém criado');
END

IF NOT EXISTS (SELECT 1 FROM Status WHERE Nome = 'Em andamento')
BEGIN
    INSERT INTO Status (Nome, Descricao)
    VALUES ('Em andamento', 'Equipe trabalhando na solicitação');
END

IF NOT EXISTS (SELECT 1 FROM Status WHERE Nome = 'Resolvido')
BEGIN
    INSERT INTO Status (Nome, Descricao)
    VALUES ('Resolvido', 'Chamado resolvido pela equipe');
END

-- ⭐ IMPORTANTE: Adiciona status "Fechado" necessário para encerrar chamados
IF NOT EXISTS (SELECT 1 FROM Status WHERE Nome = 'Fechado')
BEGIN
    INSERT INTO Status (Nome, Descricao)
    VALUES ('Fechado', 'Chamado encerrado pelo administrador');
    PRINT '✓ Status "Fechado" adicionado (necessário para endpoint /fechar)';
END

PRINT 'Status inseridos: ' + CAST(@@ROWCOUNT AS VARCHAR);
GO

-- =============================================
-- 4. USUÁRIO ADMINISTRADOR DE TESTE
-- =============================================
PRINT 'Verificando usuário administrador...';

IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE Email = 'admin@teste.com')
BEGIN
    -- Nota: A senha será criada via API /auth/register
    -- Este é apenas um placeholder para garantir a estrutura
    PRINT 'Usuario admin@teste.com nao existe. Registre via API /auth/register';
    PRINT 'Depois execute: UPDATE Usuarios SET TipoUsuario = 3 WHERE Email = ''admin@teste.com''';
END
ELSE
BEGIN
    -- Garante que o usuário existente seja Administrador
    UPDATE Usuarios 
    SET TipoUsuario = 3
    WHERE Email = 'admin@teste.com' AND TipoUsuario != 3;
    
    IF @@ROWCOUNT > 0
        PRINT '✓ Usuario admin@teste.com promovido a Administrador (TipoUsuario = 3)';
    ELSE
        PRINT '✓ Usuario admin@teste.com ja e Administrador';
END
GO

-- =============================================
-- 5. VERIFICAÇÃO FINAL
-- =============================================
PRINT '';
PRINT '========================================';
PRINT 'VERIFICACAO FINAL';
PRINT '========================================';

SELECT 'Categorias' AS Tabela, COUNT(*) AS Total FROM Categorias
UNION ALL
SELECT 'Prioridades', COUNT(*) FROM Prioridades
UNION ALL
SELECT 'Status', COUNT(*) FROM Status
UNION ALL
SELECT 'Usuarios', COUNT(*) FROM Usuarios;

PRINT '';
PRINT '✓ Seed data concluído!';
PRINT '';
PRINT 'Tipos de Usuario:';
PRINT '  1 = Solicitante (usuario comum)';
PRINT '  2 = Tecnico';
PRINT '  3 = Administrador (pode encerrar chamados)';
PRINT '';
GO
