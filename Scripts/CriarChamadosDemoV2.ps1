# ========================================
# Criar Chamados de Demonstracao (v2)
# ========================================
# Usa Entity Framework para garantir compatibilidade

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

Set-Location $backendPath

Write-Host "[1/2] Compilando Backend..." -ForegroundColor Yellow
dotnet build -c Release --nologo 2>&1 | Out-Null
Write-Host "[OK] Backend compilado" -ForegroundColor Green
Write-Host ""

Write-Host "[2/2] Criando chamados demo..." -ForegroundColor Yellow

# Criar script C# para executar via EF Core
$csharpScript = @'
using Microsoft.EntityFrameworkCore;
using SistemaChamados.Core.Entities;
using SistemaChamados.Data;
using System;
using System.Linq;

var optionsBuilder = new DbContextOptionsBuilder<ApplicationDbContext>();
optionsBuilder.UseSqlServer("Server=(localdb)\\mssqllocaldb;Database=SistemaChamados;Trusted_Connection=True;");

using var context = new ApplicationDbContext(optionsBuilder.Options);

Console.WriteLine("Limpando chamados existentes...");

// Limpar dados
context.HistoricoChamados.RemoveRange(context.HistoricoChamados);
context.Atualizacoes.RemoveRange(context.Atualizacoes);
context.Chamados.RemoveRange(context.Chamados);
context.SaveChanges();

Console.WriteLine("Obtendo usuarios...");

// Obter usuarios
var admin = context.Usuarios.FirstOrDefault(u => u.Email == "admin@sistema.com");
var aluno = context.Usuarios.FirstOrDefault(u => u.Email == "aluno@sistema.com");
var professor = context.Usuarios.FirstOrDefault(u => u.Email == "professor@sistema.com");

if (admin == null || aluno == null || professor == null)
{
    Console.WriteLine("ERRO: Usuarios nao encontrados!");
    return;
}

// Obter categorias, prioridades e status
var catHardware = context.Categorias.First(c => c.Nome == "Hardware");
var catSoftware = context.Categorias.First(c => c.Nome == "Software");
var catRede = context.Categorias.First(c => c.Nome == "Rede");

var prioAlta = context.Prioridades.First(p => p.Nome == "Alta");
var prioMedia = context.Prioridades.First(p => p.Nome == "Media");
var prioBaixa = context.Prioridades.First(p => p.Nome == "Baixa");

var statusAberto = context.Status.First(s => s.Nome == "Aberto");
var statusEmAndamento = context.Status.First(s => s.Nome == "Em Andamento");
var statusEncerrado = context.Status.First(s => s.Nome == "Encerrado");

Console.WriteLine("Criando chamados do Aluno...");

// ==========================================
// CHAMADOS DO ALUNO
// ==========================================

var chamado1 = new Chamado
{
    Titulo = "Computador do laboratorio muito lento",
    Descricao = "O computador da sala 201 esta extremamente lento. Demora varios minutos para abrir programas e o sistema trava com frequencia.",
    CategoriaId = catHardware.Id,
    PrioriadadeId = prioMedia.Id,
    StatusId = statusAberto.Id,
    SolicitanteId = aluno.Id,
    DataAbertura = DateTime.UtcNow.AddHours(-2),
    Local = "Laboratorio 201 - Computador 15"
};

var chamado2 = new Chamado
{
    Titulo = "Visual Studio nao abre projetos",
    Descricao = "O Visual Studio 2022 instalado no laboratorio nao consegue abrir projetos .NET. Aparece um erro de dependencias faltando.",
    CategoriaId = catSoftware.Id,
    PrioriadadeId = prioAlta.Id,
    StatusId = statusEmAndamento.Id,
    SolicitanteId = aluno.Id,
    TecnicoResponsavelId = professor.Id,
    DataAbertura = DateTime.UtcNow.AddHours(-5),
    Local = "Laboratorio 301 - Computador 08"
};

var chamado3 = new Chamado
{
    Titulo = "Wi-Fi da biblioteca com conexao intermitente",
    Descricao = "O sinal Wi-Fi na biblioteca fica caindo constantemente. Impossivel assistir aulas online ou fazer downloads.",
    CategoriaId = catRede.Id,
    PrioriadadeId = prioMedia.Id,
    StatusId = statusAberto.Id,
    SolicitanteId = aluno.Id,
    DataAbertura = DateTime.UtcNow.AddHours(-1),
    Local = "Biblioteca - 2o andar"
};

context.Chamados.AddRange(chamado1, chamado2, chamado3);
context.SaveChanges();

// Adicionar atualizacao no chamado 2
context.Atualizacoes.Add(new Atualizacao
{
    ChamadoId = chamado2.Id,
    UsuarioId = professor.Id,
    Descricao = "Identifiquei o problema. Faltam alguns pacotes do .NET SDK. Vou instalar e testar.",
    DataAtualizacao = DateTime.UtcNow.AddHours(-3)
});

Console.WriteLine("Criando chamados do Professor...");

// ==========================================
// CHAMADOS DO PROFESSOR
// ==========================================

var chamado4 = new Chamado
{
    Titulo = "Projetor da sala 105 nao liga",
    Descricao = "O projetor da sala 105 nao esta ligando. Tenho aula em 2 horas e preciso usar apresentacoes. URGENTE!",
    CategoriaId = catHardware.Id,
    PrioriadadeId = prioAlta.Id,
    StatusId = statusAberto.Id,
    SolicitanteId = professor.Id,
    DataAbertura = DateTime.UtcNow.AddMinutes(-30),
    Local = "Sala 105"
};

var chamado5 = new Chamado
{
    Titulo = "Solicitar atualizacao do Office",
    Descricao = "O pacote Office dos computadores do laboratorio esta desatualizado (versao 2019). Gostaria de solicitar atualizacao para a versao mais recente.",
    CategoriaId = catSoftware.Id,
    PrioriadadeId = prioBaixa.Id,
    StatusId = statusEncerrado.Id,
    SolicitanteId = professor.Id,
    TecnicoResponsavelId = admin.Id,
    DataAbertura = DateTime.UtcNow.AddDays(-3),
    DataFechamento = DateTime.UtcNow.AddDays(-1),
    Local = "Laboratorio 401"
};

var chamado6 = new Chamado
{
    Titulo = "Internet lenta impede uso de plataforma online",
    Descricao = "A velocidade da internet na sala 302 esta muito baixa. Nao consigo acessar a plataforma de ensino para passar videos e materiais aos alunos.",
    CategoriaId = catRede.Id,
    PrioriadadeId = prioAlta.Id,
    StatusId = statusAberto.Id,
    SolicitanteId = professor.Id,
    DataAbertura = DateTime.UtcNow.AddHours(-4),
    Local = "Sala 302"
};

context.Chamados.AddRange(chamado4, chamado5, chamado6);
context.SaveChanges();

// Adicionar atualizacoes e historico no chamado 5 (encerrado)
context.Atualizacoes.AddRange(
    new Atualizacao
    {
        ChamadoId = chamado5.Id,
        UsuarioId = admin.Id,
        Descricao = "Chamado recebido. Vou verificar disponibilidade de licencas e agenda de manutencao.",
        DataAtualizacao = DateTime.UtcNow.AddDays(-2)
    },
    new Atualizacao
    {
        ChamadoId = chamado5.Id,
        UsuarioId = admin.Id,
        Descricao = "Atualizacao concluida! Todos os computadores do laboratorio 401 agora tem Office 2021.",
        DataAtualizacao = DateTime.UtcNow.AddDays(-1)
    }
);

context.HistoricoChamados.AddRange(
    new HistoricoChamado
    {
        ChamadoId = chamado5.Id,
        StatusAnteriorId = statusAberto.Id,
        StatusNovoId = statusEmAndamento.Id,
        UsuarioId = admin.Id,
        DataMudanca = DateTime.UtcNow.AddDays(-2),
        Observacao = "Iniciando processo de atualizacao"
    },
    new HistoricoChamado
    {
        ChamadoId = chamado5.Id,
        StatusAnteriorId = statusEmAndamento.Id,
        StatusNovoId = statusEncerrado.Id,
        UsuarioId = admin.Id,
        DataMudanca = DateTime.UtcNow.AddDays(-1),
        Observacao = "Atualizacao concluida com sucesso"
    }
);

Console.WriteLine("Criando chamados do Admin...");

// ==========================================
// CHAMADOS DO ADMIN
// ==========================================

var chamado7 = new Chamado
{
    Titulo = "Realizar backup completo do servidor principal",
    Descricao = "Agendar e executar backup completo do servidor de arquivos da faculdade. Backup trimestral obrigatorio.",
    CategoriaId = catRede.Id,
    PrioriadadeId = prioAlta.Id,
    StatusId = statusEmAndamento.Id,
    SolicitanteId = admin.Id,
    TecnicoResponsavelId = admin.Id,
    DataAbertura = DateTime.UtcNow.AddDays(-1),
    Local = "Sala de Servidores - Predio Principal"
};

var chamado8 = new Chamado
{
    Titulo = "Agendar manutencao preventiva dos computadores",
    Descricao = "Planejar manutencao preventiva trimestral: limpeza, atualizacoes de sistema, verificacao de hardware.",
    CategoriaId = catHardware.Id,
    PrioriadadeId = prioBaixa.Id,
    StatusId = statusAberto.Id,
    SolicitanteId = admin.Id,
    DataAbertura = DateTime.UtcNow.AddDays(-2),
    Local = "Todos os laboratorios"
};

var chamado9 = new Chamado
{
    Titulo = "Instalar IDE PyCharm nos laboratorios",
    Descricao = "Instalar PyCharm Community Edition nos computadores dos laboratorios 201, 301 e 401 para as aulas de Python do proximo semestre.",
    CategoriaId = catSoftware.Id,
    PrioriadadeId = prioMedia.Id,
    StatusId = statusAberto.Id,
    SolicitanteId = admin.Id,
    DataAbertura = DateTime.UtcNow.AddHours(-6),
    Local = "Laboratorios 201, 301, 401"
};

context.Chamados.AddRange(chamado7, chamado8, chamado9);
context.SaveChanges();

// Adicionar atualizacao no chamado 7
context.Atualizacoes.Add(new Atualizacao
{
    ChamadoId = chamado7.Id,
    UsuarioId = admin.Id,
    Descricao = "Backup iniciado. Estimativa de conclusao: 6 horas. Progresso atual: 35%",
    DataAtualizacao = DateTime.UtcNow.AddHours(-2)
});

context.SaveChanges();

Console.WriteLine("\n========================================");
Console.WriteLine("  SUCESSO!");
Console.WriteLine("========================================");
Console.WriteLine($"\nTotal de chamados criados: {context.Chamados.Count()}");
Console.WriteLine($"  - Aluno: {context.Chamados.Count(c => c.SolicitanteId == aluno.Id)}");
Console.WriteLine($"  - Professor: {context.Chamados.Count(c => c.SolicitanteId == professor.Id)}");
Console.WriteLine($"  - Admin: {context.Chamados.Count(c => c.SolicitanteId == admin.Id)}");
Console.WriteLine("\nChamados por status:");
Console.WriteLine($"  - Abertos: {context.Chamados.Count(c => c.StatusId == statusAberto.Id)}");
Console.WriteLine($"  - Em Andamento: {context.Chamados.Count(c => c.StatusId == statusEmAndamento.Id)}");
Console.WriteLine($"  - Encerrados: {context.Chamados.Count(c => c.StatusId == statusEncerrado.Id)}");
Console.WriteLine("\n========================================\n");
'@

# Salvar script
$tempFile = Join-Path $env:TEMP "criar_chamados.cs"
$csharpScript | Out-File -FilePath $tempFile -Encoding UTF8

# Executar como script dotnet
try {
    dotnet script $tempFile
    Write-Host ""
    Write-Host "[OK] Chamados demo criados!" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "[AVISO] dotnet script nao disponivel. Tentando metodo alternativo..." -ForegroundColor Yellow
    
    # Criar projeto temporario
    $tempProject = Join-Path $env:TEMP "ChamadosDemo"
    if (Test-Path $tempProject) {
        Remove-Item $tempProject -Recurse -Force
    }
    
    New-Item -ItemType Directory -Path $tempProject | Out-Null
    Set-Location $tempProject
    
    dotnet new console --force | Out-Null
    
    # Adicionar pacotes necessarios
    dotnet add package Microsoft.EntityFrameworkCore.SqlServer | Out-Null
    
    # Copiar Program.cs
    $csharpScript | Out-File -FilePath "Program.cs" -Encoding UTF8
    
    # Adicionar referencias ao projeto principal
    dotnet add reference "$backendPath\SistemaChamados.csproj" | Out-Null
    
    # Executar
    dotnet run
    
    # Voltar e limpar
    Set-Location $backendPath
    Remove-Item $tempProject -Recurse -Force
}

# Limpar
Remove-Item $tempFile -ErrorAction SilentlyContinue

Write-Host "Chamados de demonstracao prontos para uso!" -ForegroundColor Green
Write-Host ""
