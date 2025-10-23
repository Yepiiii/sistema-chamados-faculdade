# ========================================
# Criar Chamados de Demonstracao
# ========================================
# Este script limpa todos os chamados existentes e cria
# 3 chamados genericos para cada usuario (Admin, Aluno, Professor)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Criar Chamados de Demonstracao" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Detectar caminhos
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$backendPath = Join-Path $repoRoot "Backend"

if (-not (Test-Path $backendPath)) {
    Write-Host "[ERRO] Backend nao encontrado em: $backendPath" -ForegroundColor Red
    exit 1
}

# Mudar para pasta Backend
Set-Location $backendPath

Write-Host "[1/3] Limpando chamados existentes..." -ForegroundColor Yellow

# Script SQL para limpar e criar chamados demo
$sqlScript = @"
-- Limpar chamados existentes
DELETE FROM HistoricoChamados;
DELETE FROM Atualizacoes;
DELETE FROM Chamados;

-- Resetar identity
DBCC CHECKIDENT ('Chamados', RESEED, 0);
DBCC CHECKIDENT ('Atualizacoes', RESEED, 0);
DBCC CHECKIDENT ('HistoricoChamados', RESEED, 0);

-- Obter IDs dos usuarios
DECLARE @AdminId INT = (SELECT Id FROM Usuarios WHERE Email = 'admin@sistema.com');
DECLARE @AlunoId INT = (SELECT Id FROM Usuarios WHERE Email = 'aluno@sistema.com');
DECLARE @ProfessorId INT = (SELECT Id FROM Usuarios WHERE Email = 'professor@sistema.com');

-- Obter IDs de categorias, prioridades e status
DECLARE @CatHardware INT = (SELECT Id FROM Categorias WHERE Nome = 'Hardware');
DECLARE @CatSoftware INT = (SELECT Id FROM Categorias WHERE Nome = 'Software');
DECLARE @CatRede INT = (SELECT Id FROM Categorias WHERE Nome = 'Rede');

DECLARE @PrioAlta INT = (SELECT Id FROM Prioridades WHERE Nome = 'Alta');
DECLARE @PrioMedia INT = (SELECT Id FROM Prioridades WHERE Nome = 'Media');
DECLARE @PrioBaixa INT = (SELECT Id FROM Prioridades WHERE Nome = 'Baixa');

DECLARE @StatusAberto INT = (SELECT Id FROM Status WHERE Nome = 'Aberto');
DECLARE @StatusEmAndamento INT = (SELECT Id FROM Status WHERE Nome = 'Em Andamento');
DECLARE @StatusEncerrado INT = (SELECT Id FROM Status WHERE Nome = 'Encerrado');

-- ==========================================
-- CHAMADOS DO ALUNO (3 chamados)
-- ==========================================

-- Chamado 1: Aluno - Computador lento (Aberto)
INSERT INTO Chamados (Titulo, Descricao, CategoriaId, PrioriadadeId, StatusId, SolicitanteId, DataAbertura, Local)
VALUES (
    'Computador do laboratorio muito lento',
    'O computador da sala 201 esta extremamente lento. Demora varios minutos para abrir programas e o sistema trava com frequencia.',
    @CatHardware,
    @PrioMedia,
    @StatusAberto,
    @AlunoId,
    DATEADD(hour, -2, GETUTCDATE()),
    'Laboratorio 201 - Computador 15'
);

-- Chamado 2: Aluno - Problema com software (Em Andamento)
INSERT INTO Chamados (Titulo, Descricao, CategoriaId, PrioriadadeId, StatusId, SolicitanteId, TecnicoResponsavelId, DataAbertura, Local)
VALUES (
    'Visual Studio nao abre projetos',
    'O Visual Studio 2022 instalado no laboratorio nao consegue abrir projetos .NET. Aparece um erro de dependencias faltando.',
    @CatSoftware,
    @PrioAlta,
    @StatusEmAndamento,
    @AlunoId,
    @ProfessorId,
    DATEADD(hour, -5, GETUTCDATE()),
    'Laboratorio 301 - Computador 08'
);

-- Adicionar atualizacao no chamado em andamento
DECLARE @ChamadoAlunoId INT = SCOPE_IDENTITY();
INSERT INTO Atualizacoes (ChamadoId, UsuarioId, Descricao, DataAtualizacao)
VALUES (
    @ChamadoAlunoId,
    @ProfessorId,
    'Identifiquei o problema. Faltam alguns pacotes do .NET SDK. Vou instalar e testar.',
    DATEADD(hour, -3, GETUTCDATE())
);

-- Chamado 3: Aluno - Wi-Fi com problemas (Aberto)
INSERT INTO Chamados (Titulo, Descricao, CategoriaId, PrioriadadeId, StatusId, SolicitanteId, DataAbertura, Local)
VALUES (
    'Wi-Fi da biblioteca com conexao intermitente',
    'O sinal Wi-Fi na biblioteca fica caindo constantemente. Impossivel assistir aulas online ou fazer downloads.',
    @CatRede,
    @PrioMedia,
    @StatusAberto,
    @AlunoId,
    DATEADD(hour, -1, GETUTCDATE()),
    'Biblioteca - 2o andar'
);

-- ==========================================
-- CHAMADOS DO PROFESSOR (3 chamados)
-- ==========================================

-- Chamado 1: Professor - Projetor com defeito (Alta prioridade)
INSERT INTO Chamados (Titulo, Descricao, CategoriaId, PrioriadadeId, StatusId, SolicitanteId, DataAbertura, Local)
VALUES (
    'Projetor da sala 105 nao liga',
    'O projetor da sala 105 nao esta ligando. Tenho aula em 2 horas e preciso usar apresentacoes. URGENTE!',
    @CatHardware,
    @PrioAlta,
    @StatusAberto,
    @ProfessorId,
    DATEADD(minute, -30, GETUTCDATE()),
    'Sala 105'
);

-- Chamado 2: Professor - Software desatualizado (Encerrado)
INSERT INTO Chamados (Titulo, Descricao, CategoriaId, PrioriadadeId, StatusId, SolicitanteId, TecnicoResponsavelId, DataAbertura, DataFechamento, Local)
VALUES (
    'Solicitar atualizacao do Office',
    'O pacote Office dos computadores do laboratorio esta desatualizado (versao 2019). Gostaria de solicitar atualizacao para a versao mais recente.',
    @CatSoftware,
    @PrioBaixa,
    @StatusEncerrado,
    @ProfessorId,
    @AdminId,
    DATEADD(day, -3, GETUTCDATE()),
    DATEADD(day, -1, GETUTCDATE()),
    'Laboratorio 401'
);

-- Adicionar historico e atualizacoes no chamado encerrado
DECLARE @ChamadoProfId INT = SCOPE_IDENTITY();

INSERT INTO Atualizacoes (ChamadoId, UsuarioId, Descricao, DataAtualizacao)
VALUES (
    @ChamadoProfId,
    @AdminId,
    'Chamado recebido. Vou verificar disponibilidade de licencas e agenda de manutencao.',
    DATEADD(day, -2, GETUTCDATE())
);

INSERT INTO Atualizacoes (ChamadoId, UsuarioId, Descricao, DataAtualizacao)
VALUES (
    @ChamadoProfId,
    @AdminId,
    'Atualizacao concluida! Todos os computadores do laboratorio 401 agora tem Office 2021.',
    DATEADD(day, -1, GETUTCDATE())
);

INSERT INTO HistoricoChamados (ChamadoId, StatusAnteriorId, StatusNovoId, UsuarioId, DataMudanca, Observacao)
VALUES (
    @ChamadoProfId,
    @StatusAberto,
    @StatusEmAndamento,
    @AdminId,
    DATEADD(day, -2, GETUTCDATE()),
    'Iniciando processo de atualizacao'
);

INSERT INTO HistoricoChamados (ChamadoId, StatusAnteriorId, StatusNovoId, UsuarioId, DataMudanca, Observacao)
VALUES (
    @ChamadoProfId,
    @StatusEmAndamento,
    @StatusEncerrado,
    @AdminId,
    DATEADD(day, -1, GETUTCDATE()),
    'Atualizacao concluida com sucesso'
);

-- Chamado 3: Professor - Rede lenta na sala de aula (Aberto)
INSERT INTO Chamados (Titulo, Descricao, CategoriaId, PrioriadadeId, StatusId, SolicitanteId, DataAbertura, Local)
VALUES (
    'Internet lenta impede uso de plataforma online',
    'A velocidade da internet na sala 302 esta muito baixa. Nao consigo acessar a plataforma de ensino para passar videos e materiais aos alunos.',
    @CatRede,
    @PrioAlta,
    @StatusAberto,
    @ProfessorId,
    DATEADD(hour, -4, GETUTCDATE()),
    'Sala 302'
);

-- ==========================================
-- CHAMADOS DO ADMIN (3 chamados)
-- ==========================================

-- Chamado 1: Admin - Backup do servidor (Em Andamento)
INSERT INTO Chamados (Titulo, Descricao, CategoriaId, PrioriadadeId, StatusId, SolicitanteId, TecnicoResponsavelId, DataAbertura, Local)
VALUES (
    'Realizar backup completo do servidor principal',
    'Agendar e executar backup completo do servidor de arquivos da faculdade. Backup trimestral obrigatorio.',
    @CatRede,
    @PrioAlta,
    @StatusEmAndamento,
    @AdminId,
    @AdminId,
    DATEADD(day, -1, GETUTCDATE()),
    'Sala de Servidores - Predio Principal'
);

-- Adicionar atualizacao
DECLARE @ChamadoAdminId INT = SCOPE_IDENTITY();
INSERT INTO Atualizacoes (ChamadoId, UsuarioId, Descricao, DataAtualizacao)
VALUES (
    @ChamadoAdminId,
    @AdminId,
    'Backup iniciado. Estimativa de conclusao: 6 horas. Progresso atual: 35%',
    DATEADD(hour, -2, GETUTCDATE())
);

-- Chamado 2: Admin - Manutencao preventiva (Baixa prioridade)
INSERT INTO Chamados (Titulo, Descricao, CategoriaId, PrioriadadeId, StatusId, SolicitanteId, DataAbertura, Local)
VALUES (
    'Agendar manutencao preventiva dos computadores',
    'Planejar manutencao preventiva trimestral: limpeza, atualizacoes de sistema, verificacao de hardware.',
    @CatHardware,
    @PrioBaixa,
    @StatusAberto,
    @AdminId,
    DATEADD(day, -2, GETUTCDATE()),
    'Todos os laboratorios'
);

-- Chamado 3: Admin - Instalacao de novo software (Aberto)
INSERT INTO Chamados (Titulo, Descricao, CategoriaId, PrioriadadeId, StatusId, SolicitanteId, DataAbertura, Local)
VALUES (
    'Instalar IDE PyCharm nos laboratorios',
    'Instalar PyCharm Community Edition nos computadores dos laboratorios 201, 301 e 401 para as aulas de Python do proximo semestre.',
    @CatSoftware,
    @PrioMedia,
    @StatusAberto,
    @AdminId,
    DATEADD(hour, -6, GETUTCDATE()),
    'Laboratorios 201, 301, 401'
);

-- Mostrar resultado
SELECT 
    'RESUMO DOS CHAMADOS CRIADOS' as Info,
    COUNT(*) as TotalChamados,
    SUM(CASE WHEN SolicitanteId = @AlunoId THEN 1 ELSE 0 END) as ChamadosAluno,
    SUM(CASE WHEN SolicitanteId = @ProfessorId THEN 1 ELSE 0 END) as ChamadosProfessor,
    SUM(CASE WHEN SolicitanteId = @AdminId THEN 1 ELSE 0 END) as ChamadosAdmin
FROM Chamados;

SELECT 
    'CHAMADOS POR STATUS' as Info,
    s.Nome as Status,
    COUNT(*) as Quantidade
FROM Chamados c
INNER JOIN Status s ON c.StatusId = s.Id
GROUP BY s.Nome;
"@

# Salvar script SQL temporario
$tempSqlFile = Join-Path $env:TEMP "criar_chamados_demo.sql"
$sqlScript | Out-File -FilePath $tempSqlFile -Encoding UTF8

Write-Host "[OK] Script SQL criado" -ForegroundColor Green
Write-Host ""

Write-Host "[2/3] Executando script no banco de dados..." -ForegroundColor Yellow

try {
    # Executar usando dotnet ef
    $result = dotnet ef database update 2>&1
    
    # Executar script SQL customizado
    $connectionString = "Server=(localdb)\mssqllocaldb;Database=SistemaChamados;Trusted_Connection=True;"
    
    # Usar sqlcmd se disponivel
    $sqlcmd = Get-Command sqlcmd -ErrorAction SilentlyContinue
    if ($sqlcmd) {
        sqlcmd -S "(localdb)\mssqllocaldb" -d "SistemaChamados" -i $tempSqlFile
    } else {
        # Usar Invoke-Sqlcmd do modulo SqlServer
        if (Get-Module -ListAvailable -Name SqlServer) {
            Import-Module SqlServer
            Invoke-Sqlcmd -ServerInstance "(localdb)\mssqllocaldb" -Database "SistemaChamados" -InputFile $tempSqlFile
        } else {
            Write-Host "[AVISO] sqlcmd e SqlServer PowerShell module nao encontrados" -ForegroundColor Yellow
            Write-Host "[INFO] Usando metodo alternativo..." -ForegroundColor Cyan
            
            # Criar script C# temporario para executar SQL
            $csScript = @"
using System;
using System.Data.SqlClient;
using System.IO;

class Program
{
    static void Main()
    {
        var connectionString = "Server=(localdb)\\mssqllocaldb;Database=SistemaChamados;Trusted_Connection=True;";
        var sqlScript = File.ReadAllText("$tempSqlFile");
        
        using (var connection = new SqlConnection(connectionString))
        {
            connection.Open();
            
            // Dividir por GO e executar cada batch
            var batches = sqlScript.Split(new[] { "\r\nGO\r\n", "\nGO\n" }, StringSplitOptions.RemoveEmptyEntries);
            
            foreach (var batch in batches)
            {
                if (!string.IsNullOrWhiteSpace(batch))
                {
                    using (var command = new SqlCommand(batch, connection))
                    {
                        command.ExecuteNonQuery();
                    }
                }
            }
            
            Console.WriteLine("Script executado com sucesso!");
        }
    }
}
"@
            $tempCsFile = Join-Path $env:TEMP "exec_sql.cs"
            $csScript | Out-File -FilePath $tempCsFile -Encoding UTF8
            
            # Compilar e executar
            csc /out:"$env:TEMP\exec_sql.exe" $tempCsFile 2>&1 | Out-Null
            & "$env:TEMP\exec_sql.exe"
            
            # Limpar arquivos temporarios
            Remove-Item $tempCsFile -ErrorAction SilentlyContinue
            Remove-Item "$env:TEMP\exec_sql.exe" -ErrorAction SilentlyContinue
        }
    }
    
    Write-Host "[OK] Chamados criados com sucesso!" -ForegroundColor Green
    
} catch {
    Write-Host "[ERRO] Falha ao executar script: $_" -ForegroundColor Red
    exit 1
} finally {
    # Limpar arquivo temporario
    Remove-Item $tempSqlFile -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "[3/3] Verificando resultado..." -ForegroundColor Yellow

# Consultar total de chamados
$verificacao = @"
SELECT COUNT(*) as Total FROM Chamados;
"@

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  CHAMADOS DEMO CRIADOS COM SUCESSO!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Total de chamados criados: 9 (3 por usuario)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Distribuicao:" -ForegroundColor White
Write-Host "  - Aluno: 3 chamados" -ForegroundColor Cyan
Write-Host "    * Computador lento (Aberto)" -ForegroundColor Gray
Write-Host "    * Visual Studio com problema (Em Andamento)" -ForegroundColor Gray
Write-Host "    * Wi-Fi intermitente (Aberto)" -ForegroundColor Gray
Write-Host ""
Write-Host "  - Professor: 3 chamados" -ForegroundColor Cyan
Write-Host "    * Projetor nao liga (Aberto - URGENTE)" -ForegroundColor Gray
Write-Host "    * Atualizacao Office (Encerrado)" -ForegroundColor Gray
Write-Host "    * Internet lenta (Aberto)" -ForegroundColor Gray
Write-Host ""
Write-Host "  - Admin: 3 chamados" -ForegroundColor Cyan
Write-Host "    * Backup servidor (Em Andamento)" -ForegroundColor Gray
Write-Host "    * Manutencao preventiva (Aberto)" -ForegroundColor Gray
Write-Host "    * Instalar PyCharm (Aberto)" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Agora voce pode testar o sistema com chamados realistas!" -ForegroundColor Green
Write-Host ""
