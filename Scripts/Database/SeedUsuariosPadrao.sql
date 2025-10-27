-- ========================================
-- Script: Criar Usuarios Padrao
-- ========================================
-- Este script cria os 4 usuarios padrao do sistema
-- Senhas hashadas com BCrypt para Admin@123

USE SistemaChamados;
GO

-- Verificar se usuarios ja existem
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE Email = 'admin@sistema.com')
BEGIN
    PRINT 'Criando Admin...';
    INSERT INTO Usuarios (NomeCompleto, Email, SenhaHash, TipoUsuario, DataCadastro, Ativo)
    VALUES (
        'Administrador Sistema',
        'admin@sistema.com',
        '$2a$11$vqJZ3eQJ1HLKhxVGjQqZ4.L8Y9XZWGxNQr9F5wYLcKNxvC7oYzHQa', -- Admin@123
        3, -- Admin
        GETDATE(),
        1
    );
END
ELSE
BEGIN
    PRINT 'Admin ja existe';
END
GO

-- Verificar e criar Tecnico Intermediario (Nivel 2)
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE Email = 'tecnico@empresa.com')
BEGIN
    PRINT 'Criando Tecnico Intermediario (Nivel 2)...';
    
    DECLARE @TecnicoN2Id INT;
    
    INSERT INTO Usuarios (NomeCompleto, Email, SenhaHash, TipoUsuario, DataCadastro, Ativo)
    VALUES (
        'Tecnico Intermediario - Nivel 2',
        'tecnico@empresa.com',
        '$2a$11$vqJZ3eQJ1HLKhxVGjQqZ4.L8Y9XZWGxNQr9F5wYLcKNxvC7oYzHQa', -- Admin@123
        2, -- Tecnico TI
        GETDATE(),
        1
    );
    
    SET @TecnicoN2Id = SCOPE_IDENTITY();
    
    INSERT INTO TecnicoTIPerfis (UsuarioId, AreaAtuacao, DataContratacao, NivelTecnico)
    VALUES (
        @TecnicoN2Id,
        'Suporte Intermediario',
        GETDATE(),
        2 -- Nivel 2
    );
END
ELSE
BEGIN
    PRINT 'Tecnico Intermediario ja existe';
END
GO

-- Verificar e criar Tecnico Senior (Nivel 3)
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE Email = 'senior@empresa.com')
BEGIN
    PRINT 'Criando Tecnico Senior (Nivel 3)...';
    
    DECLARE @TecnicoN3Id INT;
    
    INSERT INTO Usuarios (NomeCompleto, Email, SenhaHash, TipoUsuario, DataCadastro, Ativo)
    VALUES (
        'Tecnico Senior - Nivel 3',
        'senior@empresa.com',
        '$2a$11$vqJZ3eQJ1HLKhxVGjQqZ4.L8Y9XZWGxNQr9F5wYLcKNxvC7oYzHQa', -- Admin@123
        2, -- Tecnico TI
        GETDATE(),
        1
    );
    
    SET @TecnicoN3Id = SCOPE_IDENTITY();
    
    INSERT INTO TecnicoTIPerfis (UsuarioId, AreaAtuacao, DataContratacao, NivelTecnico)
    VALUES (
        @TecnicoN3Id,
        'Especialista Senior',
        GETDATE(),
        3 -- Nivel 3
    );
END
ELSE
BEGIN
    PRINT 'Tecnico Senior ja existe';
END
GO

-- Verificar e criar Colaborador
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE Email = 'colaborador@empresa.com')
BEGIN
    PRINT 'Criando Colaborador...';
    
    DECLARE @ColaboradorId INT;
    
    INSERT INTO Usuarios (NomeCompleto, Email, SenhaHash, TipoUsuario, DataCadastro, Ativo)
    VALUES (
        'Colaborador Teste',
        'colaborador@empresa.com',
        '$2a$11$vqJZ3eQJ1HLKhxVGjQqZ4.L8Y9XZWGxNQr9F5wYLcKNxvC7oYzHQa', -- Admin@123
        1, -- Colaborador
        GETDATE(),
        1
    );
    
    SET @ColaboradorId = SCOPE_IDENTITY();
    
    INSERT INTO ColaboradorPerfis (UsuarioId, Matricula, Departamento, DataAdmissao)
    VALUES (
        @ColaboradorId,
        'COL001',
        'Departamento Teste',
        GETDATE()
    );
END
ELSE
BEGIN
    PRINT 'Colaborador ja existe';
END
GO

-- Exibir resultado
PRINT '';
PRINT '========================================';
PRINT ' USUARIOS PADRAO CRIADOS/VERIFICADOS';
PRINT '========================================';
PRINT '';

SELECT 
    u.Id,
    u.NomeCompleto,
    u.Email,
    CASE u.TipoUsuario
        WHEN 1 THEN 'Colaborador'
        WHEN 2 THEN 'Tecnico TI'
        WHEN 3 THEN 'Admin'
    END AS TipoUsuario,
    ISNULL(t.NivelTecnico, 0) AS NivelTecnico,
    ISNULL(t.AreaAtuacao, c.Departamento) AS Area
FROM Usuarios u
LEFT JOIN TecnicoTIPerfis t ON u.Id = t.UsuarioId
LEFT JOIN ColaboradorPerfis c ON u.Id = c.UsuarioId
WHERE u.Email IN (
    'admin@sistema.com',
    'tecnico@empresa.com',
    'senior@empresa.com',
    'colaborador@empresa.com'
)
ORDER BY u.TipoUsuario DESC, u.Id;

PRINT '';
PRINT '========================================';
PRINT ' CREDENCIAIS DE ACESSO';
PRINT '========================================';
PRINT '';
PRINT 'Admin:          admin@sistema.com / Admin@123';
PRINT 'Tecnico N2:     tecnico@empresa.com / Admin@123';
PRINT 'Tecnico N3:     senior@empresa.com / Admin@123';
PRINT 'Colaborador:    colaborador@empresa.com / Admin@123';
PRINT '';
GO
