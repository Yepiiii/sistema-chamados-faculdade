-- Script rápido para adicionar coluna FechadoPorId
USE SistemaChamadosDb;
GO

-- Verificar se a coluna já existe
IF COL_LENGTH('Chamados', 'FechadoPorId') IS NULL
BEGIN
    PRINT 'Adicionando coluna FechadoPorId...';
    ALTER TABLE Chamados ADD FechadoPorId INT NULL;
    PRINT 'Coluna FechadoPorId adicionada com sucesso!';
END
ELSE
BEGIN
    PRINT 'Coluna FechadoPorId já existe.';
END
GO

-- Criar FK se não existir
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys 
    WHERE name = 'FK_Chamados_Usuarios_FechadoPorId'
)
BEGIN
    PRINT 'Criando FK FechadoPorId...';
    ALTER TABLE Chamados
    ADD CONSTRAINT FK_Chamados_Usuarios_FechadoPorId
    FOREIGN KEY (FechadoPorId) REFERENCES Usuarios(Id) ON DELETE SET NULL;
    PRINT 'FK criada com sucesso!';
END
ELSE
BEGIN
    PRINT 'FK já existe.';
END
GO

PRINT 'Script concluído!';
GO
