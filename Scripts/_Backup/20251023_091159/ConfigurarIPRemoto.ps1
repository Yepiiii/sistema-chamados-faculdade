param(
    [Parameter(Mandatory=$true)]
    [string]$Url
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Configurar URL Remota" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Validar URL
if ($Url -notmatch "^https?://") {
    Write-Host "[ERRO] URL invalida! Deve comecar com http:// ou https://" -ForegroundColor Red
    Write-Host "Exemplo: https://abc123.ngrok-free.app" -ForegroundColor Yellow
    exit 1
}

# Remover barra final se existir
$Url = $Url.TrimEnd('/')

Write-Host "[INFO] URL fornecida: $Url" -ForegroundColor Cyan
Write-Host ""

# Detectar caminhos
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$constantsPath = Join-Path $repoRoot "Mobile\Helpers\Constants.cs"

if (-not (Test-Path $constantsPath)) {
    Write-Host "[ERRO] Constants.cs nao encontrado!" -ForegroundColor Red
    Write-Host "Caminho esperado: $constantsPath" -ForegroundColor Yellow
    exit 1
}

# Fazer backup
$backupPath = "$constantsPath.backup"
Copy-Item $constantsPath $backupPath -Force
Write-Host "[OK] Backup criado: Constants.cs.backup" -ForegroundColor Green
Write-Host ""

# Ler arquivo
$content = Get-Content $constantsPath -Raw

# Verificar formato atual
if ($content -notmatch 'BaseUrlPhysicalDevice\s*=>\s*"') {
    Write-Host "[ERRO] Formato do Constants.cs nao reconhecido!" -ForegroundColor Red
    Write-Host "Procure por: public static string BaseUrlPhysicalDevice" -ForegroundColor Yellow
    exit 1
}

# Extrair URL atual
if ($content -match 'BaseUrlPhysicalDevice\s*=>\s*"([^"]+)"') {
    $currentUrl = $matches[1]
    Write-Host "[INFO] URL atual: $currentUrl" -ForegroundColor Yellow
}

# Atualizar URL
$newUrl = "$Url/api/"
$pattern = '(BaseUrlPhysicalDevice\s*=>\s*)"[^"]+"'
$replacement = "`$1`"$newUrl`""
$newContent = $content -replace $pattern, $replacement

# Salvar
Set-Content -Path $constantsPath -Value $newContent -Encoding UTF8
Write-Host "[OK] Constants.cs atualizado!" -ForegroundColor Green
Write-Host ""

# Verificar resultado
$verifyContent = Get-Content $constantsPath -Raw
if ($verifyContent -match 'BaseUrlPhysicalDevice\s*=>\s*"([^"]+)"') {
    $updatedUrl = $matches[1]
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  CONFIGURACAO ATUALIZADA" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Nova URL da API:" -ForegroundColor Cyan
    Write-Host "  $updatedUrl" -ForegroundColor White -BackgroundColor DarkGreen
    Write-Host ""
    Write-Host "Arquivo:" -ForegroundColor Cyan
    Write-Host "  Mobile\Helpers\Constants.cs" -ForegroundColor White
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  PROXIMOS PASSOS" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Gerar novo APK:" -ForegroundColor White
    Write-Host "   .\GerarAPK.ps1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "2. Instalar no celular" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Testar de qualquer rede:" -ForegroundColor White
    Write-Host "   - Wi-Fi diferente" -ForegroundColor Cyan
    Write-Host "   - 4G/5G" -ForegroundColor Cyan
    Write-Host "   - Internet de outro local" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host "  CREDENCIAIS DE TESTE" -ForegroundColor Magenta
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "Administrador:" -ForegroundColor White
    Write-Host "  Email: admin@sistema.com" -ForegroundColor Cyan
    Write-Host "  Senha: Admin@123" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Aluno:" -ForegroundColor White
    Write-Host "  Email: aluno@sistema.com" -ForegroundColor Cyan
    Write-Host "  Senha: Aluno@123" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[INFO] Backup disponivel em: $backupPath" -ForegroundColor DarkGray
    Write-Host ""
} else {
    Write-Host "[ERRO] Falha na verificacao!" -ForegroundColor Red
    Write-Host "Restaurando backup..." -ForegroundColor Yellow
    Copy-Item $backupPath $constantsPath -Force
    Write-Host "[OK] Backup restaurado" -ForegroundColor Green
    exit 1
}
