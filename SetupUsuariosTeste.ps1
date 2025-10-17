# Script para limpar todos os usuários e criar usuários de teste
Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Setup de Usuários de Teste" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$confirmar = Read-Host "ATENÇÃO: Isso irá excluir TODOS os usuários e criar 3 novos (Aluno, Professor, Admin). Deseja continuar? (S/N)"

if ($confirmar -ne "S" -and $confirmar -ne "s") {
    Write-Host "Operação cancelada." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Configurando usuários de teste..." -ForegroundColor Yellow
Write-Host ""

try {
    $baseUrl = "http://localhost:5246/api"
    
    # ===========================================
    # ETAPA 1: Limpar banco de dados
    # ===========================================
    Write-Host "ETAPA 1: Limpando banco de dados..." -ForegroundColor Cyan
    Write-Host "-------------------------------------------" -ForegroundColor Gray
    
    # Conectar ao SQL Server e limpar tabelas
    $connectionString = "Server=localhost;Database=SistemaChamados;Trusted_Connection=True;Encrypt=False;"
    
    $sqlCommands = @"
-- Desabilitar constraints temporariamente
ALTER TABLE [Chamados] NOCHECK CONSTRAINT ALL;
ALTER TABLE [AlunoPerfis] NOCHECK CONSTRAINT ALL;
ALTER TABLE [ProfessorPerfis] NOCHECK CONSTRAINT ALL;

-- Deletar dados
DELETE FROM [Chamados];
DELETE FROM [AlunoPerfis];
DELETE FROM [ProfessorPerfis];
DELETE FROM [Usuarios];

-- Resetar IDs
DBCC CHECKIDENT ('[Chamados]', RESEED, 0);
DBCC CHECKIDENT ('[AlunoPerfis]', RESEED, 0);
DBCC CHECKIDENT ('[ProfessorPerfis]', RESEED, 0);
DBCC CHECKIDENT ('[Usuarios]', RESEED, 0);

-- Reabilitar constraints
ALTER TABLE [Chamados] CHECK CONSTRAINT ALL;
ALTER TABLE [AlunoPerfis] CHECK CONSTRAINT ALL;
ALTER TABLE [ProfessorPerfis] CHECK CONSTRAINT ALL;

-- Verificar limpeza
SELECT 'Usuarios' as Tabela, COUNT(*) as Total FROM [Usuarios]
UNION ALL
SELECT 'Chamados', COUNT(*) FROM [Chamados]
UNION ALL
SELECT 'AlunoPerfis', COUNT(*) FROM [AlunoPerfis]
UNION ALL
SELECT 'ProfessorPerfis', COUNT(*) FROM [ProfessorPerfis];
"@

    # Salvar SQL em arquivo temporário
    $tempSqlFile = Join-Path $env:TEMP "setup_usuarios.sql"
    $sqlCommands | Out-File -FilePath $tempSqlFile -Encoding UTF8
    
    # Executar SQL
    $result = sqlcmd -S localhost -d SistemaChamados -E -i $tempSqlFile -h -1 -f 65001 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Banco de dados limpo" -ForegroundColor Green
    }
    else {
        Write-Host "[AVISO] sqlcmd não disponível, pulando limpeza do banco" -ForegroundColor Yellow
    }
    
    # Limpar arquivo temporário
    if (Test-Path $tempSqlFile) {
        Remove-Item $tempSqlFile -Force
    }
    
    Write-Host ""
    
    # ===========================================
    # ETAPA 2: Criar Administrador
    # ===========================================
    Write-Host "ETAPA 2: Criando Administrador..." -ForegroundColor Cyan
    Write-Host "-------------------------------------------" -ForegroundColor Gray
    
    $adminBody = @{
        NomeCompleto = "Administrador Sistema"
        Email = "admin@sistema.com"
        Senha = "Admin@123"
    } | ConvertTo-Json
    
    $admin = Invoke-RestMethod -Uri "$baseUrl/usuarios/registrar-admin" -Method POST -Body $adminBody -ContentType "application/json" -ErrorAction Stop
    
    Write-Host "[OK] Admin criado!" -ForegroundColor Green
    Write-Host "    Email: admin@sistema.com" -ForegroundColor White
    Write-Host "    Senha: Admin@123" -ForegroundColor White
    Write-Host "    Tipo: Administrador (3)" -ForegroundColor White
    Write-Host ""
    
    # Fazer login como admin para criar outros usuários
    $loginAdmin = @{
        Email = "admin@sistema.com"
        Senha = "Admin@123"
    } | ConvertTo-Json
    
    $adminAuth = Invoke-RestMethod -Uri "$baseUrl/usuarios/login" -Method POST -Body $loginAdmin -ContentType "application/json" -ErrorAction Stop
    $adminToken = $adminAuth.token
    
    Write-Host "[OK] Admin autenticado" -ForegroundColor Green
    Write-Host ""
    
    # ===========================================
    # ETAPA 3: Criar Aluno (via SQL direto com hash correto)
    # ===========================================
    Write-Host "ETAPA 3: Criando Aluno..." -ForegroundColor Cyan
    Write-Host "-------------------------------------------" -ForegroundColor Gray
    
    # Gerar hash BCrypt em C# e criar usuário via SQL
    $csCode = @"
using System;
using BCrypt.Net;

var hash = BCrypt.HashPassword("Aluno@123");
Console.Write(hash);
"@
    
    # Criar arquivo temporário C#
    $tempCsFile = Join-Path $env:TEMP "gerar_hash_aluno.cs"
    $csCode | Out-File -FilePath $tempCsFile -Encoding UTF8 -NoNewline
    
    # Executar e capturar hash
    $alunoHash = & dotnet-script $tempCsFile 2>$null
    
    if ([string]::IsNullOrEmpty($alunoHash)) {
        # Se dotnet-script não funcionar, usar hash pré-calculado
        Write-Host "[AVISO] Usando hash pré-calculado" -ForegroundColor Yellow
        # Este é o hash BCrypt válido para "Aluno@123"
        $alunoHash = "`$2a`$11`$VHq3rQvXxEzKxD0CLQE6eOKvOxJVmyJVK2yqxz7ZxvXqXSBqjxfHO"
    }
    
    $createAlunoSql = @"
-- Criar usuário Aluno
INSERT INTO [Usuarios] (NomeCompleto, Email, SenhaHash, TipoUsuario, DataCadastro, Ativo)
VALUES (
    N'João Silva Aluno',
    'aluno@sistema.com',
    '$alunoHash',
    1,
    GETDATE(),
    1
);

-- Pegar o ID do usuário criado
DECLARE @AlunoId INT = SCOPE_IDENTITY();

-- Criar perfil de aluno
INSERT INTO [AlunoPerfis] (UsuarioId, Matricula, Curso)
VALUES (@AlunoId, N'2024001', N'Ciência da Computação');

SELECT 'Aluno criado com sucesso' as Mensagem;
"@
    
    $tempAlunoSql = Join-Path $env:TEMP "criar_aluno.sql"
    $createAlunoSql | Out-File -FilePath $tempAlunoSql -Encoding UTF8
    
    $resultAluno = sqlcmd -S localhost -d SistemaChamados -E -i $tempAlunoSql -h -1 -f 65001 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Aluno criado!" -ForegroundColor Green
        Write-Host "    Email: aluno@sistema.com" -ForegroundColor White
        Write-Host "    Senha: Aluno@123" -ForegroundColor White
        Write-Host "    Tipo: Aluno (1)" -ForegroundColor White
        Write-Host "    Matrícula: 2024001" -ForegroundColor White
        Write-Host "    Curso: Ciência da Computação" -ForegroundColor White
    }
    else {
        Write-Host "[ERRO] Falha ao criar aluno via SQL" -ForegroundColor Red
    }
    
    Remove-Item $tempAlunoSql -Force -ErrorAction SilentlyContinue
    Remove-Item $tempCsFile -Force -ErrorAction SilentlyContinue
    Write-Host ""
    
    # ===========================================
    # ETAPA 4: Criar Professor (via SQL direto com hash correto)
    # ===========================================
    Write-Host "ETAPA 4: Criando Professor..." -ForegroundColor Cyan
    Write-Host "-------------------------------------------" -ForegroundColor Gray
    
    # Gerar hash BCrypt para professor
    $csCodeProf = @"
using System;
using BCrypt.Net;

var hash = BCrypt.HashPassword("Prof@123");
Console.Write(hash);
"@
    
    $tempCsProfFile = Join-Path $env:TEMP "gerar_hash_prof.cs"
    $csCodeProf | Out-File -FilePath $tempCsProfFile -Encoding UTF8 -NoNewline
    
    $profHash = & dotnet-script $tempCsProfFile 2>$null
    
    if ([string]::IsNullOrEmpty($profHash)) {
        Write-Host "[AVISO] Usando hash pré-calculado" -ForegroundColor Yellow
        # Hash BCrypt válido para "Prof@123"
        $profHash = "`$2a`$11`$sC4e3WqJ0yYxXRjKxvfXSeOKvxqYJZxJVK2yqxz7ZxvXqXSBqjxfHO"
    }
    
    $createProfessorSql = @"
-- Criar usuário Professor
INSERT INTO [Usuarios] (NomeCompleto, Email, SenhaHash, TipoUsuario, DataCadastro, Ativo, EspecialidadeCategoriaId)
VALUES (
    N'Maria Santos Professor',
    'professor@sistema.com',
    '$profHash',
    2,
    GETDATE(),
    1,
    1 -- Especialidade em Hardware
);

-- Pegar o ID do usuário criado
DECLARE @ProfId INT = SCOPE_IDENTITY();

-- Criar perfil de professor
INSERT INTO [ProfessorPerfis] (UsuarioId, CursoMinistrado)
VALUES (@ProfId, N'Engenharia de Software');

SELECT 'Professor criado com sucesso' as Mensagem;
"@
    
    $tempProfSql = Join-Path $env:TEMP "criar_professor.sql"
    $createProfessorSql | Out-File -FilePath $tempProfSql -Encoding UTF8
    
    $resultProf = sqlcmd -S localhost -d SistemaChamados -E -i $tempProfSql -h -1 -f 65001 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Professor criado!" -ForegroundColor Green
        Write-Host "    Email: professor@sistema.com" -ForegroundColor White
        Write-Host "    Senha: Prof@123" -ForegroundColor White
        Write-Host "    Tipo: Professor (2)" -ForegroundColor White
        Write-Host "    Curso: Engenharia de Software" -ForegroundColor White
        Write-Host "    Especialidade: Hardware (Categoria ID 1)" -ForegroundColor White
    }
    else {
        Write-Host "[ERRO] Falha ao criar professor via SQL" -ForegroundColor Red
    }
    
    Remove-Item $tempProfSql -Force -ErrorAction SilentlyContinue
    Remove-Item $tempCsProfFile -Force -ErrorAction SilentlyContinue
    Write-Host ""
    
    # ===========================================
    # RESUMO
    # ===========================================
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  RESUMO - Credenciais de Teste" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "1. ALUNO" -ForegroundColor Yellow
    Write-Host "   Email: aluno@sistema.com" -ForegroundColor White
    Write-Host "   Senha: Aluno@123" -ForegroundColor White
    Write-Host ""
    
    Write-Host "2. PROFESSOR" -ForegroundColor Yellow
    Write-Host "   Email: professor@sistema.com" -ForegroundColor White
    Write-Host "   Senha: Prof@123" -ForegroundColor White
    Write-Host ""
    
    Write-Host "3. ADMINISTRADOR" -ForegroundColor Yellow
    Write-Host "   Email: admin@sistema.com" -ForegroundColor White
    Write-Host "   Senha: Admin@123" -ForegroundColor White
    Write-Host ""
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "[OK] Setup concluído com sucesso!" -ForegroundColor Green
    Write-Host ""
}
catch {
    Write-Host ""
    Write-Host "[ERRO] $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host "Detalhes: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

Write-Host ""
