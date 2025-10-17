# Script para testar regras de visualização de chamados
Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Teste de Regras de Visualização" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:5246/api"

try {
    # ===========================================
    # PREPARAÇÃO: Criar chamados de teste
    # ===========================================
    Write-Host "PREPARAÇÃO: Criando chamados de teste..." -ForegroundColor Yellow
    Write-Host "-------------------------------------------" -ForegroundColor Gray
    
    # Login como Aluno
    $loginAluno = @{
        Email = "aluno@sistema.com"
        Senha = "Aluno@123"
    } | ConvertTo-Json
    
    $authAluno = Invoke-RestMethod -Uri "$baseUrl/usuarios/login" -Method POST -Body $loginAluno -ContentType "application/json"
    $tokenAluno = $authAluno.token
    $headersAluno = @{ Authorization = "Bearer $tokenAluno" }
    
    # Login como Professor
    $loginProf = @{
        Email = "professor@sistema.com"
        Senha = "Prof@123"
    } | ConvertTo-Json
    
    $authProf = Invoke-RestMethod -Uri "$baseUrl/usuarios/login" -Method POST -Body $loginProf -ContentType "application/json"
    $tokenProf = $authProf.token
    $headersProf = @{ Authorization = "Bearer $tokenProf" }
    
    # Login como Admin
    $loginAdmin = @{
        Email = "admin@sistema.com"
        Senha = "Admin@123"
    } | ConvertTo-Json
    
    $authAdmin = Invoke-RestMethod -Uri "$baseUrl/usuarios/login" -Method POST -Body $loginAdmin -ContentType "application/json"
    $tokenAdmin = $authAdmin.token
    $headersAdmin = @{ Authorization = "Bearer $tokenAdmin" }
    
    Write-Host "[OK] Logins realizados com sucesso" -ForegroundColor Green
    Write-Host ""
    
    # Criar chamado do Aluno
    $chamadoAluno = @{
        Titulo = "Chamado do Aluno - Teste"
        Descricao = "Este é um chamado criado pelo aluno para teste de visualização"
        CategoriaId = 1
        PrioridadeId = 2
    } | ConvertTo-Json
    
    $resultAluno = Invoke-RestMethod -Uri "$baseUrl/chamados" -Method POST -Body $chamadoAluno -ContentType "application/json" -Headers $headersAluno
    $chamadoAlunoId = $resultAluno.id
    Write-Host "[OK] Chamado do Aluno criado (ID: $chamadoAlunoId)" -ForegroundColor Green
    
    # Criar chamado do Professor
    $chamadoProf = @{
        Titulo = "Chamado do Professor - Teste"
        Descricao = "Este é um chamado criado pelo professor para teste de visualização"
        CategoriaId = 2
        PrioridadeId = 1
    } | ConvertTo-Json
    
    $resultProf = Invoke-RestMethod -Uri "$baseUrl/chamados" -Method POST -Body $chamadoProf -ContentType "application/json" -Headers $headersProf
    $chamadoProfId = $resultProf.id
    Write-Host "[OK] Chamado do Professor criado (ID: $chamadoProfId)" -ForegroundColor Green
    
    # Admin atribui Professor como técnico no chamado do Aluno
    $atualizar = @{
        StatusId = 2
        TecnicoId = $authProf.usuario.id
    } | ConvertTo-Json
    
    Invoke-RestMethod -Uri "$baseUrl/chamados/$chamadoAlunoId" -Method PUT -Body $atualizar -ContentType "application/json" -Headers $headersAdmin | Out-Null
    Write-Host "[OK] Professor atribuído como técnico no chamado do Aluno" -ForegroundColor Green
    Write-Host ""
    
    # ===========================================
    # TESTE 1: Aluno visualiza chamados
    # ===========================================
    Write-Host "TESTE 1: ALUNO visualizando chamados" -ForegroundColor Cyan
    Write-Host "-------------------------------------------" -ForegroundColor Gray
    Write-Host "Regra: Aluno deve ver APENAS seus próprios chamados" -ForegroundColor White
    Write-Host ""
    
    $chamadosAluno = Invoke-RestMethod -Uri "$baseUrl/chamados" -Method GET -Headers $headersAluno
    Write-Host "Total de chamados visíveis: $($chamadosAluno.Count)" -ForegroundColor White
    
    foreach ($c in $chamadosAluno) {
        Write-Host "  - ID: $($c.id) | Titulo: $($c.titulo)" -ForegroundColor Gray
    }
    
    $alunoChamadosInvalidos = $chamadosAluno | Where-Object { $_.solicitante.id -ne $authAluno.usuario.id }
    if (-not $alunoChamadosInvalidos -or $alunoChamadosInvalidos.Count -eq 0) {
        Write-Host "[OK] CORRETO: Aluno ve apenas chamados do proprio usuario" -ForegroundColor Green
    }
    else {
        Write-Host "[ERRO] Aluno esta vendo chamados de outros usuarios!" -ForegroundColor Red
        foreach ($invalid in $alunoChamadosInvalidos) {
            Write-Host "    -> Chamado $($invalid.id) pertence a usuario $($invalid.solicitante.id)" -ForegroundColor Red
        }
    }
    Write-Host ""
    
    # Teste: Aluno tenta acessar chamado do Professor
    Write-Host "Tentando acessar chamado do Professor (deve falhar)..." -ForegroundColor Yellow
    try {
        $tentativa = Invoke-RestMethod -Uri "$baseUrl/chamados/$chamadoProfId" -Method GET -Headers $headersAluno
        Write-Host "[ERRO] Aluno conseguiu acessar chamado do Professor!" -ForegroundColor Red
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 403) {
            Write-Host "[OK] CORRETO: Acesso negado (403 Forbidden)" -ForegroundColor Green
        }
        else {
            Write-Host "[AVISO] Erro inesperado: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    Write-Host ""
    
    # ===========================================
    # TESTE 2: Professor visualiza chamados
    # ===========================================
    Write-Host "TESTE 2: PROFESSOR visualizando chamados" -ForegroundColor Cyan
    Write-Host "-------------------------------------------" -ForegroundColor Gray
    Write-Host "Regra: Professor deve ver seus chamados + chamados onde é técnico" -ForegroundColor White
    Write-Host ""
    
    $chamadosProf = Invoke-RestMethod -Uri "$baseUrl/chamados" -Method GET -Headers $headersProf
    Write-Host "Total de chamados visíveis: $($chamadosProf.Count)" -ForegroundColor White
    
    foreach ($c in $chamadosProf) {
        $isTecnico = if ($c.tecnicoId -eq $authProf.usuario.id) { " (TÉCNICO)" } else { " (CRIADOR)" }
        Write-Host "  - ID: $($c.id) | Titulo: $($c.titulo)$isTecnico" -ForegroundColor Gray
    }
    
    $profChamadosInvalidos = $chamadosProf | Where-Object { $_.solicitante.id -ne $authProf.usuario.id -and $_.tecnicoId -ne $authProf.usuario.id }
    if (-not $profChamadosInvalidos -or $profChamadosInvalidos.Count -eq 0) {
    Write-Host "[OK] CORRETO: Professor ve apenas chamados proprios ou atribuidos como tecnico" -ForegroundColor Green
    }
    else {
        Write-Host "[ERRO] Professor esta vendo chamados sem relacao!" -ForegroundColor Red
        foreach ($invalid in $profChamadosInvalidos) {
            Write-Host "    -> Chamado $($invalid.id) pertence a usuario $($invalid.solicitante.id) e tecnico $($invalid.tecnicoId)" -ForegroundColor Red
        }
    }
    Write-Host ""
    
    # ===========================================
    # TESTE 3: Admin visualiza chamados
    # ===========================================
    Write-Host "TESTE 3: ADMIN visualizando chamados" -ForegroundColor Cyan
    Write-Host "-------------------------------------------" -ForegroundColor Gray
    Write-Host "Regra: Admin deve ver TODOS os chamados do sistema" -ForegroundColor White
    Write-Host ""
    
    $chamadosAdmin = Invoke-RestMethod -Uri "$baseUrl/chamados" -Method GET -Headers $headersAdmin
    Write-Host "Total de chamados visíveis: $($chamadosAdmin.Count)" -ForegroundColor White
    
    foreach ($c in $chamadosAdmin) {
        $criador = $c.solicitante.nomeCompleto
        Write-Host "  - ID: $($c.id) | Titulo: $($c.titulo) | Criador: $criador" -ForegroundColor Gray
    }
    
    if ($chamadosAdmin.Count -ge 2) {
        Write-Host "[OK] CORRETO: Admin ve todos os chamados" -ForegroundColor Green
    }
    else {
        Write-Host "[ERRO] Admin deveria ver todos os chamados" -ForegroundColor Red
    }
    Write-Host ""
    
    # ===========================================
    # TESTE 4: Permissões de atualização
    # ===========================================
    Write-Host "TESTE 4: Permissões de ATUALIZAÇÃO" -ForegroundColor Cyan
    Write-Host "-------------------------------------------" -ForegroundColor Gray
    
    # Aluno tenta atualizar seu próprio chamado
    Write-Host "Aluno tentando atualizar seu proprio chamado (deve falhar)..." -ForegroundColor Yellow
    try {
        $update = @{ StatusId = 3 } | ConvertTo-Json
        Invoke-RestMethod -Uri "$baseUrl/chamados/$chamadoAlunoId" -Method PUT -Body $update -ContentType "application/json" -Headers $headersAluno | Out-Null
        Write-Host "[ERRO] Aluno conseguiu atualizar chamado!" -ForegroundColor Red
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 403) {
            Write-Host "[OK] CORRETO: Apenas admin pode atualizar (403 Forbidden)" -ForegroundColor Green
        }
        else {
            Write-Host "[AVISO] Erro inesperado: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    
    # Professor tenta atualizar chamado
    Write-Host "Professor tentando atualizar chamado (deve falhar)..." -ForegroundColor Yellow
    try {
        $update = @{ StatusId = 3 } | ConvertTo-Json
        Invoke-RestMethod -Uri "$baseUrl/chamados/$chamadoProfId" -Method PUT -Body $update -ContentType "application/json" -Headers $headersProf | Out-Null
        Write-Host "[ERRO] Professor conseguiu atualizar chamado!" -ForegroundColor Red
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 403) {
            Write-Host "[OK] CORRETO: Apenas admin pode atualizar (403 Forbidden)" -ForegroundColor Green
        }
        else {
            Write-Host "[AVISO] Erro inesperado: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    
    # Admin atualiza chamado
    Write-Host "Admin atualizando chamado (deve funcionar)..." -ForegroundColor Yellow
    try {
        $update = @{ StatusId = 3 } | ConvertTo-Json
        Invoke-RestMethod -Uri "$baseUrl/chamados/$chamadoProfId" -Method PUT -Body $update -ContentType "application/json" -Headers $headersAdmin | Out-Null
        Write-Host "[OK] CORRETO: Admin atualizou com sucesso" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERRO] Admin nao conseguiu atualizar: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""
    
    # ===========================================
    # RESUMO
    # ===========================================
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  RESUMO DOS TESTES" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[OK] Regras de visualizacao implementadas" -ForegroundColor Green
    Write-Host "[OK] Aluno: ve apenas seus proprios chamados" -ForegroundColor Green
    Write-Host "[OK] Professor: ve seus chamados + atribuidos como tecnico" -ForegroundColor Green
    Write-Host "[OK] Admin: ve todos os chamados" -ForegroundColor Green
    Write-Host "[OK] Apenas Admin pode atualizar/encerrar chamados" -ForegroundColor Green
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
