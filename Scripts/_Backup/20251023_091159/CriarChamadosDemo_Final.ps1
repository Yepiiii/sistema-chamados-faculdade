# ========================================
# Criar 3 Chamados para Cada Usuario
# ========================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Criar Chamados de Demonstracao" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:5246/api"

# Funcao para fazer login e obter token
function Get-Token {
    param($email, $senha)
    
    $body = @{
        email = $email
        senha = $senha
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/usuarios/login" -Method Post -Body $body -ContentType "application/json"
        return $response.token
    } catch {
        Write-Host "[ERRO] Login falhou para $email" -ForegroundColor Red
        return $null
    }
}

# Funcao para criar chamado
function New-Chamado {
    param($token, $titulo, $descricao, $categoriaId, $prioridadeId)
    
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    $body = @{
        titulo = $titulo
        descricao = $descricao
        categoriaId = $categoriaId
        prioridadeId = $prioridadeId
        usarAnaliseAutomatica = $false
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/chamados" -Method Post -Headers $headers -Body $body
        Write-Host "  [OK] Criado: $titulo" -ForegroundColor Green
        return $response
    } catch {
        Write-Host "  [ERRO] Falha ao criar: $titulo" -ForegroundColor Red
        Write-Host "  Detalhes: $_" -ForegroundColor DarkRed
        return $null
    }
}

# Obter IDs de categorias e prioridades
Write-Host "[1/4] Obtendo categorias e prioridades..." -ForegroundColor Yellow

try {
    $categorias = Invoke-RestMethod -Uri "$baseUrl/categorias" -Method Get
    $prioridades = Invoke-RestMethod -Uri "$baseUrl/prioridades" -Method Get
    
    $catHardware = ($categorias | Where-Object { $_.nome -eq "Hardware" }).id
    $catSoftware = ($categorias | Where-Object { $_.nome -eq "Software" }).id
    $catRede = ($categorias | Where-Object { $_.nome -eq "Rede" }).id
    
    $prioAlta = ($prioridades | Where-Object { $_.nome -eq "Alta" }).id
    $prioMedia = ($prioridades | Where-Object { $_.nome -eq "Media" }).id
    $prioBaixa = ($prioridades | Where-Object { $_.nome -eq "Baixa" }).id
    
    Write-Host "[OK] Categorias e prioridades obtidas" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "[ERRO] Falha ao obter categorias/prioridades: $_" -ForegroundColor Red
    exit 1
}

# ==========================================
# ALUNO - 3 chamados
# ==========================================

Write-Host "[2/4] Criando chamados do ALUNO..." -ForegroundColor Yellow

$tokenAluno = Get-Token -email "aluno@sistema.com" -senha "Aluno@123"

if ($tokenAluno) {
    New-Chamado -token $tokenAluno `
        -titulo "Computador do laboratorio muito lento" `
        -descricao "O computador da sala 201 esta extremamente lento. Demora varios minutos para abrir programas e o sistema trava com frequencia. Preciso usar para fazer trabalhos da faculdade." `
        -categoriaId $catHardware `
        -prioridadeId $prioMedia
    
    New-Chamado -token $tokenAluno `
        -titulo "Visual Studio nao abre projetos .NET" `
        -descricao "O Visual Studio 2022 instalado no laboratorio nao consegue abrir projetos .NET. Aparece um erro de dependencias faltando. Tentei reinstalar mas o problema persiste." `
        -categoriaId $catSoftware `
        -prioridadeId $prioAlta
    
    New-Chamado -token $tokenAluno `
        -titulo "Wi-Fi da biblioteca com conexao intermitente" `
        -descricao "O sinal Wi-Fi na biblioteca fica caindo constantemente. Impossivel assistir aulas online ou fazer downloads de materiais. O problema acontece principalmente no 2o andar." `
        -categoriaId $catRede `
        -prioridadeId $prioMedia
    
    Write-Host ""
}

# ==========================================
# PROFESSOR - 3 chamados
# ==========================================

Write-Host "[3/4] Criando chamados do PROFESSOR..." -ForegroundColor Yellow

$tokenProf = Get-Token -email "professor@sistema.com" -senha "Prof@123"

if ($tokenProf) {
    New-Chamado -token $tokenProf `
        -titulo "Projetor da sala 105 nao liga" `
        -descricao "O projetor da sala 105 nao esta ligando. Ja verifiquei os cabos e o controle remoto. Tenho aula em 2 horas e preciso usar apresentacoes. URGENTE!" `
        -categoriaId $catHardware `
        -prioridadeId $prioAlta
    
    New-Chamado -token $tokenProf `
        -titulo "Solicitar atualizacao do Microsoft Office" `
        -descricao "O pacote Office dos computadores do laboratorio esta desatualizado (versao 2019). Varios recursos novos que preciso mostrar aos alunos nao estao disponiveis. Gostaria de solicitar atualizacao para a versao mais recente." `
        -categoriaId $catSoftware `
        -prioridadeId $prioBaixa
    
    New-Chamado -token $tokenProf `
        -titulo "Internet lenta impede uso de plataforma online" `
        -descricao "A velocidade da internet na sala 302 esta muito baixa (menos de 1 Mbps). Nao consigo acessar a plataforma de ensino para passar videos e materiais aos alunos. Isso tem atrapalhado todas as minhas aulas." `
        -categoriaId $catRede `
        -prioridadeId $prioAlta
    
    Write-Host ""
}

# ==========================================
# ADMIN - 3 chamados
# ==========================================

Write-Host "[4/4] Criando chamados do ADMIN..." -ForegroundColor Yellow

$tokenAdmin = Get-Token -email "admin@sistema.com" -senha "Admin@123"

if ($tokenAdmin) {
    New-Chamado -token $tokenAdmin `
        -titulo "Realizar backup completo do servidor principal" `
        -descricao "Agendar e executar backup completo do servidor de arquivos da faculdade. Backup trimestral obrigatorio conforme politica de seguranca. Inclui todos os documentos, banco de dados e configuracoes." `
        -categoriaId $catRede `
        -prioridadeId $prioAlta
    
    New-Chamado -token $tokenAdmin `
        -titulo "Agendar manutencao preventiva dos computadores" `
        -descricao "Planejar manutencao preventiva trimestral de todos os computadores dos laboratorios: limpeza fisica, atualizacoes de sistema operacional, verificacao de hardware, substituicao de componentes desgastados." `
        -categoriaId $catHardware `
        -prioridadeId $prioBaixa
    
    New-Chamado -token $tokenAdmin `
        -titulo "Instalar IDE PyCharm nos laboratorios" `
        -descricao "Instalar PyCharm Community Edition nos computadores dos laboratorios 201, 301 e 401 para as aulas de Python do proximo semestre. Aproximadamente 60 computadores no total." `
        -categoriaId $catSoftware `
        -prioridadeId $prioMedia
    
    Write-Host ""
}

# Resultado final
Write-Host "========================================" -ForegroundColor Green
Write-Host "  CHAMADOS CRIADOS COM SUCESSO!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Total de chamados criados: 9" -ForegroundColor Cyan
Write-Host ""
Write-Host "Distribuicao:" -ForegroundColor White
Write-Host "  Aluno: 3 chamados" -ForegroundColor Cyan
Write-Host "    - Computador lento (Media)" -ForegroundColor Gray
Write-Host "    - Visual Studio com erro (Alta)" -ForegroundColor Gray
Write-Host "    - Wi-Fi intermitente (Media)" -ForegroundColor Gray
Write-Host ""
Write-Host "  Professor: 3 chamados" -ForegroundColor Cyan
Write-Host "    - Projetor nao liga (Alta - URGENTE)" -ForegroundColor Gray
Write-Host "    - Atualizacao Office (Baixa)" -ForegroundColor Gray
Write-Host "    - Internet lenta (Alta)" -ForegroundColor Gray
Write-Host ""
Write-Host "  Admin: 3 chamados" -ForegroundColor Cyan
Write-Host "    - Backup servidor (Alta)" -ForegroundColor Gray
Write-Host "    - Manutencao preventiva (Baixa)" -ForegroundColor Gray
Write-Host "    - Instalar PyCharm (Media)" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Teste o sistema agora com chamados realistas!" -ForegroundColor Green
Write-Host ""
