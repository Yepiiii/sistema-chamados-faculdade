-- Criar Técnicos de Nível 1, 2 e 3

-- Técnico Nível 1 (Básico)
INSERT INTO Usuarios (NomeCompleto, Email, SenhaHash, TipoUsuario, DataCadastro, Ativo, EspecialidadeCategoriaId)
VALUES ('Técnico Junior - Nível 1', 'junior@empresa.com', '$2a$11$xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', 2, GETDATE(), 1, 1);

DECLARE @IdJunior INT = SCOPE_IDENTITY();

INSERT INTO TecnicoTIPerfis (UsuarioId, AreaAtuacao, DataContratacao, NivelTecnico)
VALUES (@IdJunior, 'Suporte Básico', GETDATE(), 1);

-- Técnico Nível 3 (Sênior/Especialista)
INSERT INTO Usuarios (NomeCompleto, Email, SenhaHash, TipoUsuario, DataCadastro, Ativo, EspecialidadeCategoriaId)
VALUES ('Técnico Senior - Nível 3', 'senior@empresa.com', '$2a$11$xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', 2, GETDATE(), 1, 1);

DECLARE @IdSenior INT = SCOPE_IDENTITY();

INSERT INTO TecnicoTIPerfis (UsuarioId, AreaAtuacao, DataContratacao, NivelTecnico)
VALUES (@IdSenior, 'Especialista', GETDATE(), 3);

-- Exibir todos os técnicos com seus níveis
SELECT 
    u.Id,
    u.NomeCompleto,
    u.Email,
    t.NivelTecnico,
    t.AreaAtuacao,
    CASE t.NivelTecnico
        WHEN 1 THEN 'Nível 1 - Suporte Básico'
        WHEN 2 THEN 'Nível 2 - Suporte Intermediário'
        WHEN 3 THEN 'Nível 3 - Especialista Sênior'
    END AS DescricaoNivel
FROM Usuarios u
INNER JOIN TecnicoTIPerfis t ON u.Id = t.UsuarioId
WHERE u.TipoUsuario = 2
ORDER BY t.NivelTecnico;
