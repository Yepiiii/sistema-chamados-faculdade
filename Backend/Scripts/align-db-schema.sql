-- Script de alinhamento do schema com o modelo C#
-- Execute em um ambiente de teste antes de aplicar em produção.
BEGIN TRANSACTION;

-- 1) Adicionar coluna FechadoPorId em Chamados (se não existir) e FK
IF COL_LENGTH('Chamados','FechadoPorId') IS NULL
BEGIN
    ALTER TABLE Chamados
    ADD FechadoPorId INT NULL;
END

-- Criar constraint FK se ainda não existir
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys fk
    JOIN sys.tables t ON fk.parent_object_id = t.object_id
    WHERE t.name = 'Chamados' AND fk.name = 'FK_Chamados_Usuarios_FechadoPorId')
BEGIN
    ALTER TABLE Chamados
    ADD CONSTRAINT FK_Chamados_Usuarios_FechadoPorId
    FOREIGN KEY (FechadoPorId) REFERENCES Usuarios(Id) ON DELETE SET NULL;
END

-- 2) Aumentar Categorias.Descricao para 500 (opcional; alinhar com model)
-- Só altera se a coluna existir e tiver tamanho menor que 500
IF EXISTS(
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Categorias' AND COLUMN_NAME = 'Descricao' AND CHARACTER_MAXIMUM_LENGTH IS NOT NULL AND CHARACTER_MAXIMUM_LENGTH < 500
)
BEGIN
    ALTER TABLE Categorias
    ALTER COLUMN Descricao NVARCHAR(500) NULL;
END

-- 3) Adicionar TempoRespostaHoras em Prioridades (se não existir)
IF COL_LENGTH('Prioridades','TempoRespostaHoras') IS NULL
BEGIN
    ALTER TABLE Prioridades
    ADD TempoRespostaHoras INT NOT NULL DEFAULT 0;
END

-- 4) Adicionar IsInterno e Especialidade em Usuarios (se não existirem)
IF COL_LENGTH('Usuarios','IsInterno') IS NULL
BEGIN
    ALTER TABLE Usuarios
    ADD IsInterno BIT NOT NULL DEFAULT 1;
END

IF COL_LENGTH('Usuarios','Especialidade') IS NULL
BEGIN
    ALTER TABLE Usuarios
    ADD Especialidade NVARCHAR(100) NULL;
END

-- 5) Ajustar Comentarios.Texto para NVARCHAR(1000)
IF EXISTS(
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Comentarios' AND COLUMN_NAME = 'Texto' AND (CHARACTER_MAXIMUM_LENGTH IS NULL OR CHARACTER_MAXIMUM_LENGTH < 1000)
)
BEGIN
    ALTER TABLE Comentarios
    ALTER COLUMN Texto NVARCHAR(1000) NOT NULL;
END

COMMIT TRANSACTION;

-- FIM
-- Observação: revise constraints e índices adicionais (ex.: índice único em Usuarios.Email) caso queira recriá-los explicitamente.
