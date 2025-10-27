# ========================================
# Script: Popular Usuários Padrão
# ========================================
# Este script cria os 4 usuários padrão do sistema
# via API REST (garante que as senhas sejam hasheadas corretamente)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " POPULANDO USUARIOS PADRAO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "" -ForegroundColor White

$backendUrl = "http://localhost:5246"

# Verificar se backend está rodando
Write-Host "1. Verificando se backend está rodando..." -ForegroundColor Yellow
try {
    $null = Invoke-RestMethod -Uri "$backendUrl/api/Categorias" -Method Get -TimeoutSec 5
    Write-Host "   OK Backend respondendo!" -ForegroundColor Green
    Write-Host "" -ForegroundColor White
} catch {
    Write-Host "   ERRO: Backend nao esta rodando!" -ForegroundColor Red
    Write-Host "   Execute primeiro: .\IniciarWeb.ps1" -ForegroundColor Yellow
    Write-Host "" -ForegroundColor White
    exit 1
}

# Lista de usuários padrão
$usuarios = @(
    @{
        email = "admin@sistema.com"
        senha = "Admin@123"
        nomeCompleto = "Administrador Sistema"
        tipoUsuario = 3  # Admin
        descricao = "Admin (Administrador)"
    },
    @{
        email = "tecnico@empresa.com"
        senha = "Admin@123"
        nomeCompleto = "Técnico Intermediário - Nível 2"
        tipoUsuario = 2  # Técnico TI
        nivelTecnico = 2
        areaAtuacao = "Suporte Intermediário"
        descricao = "Técnico Intermediário (Nível 2)"
    },
    @{
        email = "senior@empresa.com"
        senha = "Admin@123"
        nomeCompleto = "Técnico Sênior - Nível 3"
        tipoUsuario = 2  # Técnico TI
        nivelTecnico = 3
        areaAtuacao = "Especialista Sênior"
        descricao = "Técnico Sênior (Nível 3)"
    },
    @{
        email = "colaborador@empresa.com"
        senha = "Admin@123"
        nomeCompleto = "Colaborador Teste"
        tipoUsuario = 1  # Colaborador
        matricula = "COL001"
        departamento = "Departamento Teste"
        descricao = "Colaborador"
    }
)

Write-Host "2. Criando usuarios padrao..." -ForegroundColor Yellow
Write-Host "" -ForegroundColor White

$criados = 0
$jaExistentes = 0

foreach ($user in $usuarios) {
    Write-Host "   Processando: $($user.descricao) ($($user.email))..." -ForegroundColor White
    
    # Montar payload baseado no tipo de usuário
    $payload = @{
        email = $user.email
        senha = $user.senha
        nomeCompleto = $user.nomeCompleto
        tipoUsuario = $user.tipoUsuario
    }
    
    # Adicionar campos específicos de Técnico TI
    if ($user.tipoUsuario -eq 2) {
        $payload.nivelTecnico = $user.nivelTecnico
        $payload.areaAtuacao = $user.areaAtuacao
    }
    
    # Adicionar campos específicos de Colaborador
    if ($user.tipoUsuario -eq 1) {
        $payload.matricula = $user.matricula
        $payload.departamento = $user.departamento
    }
    
    $body = $payload | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$backendUrl/api/Usuarios/register" `
                                      -Method Post `
                                      -Body $body `
                                      -ContentType "application/json" `
                                      -ErrorAction Stop
        
        Write-Host "      OK Criado com sucesso! ID: $($response.id)" -ForegroundColor Green
        $criados++
    }
    catch {
        $errorMessage = $_.Exception.Message
        
        if ($errorMessage -like "*existe*" -or $errorMessage -like "*already exists*" -or $errorMessage -like "*cadastrado*") {
            Write-Host "      OK Ja existe no banco" -ForegroundColor Gray
            $jaExistentes++
        }
        else {
            Write-Host "      ERRO: $errorMessage" -ForegroundColor Red
        }
    }
    
    Start-Sleep -Milliseconds 200
}

# Resumo
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " RESUMO DA OPERAÇÃO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Usuários criados: $criados" -ForegroundColor Green
Write-Host "   Já existentes: $jaExistentes" -ForegroundColor Gray
Write-Host "   Total processados: $($usuarios.Count)" -ForegroundColor White

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " CREDENCIAIS DE ACESSO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "" -ForegroundColor White

Write-Host "OK Admin (Administrador)" -ForegroundColor Cyan
Write-Host "   Email: admin@sistema.com" -ForegroundColor White
Write-Host "   Senha: Admin@123" -ForegroundColor White
Write-Host "   Tipo: Admin (pode tudo)" -ForegroundColor Gray
Write-Host "" -ForegroundColor White

Write-Host "OK Tecnico Intermediario (Nivel 2)" -ForegroundColor Yellow
Write-Host "   Email: tecnico@empresa.com" -ForegroundColor White
Write-Host "   Senha: Admin@123" -ForegroundColor White
Write-Host "   Tipo: Tecnico TI (Nivel 2 - Suporte Intermediario)" -ForegroundColor Gray
Write-Host "   Atende: Chamados de baixa/media complexidade" -ForegroundColor DarkGray
Write-Host "" -ForegroundColor White

Write-Host "OK Tecnico Senior (Nivel 3)" -ForegroundColor Yellow
Write-Host "   Email: senior@empresa.com" -ForegroundColor White
Write-Host "   Senha: Admin@123" -ForegroundColor White
Write-Host "   Tipo: Tecnico TI (Nivel 3 - Especialista Senior)" -ForegroundColor Gray
Write-Host "   Atende: Chamados de alta complexidade/criticos" -ForegroundColor DarkGray
Write-Host "" -ForegroundColor White

Write-Host "OK Colaborador" -ForegroundColor Green
Write-Host "   Email: colaborador@empresa.com" -ForegroundColor White
Write-Host "   Senha: Admin@123" -ForegroundColor White
Write-Host "   Tipo: Colaborador (pode criar chamados)" -ForegroundColor Gray
Write-Host "" -ForegroundColor White

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Acesse: http://localhost:5246" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "" -ForegroundColor White
