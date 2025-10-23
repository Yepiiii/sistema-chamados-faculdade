# ==============================================================================
# Script: ConfigurarFirewall.ps1
# Descricao: Configura o Firewall do Windows para permitir acesso a API
# Autor: Sistema
# Data: 23/10/2025
# IMPORTANTE: Execute como Administrador
# ==============================================================================

# Verificar se esta rodando como Administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "==================================================================" -ForegroundColor Red
    Write-Host "    ERRO: Este script precisa ser executado como Administrador!" -ForegroundColor Red
    Write-Host "==================================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Clique com botao direito no PowerShell e escolha:" -ForegroundColor Yellow
    Write-Host "'Executar como Administrador'" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Depois execute novamente:" -ForegroundColor White
    Write-Host ".\ConfigurarFirewall.ps1" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    CONFIGURADOR DE FIREWALL - Sistema de Chamados" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# Remover regra antiga se existir
Write-Host "[*] Removendo regras antigas (se existirem)..." -ForegroundColor Yellow
try {
    netsh advfirewall firewall delete rule name="Sistema Chamados API" | Out-Null
    Write-Host "[OK] Regras antigas removidas" -ForegroundColor Green
} catch {
    Write-Host "[*] Nenhuma regra antiga encontrada" -ForegroundColor Gray
}

Write-Host ""

# Adicionar nova regra - Entrada (Inbound)
Write-Host "[*] Adicionando regra de entrada (Inbound) na porta 5246..." -ForegroundColor Yellow
netsh advfirewall firewall add rule name="Sistema Chamados API" dir=in action=allow protocol=TCP localport=5246

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Regra de entrada adicionada com sucesso!" -ForegroundColor Green
} else {
    Write-Host "[X] ERRO ao adicionar regra de entrada" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Adicionar regra de saida (Outbound) tambem
Write-Host "[*] Adicionando regra de saida (Outbound) na porta 5246..." -ForegroundColor Yellow
netsh advfirewall firewall add rule name="Sistema Chamados API (Saida)" dir=out action=allow protocol=TCP localport=5246

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Regra de saida adicionada com sucesso!" -ForegroundColor Green
} else {
    Write-Host "[!] Aviso: Falha ao adicionar regra de saida (nao critico)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Green
Write-Host "    FIREWALL CONFIGURADO COM SUCESSO!" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Regras adicionadas:" -ForegroundColor Cyan
Write-Host "  - Nome: Sistema Chamados API" -ForegroundColor White
Write-Host "  - Porta: 5246 (TCP)" -ForegroundColor White
Write-Host "  - Direcao: Entrada (Inbound)" -ForegroundColor White
Write-Host "  - Acao: Permitir" -ForegroundColor White
Write-Host ""
Write-Host "A API agora pode ser acessada por dispositivos na rede local!" -ForegroundColor Green
Write-Host ""
