<#
.SYNOPSIS
  Load test for lab6 ECS auto scaling (CPU target tracking).

.DESCRIPTION
  Generates HTTP traffic to backend (/chat) and optionally frontend (/).
  Use while watching ECS desired count in AWS Console or via -WatchEcs.

.PARAMETER AlbDns
  ALB DNS name. If omitted, reads terraform output from parent lab6 folder.

.PARAMETER DurationMinutes
  How long to run the load test.

.PARAMETER Workers
  Number of parallel PowerShell runspaces (concurrent load generators).

.PARAMETER Target
  backend | frontend | both

.PARAMETER WatchEcs
  Poll ECS desired/running counts every 30s (requires AWS CLI).

.EXAMPLE
  cd lab6\scripts
  .\test-autoscaling.ps1

.EXAMPLE
  .\test-autoscaling.ps1 -DurationMinutes 8 -Workers 40 -WatchEcs
#>
[CmdletBinding()]
param(
    [string] $AlbDns,
    [int] $DurationMinutes = 5,
    [int] $Workers = 30,
    [ValidateSet('backend', 'frontend', 'both')]
    [string] $Target = 'backend',
    [string] $ClusterName = 'lista6-cluster',
    [string] $FrontendService = 'lista6-frontend-svc',
    [string] $BackendService = 'lista6-backend-svc',
    [string] $Region = 'us-east-1',
    [switch] $WatchEcs
)

$ErrorActionPreference = 'Stop'

function Get-AlbDnsFromTerraform {
    $lab6Root = Split-Path $PSScriptRoot -Parent
    Push-Location $lab6Root
    try {
        $dns = terraform output -raw alb_dns_name 2>$null
        if (-not $dns) { throw 'Run terraform apply in lab6 first, or pass -AlbDns.' }
        return $dns.Trim()
    }
    finally {
        Pop-Location
    }
}

function Get-EcsCounts {
    param([string[]] $Services)
    $json = aws ecs describe-services `
        --region $Region `
        --cluster $ClusterName `
        --services $Services `
        --query 'services[*].{name:serviceName,desired:desiredCount,running:runningCount,pending:pendingCount}' `
        --output json 2>$null
    if ($LASTEXITCODE -ne 0) { return $null }
    return $json | ConvertFrom-Json
}

if (-not $AlbDns) {
    $AlbDns = Get-AlbDnsFromTerraform
}

$baseHttp = "http://$AlbDns"
$backendAllUrl = "$baseHttp/chat/all?username=loadtest"
$backendPollUrl = "$baseHttp/chat?username=loadtest&after=2000-01-01T00:00:00"
$frontendUrl = "$baseHttp/"

$endTime = (Get-Date).AddMinutes($DurationMinutes)

$urls = @()
switch ($Target) {
    'backend' { $urls = @($backendAllUrl, $backendPollUrl) }
    'frontend' { $urls = @($frontendUrl) }
    'both' { $urls = @($frontendUrl, $backendAllUrl, $backendPollUrl) }
}

$backendPostUrl = "$baseHttp/chat"

Write-Host '=== Lab6 auto scaling load test ===' -ForegroundColor Cyan
Write-Host "ALB:          $baseHttp"
Write-Host "Target:       $Target"
Write-Host "Workers:      $Workers"
Write-Host "Duration:     $DurationMinutes min"
Write-Host "URLs:"
$urls | ForEach-Object { Write-Host "  $_" }
Write-Host ''
Write-Host 'Open AWS Console: ECS -> cluster -> service -> Tasks / Auto scaling' -ForegroundColor Yellow
Write-Host 'Scale-out usually within 1-3 min. After you stop, scale-in may take ~5-15 min (cooldown).' -ForegroundColor Yellow
Write-Host ''

$runspaces = [System.Collections.Generic.List[PowerShell]]::new()
$pool = [runspacefactory]::CreateRunspacePool(1, $Workers)
$pool.Open()

$backendPostUrlForRunspace = $backendPostUrl
for ($i = 0; $i -lt $Workers; $i++) {
    $ps = [PowerShell]::Create()
    $ps.RunspacePool = $pool
    [void]$ps.AddScript({
        param($Urls, $StopAt, $BackendPost)
        $rng = [System.Random]::new()
        while ((Get-Date) -lt $StopAt) {
            foreach ($u in $Urls) {
                try {
                    Invoke-WebRequest -Uri $u -Method GET -TimeoutSec 10 -UseBasicParsing | Out-Null
                }
                catch {}
                if ($rng.NextDouble() -lt 0.15) {
                    try {
                        $body = '{"username":"loadtest","message":"stress ' + (Get-Date).Ticks + '"}'
                        Invoke-WebRequest -Uri $BackendPost -Method POST -Body $body `
                            -ContentType 'application/json' -TimeoutSec 10 -UseBasicParsing | Out-Null
                    }
                    catch {}
                }
            }
        }
    }).AddArgument($urls).AddArgument($endTime).AddArgument($backendPostUrlForRunspace)
    $runspaces.Add($ps) | Out-Null
    $ps.BeginInvoke() | Out-Null
}

$watchServices = @($BackendService, $FrontendService)
if ($Target -eq 'frontend') { $watchServices = @($FrontendService) }
elseif ($Target -eq 'backend') { $watchServices = @($BackendService) }

Write-Host "Load running until $(Get-Date -Format 'HH:mm:ss') ($DurationMinutes min). Ctrl+C = stop early." -ForegroundColor Green

$lastEcsPoll = [datetime]::MinValue
try {
    while ((Get-Date) -lt $endTime) {
        if ($WatchEcs -and ((Get-Date) - $lastEcsPoll).TotalSeconds -ge 30) {
            $counts = Get-EcsCounts -Services $watchServices
            if ($counts) {
                Write-Host ("[{0}] ECS:" -f (Get-Date -Format 'HH:mm:ss')) -NoNewline
                $counts | ForEach-Object {
                    Write-Host (" {0} desired={1} running={2}" -f $_.name, $_.desired, $_.running) -NoNewline
                }
                Write-Host ''
            }
            else {
                Write-Host '[WARN] aws ecs describe-services failed. Configure AWS CLI or omit -WatchEcs.' -ForegroundColor DarkYellow
            }
            $lastEcsPoll = Get-Date
        }
        elseif (-not $WatchEcs) {
            $remaining = [math]::Round(($endTime - (Get-Date)).TotalSeconds)
            if ($remaining % 30 -lt 10) {
                Write-Host "  ... $remaining s remaining"
            }
        }
        Start-Sleep -Seconds 10
    }
}
finally {
    Write-Host 'Waiting for workers to finish...' -ForegroundColor Cyan
    foreach ($ps in $runspaces) {
        try {
            if (-not $ps.IsCompleted) { $ps.Stop() | Out-Null }
            $ps.EndInvoke() | Out-Null
        }
        catch {}
        $ps.Dispose()
    }
    $pool.Close()
    $pool.Dispose()
}

Write-Host ''
Write-Host 'Load test finished. Check scale-in over the next 5-15 minutes.' -ForegroundColor Cyan
if (Get-Command aws -ErrorAction SilentlyContinue) {
    Write-Host 'Final ECS state:' -ForegroundColor Cyan
    $final = Get-EcsCounts -Services @($BackendService, $FrontendService)
    $final | Format-Table name, desired, running, pending -AutoSize
}
