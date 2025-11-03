param(
    [string]$Email = "admin@helpdesk.com",
    [string]$Senha = "admin123",
    [int]$MaxAttempts = 15,
    [int]$DelaySeconds = 2
)

$projectPath = Join-Path $PSScriptRoot "..\SistemaChamados.csproj"

$job = Start-Job {
    param($projPath)
    dotnet run --project $projPath --launch-profile "http"
} -ArgumentList $projectPath

try {
    $body = @{ Email = $Email; Senha = $Senha } | ConvertTo-Json

    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        Start-Sleep -Seconds $DelaySeconds
        try {
            $response = Invoke-RestMethod -Uri "http://localhost:5246/api/usuarios/login" -Method Post -Body $body -ContentType "application/json"
            [pscustomobject]@{
                Email = $Email
                TipoUsuario = $response.tipoUsuario
                Token = $response.token
            } | ConvertTo-Json -Depth 3
            break
        }
        catch {
            if ($attempt -eq $MaxAttempts) {
                throw
            }
        }
    }
}
finally {
    if ($job.State -eq "Running") {
        Stop-Job -Job $job -ErrorAction SilentlyContinue
    }
    Receive-Job -Job $job -ErrorAction SilentlyContinue | Out-String | Write-Verbose
    Remove-Job -Job $job -ErrorAction SilentlyContinue
}
