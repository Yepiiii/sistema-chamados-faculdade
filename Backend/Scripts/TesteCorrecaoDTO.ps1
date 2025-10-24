# Script para testar a correcao do DTO - TecnicoAtribuidoNome
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TESTE: Validacao Correcao DTO" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$apiUrl = "http://localhost:5246/api"

try {
    # 1. Login
    Write-Host "[1] Fazendo login..." -ForegroundColor Yellow
    $loginBody = @{
        email = "colaborador@empresa.com"
        senha = "Admin@123"
    } | ConvertTo-Json
    
    $login = Invoke-RestMethod -Uri "$apiUrl/usuarios/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $login.token
    $headers = @{ Authorization = "Bearer $token" }
    Write-Host "    Login bem-sucedido!" -ForegroundColor Green
    
    # 2. Criar chamado com atribuicao automatica
    Write-Host "`n[2] Criando chamado com atribuicao automatica..." -ForegroundColor Yellow
    $chamadoBody = @{
        titulo = "Teste Final Validacao DTO - $(Get-Date -Format 'HH:mm:ss')"
        descricao = "Validando se TecnicoAtribuidoNome aparece na resposta da API"
        categoriaId = 1
        prioridadeId = 2
        usarAnaliseAutomatica = $true
    } | ConvertTo-Json
    
    $chamado = Invoke-RestMethod -Uri "$apiUrl/chamados" -Method Post -Body $chamadoBody -Headers $headers -ContentType "application/json"
    
    # 3. Exibir resultados
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "RESULTADO DO TESTE" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Chamado ID: $($chamado.id)" -ForegroundColor Cyan
    Write-Host "Titulo: $($chamado.titulo)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "--- CAMPOS ADICIONADOS ---" -ForegroundColor Magenta
    Write-Host "TecnicoAtribuidoId: $($chamado.tecnicoAtribuidoId)" -ForegroundColor Yellow
    Write-Host "TecnicoAtribuidoNome: $($chamado.tecnicoAtribuidoNome)" -ForegroundColor Yellow
    Write-Host "CategoriaNome: $($chamado.categoriaNome)" -ForegroundColor Yellow
    Write-Host "PrioridadeNome: $($chamado.prioridadeNome)" -ForegroundColor Yellow
    
    # 4. Validacao
    Write-Host "`n========================================" -ForegroundColor Cyan
    if ($chamado.tecnicoAtribuidoNome) {
        Write-Host "SUCESSO!" -ForegroundColor Green -BackgroundColor Black
        Write-Host "TecnicoAtribuidoNome retornado: '$($chamado.tecnicoAtribuidoNome)'" -ForegroundColor Green
        Write-Host "A correcao do DTO esta funcionando corretamente!" -ForegroundColor Green
    } else {
        Write-Host "FALHA!" -ForegroundColor Red -BackgroundColor Black
        Write-Host "TecnicoAtribuidoNome ainda esta nulo/vazio" -ForegroundColor Red
        Write-Host "A correcao do DTO NAO esta funcionando" -ForegroundColor Red
    }
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    # 5. Verificar no banco de dados
    Write-Host "`n[3] Verificando no banco de dados..." -ForegroundColor Yellow
    $query = "SELECT Id, TecnicoId, TecnicoAtribuidoId, Titulo FROM Chamados WHERE Id = $($chamado.id)"
    $dbResult = sqlcmd -S "(localdb)\MSSQLLocalDB" -d SistemaChamados -Q $query -h -1 -W
    Write-Host "Resultado do banco:" -ForegroundColor Cyan
    Write-Host $dbResult -ForegroundColor Gray
    
} catch {
    Write-Host "`nERRO: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "StatusCode: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
}
