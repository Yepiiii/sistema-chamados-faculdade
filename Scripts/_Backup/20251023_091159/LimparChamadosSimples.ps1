# ===================================
# LIMPAR CHAMADOS E CRIAR DEMOS
# ===================================

Write-Host "Limpando chamados existentes..." -ForegroundColor Yellow

# String de conexao
$connString = "Server=(localdb)\mssqllocaldb;Database=SistemaChamados;Integrated Security=True;"

# Criar conexao
$conn = New-Object System.Data.SqlClient.SqlConnection($connString)

try {
    $conn.Open()
    
    # Limpar
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "DELETE FROM Chamados; DBCC CHECKIDENT ('Chamados', RESEED, 0);"
    $cmd.ExecuteNonQuery() | Out-Null
    
    Write-Host "[OK] Chamados limpos!" -ForegroundColor Green
    Write-Host "Pronto! Banco de dados limpo." -ForegroundColor Cyan
    
} catch {
    Write-Host "[ERRO] $_" -ForegroundColor Red
} finally {
    $conn.Close()
}
