-- =============================================
-- Script: Analise Completa do Banco GuiNRB
-- Descricao: Verifica estrutura, dados e usuarios
-- =============================================

USE SistemaChamados;
GO

PRINT '========================================';
PRINT 'ANALISE COMPLETA DO BANCO DE DADOS';
PRINT '========================================';
PRINT '';

-- =============================================
-- 1. VERIFICAR ESTRUTURA DAS TABELAS
-- =============================================
PRINT '1. ESTRUTURA DAS TABELAS';
PRINT '----------------------------------------';

SELECT 
    t.name AS Tabela,
    COUNT(c.name) AS NumColunas
FROM sys.tables t
LEFT JOIN sys.columns c ON t.object_id = c.object_id
WHERE t.name IN ('Usuarios', 'Categorias', 'Prioridades', 'Status', 'Chamados', 'Especialidades')
GROUP BY t.name
ORDER BY t.name;

PRINT '';

-- =============================================
-- 2. VERIFICAR DADOS BASICOS
-- =============================================
PRINT '2. DADOS BASICOS (Seed Data)';
PRINT '----------------------------------------';

SELECT 'Categorias' AS Tabela, COUNT(*) AS Total FROM Categorias
UNION ALL
SELECT 'Prioridades', COUNT(*) FROM Prioridades
UNION ALL
SELECT 'Status', COUNT(*) FROM Status
UNION ALL
SELECT 'Usuarios', COUNT(*) FROM Usuarios
UNION ALL
SELECT 'Chamados', COUNT(*) FROM Chamados
UNION ALL
SELECT 'Especialidades', COUNT(*) FROM Especialidades;

PRINT '';

-- =============================================
-- 3. VERIFICAR CATEGORIAS
-- =============================================
PRINT '3. CATEGORIAS';
PRINT '----------------------------------------';

SELECT Id, Nome, Descricao
FROM Categorias
ORDER BY Id;

PRINT '';

-- =============================================
-- 4. VERIFICAR PRIORIDADES
-- =============================================
PRINT '4. PRIORIDADES';
PRINT '----------------------------------------';

SELECT Id, Nome, Descricao, Nivel
FROM Prioridades
ORDER BY Nivel;

PRINT '';

-- =============================================
-- 5. VERIFICAR STATUS (IMPORTANTE!)
-- =============================================
PRINT '5. STATUS (Deve incluir "Fechado")';
PRINT '----------------------------------------';

SELECT Id, Nome, Descricao
FROM Status
ORDER BY Id;

-- Verificar se "Fechado" existe
DECLARE @StatusFechadoId INT;

IF EXISTS (SELECT 1 FROM Status WHERE Nome = 'Fechado')
BEGIN
    PRINT '';
    PRINT '✓ Status "Fechado" encontrado! (Necessario para encerrar chamados)';
    
    SELECT @StatusFechadoId = Id 
    FROM Status 
    WHERE Nome = 'Fechado';
    
    PRINT 'ID do Status Fechado: ' + CAST(@StatusFechadoId AS VARCHAR);
END
ELSE
BEGIN
    PRINT '';
    PRINT '❌ ERRO: Status "Fechado" NAO ENCONTRADO!';
    PRINT 'Execute: INSERT INTO Status (Nome, Descricao) VALUES (''Fechado'', ''Chamado encerrado'');';
END

PRINT '';

-- =============================================
-- 6. VERIFICAR USUARIOS
-- =============================================
PRINT '6. USUARIOS CADASTRADOS';
PRINT '----------------------------------------';

SELECT 
    Id,
    Nome,
    Email,
    TipoUsuario,
    CASE TipoUsuario
        WHEN 1 THEN 'Solicitante'
        WHEN 2 THEN 'Tecnico'
        WHEN 3 THEN 'Administrador'
        ELSE 'Desconhecido'
    END AS TipoUsuarioNome,
    Ativo,
    CASE Ativo
        WHEN 1 THEN 'Sim'
        ELSE 'Nao'
    END AS AtivoTexto
FROM Usuarios
ORDER BY TipoUsuario DESC, Nome;

PRINT '';

-- =============================================
-- 7. VERIFICAR USUARIO DE TESTE (ADMIN)
-- =============================================
PRINT '7. VERIFICACAO DO USUARIO ADMIN@TESTE.COM';
PRINT '----------------------------------------';

DECLARE @AdminCount INT;
DECLARE @AdminTipo INT;
DECLARE @AdminAtivo BIT;

SELECT 
    @AdminCount = COUNT(*),
    @AdminTipo = MAX(TipoUsuario),
    @AdminAtivo = MAX(CAST(Ativo AS INT))
FROM Usuarios
WHERE Email = 'admin@teste.com';

IF @AdminCount = 0
BEGIN
    PRINT '❌ Usuario admin@teste.com NAO EXISTE!';
    PRINT '';
    PRINT 'Solucao:';
    PRINT '1. Registrar via API: POST /auth/register';
    PRINT '   Body: {"nome":"Administrador","email":"admin@teste.com","senha":"Admin123!","tipoUsuario":1}';
    PRINT '2. Depois promover: UPDATE Usuarios SET TipoUsuario = 3 WHERE Email = ''admin@teste.com'';';
END
ELSE
BEGIN
    PRINT 'Usuario admin@teste.com encontrado!';
    PRINT '';
    
    SELECT 
        Id,
        Nome,
        Email,
        TipoUsuario,
        CASE TipoUsuario
            WHEN 1 THEN 'Solicitante (NAO PODE ENCERRAR)'
            WHEN 2 THEN 'Tecnico (NAO PODE ENCERRAR)'
            WHEN 3 THEN 'Administrador (PODE ENCERRAR)'
            ELSE 'Tipo Desconhecido'
        END AS Permissao,
        Ativo
    FROM Usuarios
    WHERE Email = 'admin@teste.com';
    
    PRINT '';
    
    IF @AdminTipo = 3
    BEGIN
        PRINT '✓ Usuario E ADMINISTRADOR (TipoUsuario = 3)';
        PRINT '✓ Pode encerrar chamados via endpoint /chamados/{id}/fechar';
    END
    ELSE
    BEGIN
        PRINT '❌ Usuario NAO E ADMINISTRADOR (TipoUsuario = ' + CAST(@AdminTipo AS VARCHAR) + ')';
        PRINT '';
        PRINT 'Executar para corrigir:';
        PRINT 'UPDATE Usuarios SET TipoUsuario = 3 WHERE Email = ''admin@teste.com'';';
    END
    
    PRINT '';
    
    IF @AdminAtivo = 1
        PRINT '✓ Usuario esta ATIVO';
    ELSE
        PRINT '❌ Usuario esta INATIVO';
END

PRINT '';

-- =============================================
-- 8. VERIFICAR CHAMADOS
-- =============================================
PRINT '8. CHAMADOS EXISTENTES';
PRINT '----------------------------------------';

IF EXISTS (SELECT 1 FROM Chamados)
BEGIN
    SELECT 
        c.Id,
        c.Titulo,
        s.Nome AS Status,
        p.Nome AS Prioridade,
        cat.Nome AS Categoria,
        u.Nome AS Solicitante,
        c.DataAbertura,
        c.DataFechamento,
        CASE 
            WHEN c.DataFechamento IS NOT NULL THEN 'Encerrado'
            ELSE 'Aberto'
        END AS Situacao
    FROM Chamados c
    LEFT JOIN Status s ON c.StatusId = s.Id
    LEFT JOIN Prioridades p ON c.PrioridadeId = p.Id
    LEFT JOIN Categorias cat ON c.CategoriaId = cat.Id
    LEFT JOIN Usuarios u ON c.SolicitanteId = u.Id
    ORDER BY c.DataAbertura DESC;
END
ELSE
BEGIN
    PRINT 'Nenhum chamado cadastrado ainda.';
END

PRINT '';

-- =============================================
-- 9. DIAGNOSTICO FINAL
-- =============================================
PRINT '========================================';
PRINT 'DIAGNOSTICO FINAL';
PRINT '========================================';
PRINT '';

-- Verificar se tudo esta OK para encerrar chamados
DECLARE @DiagOK BIT = 1;
DECLARE @Problemas NVARCHAR(MAX) = '';

-- Verifica Status Fechado
IF NOT EXISTS (SELECT 1 FROM Status WHERE Nome = 'Fechado')
BEGIN
    SET @DiagOK = 0;
    SET @Problemas = @Problemas + '❌ Status "Fechado" nao existe' + CHAR(13) + CHAR(10);
END

-- Verifica Admin
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE Email = 'admin@teste.com' AND TipoUsuario = 3)
BEGIN
    SET @DiagOK = 0;
    SET @Problemas = @Problemas + '❌ Usuario admin@teste.com nao e Administrador (TipoUsuario != 3)' + CHAR(13) + CHAR(10);
END

IF @DiagOK = 1
BEGIN
    PRINT '✓✓✓ TUDO OK! ✓✓✓';
    PRINT '';
    PRINT 'Sistema pronto para:';
    PRINT '- Criar chamados via API';
    PRINT '- Encerrar chamados via API (endpoint /fechar)';
    PRINT '- Testar no app Mobile';
    PRINT '';
    PRINT 'Credenciais de teste:';
    PRINT '  Email: admin@teste.com';
    PRINT '  Senha: Admin123!';
    PRINT '  Tipo: Administrador (nivel 3)';
END
ELSE
BEGIN
    PRINT '❌ PROBLEMAS ENCONTRADOS:';
    PRINT @Problemas;
    PRINT '';
    PRINT 'Consulte o guia GUIA_BANCO_DADOS.md para corrigir.';
END

PRINT '';
PRINT '========================================';
PRINT 'Analise concluida!';
PRINT 'Data/Hora: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '========================================';
GO
