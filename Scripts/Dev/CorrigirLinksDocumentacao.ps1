# ==============================================================================
# Script: CorrigirLinksDocumentacao.ps1
# Descricao: Corrige links quebrados nos arquivos Markdown
# Autor: Sistema
# Data: 23/10/2025
# ==============================================================================

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    CORRECAO DE LINKS NA DOCUMENTACAO" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# Mapeamento de links antigos para novos
$linkMapping = @{
    # Documentos arquivados/removidos -> INDEX.md
    'GUIA_INSTALACAO.md' = 'WORKFLOWS.md'
    'CREDENCIAIS_TESTE.md' = 'docs/INDEX.md'
    'ESTRUTURA_REPOSITORIO.md' = 'docs/Desenvolvimento/EstruturaRepositorio.md'
    
    # Documentos movidos para docs/
    'docs/SETUP_PORTABILIDADE.md' = 'docs/INDEX.md'
    'docs/ACESSO_REMOTO.md' = 'docs/INDEX.md'
    'docs/CREDENCIAIS_TESTE.md' = 'docs/INDEX.md'
    'docs/OVERVIEW_MOBILE_UI_UX.md' = 'docs/Mobile/README.md'
    'docs/CORRECAO_FUSO_HORARIO.md' = 'docs/Database/README.md'
    'docs/GUIA_GERAR_APK.md' = 'docs/Mobile/GerarAPK.md'
    'docs/STATUS_MOBILE.md' = 'docs/Mobile/README.md'
    'Docs/GUIA_INICIAR_SISTEMA.md' = 'WORKFLOWS.md'
    'Docs/DEPLOYMENT.md' = 'docs/INDEX.md'
    'Docs/TROUBLESHOOTING.md' = 'docs/Mobile/Troubleshooting.md'
    
    # Scripts movidos
    'IniciarSistema.ps1' = 'Scripts/API/IniciarAPI.ps1'
    'GerarAPK.ps1' = 'Scripts/Mobile/GerarAPK.ps1'
    'ConfigurarIPDispositivo.ps1' = 'Scripts/Mobile/ConfigurarIP.ps1'
    'IniciarAPIRede.ps1' = 'Scripts/API/IniciarAPI.ps1'
    
    # Mobile overview (documentos não encontrados nos resultados - provavelmente estão em pasta docs/mobile-overview)
    'COMO_TESTAR_MOBILE.md' = 'docs/Mobile/ComoTestar.md'
    'STATUS_MOBILE.md' = 'docs/Mobile/README.md'
    'README_MOBILE.md' = 'docs/Mobile/README.md'
    
    # Backend
    'Backend/README.md' = 'docs/Desenvolvimento/Arquitetura.md'
    'Mobile/README.md' = 'docs/Mobile/README.md'
}

$totalCorrecoes = 0
$arquivosCorrigidos = 0

# Arquivos a corrigir
$mdFiles = @(
    'README.md',
    'WORKFLOWS.md',
    'docs\INDEX.md',
    'docs\Mobile\README.md',
    'docs\Mobile\GuiaInstalacaoAPK.md',
    'docs\Mobile\GerarAPK.md',
    'docs\Desenvolvimento\EstruturaRepositorio.md',
    'docs\Desenvolvimento\ReorganizacaoScripts.md'
)

foreach ($file in $mdFiles) {
    $filePath = Join-Path $PWD $file
    
    if (-not (Test-Path $filePath)) {
        Write-Host "[!] Arquivo nao encontrado: $file" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "[*] Processando: $file" -ForegroundColor Cyan
    
    $content = Get-Content $filePath -Raw -Encoding UTF8
    $originalContent = $content
    $correcoesArquivo = 0
    
    # Aplicar cada mapeamento
    foreach ($oldLink in $linkMapping.Keys) {
        $newLink = $linkMapping[$oldLink]
        
        # Padrão: [texto](oldLink)
        $pattern = "\[([^\]]+)\]\($([regex]::Escape($oldLink))\)"
        $replacement = "[$1]($newLink)"
        
        $foundMatches = [regex]::Matches($content, $pattern)
        if ($foundMatches.Count -gt 0) {
            $content = [regex]::Replace($content, $pattern, $replacement)
            Write-Host "  OK: $oldLink -> $newLink ($($foundMatches.Count) encontradas)" -ForegroundColor Green
            $correcoesArquivo += $foundMatches.Count
        }
    }
    
    # Salvar se houver alterações
    if ($content -ne $originalContent) {
        Set-Content -Path $filePath -Value $content -Encoding UTF8 -NoNewline
        $arquivosCorrigidos++
        $totalCorrecoes += $correcoesArquivo
        Write-Host "  [OK] $correcoesArquivo correcoes aplicadas" -ForegroundColor Green
    }
    else {
        Write-Host "  [OK] Nenhuma correcao necessaria" -ForegroundColor Gray
    }
    
    Write-Host ""
}

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "  RESUMO" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Arquivos corrigidos  : $arquivosCorrigidos" -ForegroundColor White
Write-Host "Total de correcoes   : $totalCorrecoes" -ForegroundColor White
Write-Host ""
Write-Host "==================================================================" -ForegroundColor Green
Write-Host "  CORRECAO CONCLUIDA!" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green
Write-Host ""
