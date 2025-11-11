# Script para configurar o Firewall do Windows
# EXECUTAR COMO ADMINISTRADOR
# Botão direito no arquivo > "Executar como Administrador"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CONFIGURANDO FIREWALL DO WINDOWS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se está executando como Administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERRO: Este script precisa ser executado como Administrador!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Como executar:" -ForegroundColor Yellow
    Write-Host "1. Clique com botão direito no arquivo" -ForegroundColor White
    Write-Host "2. Selecione 'Executar como Administrador'" -ForegroundColor White
    Write-Host ""
    Write-Host "Pressione qualquer tecla para sair..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

Write-Host "Permissões de Administrador verificadas." -ForegroundColor Green
Write-Host ""

# Verificar se as regras já existem
Write-Host "Verificando regras existentes do Firewall..." -ForegroundColor Yellow

$rule5246 = Get-NetFirewallRule -DisplayName "API Sistema Chamados" -ErrorAction SilentlyContinue
$rule8080 = Get-NetFirewallRule -DisplayName "Web Sistema Chamados" -ErrorAction SilentlyContinue

# Porta 5246 (Backend API)
if ($rule5246) {
    Write-Host ""
    Write-Host "Regra para porta 5246 já existe." -ForegroundColor Yellow
    $update5246 = Read-Host "Deseja recriar a regra? (S/N)"
    
    if ($update5246 -eq "S" -or $update5246 -eq "s") {
        Write-Host "Removendo regra antiga..." -ForegroundColor Yellow
        Remove-NetFirewallRule -DisplayName "API Sistema Chamados"
        
        Write-Host "Criando nova regra para porta 5246..." -ForegroundColor Green
        New-NetFirewallRule -DisplayName "API Sistema Chamados" `
                            -Direction Inbound `
                            -LocalPort 5246 `
                            -Protocol TCP `
                            -Action Allow `
                            -Profile Domain,Private,Public `
                            -Description "Permite acesso à API do Sistema de Chamados na porta 5246"
        
        Write-Host "Regra criada com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "Regra mantida." -ForegroundColor Cyan
    }
} else {
    Write-Host ""
    Write-Host "Criando regra para porta 5246 (Backend API)..." -ForegroundColor Green
    New-NetFirewallRule -DisplayName "API Sistema Chamados" `
                        -Direction Inbound `
                        -LocalPort 5246 `
                        -Protocol TCP `
                        -Action Allow `
                        -Profile Domain,Private,Public `
                        -Description "Permite acesso à API do Sistema de Chamados na porta 5246"
    
    Write-Host "Regra criada com sucesso!" -ForegroundColor Green
}

# Porta 8080 (Frontend Web)
if ($rule8080) {
    Write-Host ""
    Write-Host "Regra para porta 8080 já existe." -ForegroundColor Yellow
    $update8080 = Read-Host "Deseja recriar a regra? (S/N)"
    
    if ($update8080 -eq "S" -or $update8080 -eq "s") {
        Write-Host "Removendo regra antiga..." -ForegroundColor Yellow
        Remove-NetFirewallRule -DisplayName "Web Sistema Chamados"
        
        Write-Host "Criando nova regra para porta 8080..." -ForegroundColor Green
        New-NetFirewallRule -DisplayName "Web Sistema Chamados" `
                            -Direction Inbound `
                            -LocalPort 8080 `
                            -Protocol TCP `
                            -Action Allow `
                            -Profile Domain,Private,Public `
                            -Description "Permite acesso ao Frontend Web do Sistema de Chamados na porta 8080"
        
        Write-Host "Regra criada com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "Regra mantida." -ForegroundColor Cyan
    }
} else {
    Write-Host ""
    Write-Host "Criando regra para porta 8080 (Frontend Web)..." -ForegroundColor Green
    New-NetFirewallRule -DisplayName "Web Sistema Chamados" `
                        -Direction Inbound `
                        -LocalPort 8080 `
                        -Protocol TCP `
                        -Action Allow `
                        -Profile Domain,Private,Public `
                        -Description "Permite acesso ao Frontend Web do Sistema de Chamados na porta 8080"
    
    Write-Host "Regra criada com sucesso!" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  FIREWALL CONFIGURADO!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Regras criadas:" -ForegroundColor Cyan
Write-Host "- Porta 5246 (TCP) - API Sistema Chamados" -ForegroundColor White
Write-Host "- Porta 8080 (TCP) - Web Sistema Chamados" -ForegroundColor White
Write-Host ""
Write-Host "Agora seu celular poderá acessar a API no IP:" -ForegroundColor Yellow
$currentIP = (ipconfig | Select-String "IPv4" | Select-String "192.168" | Select-Object -First 1) -replace '.*:\s*', ''
$currentIP = $currentIP.Trim()
Write-Host "http://$currentIP:5246/api/" -ForegroundColor Green
Write-Host ""
Write-Host "Teste no navegador do celular:" -ForegroundColor Yellow
Write-Host "http://$currentIP:5246/swagger" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
