param(
    [string]$BaseUrl = "http://localhost:5246",
    [string]$ProjectPath = (Join-Path $PSScriptRoot "..\SistemaChamados.csproj")
)

function Invoke-ApiRequest {
    param(
        [string]$Method,
        [string]$Path,
        [hashtable]$Headers,
        [object]$Body
    )

    $uri = "$BaseUrl$Path"
    $jsonBody = $null

    if ($Body -ne $null) {
        $jsonBody = $Body | ConvertTo-Json -Depth 6
    }

    try {
        $invokeParams = @{
            Uri         = $uri
            Method      = $Method
            Headers     = $Headers
            ErrorAction = 'Stop'
        }

        if ($jsonBody) {
            $invokeParams.ContentType = 'application/json'
            $invokeParams.Body = $jsonBody
        }

        $response = Invoke-RestMethod @invokeParams

        return [pscustomobject]@{
            Path       = $Path
            Method     = $Method
            StatusCode = 200
            Success    = $true
            Body       = $response
        }
    }
    catch {
        $ex = $_.Exception
        $statusCode = $null

        if ($ex.Response -and $ex.Response.StatusCode) {
            $statusCode = [int]$ex.Response.StatusCode
        }

        return [pscustomobject]@{
            Path       = $Path
            Method     = $Method
            StatusCode = $statusCode
            Success    = $false
            Error      = $ex.Message
        }
    }
}

$job = Start-Job {
    param($projPath)
    dotnet run --project $projPath --launch-profile "http"
} -ArgumentList $ProjectPath

try {
    $timeoutSeconds = 90
    $pollInterval = 3
    $elapsed = 0
    $ready = $false

    while (-not $ready -and $elapsed -lt $timeoutSeconds) {
        Start-Sleep -Seconds $pollInterval
        $elapsed += $pollInterval

        try {
            Invoke-RestMethod -Uri "$BaseUrl/swagger/index.html" -Method Get -ErrorAction Stop | Out-Null
            $ready = $true
        }
        catch {
            if ($elapsed -ge $timeoutSeconds) {
                throw
            }
        }
    }

    $results = @()

    $results += Invoke-ApiRequest -Method 'GET' -Path '/api/categorias' -Headers @{} -Body $null

    $adminLogin = Invoke-ApiRequest -Method 'POST' -Path '/api/usuarios/login' -Headers @{} -Body @{ Email = 'admin@helpdesk.com'; Senha = 'admin123' }
    $results += $adminLogin
    $adminToken = $adminLogin.Body.token

    if ($adminToken) {
        $authHeader = @{ Authorization = "Bearer $adminToken" }
        $results += Invoke-ApiRequest -Method 'GET' -Path '/api/categorias' -Headers $authHeader -Body $null
        $results += Invoke-ApiRequest -Method 'GET' -Path '/api/usuarios/tecnicos' -Headers $authHeader -Body $null
        $results += Invoke-ApiRequest -Method 'GET' -Path '/api/chamados' -Headers $authHeader -Body $null
    }

    $tecnicoLogin = Invoke-ApiRequest -Method 'POST' -Path '/api/usuarios/login' -Headers @{} -Body @{ Email = 'tecnico@helpdesk.com'; Senha = 'admin123' }
    $results += $tecnicoLogin
    $tecnicoToken = $tecnicoLogin.Body.token

    if ($tecnicoToken) {
        $tecnicoHeader = @{ Authorization = "Bearer $tecnicoToken" }
        $results += Invoke-ApiRequest -Method 'GET' -Path '/api/usuarios/tecnicos' -Headers $tecnicoHeader -Body $null
        $results += Invoke-ApiRequest -Method 'GET' -Path '/api/chamados' -Headers $tecnicoHeader -Body $null
    }

    $usuarioLogin = Invoke-ApiRequest -Method 'POST' -Path '/api/usuarios/login' -Headers @{} -Body @{ Email = 'usuario@helpdesk.com'; Senha = 'admin123' }
    $results += $usuarioLogin
    $usuarioToken = $usuarioLogin.Body.token

    if ($usuarioToken) {
        $usuarioHeader = @{ Authorization = "Bearer $usuarioToken" }
        $results += Invoke-ApiRequest -Method 'GET' -Path '/api/usuarios/tecnicos' -Headers $usuarioHeader -Body $null
        $results += Invoke-ApiRequest -Method 'GET' -Path '/api/chamados' -Headers $usuarioHeader -Body $null
    }

    $results | ForEach-Object {
        $_ | ConvertTo-Json -Depth 6
    }
}
finally {
    if ($job.State -eq 'Running') {
        Stop-Job -Job $job -ErrorAction SilentlyContinue
    }
    Receive-Job -Job $job -ErrorAction SilentlyContinue | Out-String | Write-Verbose
    Remove-Job -Job $job -ErrorAction SilentlyContinue
}
