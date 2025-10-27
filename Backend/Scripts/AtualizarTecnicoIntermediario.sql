-- =============================================
-- Script: Corrigir Técnico Intermediário (Nível 2)
-- Descrição: Atualiza tecnico@empresa.com de Nível 1 para Nível 2
-- =============================================

USE SistemaChamados;
GO

PRINT 'Atualizando Técnico Intermediário...';

-- Buscar ID do usuário tecnico@empresa.com
DECLARE @TecnicoId INT;
SELECT @TecnicoId = Id FROM Usuarios WHERE Email = 'tecnico@empresa.com';

IF @TecnicoId IS NOT NULL
BEGIN
    -- Atualizar nome do usuário
    UPDATE Usuarios
    SET NomeCompleto = 'Técnico Intermediário - Nível 2'
    WHERE Id = @TecnicoId;
    
    PRINT '✓ Nome atualizado para: Técnico Intermediário - Nível 2';
    
    -- Atualizar nível no perfil de técnico
    UPDATE TecnicoTIPerfis
    SET NivelTecnico = 2,
        AreaAtuacao = 'Suporte Intermediário'
    WHERE UsuarioId = @TecnicoId;
    
    PRINT '✓ NivelTecnico atualizado para: 2';
    PRINT '✓ AreaAtuacao atualizada para: Suporte Intermediário';
    
    -- Verificar resultado
    SELECT 
        u.Id,
        u.Email,
        u.NomeCompleto,
        t.NivelTecnico,
        t.AreaAtuacao,
        CASE t.NivelTecnico
            WHEN 1 THEN 'Nível 1 - Suporte Básico'
            WHEN 2 THEN 'Nível 2 - Suporte Intermediário'
            WHEN 3 THEN 'Nível 3 - Especialista Sênior'
        END AS DescricaoNivel
    FROM Usuarios u
    INNER JOIN TecnicoTIPerfis t ON u.Id = t.UsuarioId
    WHERE u.Email = 'tecnico@empresa.com';
    
    PRINT '';
    PRINT '========================================';
    PRINT '✓ Técnico atualizado com sucesso!';
    PRINT '========================================';
END
ELSE
BEGIN
    PRINT '❌ Erro: Técnico tecnico@empresa.com não encontrado!';
END
GO
