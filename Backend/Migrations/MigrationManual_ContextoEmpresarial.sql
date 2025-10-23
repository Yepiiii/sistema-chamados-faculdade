-- Migration Manual: AlunoPerfis -> ColaboradorPerfis e ProfessorPerfis -> TecnicoTIPerfis
USE SistemaChamados;
GO

-- Passo 1: Renomear tabelas (se existirem)
IF OBJECT_ID('dbo.AlunoPerfis', 'U') IS NOT NULL
BEGIN
    EXEC sp_rename 'AlunoPerfis', 'ColaboradorPerfis';
    PRINT 'Tabela AlunoPerfis renomeada para ColaboradorPerfis';
END
ELSE IF OBJECT_ID('dbo.ColaboradorPerfis', 'U') IS NULL
BEGIN
    -- Criar ColaboradorPerfis se não existir
    CREATE TABLE ColaboradorPerfis (
        Id int NOT NULL IDENTITY(1,1) PRIMARY KEY,
        UsuarioId int NOT NULL,
        Matricula nvarchar(20) NOT NULL,
        Departamento nvarchar(100) NULL,
        DataAdmissao datetime2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_ColaboradorPerfis_Usuarios FOREIGN KEY (UsuarioId) REFERENCES Usuarios(Id) ON DELETE CASCADE
    );
    CREATE UNIQUE INDEX IX_ColaboradorPerfis_UsuarioId ON ColaboradorPerfis(UsuarioId);
    CREATE UNIQUE INDEX IX_ColaboradorPerfis_Matricula ON ColaboradorPerfis(Matricula);
    PRINT 'Tabela ColaboradorPerfis criada';
END
GO

IF OBJECT_ID('dbo.ProfessorPerfis', 'U') IS NOT NULL
BEGIN
    EXEC sp_rename 'ProfessorPerfis', 'TecnicoTIPerfis';
    PRINT 'Tabela ProfessorPerfis renomeada para TecnicoTIPerfis';
END
ELSE IF OBJECT_ID('dbo.TecnicoTIPerfis', 'U') IS NULL
BEGIN
    -- Criar TecnicoTIPerfis se não existir
    CREATE TABLE TecnicoTIPerfis (
        Id int NOT NULL IDENTITY(1,1) PRIMARY KEY,
        UsuarioId int NOT NULL,
        AreaAtuacao nvarchar(50) NULL,
        DataContratacao datetime2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_TecnicoTIPerfis_Usuarios FOREIGN KEY (UsuarioId) REFERENCES Usuarios(Id) ON DELETE CASCADE
    );
    CREATE UNIQUE INDEX IX_TecnicoTIPerfis_UsuarioId ON TecnicoTIPerfis(UsuarioId);
    PRINT 'Tabela TecnicoTIPerfis criada';
END
GO

-- Passo 2: Renomear colunas em ColaboradorPerfis (se existirem)
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ColaboradorPerfis') AND name = 'Curso')
BEGIN
    EXEC sp_rename 'ColaboradorPerfis.Curso', 'Departamento', 'COLUMN';
    PRINT 'Coluna Curso renomeada para Departamento';
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ColaboradorPerfis') AND name = 'Semestre')
BEGIN
    -- Adicionar DataAdmissao se não existir
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ColaboradorPerfis') AND name = 'DataAdmissao')
    BEGIN
        ALTER TABLE ColaboradorPerfis ADD DataAdmissao datetime2 NOT NULL DEFAULT GETDATE();
        PRINT 'Coluna DataAdmissao adicionada';
    END
    
    -- Remover Semestre
    ALTER TABLE ColaboradorPerfis DROP COLUMN Semestre;
    PRINT 'Coluna Semestre removida';
END
GO

-- Passo 3: Renomear colunas em TecnicoTIPerfis (se existirem)
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('TecnicoTIPerfis') AND name = 'CursoMinistrado')
BEGIN
    EXEC sp_rename 'TecnicoTIPerfis.CursoMinistrado', 'AreaAtuacao', 'COLUMN';
    PRINT 'Coluna CursoMinistrado renomeada para AreaAtuacao';
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('TecnicoTIPerfis') AND name = 'SemestreMinistrado')
BEGIN
    -- Adicionar DataContratacao se não existir
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('TecnicoTIPerfis') AND name = 'DataContratacao')
    BEGIN
        ALTER TABLE TecnicoTIPerfis ADD DataContratacao datetime2 NOT NULL DEFAULT GETDATE();
        PRINT 'Coluna DataContratacao adicionada';
    END
    
    -- Remover SemestreMinistrado
    ALTER TABLE TecnicoTIPerfis DROP COLUMN SemestreMinistrado;
    PRINT 'Coluna SemestreMinistrado removida';
END
GO

-- Passo 4: Registrar migration no histórico
IF NOT EXISTS (SELECT 1 FROM __EFMigrationsHistory WHERE MigrationId = '20251023133441_MigracaoContextoEmpresarial')
BEGIN
    INSERT INTO __EFMigrationsHistory (MigrationId, ProductVersion)
    VALUES ('20251023133441_MigracaoContextoEmpresarial', '9.0.0');
    PRINT 'Migration registrada no histórico';
END
GO

PRINT 'Migration concluída com sucesso!';
