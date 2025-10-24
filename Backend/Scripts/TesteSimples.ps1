# Script simples para testar atribuição inteligente
$baseUrl = "http://localhost:5246/api"

Write-Host "`n=== TESTE: ATRIBUICAO INTELIGENTE ===" -ForegroundColor Cyan

# Login
Write-Host "`n[1/4] Login..." -ForegroundColor Yellow
$loginBody = @{ email = "colaborador@empresa.com"; senha = "Admin@123" } | ConvertTo-Json
$loginResponse = Invoke-RestMethod -Uri "$baseUrl/usuarios/login" -Method Post -Body $loginBody -ContentType "application/json"
$token = $loginResponse.token
Write-Host "OK - Token: $($token.Substring(0,15))..." -ForegroundColor Green

# Criar chamado
Write-Host "`n[2/4] Criar chamado com IA..." -ForegroundColor Yellow
$chamadoBody = @{
    titulo = "Teste Atribuicao - Problema Wi-Fi"
    descricao = "Rede Wi-Fi lenta e instavel. Preciso conectar urgente no Teams para reuniao."
    usarAnaliseAutomatica = $true
} | ConvertTo-Json

$headers = @{ Authorization = "Bearer $token" }
$chamado = Invoke-RestMethod -Uri "$baseUrl/chamados" -Method Post -Body $chamadoBody -ContentType "application/json" -Headers $headers
Write-Host "OK - Chamado #$($chamado.id) criado" -ForegroundColor Green
Write-Host "  Categoria: $($chamado.categoriaNome)" -ForegroundColor Gray
Write-Host "  Prioridade: $($chamado.prioridadeNome)" -ForegroundColor Gray
Write-Host "  Tecnico: $($chamado.tecnicoAtribuidoNome)" -ForegroundColor Gray

# Histórico
Write-Host "`n[3/4] Historico de atribuicoes..." -ForegroundColor Yellow
$atrib = Invoke-RestMethod -Uri "$baseUrl/chamados/$($chamado.id)/atribuicoes" -Method Get -Headers $headers
Write-Host "OK - $($atrib.totalAtribuicoes) atribuicao(oes) encontrada(s)" -ForegroundColor Green
if ($atrib.atribuicoes.Count -gt 0) {
    $a = $atrib.atribuicoes[0]
    Write-Host "  Tecnico: $($a.tecnicoNome)" -ForegroundColor White
    Write-Host "  Score: $([math]::Round($a.score, 2))" -ForegroundColor White
    Write-Host "  Motivo: $($a.motivoSelecao)" -ForegroundColor White
    Write-Host "  Carga: $($a.cargaTrabalho) chamados" -ForegroundColor White
}

# Distribuição (Admin)
Write-Host "`n[4/4] Distribuicao de carga (Admin)..." -ForegroundColor Yellow
$adminLogin = @{ email = "admin@sistema.com"; senha = "Admin@123" } | ConvertTo-Json
$adminToken = (Invoke-RestMethod -Uri "$baseUrl/usuarios/login" -Method Post -Body $adminLogin -ContentType "application/json").token
$adminHeaders = @{ Authorization = "Bearer $adminToken" }
$dist = Invoke-RestMethod -Uri "$baseUrl/chamados/metricas/distribuicao" -Method Get -Headers $adminHeaders
Write-Host "OK - $($dist.totalTecnicos) tecnicos, $($dist.cargaTotal) chamados totais" -ForegroundColor Green
foreach ($t in $dist.tecnicos) {
    $barra = "#" * $t.chamadosAtivos
    Write-Host "  $($t.tecnicoNome): $barra $($t.chamadosAtivos)/10" -ForegroundColor White
}

Write-Host "`n=== TESTE CONCLUIDO COM SUCESSO ===" -ForegroundColor Green
Write-Host "Verifique os logs da API para detalhes do algoritmo`n" -ForegroundColor Cyan
