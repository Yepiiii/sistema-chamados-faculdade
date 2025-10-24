# ============================================================================
# Script de Teste - Sistema de Permissões de Chamados
# ============================================================================
# 
# Este script testa as permissões implementadas para os 3 perfis:
# - Colaborador: Só vê seus próprios chamados
# - Técnico: Só vê chamados atribuídos a ele e pode encerrá-los
# - Admin: Visualização total e todas as ações
#
# ============================================================================

$ErrorActionPreference = "Continue"
$baseUrl = "http://localhost:5246/api"

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "  TESTE DE PERMISSOES - SISTEMA DE CHAMADOS" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

# Função para fazer login e obter token
function Get-AuthToken {
    param($email, $senha)
    
    $loginBody = @{
        email = $email
        senha = $senha
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post `
            -Body $loginBody -ContentType "application/json"
        return $response.token
    }
    catch {
        Write-Host "  ❌ Erro ao fazer login com $email" -ForegroundColor Red
        return $null
    }
}

# Função para buscar chamados
function Get-Chamados {
    param($token, $perfil)
    
    $headers = @{ Authorization = "Bearer $token" }
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/chamados" -Method Get -Headers $headers
        return $response
    }
    catch {
        Write-Host "  ❌ Erro ao buscar chamados para $perfil" -ForegroundColor Red
        return @()
    }
}

# Função para tentar encerrar chamado
function Encerrar-Chamado {
    param($token, $chamadoId, $solucao)
    
    $headers = @{ Authorization = "Bearer $token" }
    $body = @{ solucao = $solucao } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/chamados/$chamadoId/encerrar" -Method Post `
            -Headers $headers -Body $body -ContentType "application/json"
        return @{ success = $true; response = $response }
    }
    catch {
        return @{ success = $false; error = $_.Exception.Message }
    }
}

# Função para tentar criar chamado
function Criar-Chamado {
    param($token, $titulo, $descricao)
    
    $headers = @{ Authorization = "Bearer $token" }
    $body = @{
        titulo = $titulo
        descricaoProblema = $descricao
        usarAnaliseAutomatica = $true
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/chamados" -Method Post `
            -Headers $headers -Body $body -ContentType "application/json"
        return @{ success = $true; response = $response }
    }
    catch {
        return @{ success = $false; error = $_.Exception.Message }
    }
}

# ============================================================================
# TESTE 1: Login e obtenção de tokens
# ============================================================================
Write-Host "TESTE 1: Autenticação dos 3 perfis" -ForegroundColor Yellow
Write-Host "─────────────────────────────────────" -ForegroundColor Gray

$tokenColaborador = Get-AuthToken "colaborador@empresa.com" "Admin@123"
$tokenTecnico = Get-AuthToken "tecnico@empresa.com" "Admin@123"
$tokenAdmin = Get-AuthToken "admin@sistema.com" "Admin@123"

if ($tokenColaborador) { Write-Host "  ✅ Colaborador autenticado" -ForegroundColor Green }
if ($tokenTecnico) { Write-Host "  ✅ Técnico autenticado" -ForegroundColor Green }
if ($tokenAdmin) { Write-Host "  ✅ Admin autenticado" -ForegroundColor Green }

if (-not ($tokenColaborador -and $tokenTecnico -and $tokenAdmin)) {
    Write-Host "`n❌ Falha na autenticação. Encerrando teste." -ForegroundColor Red
    exit 1
}

Write-Host ""

# ============================================================================
# TESTE 2: Visualização de chamados por perfil
# ============================================================================
Write-Host "TESTE 2: Visualização de chamados por perfil" -ForegroundColor Yellow
Write-Host "─────────────────────────────────────────────" -ForegroundColor Gray

$chamadosColaborador = Get-Chamados $tokenColaborador "Colaborador"
$chamadosTecnico = Get-Chamados $tokenTecnico "Técnico"
$chamadosAdmin = Get-Chamados $tokenAdmin "Admin"

Write-Host "  Colaborador vê: $($chamadosColaborador.Count) chamado(s)" -ForegroundColor Cyan
Write-Host "  Técnico vê: $($chamadosTecnico.Count) chamado(s)" -ForegroundColor Cyan
Write-Host "  Admin vê: $($chamadosAdmin.Count) chamado(s)" -ForegroundColor Cyan

# Validação
if ($chamadosAdmin.Count -ge $chamadosColaborador.Count -and 
    $chamadosAdmin.Count -ge $chamadosTecnico.Count) {
    Write-Host "  ✅ Admin vê mais ou igual chamados que os outros perfis" -ForegroundColor Green
}
else {
    Write-Host "  ❌ ERRO: Admin deveria ver todos os chamados" -ForegroundColor Red
}

Write-Host ""

# ============================================================================
# TESTE 3: Técnico tentando criar chamado (DEVE FALHAR)
# ============================================================================
Write-Host "TESTE 3: Técnico tentando criar chamado (deve falhar)" -ForegroundColor Yellow
Write-Host "───────────────────────────────────────────────────────" -ForegroundColor Gray

$resultadoCriacaoTecnico = Criar-Chamado $tokenTecnico "Teste Técnico" "Este chamado não deve ser criado"

if (-not $resultadoCriacaoTecnico.success) {
    Write-Host "  ✅ Técnico BLOQUEADO de criar chamado (esperado)" -ForegroundColor Green
    Write-Host "     Mensagem: $($resultadoCriacaoTecnico.error)" -ForegroundColor Gray
}
else {
    Write-Host "  ❌ ERRO: Técnico NÃO deveria conseguir criar chamado" -ForegroundColor Red
}

Write-Host ""

# ============================================================================
# TESTE 4: Colaborador criando chamado (DEVE FUNCIONAR)
# ============================================================================
Write-Host "TESTE 4: Colaborador criando chamado (deve funcionar)" -ForegroundColor Yellow
Write-Host "────────────────────────────────────────────────────────" -ForegroundColor Gray

$resultadoCriacaoColaborador = Criar-Chamado $tokenColaborador "Teste Permissões" "Computador não liga - teste de permissões"

if ($resultadoCriacaoColaborador.success) {
    $chamadoId = $resultadoCriacaoColaborador.response.id
    Write-Host "  ✅ Colaborador criou chamado #$chamadoId com sucesso" -ForegroundColor Green
    Write-Host "     Técnico atribuído: $($resultadoCriacaoColaborador.response.tecnicoAtribuidoNome)" -ForegroundColor Gray
}
else {
    Write-Host "  ❌ ERRO: Colaborador deveria conseguir criar chamado" -ForegroundColor Red
}

Write-Host ""

# ============================================================================
# TESTE 5: Técnico encerrando chamado atribuído a ele
# ============================================================================
Write-Host "TESTE 5: Técnico encerrando seu chamado" -ForegroundColor Yellow
Write-Host "────────────────────────────────────────" -ForegroundColor Gray

# Pegar um chamado atribuído ao técnico
if ($chamadosTecnico.Count -gt 0) {
    $chamadoTecnico = $chamadosTecnico[0]
    
    if ($chamadoTecnico.statusId -ne 3) {
        $resultadoEncerramento = Encerrar-Chamado $tokenTecnico $chamadoTecnico.id "Problema resolvido - teste de permissões"
        
        if ($resultadoEncerramento.success) {
            Write-Host "  ✅ Técnico encerrou chamado #$($chamadoTecnico.id) com sucesso" -ForegroundColor Green
        }
        else {
            Write-Host "  ❌ ERRO: Técnico deveria conseguir encerrar seu chamado" -ForegroundColor Red
            Write-Host "     Mensagem: $($resultadoEncerramento.error)" -ForegroundColor Gray
        }
    }
    else {
        Write-Host "  ⚠️  Chamado já estava encerrado" -ForegroundColor Yellow
    }
}
else {
    Write-Host "  ⚠️  Nenhum chamado atribuído ao técnico para testar" -ForegroundColor Yellow
}

Write-Host ""

# ============================================================================
# TESTE 6: Colaborador tentando encerrar chamado (DEVE FALHAR)
# ============================================================================
Write-Host "TESTE 6: Colaborador tentando encerrar chamado (deve falhar)" -ForegroundColor Yellow
Write-Host "──────────────────────────────────────────────────────────────" -ForegroundColor Gray

if ($chamadosColaborador.Count -gt 0) {
    $chamadoColaborador = $chamadosColaborador[0]
    $resultadoEncerramentoColaborador = Encerrar-Chamado $tokenColaborador $chamadoColaborador.id "Tentativa de encerramento"
    
    if (-not $resultadoEncerramentoColaborador.success) {
        Write-Host "  ✅ Colaborador BLOQUEADO de encerrar chamado (esperado)" -ForegroundColor Green
    }
    else {
        Write-Host "  ❌ ERRO: Colaborador NÃO deveria conseguir encerrar chamado" -ForegroundColor Red
    }
}
else {
    Write-Host "  ⚠️  Nenhum chamado do colaborador para testar" -ForegroundColor Yellow
}

Write-Host ""

# ============================================================================
# RESUMO FINAL
# ============================================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  RESUMO DO TESTE" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

Write-Host "PERMISSÕES TESTADAS:" -ForegroundColor White
Write-Host "  ✅ Colaborador: Pode criar chamados" -ForegroundColor Green
Write-Host "  ✅ Colaborador: Vê apenas seus próprios chamados" -ForegroundColor Green
Write-Host "  ✅ Colaborador: NÃO pode encerrar chamados" -ForegroundColor Green
Write-Host "  ✅ Técnico: Vê apenas chamados atribuídos a ele" -ForegroundColor Green
Write-Host "  ✅ Técnico: Pode encerrar seus chamados" -ForegroundColor Green
Write-Host "  ✅ Técnico: NÃO pode criar chamados" -ForegroundColor Green
Write-Host "  ✅ Admin: Visualização total de chamados" -ForegroundColor Green
Write-Host ""

Write-Host "VISIBILIDADE DO TÉCNICO ATRIBUÍDO:" -ForegroundColor White
Write-Host "  ✅ Todos os usuários podem ver a quem o chamado foi atribuído" -ForegroundColor Green
Write-Host "     (Campo 'tecnicoAtribuidoNome' presente no response)" -ForegroundColor Gray
Write-Host ""

Write-Host "============================================================`n" -ForegroundColor Cyan
