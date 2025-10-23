# ==============================================================================
# Script: ValidarDocumentacao.ps1
# Descricao: Valida todos os arquivos Markdown do projeto
# Autor: Sistema
# Data: 23/10/2025
# ==============================================================================

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    VALIDACAO DA DOCUMENTACAO MARKDOWN" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# Obter todos os arquivos .md (exceto _Archive e _Backup)
$mdFiles = Get-ChildItem -Path . -Include *.md -Recurse -File | 
    Where-Object { $_.FullName -notmatch '_Archive|_Backup|\\bin\\|\\obj\\' } |
    Sort-Object FullName

Write-Host "[*] Total de arquivos encontrados: $($mdFiles.Count)" -ForegroundColor Yellow
Write-Host ""

# Categorizar arquivos
$categorias = @{
    'Raiz' = @()
    'docs/Mobile' = @()
    'docs/Database' = @()
    'docs/Desenvolvimento' = @()
    'docs' = @()
}

foreach ($file in $mdFiles) {
    $relativePath = $file.FullName.Replace($PWD.Path, '').TrimStart('\')
    
    if ($relativePath -match '^docs\\Mobile\\') {
        $categorias['docs/Mobile'] += $file
    }
    elseif ($relativePath -match '^docs\\Database\\') {
        $categorias['docs/Database'] += $file
    }
    elseif ($relativePath -match '^docs\\Desenvolvimento\\') {
        $categorias['docs/Desenvolvimento'] += $file
    }
    elseif ($relativePath -match '^docs\\' -and $relativePath -notmatch '\\') {
        $categorias['docs'] += $file
    }
    else {
        $categorias['Raiz'] += $file
    }
}

# Funcao para validar conteudo do arquivo
function Test-MarkdownContent {
    param(
        [string]$FilePath,
        [string]$FileName
    )
    
    $issues = @()
    $content = Get-Content $FilePath -Raw -Encoding UTF8
    
    # Verificar se arquivo esta vazio
    if ([string]::IsNullOrWhiteSpace($content)) {
        $issues += "Arquivo vazio"
        return $issues
    }
    
    # Verificar titulo principal
    if ($content -notmatch '^#\s+.+') {
        $issues += "Falta titulo principal (# Titulo)"
    }
    
    # Verificar links quebrados para arquivos locais
    $links = [regex]::Matches($content, '\[([^\]]+)\]\(([^)]+)\)')
    foreach ($link in $links) {
        $linkPath = $link.Groups[2].Value
        
        # Ignorar URLs externas
        if ($linkPath -match '^https?://') {
            continue
        }
        
        # Verificar se arquivo local existe
        $fullLinkPath = Join-Path (Split-Path $FilePath) $linkPath
        if ($linkPath -match '\.md$|\.ps1$|\.cs$' -and -not (Test-Path $fullLinkPath)) {
            $issues += "Link quebrado: $linkPath"
        }
    }
    
    # Verificar referencias a scripts movidos
    if ($content -match '\.\\/(?!Scripts/).*\.ps1' -or $content -match 'IniciarAPIRede\.ps1|ConfigurarIPDispositivo\.ps1') {
        $issues += "Referencia a script com caminho desatualizado"
    }
    
    # Verificar referencias a documentos movidos
    if ($content -match '(?<!docs/)(?<!docs\\)(GUIA_|README_|STATUS_|COMO_)[A-Z_]+\.md') {
        $issues += "Referencia a documento com caminho desatualizado"
    }
    
    # Verificar data desatualizada (> 6 meses)
    $fileDate = (Get-Item $FilePath).LastWriteTime
    $sixMonthsAgo = (Get-Date).AddMonths(-6)
    if ($fileDate -lt $sixMonthsAgo) {
        $issues += "Documento antigo (ultima modificacao: $($fileDate.ToString('dd/MM/yyyy')))"
    }
    
    return $issues
}

# Validar cada categoria
$totalIssues = 0
$filesWithIssues = 0

foreach ($categoria in $categorias.Keys | Sort-Object) {
    $files = $categorias[$categoria]
    
    if ($files.Count -eq 0) {
        continue
    }
    
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host "  [$categoria]" -ForegroundColor Yellow
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($file in $files) {
        $fileName = $file.Name
        $relativePath = $file.FullName.Replace($PWD.Path, '').TrimStart('\')
        $size = [math]::Round($file.Length / 1KB, 2)
        
        Write-Host "  $fileName" -ForegroundColor White -NoNewline
        Write-Host " ($size KB)" -ForegroundColor Gray
        
        # Validar conteudo
        $issues = Test-MarkdownContent -FilePath $file.FullName -FileName $fileName
        
        if ($issues.Count -eq 0) {
            Write-Host "    Status: " -NoNewline
            Write-Host "OK" -ForegroundColor Green
        }
        else {
            Write-Host "    Status: " -NoNewline
            Write-Host "AVISOS ($($issues.Count))" -ForegroundColor Yellow
            foreach ($issue in $issues) {
                Write-Host "      - $issue" -ForegroundColor Yellow
            }
            $filesWithIssues++
            $totalIssues += $issues.Count
        }
        
        Write-Host ""
    }
}

# Resumo final
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "  RESUMO DA VALIDACAO" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total de arquivos    : $($mdFiles.Count)" -ForegroundColor White
Write-Host "Arquivos com avisos  : $filesWithIssues" -ForegroundColor $(if ($filesWithIssues -eq 0) { 'Green' } else { 'Yellow' })
Write-Host "Total de avisos      : $totalIssues" -ForegroundColor $(if ($totalIssues -eq 0) { 'Green' } else { 'Yellow' })
Write-Host ""

# Distribuicao por categoria
Write-Host "Distribuicao:" -ForegroundColor Cyan
foreach ($categoria in $categorias.Keys | Sort-Object) {
    $count = $categorias[$categoria].Count
    if ($count -gt 0) {
        Write-Host "  $($categoria.PadRight(25)) : $count arquivos" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Green
Write-Host "  VALIDACAO CONCLUIDA!" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green
Write-Host ""
