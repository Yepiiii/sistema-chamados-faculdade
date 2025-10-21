# Script para criar 3 chamados para cada usuario usando IA
# Envia APENAS a descricao - a IA gera tudo automaticamente

$baseUrl = "http://localhost:5246/api"

function Get-Token {
    param([string]$Email, [string]$Senha)
    
    $body = @{ email = $Email; senha = $Senha } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/usuarios/login" -Method Post -Body $body -ContentType "application/json"
        return $response.token
    } catch {
        Write-Host "Erro ao fazer login: $_" -ForegroundColor Red
        return $null
    }
}

function New-ChamadoComIA {
    param(
        [string]$Token,
        [string]$Descricao
    )
    
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type" = "application/json"
    }
    
    # Apenas a descricao - a IA faz o resto
    $body = @{
        descricao = $Descricao
    } | ConvertTo-Json
    
    try {
        $result = Invoke-RestMethod -Uri "$baseUrl/chamados" -Method Post -Headers $headers -Body $body
        Write-Host "Criado ID $($result.id): $($result.titulo)" -ForegroundColor Green
        Write-Host "   $($result.categoria.nome) | $($result.prioridade.nome)" -ForegroundColor Gray
        return $result
    } catch {
        Write-Host "Erro ao criar chamado: $_" -ForegroundColor Red
        if ($_.ErrorDetails) {
            Write-Host "   $($_.ErrorDetails.Message)" -ForegroundColor Yellow
        }
        return $null
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CRIANDO CHAMADOS COM ANALISE POR IA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ALUNO - Joao Silva
Write-Host "[1/3] ALUNO - Joao Silva" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray
Write-Host ""
$tokenAluno = Get-Token -Email "aluno@sistema.com" -Senha "Aluno@123"

if ($tokenAluno) {
    New-ChamadoComIA -Token $tokenAluno -Descricao "O computador da sala 201 esta extremamente lento. Demora varios minutos para abrir programas."
    Start-Sleep -Seconds 2
    
    New-ChamadoComIA -Token $tokenAluno -Descricao "A impressora da biblioteca nao esta funcionando. Preciso imprimir trabalhos urgentes."
    Start-Sleep -Seconds 2
    
    New-ChamadoComIA -Token $tokenAluno -Descricao "O WiFi do laboratorio 3 nao esta funcionando. Nao consigo acessar a internet."
}

# PROFESSOR - Maria Santos
Write-Host ""
Write-Host "[2/3] PROFESSOR - Maria Santos" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray
Write-Host ""
$tokenProfessor = Get-Token -Email "professor@sistema.com" -Senha "Prof@123"

if ($tokenProfessor) {
    New-ChamadoComIA -Token $tokenProfessor -Descricao "O projetor da sala 305 liga mas nao exibe imagem. Preciso para aula de amanha."
    Start-Sleep -Seconds 2
    
    New-ChamadoComIA -Token $tokenProfessor -Descricao "Preciso do MATLAB instalado nos computadores do laboratorio 2 para aulas de calculo numerico."
    Start-Sleep -Seconds 2
    
    New-ChamadoComIA -Token $tokenProfessor -Descricao "Preciso recuperar arquivos do servidor que foram apagados acidentalmente ontem."
}

# ADMIN - Administrador
Write-Host ""
Write-Host "[3/3] ADMIN - Administrador" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray
Write-Host ""
$tokenAdmin = Get-Token -Email "admin@sistema.com" -Senha "Admin@123"

if ($tokenAdmin) {
    New-ChamadoComIA -Token $tokenAdmin -Descricao "Realizar backup completo do servidor principal antes da atualizacao do sistema."
    Start-Sleep -Seconds 2
    
    New-ChamadoComIA -Token $tokenAdmin -Descricao "Agendar manutencao preventiva de todos os computadores dos laboratorios."
    Start-Sleep -Seconds 2
    
    New-ChamadoComIA -Token $tokenAdmin -Descricao "Instalar PyCharm Professional em todos os computadores dos laboratorios de programacao."
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PROCESSO CONCLUIDO!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
