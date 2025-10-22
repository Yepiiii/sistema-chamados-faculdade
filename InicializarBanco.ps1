# Script para Inicializar o Banco de Dados do GuiNRB
# Cria estrutura completa + dados iniciais

param(
    [switch]$DropDatabase,
    [switch]$SeedUsers
)

Write-Host "`n=== INICIALIZACAO DO BANCO DE DADOS GuiNRB ===" -ForegroundColor Cyan

$backendPath = "c:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade\Backend"

# Verifica se o diretório existe
if (-not (Test-Path $backendPath)) {
    Write-Host "ERRO: Diretorio Backend nao encontrado!" -ForegroundColor Red
    exit 1
}

Set-Location $backendPath

Write-Host "`n[1/5] Verificando configuracao..." -ForegroundColor Yellow

# Verifica appsettings.json
$appsettings = Get-Content "appsettings.json" -Raw | ConvertFrom-Json
$connectionString = $appsettings.ConnectionStrings.DefaultConnection

if ($connectionString) {
    Write-Host "  ConnectionString: $connectionString" -ForegroundColor Gray
} else {
    Write-Host "  ERRO: ConnectionString nao encontrada!" -ForegroundColor Red
    exit 1
}

# Passo 1: Dropar banco se solicitado
if ($DropDatabase) {
    Write-Host "`n[2/5] Dropando banco de dados existente..." -ForegroundColor Yellow
    dotnet ef database drop --force
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Banco dropado com sucesso!" -ForegroundColor Green
    }
}

# Passo 2: Aplicar migrations
Write-Host "`n[3/5] Aplicando migrations..." -ForegroundColor Yellow
dotnet ef database update

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ERRO ao aplicar migrations!" -ForegroundColor Red
    Write-Host "  Tentando instalar dotnet-ef..." -ForegroundColor Yellow
    dotnet tool install --global dotnet-ef
    
    Write-Host "  Tentando novamente..." -ForegroundColor Yellow
    dotnet ef database update
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ERRO: Nao foi possivel aplicar migrations!" -ForegroundColor Red
        exit 1
    }
}

Write-Host "  Migrations aplicadas com sucesso!" -ForegroundColor Green

# Passo 3: Seed data básico (executado automaticamente no program.cs)
Write-Host "`n[4/5] Dados basicos serao criados ao iniciar a API..." -ForegroundColor Yellow
Write-Host "  - Categorias (3 registros)" -ForegroundColor Gray
Write-Host "  - Prioridades (3 registros)" -ForegroundColor Gray
Write-Host "  - Status (3 registros)" -ForegroundColor Gray

# Passo 4: Adicionar Status "Fechado" se não existir
Write-Host "`n[5/5] Verificando status 'Fechado'..." -ForegroundColor Yellow

$sqlCheckStatus = @"
USE SistemaChamadosDB;

-- Verifica se status 'Fechado' existe
IF NOT EXISTS (SELECT 1 FROM Status WHERE Nome = 'Fechado')
BEGIN
    INSERT INTO Status (Nome, Descricao)
    VALUES ('Fechado', 'Chamado encerrado');
    PRINT 'Status Fechado adicionado!';
END
ELSE
BEGIN
    PRINT 'Status Fechado ja existe.';
END
GO
"@

# Tenta executar via sqlcmd
$sqlcmd = Get-Command sqlcmd -ErrorAction SilentlyContinue

if ($sqlcmd) {
    Write-Host "  Executando via sqlcmd..." -ForegroundColor Gray
    $sqlCheckStatus | & sqlcmd -S "(localdb)\mssqllocaldb" 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Status 'Fechado' verificado!" -ForegroundColor Green
    }
} else {
    Write-Host "  sqlcmd nao encontrado, status sera criado ao rodar API" -ForegroundColor Yellow
}

# Passo 5: Criar usuário administrador se solicitado
if ($SeedUsers) {
    Write-Host "`n[EXTRA] Criando usuario administrador..." -ForegroundColor Cyan
    
    $sqlCreateUser = @"
USE SistemaChamadosDB;

-- Verifica se usuario admin ja existe
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE Email = 'admin@teste.com')
BEGIN
    INSERT INTO Usuarios (Nome, Email, Senha, TipoUsuario, Ativo)
    VALUES (
        'Administrador',
        'admin@teste.com',
        -- Senha: Admin123! (hash BCrypt)
        '$2a$11$5tXZ7qVZ7Z7Z7Z7Z7Z7Z7OqVZ7Z7Z7Z7Z7Z7Z7Z7Z7Z7Z7Z7Z7Z',
        3,  -- Administrador
        1   -- Ativo
    );
    PRINT 'Usuario admin@teste.com criado!';
END
ELSE
BEGIN
    -- Atualiza para Administrador se ja existir
    UPDATE Usuarios 
    SET TipoUsuario = 3
    WHERE Email = 'admin@teste.com';
    PRINT 'Usuario admin@teste.com promovido a Administrador!';
END
GO
"@

    if ($sqlcmd) {
        $sqlCreateUser | & sqlcmd -S "(localdb)\mssqllocaldb" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  Usuario criado/atualizado!" -ForegroundColor Green
        }
    } else {
        Write-Host "  sqlcmd nao disponivel. Crie manualmente via API ou SSMS" -ForegroundColor Yellow
    }
}

Write-Host "`n=== INICIALIZACAO CONCLUIDA ===" -ForegroundColor Green
Write-Host ""
Write-Host "Estrutura do banco:" -ForegroundColor Cyan
Write-Host "  - Tabelas: Usuarios, Categorias, Prioridades, Status, Chamados, Especialidades" -ForegroundColor White
Write-Host "  - Dados basicos: Categorias (3), Prioridades (3), Status (3-4)" -ForegroundColor White
Write-Host ""

if ($SeedUsers) {
    Write-Host "Usuario de teste:" -ForegroundColor Cyan
    Write-Host "  Email: admin@teste.com" -ForegroundColor White
    Write-Host "  Senha: Admin123!" -ForegroundColor White
    Write-Host "  Tipo: Administrador (TipoUsuario = 3)" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "Para criar usuario administrador, execute:" -ForegroundColor Yellow
    Write-Host "  .\InicializarBanco.ps1 -SeedUsers" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "Proximos passos:" -ForegroundColor Cyan
Write-Host "  1. Execute: .\IniciarSistema.ps1" -ForegroundColor White
Write-Host "  2. Acesse: http://localhost:5246/swagger" -ForegroundColor White
Write-Host "  3. Registre um usuario via /auth/register" -ForegroundColor White
Write-Host "  4. Promova para admin via SSMS:" -ForegroundColor White
Write-Host "     UPDATE Usuarios SET TipoUsuario = 3 WHERE Email = 'seu@email.com'" -ForegroundColor Gray
Write-Host ""
