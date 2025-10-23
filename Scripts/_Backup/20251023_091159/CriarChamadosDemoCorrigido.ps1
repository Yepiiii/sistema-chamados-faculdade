# Script para criar 3 chamados de demonstração para cada usuário
# Corrigido: usa usarAnaliseAutomatica=true para Aluno e Professor

$baseUrl = "http://localhost:5246/api"

# Função para obter token de autenticação
function Get-Token {
    param([string]$Email, [string]$Senha)
    
    $body = @{
        email = $Email
        senha = $Senha
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/usuarios/login" -Method Post -Body $body -ContentType "application/json"
        return $response.token
    } catch {
        Write-Host "Erro ao fazer login com $Email : $_" -ForegroundColor Red
        return $null
    }
}

# Função para criar chamado
function New-Chamado {
    param(
        [string]$Token,
        [string]$Titulo,
        [string]$Descricao,
        [int]$CategoriaId,
        [int]$PrioridadeId,
        [bool]$UsarIA = $true
    )
    
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type" = "application/json"
    }
    
    $body = @{
        titulo = $Titulo
        descricao = $Descricao
        usarAnaliseAutomatica = $UsarIA
    }
    
    # Se NÃO usar IA (apenas Admin pode), adicionar categoria e prioridade
    if (-not $UsarIA) {
        $body.categoriaId = $CategoriaId
        $body.prioridadeId = $PrioridadeId
    }
    
    $bodyJson = $body | ConvertTo-Json
    
    try {
        $result = Invoke-RestMethod -Uri "$baseUrl/chamados" -Method Post -Headers $headers -Body $bodyJson
        Write-Host "✅ Criado: ID $($result.id) - $($result.titulo)" -ForegroundColor Green
        return $result
    } catch {
        Write-Host "❌ Erro ao criar chamado '$Titulo': $_" -ForegroundColor Red
        if ($_.ErrorDetails) {
            Write-Host "   Detalhes: $($_.ErrorDetails.Message)" -ForegroundColor Yellow
        }
        return $null
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   CRIANDO CHAMADOS DE DEMONSTRAÇÃO" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# ============================================
# ALUNO - João Silva (usa IA)
# ============================================
Write-Host "`n[1/3] CRIANDO CHAMADOS DO ALUNO..." -ForegroundColor Yellow
$tokenAluno = Get-Token -Email "aluno@sistema.com" -Senha "Aluno@123"

if ($tokenAluno) {
    Write-Host "Token obtido com sucesso!" -ForegroundColor Gray
    
    New-Chamado -Token $tokenAluno `
        -Titulo "Computador do laboratório muito lento" `
        -Descricao "O computador da sala 201 está extremamente lento. Demora vários minutos para abrir programas." `
        -UsarIA $true
    
    Start-Sleep -Seconds 1
    
    New-Chamado -Token $tokenAluno `
        -Titulo "Não consigo imprimir" `
        -Descricao "A impressora da biblioteca não está funcionando. Preciso imprimir trabalhos urgentes." `
        -UsarIA $true
    
    Start-Sleep -Seconds 1
    
    New-Chamado -Token $tokenAluno `
        -Titulo "WiFi não conecta no laboratório 3" `
        -Descricao "O WiFi do laboratório 3 não está funcionando. Não consigo acessar a internet." `
        -UsarIA $true
}

# ============================================
# PROFESSOR - Maria Santos (usa IA)
# ============================================
Write-Host "`n[2/3] CRIANDO CHAMADOS DO PROFESSOR..." -ForegroundColor Yellow
$tokenProfessor = Get-Token -Email "professor@sistema.com" -Senha "Prof@123"

if ($tokenProfessor) {
    Write-Host "Token obtido com sucesso!" -ForegroundColor Gray
    
    New-Chamado -Token $tokenProfessor `
        -Titulo "Projetor da sala 305 sem imagem" `
        -Descricao "O projetor da sala 305 liga mas não exibe imagem. Preciso para aula de amanhã." `
        -UsarIA $true
    
    Start-Sleep -Seconds 1
    
    New-Chamado -Token $tokenProfessor `
        -Titulo "Instalar MATLAB nos computadores" `
        -Descricao "Preciso do MATLAB instalado nos computadores do laboratório 2 para aulas de cálculo numérico." `
        -UsarIA $true
    
    Start-Sleep -Seconds 1
    
    New-Chamado -Token $tokenProfessor `
        -Titulo "Backup de arquivos do servidor" `
        -Descricao "Preciso recuperar arquivos do servidor que foram apagados acidentalmente ontem." `
        -UsarIA $true
}

# ============================================
# ADMIN - Administrador (classificação manual)
# ============================================
Write-Host "`n[3/3] CRIANDO CHAMADOS DO ADMIN..." -ForegroundColor Yellow
$tokenAdmin = Get-Token -Email "admin@sistema.com" -Senha "Admin@123"

if ($tokenAdmin) {
    Write-Host "Token obtido com sucesso!" -ForegroundColor Gray
    
    New-Chamado -Token $tokenAdmin `
        -Titulo "Realizar backup completo do servidor principal" `
        -Descricao "Realizar backup completo do servidor principal antes da atualização do sistema." `
        -CategoriaId 3 `
        -PrioridadeId 3 `
        -UsarIA $false
    
    Start-Sleep -Seconds 1
    
    New-Chamado -Token $tokenAdmin `
        -Titulo "Agendar manutenção preventiva dos computadores" `
        -Descricao "Agendar manutenção preventiva de todos os computadores dos laboratórios." `
        -CategoriaId 1 `
        -PrioridadeId 1 `
        -UsarIA $false
    
    Start-Sleep -Seconds 1
    
    New-Chamado -Token $tokenAdmin `
        -Titulo "Instalar PyCharm nos laboratórios" `
        -Descricao "Instalar PyCharm Professional em todos os computadores dos laboratórios de programação." `
        -CategoriaId 2 `
        -PrioridadeId 2 `
        -UsarIA $false
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   PROCESSO CONCLUÍDO!" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan
