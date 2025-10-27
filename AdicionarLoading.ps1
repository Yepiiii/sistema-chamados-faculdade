# Script para adicionar loading.js em todos os HTMLs
# FASE 6.1 - Loading States

Write-Host "Adicionando loading.js nas páginas..." -ForegroundColor Cyan

$pagesDir = "Frontend\pages"
$files = @(
    "admin-dashboard.html",
    "admin-chamados.html", 
    "novo-ticket.html",
    "ticket-detalhes.html",
    "config.html"
)

foreach ($file in $files) {
    $filePath = Join-Path $pagesDir $file
    
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        
        # Verifica se ja tem loading.js
        if ($content -match 'loading\.js') {
            Write-Host "  OK $file ja possui loading.js" -ForegroundColor Yellow
            continue
        }
        
        # Adiciona loading.js antes de api.js
        $updated = $content -replace '(<script src="\.\./assets/js/api\.js"></script>)', '<script src="../assets/js/loading.js"></script>`r`n    $1'
        
        Set-Content $filePath $updated -NoNewline
        Write-Host "  OK $file atualizado" -ForegroundColor Green
    } else {
        Write-Host "  ERRO $file nao encontrado" -ForegroundColor Red
    }
}

Write-Host "`nConcluido!" -ForegroundColor Green
