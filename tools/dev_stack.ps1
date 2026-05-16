param(
    [ValidateSet("android", "web")]
    [string]$Mode = "android",
    [switch]$Stop
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$mobileDir = Join-Path $repoRoot "apps\mobile"
$apiDir = Join-Path $repoRoot "services\api"
$audioDir = Join-Path $repoRoot "services\audio-engine"

$flutterPath = "C:\Users\Dell\flutter-sdk\bin\flutter.bat"
$androidStudioPath = "C:\Program Files\Android\Android Studio\bin\studio64.exe"

function Get-SaxPathProcesses {
    Get-CimInstance Win32_Process | Where-Object {
        $commandLine = $_.CommandLine
        if ([string]::IsNullOrWhiteSpace($commandLine)) {
            return $false
        }

        $commandLine -like "*$repoRoot*" -or
        $commandLine -like "*flutter_tools.snapshot*4131*" -or
        $commandLine -like "*uvicorn app.main:app*8000*" -or
        $commandLine -like "*uvicorn app.main:app*8010*"
    }
}

function Test-WindowCommandRunning {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Needle
    )

    @(Get-SaxPathProcesses | Where-Object {
        $_.CommandLine -like "*$Needle*"
    }).Count -gt 0
}

function Start-DevWindow {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,
        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory,
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    $fullCommand = @"
`$Host.UI.RawUI.WindowTitle = '$Title'
Set-Location -LiteralPath '$WorkingDirectory'
$Command
"@

    Start-Process -FilePath "powershell.exe" `
        -ArgumentList @("-NoExit", "-ExecutionPolicy", "Bypass", "-Command", $fullCommand) `
        -WorkingDirectory $WorkingDirectory `
        -WindowStyle Normal | Out-Null
}

function Stop-DevProcesses {
    $targets = Get-SaxPathProcesses
    if (-not $targets) {
        Write-Host "No SaxPath dev processes are running."
        return
    }

    foreach ($process in $targets) {
        try {
            Stop-Process -Id $process.ProcessId -Force -ErrorAction Stop
            Write-Host "Stopped PID $($process.ProcessId)"
        } catch {
            Write-Host "Failed to stop PID $($process.ProcessId): $($_.Exception.Message)"
        }
    }
}

if ($Stop) {
    Stop-DevProcesses
    exit 0
}

if (-not (Test-Path $flutterPath)) {
    throw "Flutter was not found at $flutterPath"
}

$audioCommand = @"
& py -3.12 -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8010
"@

$apiCommand = @"
`$env:API_HOST='127.0.0.1'
`$env:API_PORT='8000'
`$env:AUDIO_ENGINE_BASE_URL='http://127.0.0.1:8010'
`$env:PERSISTENCE_BACKEND='demo_file'
`$env:CORS_ALLOW_ORIGINS='["http://127.0.0.1:4131","http://localhost:4131"]'
& py -3.12 -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
"@

if (-not (Test-WindowCommandRunning "--port 8010")) {
    Start-DevWindow -Title "SaxPath Audio Engine" -WorkingDirectory $audioDir -Command $audioCommand
} else {
    Write-Host "Audio engine is already running."
}

if (-not (Test-WindowCommandRunning "--port 8000")) {
    Start-Sleep -Seconds 2
    Start-DevWindow -Title "SaxPath API" -WorkingDirectory $apiDir -Command $apiCommand
} else {
    Write-Host "API is already running."
}

if ($Mode -eq "web") {
    $webCommand = @"
& '$flutterPath' run -d web-server --web-hostname 127.0.0.1 --web-port 4131 --dart-define=API_BASE_URL=http://127.0.0.1:8000
"@

    if (-not (Test-WindowCommandRunning "--web-port 4131")) {
        Start-Sleep -Seconds 2
        Start-DevWindow -Title "SaxPath Flutter Web" -WorkingDirectory $mobileDir -Command $webCommand
    } else {
        Write-Host "Flutter web is already running at http://127.0.0.1:4131/index.html"
    }

    Start-Process "http://127.0.0.1:4131/index.html" | Out-Null
    exit 0
}

if (Test-Path $androidStudioPath) {
    Start-Process -FilePath $androidStudioPath -ArgumentList @($mobileDir) | Out-Null
}

try {
    $emulators = & $flutterPath emulators
    if ($emulators -match "Pixel_7") {
        Start-Process -FilePath "powershell.exe" `
            -ArgumentList @("-ExecutionPolicy", "Bypass", "-Command", "& '$flutterPath' emulators --launch Pixel_7") `
            -WindowStyle Hidden | Out-Null
    }
} catch {
    Write-Host "Could not auto-launch the emulator: $($_.Exception.Message)"
}

$androidCommand = @"
while (`$true) {
    `$devices = & '$flutterPath' devices
    if (`$devices -match 'emulator-' -or `$devices -match 'android') {
        break
    }

    Write-Host 'Waiting for Android device or emulator...'
    Start-Sleep -Seconds 5
}

& '$flutterPath' run --dart-define=API_BASE_URL=http://10.0.2.2:8000
"@

if (-not (Test-WindowCommandRunning "--dart-define=API_BASE_URL=http://10.0.2.2:8000")) {
    Start-Sleep -Seconds 2
    Start-DevWindow -Title "SaxPath Flutter Android" -WorkingDirectory $mobileDir -Command $androidCommand
} else {
    Write-Host "Flutter Android run is already active."
}
