-- =============================================
-- Script RAPIDO: Verificar Usuario Admin
-- =============================================

USE SistemaChamados;
GO

PRINT '========================================';
PRINT 'VERIFICACAO RAPIDA - Usuario Admin';
PRINT '========================================';
PRINT '';

-- Verificar se usuario existe e seu nivel
IF EXISTS (SELECT 1 FROM Usuarios WHERE Email = 'admin@teste.com')
BEGIN
    DECLARE @TipoUsuario INT;
    DECLARE @Ativo BIT;
    DECLARE @NomeCompleto NVARCHAR(200);
    
    SELECT 
        @NomeCompleto = NomeCompleto,
        @TipoUsuario = TipoUsuario,
        @Ativo = Ativo
    FROM Usuarios
    WHERE Email = 'admin@teste.com';
    
    PRINT 'Usuario encontrado:';
    PRINT '  Nome: ' + @NomeCompleto;
    PRINT '  Email: admin@teste.com';
    PRINT '  TipoUsuario: ' + CAST(@TipoUsuario AS VARCHAR);
    PRINT '  Nivel: ' + CASE @TipoUsuario
        WHEN 1 THEN '1 - Solicitante (NAO pode encerrar)'
        WHEN 2 THEN '2 - Tecnico (NAO pode encerrar)'
        WHEN 3 THEN '3 - Administrador (PODE encerrar)'
        ELSE 'Desconhecido'
    END;
    PRINT '  Ativo: ' + CASE @Ativo WHEN 1 THEN 'Sim' ELSE 'Nao' END;
    PRINT '';
    
    IF @TipoUsuario = 3
    BEGIN
        PRINT '✓✓✓ USUARIO E NIVEL 3 (ADMINISTRADOR) ✓✓✓';
        PRINT '';
        PRINT 'Pode executar:';
        PRINT '- POST /api/chamados/{id}/fechar';
        PRINT '- Encerrar chamados no app Mobile';
    END
    ELSE
    BEGIN
        PRINT '❌ USUARIO NAO E NIVEL 3!';
        PRINT '';
        PRINT 'Para promover, execute:';
        PRINT '';
        PRINT 'UPDATE Usuarios';
        PRINT 'SET TipoUsuario = 3';
        PRINT 'WHERE Email = ''admin@teste.com'';';
        PRINT '';
        PRINT 'GO';
    END
END
ELSE
BEGIN
    PRINT '❌ Usuario admin@teste.com NAO EXISTE!';
    PRINT '';
    PRINT 'Solucao:';
    PRINT '1. Abra: http://localhost:5246/swagger';
    PRINT '2. POST /auth/register com:';
    PRINT '   {';
    PRINT '     "nome": "Administrador",';
    PRINT '     "email": "admin@teste.com",';
    PRINT '     "senha": "Admin123!",';
    PRINT '     "tipoUsuario": 1';
    PRINT '   }';
    PRINT '3. Depois promova:';
    PRINT '   UPDATE Usuarios SET TipoUsuario = 3 WHERE Email = ''admin@teste.com'';';
END

PRINT '';

-- Verificar Status "Fechado"
PRINT '========================================';
PRINT 'Status "Fechado"';
PRINT '========================================';

IF EXISTS (SELECT 1 FROM Status WHERE Nome = 'Fechado')
BEGIN
    PRINT '✓ Status "Fechado" existe!';
    
    SELECT Id, Nome, Descricao
    FROM Status
    WHERE Nome = 'Fechado';
END
ELSE
BEGIN
    PRINT '❌ Status "Fechado" NAO existe!';
    PRINT '';
    PRINT 'Para adicionar:';
    PRINT 'INSERT INTO Status (Nome, Descricao)';
    PRINT 'VALUES (''Fechado'', ''Chamado encerrado pelo administrador'');';
END

PRINT '';
PRINT '========================================';
GO
