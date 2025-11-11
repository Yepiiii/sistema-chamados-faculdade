CREATE TABLE IF NOT EXISTS "__EFMigrationsHistory" (
    "MigrationId" TEXT NOT NULL CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY,
    "ProductVersion" TEXT NOT NULL
);

BEGIN TRANSACTION;

CREATE TABLE "Categorias" (
    "Id" int NOT NULL CONSTRAINT "PK_Categorias" PRIMARY KEY,
    "Nome" nvarchar(100) NOT NULL,
    "Descricao" nvarchar(500) NULL,
    "Ativo" bit NOT NULL DEFAULT 1,
    "DataCadastro" datetime2 NOT NULL DEFAULT (GETDATE())
);

CREATE TABLE "Prioridades" (
    "Id" int NOT NULL CONSTRAINT "PK_Prioridades" PRIMARY KEY,
    "Nome" nvarchar(50) NOT NULL,
    "Nivel" int NOT NULL,
    "Descricao" nvarchar(500) NULL,
    "TempoRespostaHoras" int NOT NULL,
    "Ativo" bit NOT NULL DEFAULT 1,
    "DataCadastro" datetime2 NOT NULL DEFAULT (GETDATE())
);

CREATE TABLE "Status" (
    "Id" int NOT NULL CONSTRAINT "PK_Status" PRIMARY KEY,
    "Nome" nvarchar(50) NOT NULL,
    "Descricao" nvarchar(500) NULL,
    "Ativo" bit NOT NULL DEFAULT 1,
    "DataCadastro" datetime2 NOT NULL DEFAULT (GETDATE())
);

CREATE TABLE "Usuarios" (
    "Id" int NOT NULL CONSTRAINT "PK_Usuarios" PRIMARY KEY,
    "NomeCompleto" nvarchar(150) NOT NULL,
    "Email" nvarchar(150) NOT NULL,
    "SenhaHash" nvarchar(255) NOT NULL,
    "TipoUsuario" int NOT NULL,
    "IsInterno" bit NOT NULL DEFAULT 1,
    "Especialidade" nvarchar(100) NULL,
    "EspecialidadeCategoriaId" int NULL,
    "Ativo" bit NOT NULL DEFAULT 1,
    "PasswordResetToken" nvarchar(255) NULL,
    "ResetTokenExpires" datetime2 NULL,
    "DataCadastro" datetime2 NOT NULL DEFAULT (GETDATE()),
    CONSTRAINT "FK_Usuarios_Categorias_EspecialidadeCategoriaId" FOREIGN KEY ("EspecialidadeCategoriaId") REFERENCES "Categorias" ("Id") ON DELETE SET NULL
);

CREATE TABLE "Chamados" (
    "Id" int NOT NULL CONSTRAINT "PK_Chamados" PRIMARY KEY,
    "Titulo" nvarchar(200) NOT NULL,
    "Descricao" nvarchar(max) NOT NULL,
    "DataAbertura" datetime2 NOT NULL DEFAULT (GETDATE()),
    "DataFechamento" datetime2 NULL,
    "DataUltimaAtualizacao" datetime2 NULL,
    "SlaDataExpiracao" datetime2 NULL,
    "SolicitanteId" int NOT NULL,
    "TecnicoId" int NULL,
    "CategoriaId" int NOT NULL,
    "PrioridadeId" int NOT NULL,
    "StatusId" int NOT NULL,
    CONSTRAINT "FK_Chamados_Categorias_CategoriaId" FOREIGN KEY ("CategoriaId") REFERENCES "Categorias" ("Id") ON DELETE RESTRICT,
    CONSTRAINT "FK_Chamados_Prioridades_PrioridadeId" FOREIGN KEY ("PrioridadeId") REFERENCES "Prioridades" ("Id") ON DELETE RESTRICT,
    CONSTRAINT "FK_Chamados_Status_StatusId" FOREIGN KEY ("StatusId") REFERENCES "Status" ("Id") ON DELETE RESTRICT,
    CONSTRAINT "FK_Chamados_Usuarios_SolicitanteId" FOREIGN KEY ("SolicitanteId") REFERENCES "Usuarios" ("Id") ON DELETE RESTRICT,
    CONSTRAINT "FK_Chamados_Usuarios_TecnicoId" FOREIGN KEY ("TecnicoId") REFERENCES "Usuarios" ("Id") ON DELETE RESTRICT
);

CREATE TABLE "Anexos" (
    "Id" int NOT NULL CONSTRAINT "PK_Anexos" PRIMARY KEY,
    "NomeArquivo" nvarchar(255) NOT NULL,
    "CaminhoArquivo" nvarchar(500) NOT NULL,
    "TamanhoBytes" bigint NOT NULL,
    "TipoMime" nvarchar(100) NOT NULL,
    "DataUpload" datetime2 NOT NULL DEFAULT (GETDATE()),
    "ChamadoId" int NOT NULL,
    "UsuarioId" int NOT NULL,
    CONSTRAINT "FK_Anexos_Chamados_ChamadoId" FOREIGN KEY ("ChamadoId") REFERENCES "Chamados" ("Id") ON DELETE CASCADE,
    CONSTRAINT "FK_Anexos_Usuarios_UsuarioId" FOREIGN KEY ("UsuarioId") REFERENCES "Usuarios" ("Id") ON DELETE RESTRICT
);

CREATE TABLE "Comentarios" (
    "Id" int NOT NULL CONSTRAINT "PK_Comentarios" PRIMARY KEY,
    "Texto" nvarchar(max) NOT NULL,
    "DataCriacao" datetime2 NOT NULL DEFAULT (GETDATE()),
    "IsInterno" bit NOT NULL DEFAULT 0,
    "ChamadoId" int NOT NULL,
    "UsuarioId" int NOT NULL,
    CONSTRAINT "FK_Comentarios_Chamados_ChamadoId" FOREIGN KEY ("ChamadoId") REFERENCES "Chamados" ("Id") ON DELETE CASCADE,
    CONSTRAINT "FK_Comentarios_Usuarios_UsuarioId" FOREIGN KEY ("UsuarioId") REFERENCES "Usuarios" ("Id") ON DELETE RESTRICT
);

CREATE INDEX "IX_Anexos_ChamadoId" ON "Anexos" ("ChamadoId");

CREATE INDEX "IX_Anexos_UsuarioId" ON "Anexos" ("UsuarioId");

CREATE INDEX "IX_Chamados_CategoriaId" ON "Chamados" ("CategoriaId");

CREATE INDEX "IX_Chamados_PrioridadeId" ON "Chamados" ("PrioridadeId");

CREATE INDEX "IX_Chamados_SolicitanteId" ON "Chamados" ("SolicitanteId");

CREATE INDEX "IX_Chamados_StatusId" ON "Chamados" ("StatusId");

CREATE INDEX "IX_Chamados_TecnicoId" ON "Chamados" ("TecnicoId");

CREATE INDEX "IX_Comentarios_ChamadoId" ON "Comentarios" ("ChamadoId");

CREATE INDEX "IX_Comentarios_UsuarioId" ON "Comentarios" ("UsuarioId");

CREATE UNIQUE INDEX "IX_Usuarios_Email" ON "Usuarios" ("Email");

CREATE INDEX "IX_Usuarios_EspecialidadeCategoriaId" ON "Usuarios" ("EspecialidadeCategoriaId");

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20251111025617_InitialCreateSqlServer', '8.0.0');

COMMIT;

BEGIN TRANSACTION;

ALTER TABLE "Chamados" ADD "FechadoPorId" INTEGER NULL;

CREATE INDEX "IX_Chamados_FechadoPorId" ON "Chamados" ("FechadoPorId");

CREATE TABLE "ef_temp_Usuarios" (
    "Id" INTEGER NOT NULL CONSTRAINT "PK_Usuarios" PRIMARY KEY AUTOINCREMENT,
    "Ativo" INTEGER NOT NULL DEFAULT 1,
    "DataCadastro" TEXT NOT NULL DEFAULT (GETDATE()),
    "Email" TEXT NOT NULL,
    "Especialidade" TEXT NULL,
    "EspecialidadeCategoriaId" INTEGER NULL,
    "IsInterno" INTEGER NOT NULL DEFAULT 1,
    "NomeCompleto" TEXT NOT NULL,
    "PasswordResetToken" TEXT NULL,
    "ResetTokenExpires" TEXT NULL,
    "SenhaHash" TEXT NOT NULL,
    "TipoUsuario" INTEGER NOT NULL,
    CONSTRAINT "FK_Usuarios_Categorias_EspecialidadeCategoriaId" FOREIGN KEY ("EspecialidadeCategoriaId") REFERENCES "Categorias" ("Id") ON DELETE SET NULL
);

INSERT INTO "ef_temp_Usuarios" ("Id", "Ativo", "DataCadastro", "Email", "Especialidade", "EspecialidadeCategoriaId", "IsInterno", "NomeCompleto", "PasswordResetToken", "ResetTokenExpires", "SenhaHash", "TipoUsuario")
SELECT "Id", "Ativo", "DataCadastro", "Email", "Especialidade", "EspecialidadeCategoriaId", "IsInterno", "NomeCompleto", "PasswordResetToken", "ResetTokenExpires", "SenhaHash", "TipoUsuario"
FROM "Usuarios";

CREATE TABLE "ef_temp_Status" (
    "Id" INTEGER NOT NULL CONSTRAINT "PK_Status" PRIMARY KEY AUTOINCREMENT,
    "Ativo" INTEGER NOT NULL DEFAULT 1,
    "DataCadastro" TEXT NOT NULL DEFAULT (GETDATE()),
    "Descricao" TEXT NULL,
    "Nome" TEXT NOT NULL
);

INSERT INTO "ef_temp_Status" ("Id", "Ativo", "DataCadastro", "Descricao", "Nome")
SELECT "Id", "Ativo", "DataCadastro", "Descricao", "Nome"
FROM "Status";

CREATE TABLE "ef_temp_Prioridades" (
    "Id" INTEGER NOT NULL CONSTRAINT "PK_Prioridades" PRIMARY KEY AUTOINCREMENT,
    "Ativo" INTEGER NOT NULL DEFAULT 1,
    "DataCadastro" TEXT NOT NULL DEFAULT (GETDATE()),
    "Descricao" TEXT NULL,
    "Nivel" INTEGER NOT NULL,
    "Nome" TEXT NOT NULL,
    "TempoRespostaHoras" INTEGER NOT NULL
);

INSERT INTO "ef_temp_Prioridades" ("Id", "Ativo", "DataCadastro", "Descricao", "Nivel", "Nome", "TempoRespostaHoras")
SELECT "Id", "Ativo", "DataCadastro", "Descricao", "Nivel", "Nome", "TempoRespostaHoras"
FROM "Prioridades";

CREATE TABLE "ef_temp_Comentarios" (
    "Id" INTEGER NOT NULL CONSTRAINT "PK_Comentarios" PRIMARY KEY AUTOINCREMENT,
    "ChamadoId" INTEGER NOT NULL,
    "DataCriacao" TEXT NOT NULL DEFAULT (GETDATE()),
    "IsInterno" INTEGER NOT NULL DEFAULT 0,
    "Texto" TEXT NOT NULL,
    "UsuarioId" INTEGER NOT NULL,
    CONSTRAINT "FK_Comentarios_Chamados_ChamadoId" FOREIGN KEY ("ChamadoId") REFERENCES "Chamados" ("Id") ON DELETE CASCADE,
    CONSTRAINT "FK_Comentarios_Usuarios_UsuarioId" FOREIGN KEY ("UsuarioId") REFERENCES "Usuarios" ("Id") ON DELETE RESTRICT
);

INSERT INTO "ef_temp_Comentarios" ("Id", "ChamadoId", "DataCriacao", "IsInterno", "Texto", "UsuarioId")
SELECT "Id", "ChamadoId", "DataCriacao", "IsInterno", "Texto", "UsuarioId"
FROM "Comentarios";

CREATE TABLE "ef_temp_Chamados" (
    "Id" INTEGER NOT NULL CONSTRAINT "PK_Chamados" PRIMARY KEY AUTOINCREMENT,
    "CategoriaId" INTEGER NOT NULL,
    "DataAbertura" TEXT NOT NULL DEFAULT (GETDATE()),
    "DataFechamento" TEXT NULL,
    "DataUltimaAtualizacao" TEXT NULL,
    "Descricao" TEXT NOT NULL,
    "FechadoPorId" INTEGER NULL,
    "PrioridadeId" INTEGER NOT NULL,
    "SlaDataExpiracao" TEXT NULL,
    "SolicitanteId" INTEGER NOT NULL,
    "StatusId" INTEGER NOT NULL,
    "TecnicoId" INTEGER NULL,
    "Titulo" TEXT NOT NULL,
    CONSTRAINT "FK_Chamados_Categorias_CategoriaId" FOREIGN KEY ("CategoriaId") REFERENCES "Categorias" ("Id") ON DELETE RESTRICT,
    CONSTRAINT "FK_Chamados_Prioridades_PrioridadeId" FOREIGN KEY ("PrioridadeId") REFERENCES "Prioridades" ("Id") ON DELETE RESTRICT,
    CONSTRAINT "FK_Chamados_Status_StatusId" FOREIGN KEY ("StatusId") REFERENCES "Status" ("Id") ON DELETE RESTRICT,
    CONSTRAINT "FK_Chamados_Usuarios_FechadoPorId" FOREIGN KEY ("FechadoPorId") REFERENCES "Usuarios" ("Id") ON DELETE SET NULL,
    CONSTRAINT "FK_Chamados_Usuarios_SolicitanteId" FOREIGN KEY ("SolicitanteId") REFERENCES "Usuarios" ("Id") ON DELETE RESTRICT,
    CONSTRAINT "FK_Chamados_Usuarios_TecnicoId" FOREIGN KEY ("TecnicoId") REFERENCES "Usuarios" ("Id") ON DELETE RESTRICT
);

INSERT INTO "ef_temp_Chamados" ("Id", "CategoriaId", "DataAbertura", "DataFechamento", "DataUltimaAtualizacao", "Descricao", "FechadoPorId", "PrioridadeId", "SlaDataExpiracao", "SolicitanteId", "StatusId", "TecnicoId", "Titulo")
SELECT "Id", "CategoriaId", "DataAbertura", "DataFechamento", "DataUltimaAtualizacao", "Descricao", "FechadoPorId", "PrioridadeId", "SlaDataExpiracao", "SolicitanteId", "StatusId", "TecnicoId", "Titulo"
FROM "Chamados";

CREATE TABLE "ef_temp_Categorias" (
    "Id" INTEGER NOT NULL CONSTRAINT "PK_Categorias" PRIMARY KEY AUTOINCREMENT,
    "Ativo" INTEGER NOT NULL DEFAULT 1,
    "DataCadastro" TEXT NOT NULL DEFAULT (GETDATE()),
    "Descricao" TEXT NULL,
    "Nome" TEXT NOT NULL
);

INSERT INTO "ef_temp_Categorias" ("Id", "Ativo", "DataCadastro", "Descricao", "Nome")
SELECT "Id", "Ativo", "DataCadastro", "Descricao", "Nome"
FROM "Categorias";

CREATE TABLE "ef_temp_Anexos" (
    "Id" INTEGER NOT NULL CONSTRAINT "PK_Anexos" PRIMARY KEY AUTOINCREMENT,
    "CaminhoArquivo" TEXT NOT NULL,
    "ChamadoId" INTEGER NOT NULL,
    "DataUpload" TEXT NOT NULL DEFAULT (GETDATE()),
    "NomeArquivo" TEXT NOT NULL,
    "TamanhoBytes" INTEGER NOT NULL,
    "TipoMime" TEXT NOT NULL,
    "UsuarioId" INTEGER NOT NULL,
    CONSTRAINT "FK_Anexos_Chamados_ChamadoId" FOREIGN KEY ("ChamadoId") REFERENCES "Chamados" ("Id") ON DELETE CASCADE,
    CONSTRAINT "FK_Anexos_Usuarios_UsuarioId" FOREIGN KEY ("UsuarioId") REFERENCES "Usuarios" ("Id") ON DELETE RESTRICT
);

INSERT INTO "ef_temp_Anexos" ("Id", "CaminhoArquivo", "ChamadoId", "DataUpload", "NomeArquivo", "TamanhoBytes", "TipoMime", "UsuarioId")
SELECT "Id", "CaminhoArquivo", "ChamadoId", "DataUpload", "NomeArquivo", "TamanhoBytes", "TipoMime", "UsuarioId"
FROM "Anexos";

COMMIT;

PRAGMA foreign_keys = 0;

BEGIN TRANSACTION;

DROP TABLE "Usuarios";

ALTER TABLE "ef_temp_Usuarios" RENAME TO "Usuarios";

DROP TABLE "Status";

ALTER TABLE "ef_temp_Status" RENAME TO "Status";

DROP TABLE "Prioridades";

ALTER TABLE "ef_temp_Prioridades" RENAME TO "Prioridades";

DROP TABLE "Comentarios";

ALTER TABLE "ef_temp_Comentarios" RENAME TO "Comentarios";

DROP TABLE "Chamados";

ALTER TABLE "ef_temp_Chamados" RENAME TO "Chamados";

DROP TABLE "Categorias";

ALTER TABLE "ef_temp_Categorias" RENAME TO "Categorias";

DROP TABLE "Anexos";

ALTER TABLE "ef_temp_Anexos" RENAME TO "Anexos";

COMMIT;

PRAGMA foreign_keys = 1;

BEGIN TRANSACTION;

CREATE UNIQUE INDEX "IX_Usuarios_Email" ON "Usuarios" ("Email");

CREATE INDEX "IX_Usuarios_EspecialidadeCategoriaId" ON "Usuarios" ("EspecialidadeCategoriaId");

CREATE INDEX "IX_Comentarios_ChamadoId" ON "Comentarios" ("ChamadoId");

CREATE INDEX "IX_Comentarios_UsuarioId" ON "Comentarios" ("UsuarioId");

CREATE INDEX "IX_Chamados_CategoriaId" ON "Chamados" ("CategoriaId");

CREATE INDEX "IX_Chamados_FechadoPorId" ON "Chamados" ("FechadoPorId");

CREATE INDEX "IX_Chamados_PrioridadeId" ON "Chamados" ("PrioridadeId");

CREATE INDEX "IX_Chamados_SolicitanteId" ON "Chamados" ("SolicitanteId");

CREATE INDEX "IX_Chamados_StatusId" ON "Chamados" ("StatusId");

CREATE INDEX "IX_Chamados_TecnicoId" ON "Chamados" ("TecnicoId");

CREATE INDEX "IX_Anexos_ChamadoId" ON "Anexos" ("ChamadoId");

CREATE INDEX "IX_Anexos_UsuarioId" ON "Anexos" ("UsuarioId");

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20251111113722_AlignDbSchemaForChamado', '8.0.0');

COMMIT;

