IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111025617_InitialCreateSqlServer'
)
BEGIN
    CREATE TABLE [Categorias] (
        [Id] int NOT NULL IDENTITY,
        [Nome] nvarchar(100) NOT NULL,
        [Descricao] nvarchar(500) NULL,
        [Ativo] bit NOT NULL DEFAULT CAST(1 AS bit),
        [DataCadastro] datetime2 NOT NULL DEFAULT (GETDATE()),
        CONSTRAINT [PK_Categorias] PRIMARY KEY ([Id])
    );
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111025617_InitialCreateSqlServer'
)
BEGIN
    CREATE TABLE [Prioridades] (
        [Id] int NOT NULL IDENTITY,
        [Nome] nvarchar(50) NOT NULL,
        [Nivel] int NOT NULL,
        [Descricao] nvarchar(500) NULL,
        [TempoRespostaHoras] int NOT NULL,
        [Ativo] bit NOT NULL DEFAULT CAST(1 AS bit),
        [DataCadastro] datetime2 NOT NULL DEFAULT (GETDATE()),
        CONSTRAINT [PK_Prioridades] PRIMARY KEY ([Id])
    );
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111025617_InitialCreateSqlServer'
)
BEGIN
    CREATE TABLE [Status] (
        [Id] int NOT NULL IDENTITY,
        [Nome] nvarchar(50) NOT NULL,
        [Descricao] nvarchar(500) NULL,
        [Ativo] bit NOT NULL DEFAULT CAST(1 AS bit),
        [DataCadastro] datetime2 NOT NULL DEFAULT (GETDATE()),
        CONSTRAINT [PK_Status] PRIMARY KEY ([Id])
    );
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111025617_InitialCreateSqlServer'
)
BEGIN
    CREATE TABLE [Usuarios] (
        [Id] int NOT NULL IDENTITY,
        [NomeCompleto] nvarchar(150) NOT NULL,
        [Email] nvarchar(150) NOT NULL,
        [SenhaHash] nvarchar(255) NOT NULL,
        [TipoUsuario] int NOT NULL,
        [IsInterno] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Especialidade] nvarchar(100) NULL,
        [EspecialidadeCategoriaId] int NULL,
        [Ativo] bit NOT NULL DEFAULT CAST(1 AS bit),
        [PasswordResetToken] nvarchar(255) NULL,
        [ResetTokenExpires] datetime2 NULL,
        [DataCadastro] datetime2 NOT NULL DEFAULT (GETDATE()),
        CONSTRAINT [PK_Usuarios] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_Usuarios_Categorias_EspecialidadeCategoriaId] FOREIGN KEY ([EspecialidadeCategoriaId]) REFERENCES [Categorias] ([Id]) ON DELETE SET NULL
    );
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111025617_InitialCreateSqlServer'
)
BEGIN
    CREATE TABLE [Chamados] (
        [Id] int NOT NULL IDENTITY,
        [Titulo] nvarchar(200) NOT NULL,
        [Descricao] nvarchar(max) NOT NULL,
        [DataAbertura] datetime2 NOT NULL DEFAULT (GETDATE()),
        [DataFechamento] datetime2 NULL,
        [DataUltimaAtualizacao] datetime2 NULL,
        [SlaDataExpiracao] datetime2 NULL,
        [SolicitanteId] int NOT NULL,
        [TecnicoId] int NULL,
        [CategoriaId] int NOT NULL,
        [PrioridadeId] int NOT NULL,
        [StatusId] int NOT NULL,
        CONSTRAINT [PK_Chamados] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_Chamados_Categorias_CategoriaId] FOREIGN KEY ([CategoriaId]) REFERENCES [Categorias] ([Id]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Chamados_Prioridades_PrioridadeId] FOREIGN KEY ([PrioridadeId]) REFERENCES [Prioridades] ([Id]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Chamados_Status_StatusId] FOREIGN KEY ([StatusId]) REFERENCES [Status] ([Id]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Chamados_Usuarios_SolicitanteId] FOREIGN KEY ([SolicitanteId]) REFERENCES [Usuarios] ([Id]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Chamados_Usuarios_TecnicoId] FOREIGN KEY ([TecnicoId]) REFERENCES [Usuarios] ([Id]) ON DELETE NO ACTION
    );
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111025617_InitialCreateSqlServer'
)
BEGIN
    CREATE TABLE [Anexos] (
        [Id] int NOT NULL IDENTITY,
        [NomeArquivo] nvarchar(255) NOT NULL,
        [CaminhoArquivo] nvarchar(500) NOT NULL,
        [TamanhoBytes] bigint NOT NULL,
        [TipoMime] nvarchar(100) NOT NULL,
        [DataUpload] datetime2 NOT NULL DEFAULT (GETDATE()),
        [ChamadoId] int NOT NULL,
        [UsuarioId] int NOT NULL,
        CONSTRAINT [PK_Anexos] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_Anexos_Chamados_ChamadoId] FOREIGN KEY ([ChamadoId]) REFERENCES [Chamados] ([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_Anexos_Usuarios_UsuarioId] FOREIGN KEY ([UsuarioId]) REFERENCES [Usuarios] ([Id]) ON DELETE NO ACTION
    );
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111025617_InitialCreateSqlServer'
)
BEGIN
    CREATE TABLE [Comentarios] (
        [Id] int NOT NULL IDENTITY,
        [Texto] nvarchar(max) NOT NULL,
        [DataCriacao] datetime2 NOT NULL DEFAULT (GETDATE()),
        [IsInterno] bit NOT NULL DEFAULT CAST(0 AS bit),
        [ChamadoId] int NOT NULL,
        [UsuarioId] int NOT NULL,
        CONSTRAINT [PK_Comentarios] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_Comentarios_Chamados_ChamadoId] FOREIGN KEY ([ChamadoId]) REFERENCES [Chamados] ([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_Comentarios_Usuarios_UsuarioId] FOREIGN KEY ([UsuarioId]) REFERENCES [Usuarios] ([Id]) ON DELETE NO ACTION
    );
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111025617_InitialCreateSqlServer'
)
BEGIN
    CREATE INDEX [IX_Anexos_ChamadoId] ON [Anexos] ([ChamadoId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111025617_InitialCreateSqlServer'
)
BEGIN
    CREATE INDEX [IX_Anexos_UsuarioId] ON [Anexos] ([UsuarioId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111025617_InitialCreateSqlServer'
)
BEGIN
    CREATE INDEX [IX_Chamados_CategoriaId] ON [Chamados] ([CategoriaId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111025617_InitialCreateSqlServer'
)
BEGIN
    CREATE INDEX [IX_Chamados_PrioridadeId] ON [Chamados] ([PrioridadeId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111025617_InitialCreateSqlServer'
)
BEGIN
    CREATE INDEX [IX_Chamados_SolicitanteId] ON [Chamados] ([SolicitanteId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111025617_InitialCreateSqlServer'
)
BEGIN
    CREATE INDEX [IX_Chamados_StatusId] ON [Chamados] ([StatusId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111025617_InitialCreateSqlServer'
)
BEGIN
    CREATE INDEX [IX_Chamados_TecnicoId] ON [Chamados] ([TecnicoId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111025617_InitialCreateSqlServer'
)
BEGIN
    CREATE INDEX [IX_Comentarios_ChamadoId] ON [Comentarios] ([ChamadoId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111025617_InitialCreateSqlServer'
)
BEGIN
    CREATE INDEX [IX_Comentarios_UsuarioId] ON [Comentarios] ([UsuarioId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111025617_InitialCreateSqlServer'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Usuarios_Email] ON [Usuarios] ([Email]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111025617_InitialCreateSqlServer'
)
BEGIN
    CREATE INDEX [IX_Usuarios_EspecialidadeCategoriaId] ON [Usuarios] ([EspecialidadeCategoriaId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111025617_InitialCreateSqlServer'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20251111025617_InitialCreateSqlServer', N'8.0.0');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var0 sysname;
    SELECT @var0 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Usuarios]') AND [c].[name] = N'TipoUsuario');
    IF @var0 IS NOT NULL EXEC(N'ALTER TABLE [Usuarios] DROP CONSTRAINT [' + @var0 + '];');
    ALTER TABLE [Usuarios] ALTER COLUMN [TipoUsuario] INTEGER NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var1 sysname;
    SELECT @var1 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Usuarios]') AND [c].[name] = N'SenhaHash');
    IF @var1 IS NOT NULL EXEC(N'ALTER TABLE [Usuarios] DROP CONSTRAINT [' + @var1 + '];');
    ALTER TABLE [Usuarios] ALTER COLUMN [SenhaHash] TEXT NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var2 sysname;
    SELECT @var2 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Usuarios]') AND [c].[name] = N'ResetTokenExpires');
    IF @var2 IS NOT NULL EXEC(N'ALTER TABLE [Usuarios] DROP CONSTRAINT [' + @var2 + '];');
    ALTER TABLE [Usuarios] ALTER COLUMN [ResetTokenExpires] TEXT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var3 sysname;
    SELECT @var3 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Usuarios]') AND [c].[name] = N'PasswordResetToken');
    IF @var3 IS NOT NULL EXEC(N'ALTER TABLE [Usuarios] DROP CONSTRAINT [' + @var3 + '];');
    ALTER TABLE [Usuarios] ALTER COLUMN [PasswordResetToken] TEXT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var4 sysname;
    SELECT @var4 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Usuarios]') AND [c].[name] = N'NomeCompleto');
    IF @var4 IS NOT NULL EXEC(N'ALTER TABLE [Usuarios] DROP CONSTRAINT [' + @var4 + '];');
    ALTER TABLE [Usuarios] ALTER COLUMN [NomeCompleto] TEXT NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var5 sysname;
    SELECT @var5 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Usuarios]') AND [c].[name] = N'IsInterno');
    IF @var5 IS NOT NULL EXEC(N'ALTER TABLE [Usuarios] DROP CONSTRAINT [' + @var5 + '];');
    ALTER TABLE [Usuarios] ALTER COLUMN [IsInterno] INTEGER NOT NULL;
    ALTER TABLE [Usuarios] ADD DEFAULT CAST(1 AS INTEGER) FOR [IsInterno];
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DROP INDEX [IX_Usuarios_EspecialidadeCategoriaId] ON [Usuarios];
    DECLARE @var6 sysname;
    SELECT @var6 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Usuarios]') AND [c].[name] = N'EspecialidadeCategoriaId');
    IF @var6 IS NOT NULL EXEC(N'ALTER TABLE [Usuarios] DROP CONSTRAINT [' + @var6 + '];');
    ALTER TABLE [Usuarios] ALTER COLUMN [EspecialidadeCategoriaId] INTEGER NULL;
    CREATE INDEX [IX_Usuarios_EspecialidadeCategoriaId] ON [Usuarios] ([EspecialidadeCategoriaId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var7 sysname;
    SELECT @var7 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Usuarios]') AND [c].[name] = N'Especialidade');
    IF @var7 IS NOT NULL EXEC(N'ALTER TABLE [Usuarios] DROP CONSTRAINT [' + @var7 + '];');
    ALTER TABLE [Usuarios] ALTER COLUMN [Especialidade] TEXT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DROP INDEX [IX_Usuarios_Email] ON [Usuarios];
    DECLARE @var8 sysname;
    SELECT @var8 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Usuarios]') AND [c].[name] = N'Email');
    IF @var8 IS NOT NULL EXEC(N'ALTER TABLE [Usuarios] DROP CONSTRAINT [' + @var8 + '];');
    ALTER TABLE [Usuarios] ALTER COLUMN [Email] TEXT NOT NULL;
    CREATE UNIQUE INDEX [IX_Usuarios_Email] ON [Usuarios] ([Email]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var9 sysname;
    SELECT @var9 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Usuarios]') AND [c].[name] = N'DataCadastro');
    IF @var9 IS NOT NULL EXEC(N'ALTER TABLE [Usuarios] DROP CONSTRAINT [' + @var9 + '];');
    ALTER TABLE [Usuarios] ALTER COLUMN [DataCadastro] TEXT NOT NULL;
    ALTER TABLE [Usuarios] ADD DEFAULT (GETDATE()) FOR [DataCadastro];
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var10 sysname;
    SELECT @var10 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Usuarios]') AND [c].[name] = N'Ativo');
    IF @var10 IS NOT NULL EXEC(N'ALTER TABLE [Usuarios] DROP CONSTRAINT [' + @var10 + '];');
    ALTER TABLE [Usuarios] ALTER COLUMN [Ativo] INTEGER NOT NULL;
    ALTER TABLE [Usuarios] ADD DEFAULT CAST(1 AS INTEGER) FOR [Ativo];
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var11 sysname;
    SELECT @var11 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Usuarios]') AND [c].[name] = N'Id');
    IF @var11 IS NOT NULL EXEC(N'ALTER TABLE [Usuarios] DROP CONSTRAINT [' + @var11 + '];');
    ALTER TABLE [Usuarios] ALTER COLUMN [Id] INTEGER NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var12 sysname;
    SELECT @var12 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Status]') AND [c].[name] = N'Nome');
    IF @var12 IS NOT NULL EXEC(N'ALTER TABLE [Status] DROP CONSTRAINT [' + @var12 + '];');
    ALTER TABLE [Status] ALTER COLUMN [Nome] TEXT NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var13 sysname;
    SELECT @var13 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Status]') AND [c].[name] = N'Descricao');
    IF @var13 IS NOT NULL EXEC(N'ALTER TABLE [Status] DROP CONSTRAINT [' + @var13 + '];');
    ALTER TABLE [Status] ALTER COLUMN [Descricao] TEXT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var14 sysname;
    SELECT @var14 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Status]') AND [c].[name] = N'DataCadastro');
    IF @var14 IS NOT NULL EXEC(N'ALTER TABLE [Status] DROP CONSTRAINT [' + @var14 + '];');
    ALTER TABLE [Status] ALTER COLUMN [DataCadastro] TEXT NOT NULL;
    ALTER TABLE [Status] ADD DEFAULT (GETDATE()) FOR [DataCadastro];
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var15 sysname;
    SELECT @var15 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Status]') AND [c].[name] = N'Ativo');
    IF @var15 IS NOT NULL EXEC(N'ALTER TABLE [Status] DROP CONSTRAINT [' + @var15 + '];');
    ALTER TABLE [Status] ALTER COLUMN [Ativo] INTEGER NOT NULL;
    ALTER TABLE [Status] ADD DEFAULT CAST(1 AS INTEGER) FOR [Ativo];
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var16 sysname;
    SELECT @var16 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Status]') AND [c].[name] = N'Id');
    IF @var16 IS NOT NULL EXEC(N'ALTER TABLE [Status] DROP CONSTRAINT [' + @var16 + '];');
    ALTER TABLE [Status] ALTER COLUMN [Id] INTEGER NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var17 sysname;
    SELECT @var17 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Prioridades]') AND [c].[name] = N'TempoRespostaHoras');
    IF @var17 IS NOT NULL EXEC(N'ALTER TABLE [Prioridades] DROP CONSTRAINT [' + @var17 + '];');
    ALTER TABLE [Prioridades] ALTER COLUMN [TempoRespostaHoras] INTEGER NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var18 sysname;
    SELECT @var18 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Prioridades]') AND [c].[name] = N'Nome');
    IF @var18 IS NOT NULL EXEC(N'ALTER TABLE [Prioridades] DROP CONSTRAINT [' + @var18 + '];');
    ALTER TABLE [Prioridades] ALTER COLUMN [Nome] TEXT NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var19 sysname;
    SELECT @var19 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Prioridades]') AND [c].[name] = N'Nivel');
    IF @var19 IS NOT NULL EXEC(N'ALTER TABLE [Prioridades] DROP CONSTRAINT [' + @var19 + '];');
    ALTER TABLE [Prioridades] ALTER COLUMN [Nivel] INTEGER NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var20 sysname;
    SELECT @var20 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Prioridades]') AND [c].[name] = N'Descricao');
    IF @var20 IS NOT NULL EXEC(N'ALTER TABLE [Prioridades] DROP CONSTRAINT [' + @var20 + '];');
    ALTER TABLE [Prioridades] ALTER COLUMN [Descricao] TEXT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var21 sysname;
    SELECT @var21 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Prioridades]') AND [c].[name] = N'DataCadastro');
    IF @var21 IS NOT NULL EXEC(N'ALTER TABLE [Prioridades] DROP CONSTRAINT [' + @var21 + '];');
    ALTER TABLE [Prioridades] ALTER COLUMN [DataCadastro] TEXT NOT NULL;
    ALTER TABLE [Prioridades] ADD DEFAULT (GETDATE()) FOR [DataCadastro];
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var22 sysname;
    SELECT @var22 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Prioridades]') AND [c].[name] = N'Ativo');
    IF @var22 IS NOT NULL EXEC(N'ALTER TABLE [Prioridades] DROP CONSTRAINT [' + @var22 + '];');
    ALTER TABLE [Prioridades] ALTER COLUMN [Ativo] INTEGER NOT NULL;
    ALTER TABLE [Prioridades] ADD DEFAULT CAST(1 AS INTEGER) FOR [Ativo];
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var23 sysname;
    SELECT @var23 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Prioridades]') AND [c].[name] = N'Id');
    IF @var23 IS NOT NULL EXEC(N'ALTER TABLE [Prioridades] DROP CONSTRAINT [' + @var23 + '];');
    ALTER TABLE [Prioridades] ALTER COLUMN [Id] INTEGER NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DROP INDEX [IX_Comentarios_UsuarioId] ON [Comentarios];
    DECLARE @var24 sysname;
    SELECT @var24 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Comentarios]') AND [c].[name] = N'UsuarioId');
    IF @var24 IS NOT NULL EXEC(N'ALTER TABLE [Comentarios] DROP CONSTRAINT [' + @var24 + '];');
    ALTER TABLE [Comentarios] ALTER COLUMN [UsuarioId] INTEGER NOT NULL;
    CREATE INDEX [IX_Comentarios_UsuarioId] ON [Comentarios] ([UsuarioId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var25 sysname;
    SELECT @var25 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Comentarios]') AND [c].[name] = N'Texto');
    IF @var25 IS NOT NULL EXEC(N'ALTER TABLE [Comentarios] DROP CONSTRAINT [' + @var25 + '];');
    ALTER TABLE [Comentarios] ALTER COLUMN [Texto] TEXT NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var26 sysname;
    SELECT @var26 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Comentarios]') AND [c].[name] = N'IsInterno');
    IF @var26 IS NOT NULL EXEC(N'ALTER TABLE [Comentarios] DROP CONSTRAINT [' + @var26 + '];');
    ALTER TABLE [Comentarios] ALTER COLUMN [IsInterno] INTEGER NOT NULL;
    ALTER TABLE [Comentarios] ADD DEFAULT CAST(0 AS INTEGER) FOR [IsInterno];
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var27 sysname;
    SELECT @var27 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Comentarios]') AND [c].[name] = N'DataCriacao');
    IF @var27 IS NOT NULL EXEC(N'ALTER TABLE [Comentarios] DROP CONSTRAINT [' + @var27 + '];');
    ALTER TABLE [Comentarios] ALTER COLUMN [DataCriacao] TEXT NOT NULL;
    ALTER TABLE [Comentarios] ADD DEFAULT (GETDATE()) FOR [DataCriacao];
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DROP INDEX [IX_Comentarios_ChamadoId] ON [Comentarios];
    DECLARE @var28 sysname;
    SELECT @var28 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Comentarios]') AND [c].[name] = N'ChamadoId');
    IF @var28 IS NOT NULL EXEC(N'ALTER TABLE [Comentarios] DROP CONSTRAINT [' + @var28 + '];');
    ALTER TABLE [Comentarios] ALTER COLUMN [ChamadoId] INTEGER NOT NULL;
    CREATE INDEX [IX_Comentarios_ChamadoId] ON [Comentarios] ([ChamadoId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var29 sysname;
    SELECT @var29 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Comentarios]') AND [c].[name] = N'Id');
    IF @var29 IS NOT NULL EXEC(N'ALTER TABLE [Comentarios] DROP CONSTRAINT [' + @var29 + '];');
    ALTER TABLE [Comentarios] ALTER COLUMN [Id] INTEGER NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var30 sysname;
    SELECT @var30 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Chamados]') AND [c].[name] = N'Titulo');
    IF @var30 IS NOT NULL EXEC(N'ALTER TABLE [Chamados] DROP CONSTRAINT [' + @var30 + '];');
    ALTER TABLE [Chamados] ALTER COLUMN [Titulo] TEXT NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DROP INDEX [IX_Chamados_TecnicoId] ON [Chamados];
    DECLARE @var31 sysname;
    SELECT @var31 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Chamados]') AND [c].[name] = N'TecnicoId');
    IF @var31 IS NOT NULL EXEC(N'ALTER TABLE [Chamados] DROP CONSTRAINT [' + @var31 + '];');
    ALTER TABLE [Chamados] ALTER COLUMN [TecnicoId] INTEGER NULL;
    CREATE INDEX [IX_Chamados_TecnicoId] ON [Chamados] ([TecnicoId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DROP INDEX [IX_Chamados_StatusId] ON [Chamados];
    DECLARE @var32 sysname;
    SELECT @var32 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Chamados]') AND [c].[name] = N'StatusId');
    IF @var32 IS NOT NULL EXEC(N'ALTER TABLE [Chamados] DROP CONSTRAINT [' + @var32 + '];');
    ALTER TABLE [Chamados] ALTER COLUMN [StatusId] INTEGER NOT NULL;
    CREATE INDEX [IX_Chamados_StatusId] ON [Chamados] ([StatusId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DROP INDEX [IX_Chamados_SolicitanteId] ON [Chamados];
    DECLARE @var33 sysname;
    SELECT @var33 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Chamados]') AND [c].[name] = N'SolicitanteId');
    IF @var33 IS NOT NULL EXEC(N'ALTER TABLE [Chamados] DROP CONSTRAINT [' + @var33 + '];');
    ALTER TABLE [Chamados] ALTER COLUMN [SolicitanteId] INTEGER NOT NULL;
    CREATE INDEX [IX_Chamados_SolicitanteId] ON [Chamados] ([SolicitanteId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var34 sysname;
    SELECT @var34 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Chamados]') AND [c].[name] = N'SlaDataExpiracao');
    IF @var34 IS NOT NULL EXEC(N'ALTER TABLE [Chamados] DROP CONSTRAINT [' + @var34 + '];');
    ALTER TABLE [Chamados] ALTER COLUMN [SlaDataExpiracao] TEXT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DROP INDEX [IX_Chamados_PrioridadeId] ON [Chamados];
    DECLARE @var35 sysname;
    SELECT @var35 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Chamados]') AND [c].[name] = N'PrioridadeId');
    IF @var35 IS NOT NULL EXEC(N'ALTER TABLE [Chamados] DROP CONSTRAINT [' + @var35 + '];');
    ALTER TABLE [Chamados] ALTER COLUMN [PrioridadeId] INTEGER NOT NULL;
    CREATE INDEX [IX_Chamados_PrioridadeId] ON [Chamados] ([PrioridadeId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var36 sysname;
    SELECT @var36 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Chamados]') AND [c].[name] = N'Descricao');
    IF @var36 IS NOT NULL EXEC(N'ALTER TABLE [Chamados] DROP CONSTRAINT [' + @var36 + '];');
    ALTER TABLE [Chamados] ALTER COLUMN [Descricao] TEXT NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var37 sysname;
    SELECT @var37 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Chamados]') AND [c].[name] = N'DataUltimaAtualizacao');
    IF @var37 IS NOT NULL EXEC(N'ALTER TABLE [Chamados] DROP CONSTRAINT [' + @var37 + '];');
    ALTER TABLE [Chamados] ALTER COLUMN [DataUltimaAtualizacao] TEXT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var38 sysname;
    SELECT @var38 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Chamados]') AND [c].[name] = N'DataFechamento');
    IF @var38 IS NOT NULL EXEC(N'ALTER TABLE [Chamados] DROP CONSTRAINT [' + @var38 + '];');
    ALTER TABLE [Chamados] ALTER COLUMN [DataFechamento] TEXT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var39 sysname;
    SELECT @var39 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Chamados]') AND [c].[name] = N'DataAbertura');
    IF @var39 IS NOT NULL EXEC(N'ALTER TABLE [Chamados] DROP CONSTRAINT [' + @var39 + '];');
    ALTER TABLE [Chamados] ALTER COLUMN [DataAbertura] TEXT NOT NULL;
    ALTER TABLE [Chamados] ADD DEFAULT (GETDATE()) FOR [DataAbertura];
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DROP INDEX [IX_Chamados_CategoriaId] ON [Chamados];
    DECLARE @var40 sysname;
    SELECT @var40 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Chamados]') AND [c].[name] = N'CategoriaId');
    IF @var40 IS NOT NULL EXEC(N'ALTER TABLE [Chamados] DROP CONSTRAINT [' + @var40 + '];');
    ALTER TABLE [Chamados] ALTER COLUMN [CategoriaId] INTEGER NOT NULL;
    CREATE INDEX [IX_Chamados_CategoriaId] ON [Chamados] ([CategoriaId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var41 sysname;
    SELECT @var41 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Chamados]') AND [c].[name] = N'Id');
    IF @var41 IS NOT NULL EXEC(N'ALTER TABLE [Chamados] DROP CONSTRAINT [' + @var41 + '];');
    ALTER TABLE [Chamados] ALTER COLUMN [Id] INTEGER NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    ALTER TABLE [Chamados] ADD [FechadoPorId] INTEGER NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var42 sysname;
    SELECT @var42 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Categorias]') AND [c].[name] = N'Nome');
    IF @var42 IS NOT NULL EXEC(N'ALTER TABLE [Categorias] DROP CONSTRAINT [' + @var42 + '];');
    ALTER TABLE [Categorias] ALTER COLUMN [Nome] TEXT NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var43 sysname;
    SELECT @var43 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Categorias]') AND [c].[name] = N'Descricao');
    IF @var43 IS NOT NULL EXEC(N'ALTER TABLE [Categorias] DROP CONSTRAINT [' + @var43 + '];');
    ALTER TABLE [Categorias] ALTER COLUMN [Descricao] TEXT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var44 sysname;
    SELECT @var44 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Categorias]') AND [c].[name] = N'DataCadastro');
    IF @var44 IS NOT NULL EXEC(N'ALTER TABLE [Categorias] DROP CONSTRAINT [' + @var44 + '];');
    ALTER TABLE [Categorias] ALTER COLUMN [DataCadastro] TEXT NOT NULL;
    ALTER TABLE [Categorias] ADD DEFAULT (GETDATE()) FOR [DataCadastro];
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var45 sysname;
    SELECT @var45 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Categorias]') AND [c].[name] = N'Ativo');
    IF @var45 IS NOT NULL EXEC(N'ALTER TABLE [Categorias] DROP CONSTRAINT [' + @var45 + '];');
    ALTER TABLE [Categorias] ALTER COLUMN [Ativo] INTEGER NOT NULL;
    ALTER TABLE [Categorias] ADD DEFAULT CAST(1 AS INTEGER) FOR [Ativo];
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var46 sysname;
    SELECT @var46 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Categorias]') AND [c].[name] = N'Id');
    IF @var46 IS NOT NULL EXEC(N'ALTER TABLE [Categorias] DROP CONSTRAINT [' + @var46 + '];');
    ALTER TABLE [Categorias] ALTER COLUMN [Id] INTEGER NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DROP INDEX [IX_Anexos_UsuarioId] ON [Anexos];
    DECLARE @var47 sysname;
    SELECT @var47 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Anexos]') AND [c].[name] = N'UsuarioId');
    IF @var47 IS NOT NULL EXEC(N'ALTER TABLE [Anexos] DROP CONSTRAINT [' + @var47 + '];');
    ALTER TABLE [Anexos] ALTER COLUMN [UsuarioId] INTEGER NOT NULL;
    CREATE INDEX [IX_Anexos_UsuarioId] ON [Anexos] ([UsuarioId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var48 sysname;
    SELECT @var48 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Anexos]') AND [c].[name] = N'TipoMime');
    IF @var48 IS NOT NULL EXEC(N'ALTER TABLE [Anexos] DROP CONSTRAINT [' + @var48 + '];');
    ALTER TABLE [Anexos] ALTER COLUMN [TipoMime] TEXT NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var49 sysname;
    SELECT @var49 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Anexos]') AND [c].[name] = N'TamanhoBytes');
    IF @var49 IS NOT NULL EXEC(N'ALTER TABLE [Anexos] DROP CONSTRAINT [' + @var49 + '];');
    ALTER TABLE [Anexos] ALTER COLUMN [TamanhoBytes] INTEGER NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var50 sysname;
    SELECT @var50 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Anexos]') AND [c].[name] = N'NomeArquivo');
    IF @var50 IS NOT NULL EXEC(N'ALTER TABLE [Anexos] DROP CONSTRAINT [' + @var50 + '];');
    ALTER TABLE [Anexos] ALTER COLUMN [NomeArquivo] TEXT NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var51 sysname;
    SELECT @var51 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Anexos]') AND [c].[name] = N'DataUpload');
    IF @var51 IS NOT NULL EXEC(N'ALTER TABLE [Anexos] DROP CONSTRAINT [' + @var51 + '];');
    ALTER TABLE [Anexos] ALTER COLUMN [DataUpload] TEXT NOT NULL;
    ALTER TABLE [Anexos] ADD DEFAULT (GETDATE()) FOR [DataUpload];
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DROP INDEX [IX_Anexos_ChamadoId] ON [Anexos];
    DECLARE @var52 sysname;
    SELECT @var52 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Anexos]') AND [c].[name] = N'ChamadoId');
    IF @var52 IS NOT NULL EXEC(N'ALTER TABLE [Anexos] DROP CONSTRAINT [' + @var52 + '];');
    ALTER TABLE [Anexos] ALTER COLUMN [ChamadoId] INTEGER NOT NULL;
    CREATE INDEX [IX_Anexos_ChamadoId] ON [Anexos] ([ChamadoId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var53 sysname;
    SELECT @var53 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Anexos]') AND [c].[name] = N'CaminhoArquivo');
    IF @var53 IS NOT NULL EXEC(N'ALTER TABLE [Anexos] DROP CONSTRAINT [' + @var53 + '];');
    ALTER TABLE [Anexos] ALTER COLUMN [CaminhoArquivo] TEXT NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    DECLARE @var54 sysname;
    SELECT @var54 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Anexos]') AND [c].[name] = N'Id');
    IF @var54 IS NOT NULL EXEC(N'ALTER TABLE [Anexos] DROP CONSTRAINT [' + @var54 + '];');
    ALTER TABLE [Anexos] ALTER COLUMN [Id] INTEGER NOT NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    CREATE INDEX [IX_Chamados_FechadoPorId] ON [Chamados] ([FechadoPorId]);
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    ALTER TABLE [Chamados] ADD CONSTRAINT [FK_Chamados_Usuarios_FechadoPorId] FOREIGN KEY ([FechadoPorId]) REFERENCES [Usuarios] ([Id]) ON DELETE SET NULL;
END;
GO

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251111113722_AlignDbSchemaForChamado'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20251111113722_AlignDbSchemaForChamado', N'8.0.0');
END;
GO

COMMIT;
GO

