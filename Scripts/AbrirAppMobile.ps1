# Script para abrir o App Mobile no Visual Studio
# A API ja deve estar rodando em background

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "  INICIANDO APP MOBILE - VISUAL STUDIO" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

# Verificar se API esta rodando
Write-Host "[1] Verificando se API esta online..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5246" -Method Get -ErrorAction Stop
    Write-Host "    API ONLINE em http://localhost:5246" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "    [AVISO] API nao esta respondendo!" -ForegroundColor Red
    Write-Host "    Certifique-se de que a API esta rodando antes de testar o app." -ForegroundColor Yellow
    Write-Host ""
}

# Caminho do projeto mobile
$mobileProjectPath = "C:\Users\opera\sistema-chamados-faculdade\SistemaChamados.Mobile\SistemaChamados.Mobile.csproj"
$solutionPath = "C:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade\sistema-chamados-faculdade.sln"

Write-Host "[2] Abrindo projeto Mobile no Visual Studio..." -ForegroundColor Yellow

# Tentar abrir com Visual Studio
if (Test-Path $mobileProjectPath) {
    Write-Host "    Projeto encontrado: $mobileProjectPath" -ForegroundColor Gray
    Write-Host "    Abrindo Visual Studio..." -ForegroundColor Gray
    Start-Process $mobileProjectPath
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host "  VISUAL STUDIO ABERTO COM SUCESSO!" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "PROXIMO PASSO:" -ForegroundColor Cyan
    Write-Host "1. Aguarde o Visual Studio carregar o projeto" -ForegroundColor White
    Write-Host "2. Selecione o dispositivo/emulador (Android/iOS/Windows)" -ForegroundColor White
    Write-Host "3. Pressione F5 ou clique em 'Run' para iniciar o app" -ForegroundColor White
    Write-Host ""
    Write-Host "API rodando em: http://localhost:5246" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host "    [ERRO] Projeto nao encontrado em: $mobileProjectPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "    Tentando abrir a solution completa..." -ForegroundColor Yellow
    if (Test-Path $solutionPath) {
        Start-Process $solutionPath
        Write-Host "    Solution aberta!" -ForegroundColor Green
    } else {
        Write-Host "    [ERRO] Solution tambem nao encontrada!" -ForegroundColor Red
    }
}

Write-Host "============================================================`n" -ForegroundColor Cyan
