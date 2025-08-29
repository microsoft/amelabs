param(
    [Parameter(Mandatory=$true)]
    [string] $ConnectionString
)

# 1) Prepare working folder
$appDir = "C:\apps\dotnet-sample"
if (-not (Test-Path $appDir)) {
    New-Item -ItemType Directory -Path $appDir | Out-Null
}
Set-Location $appDir

# 2) Ensure Git is present
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Invoke-WebRequest `
      "https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.1/Git-2.42.0-64-bit.exe" `
      -OutFile git-installer.exe
    Start-Process .\git-installer.exe -ArgumentList "/VERYSILENT" -Wait
}
$env:PATH += ";C:\Program Files\Git\bin"

# 3) Clone samples only once
if (-not (Test-Path ".\samples")) {
    git clone https://github.com/dotnet/samples.git
}

# 4) Go to the quickstart folder
$samplePath = ".\samples\azure\app-insights-aspnet-core-quickstart"
if (-not (Test-Path $samplePath)) {
    Write-Error "Sample path not found"
    exit 1
}
Set-Location $samplePath

# 5) Ensure .NET SDK is installed under the user profile
$dotnetDir = "$env:USERPROFILE\.dotnet"
$dotnetExe = "$dotnetDir\dotnet.exe"
if (-not (Test-Path $dotnetExe)) {
    Invoke-WebRequest "https://dot.net/v1/dotnet-install.ps1" -OutFile install-dotnet.ps1
    powershell -NoProfile -ExecutionPolicy Bypass `
      -File install-dotnet.ps1 `
      -Channel LTS `
      -InstallDir $dotnetDir
}

# 6) Configure Application Insights
$appsettings = @{
    "ApplicationInsights" = @{
        "ConnectionString" = $ConnectionString
    }
    "Logging" = @{
        "LogLevel" = @{
            "Default" = "Information"
            "Microsoft" = "Warning"
            "Microsoft.Hosting.Lifetime" = "Information"
        }
    }
    "AllowedHosts" = "*"
}

$json = $appsettings | ConvertTo-Json -Depth 4
$json | Set-Content appsettings.json

# 7) Add AI package and build
& $dotnetExe add package Microsoft.ApplicationInsights.AspNetCore
& $dotnetExe build

# 8) Create a launcher script
$launcher = Join-Path $appDir "start-sample.ps1"
@"
Set-Location `"C:\apps\dotnet-sample\samples\azure\app-insights-aspnet-core-quickstart`"
& `"$dotnetExe`" run --urls http://0.0.0.0:5000
"@ | Set-Content $launcher

# 9) Register the app startup task (SYSTEM, at boot)
$taskName = "DotnetSampleApp"
if (-not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) {
    $action  = New-ScheduledTaskAction    -Execute "Powershell.exe" `
               -Argument "-WindowStyle Hidden -File `"$launcher`""
    $trigger = New-ScheduledTaskTrigger   -AtStartup
    Register-ScheduledTask -TaskName     $taskName `
                           -Action       $action `
                           -Trigger      $trigger `
                           -Description  "Start .NET sample app at system startup" `
                           -User         "NT AUTHORITY\SYSTEM" `
                           -RunLevel     Highest
}

# 10) Create a simulation script that loops good/bad requests every 5s
$simScript = Join-Path $appDir "simulate-traffic.ps1"
@'
$goodUrl = 'http://localhost:5000'
$badUrl  = 'http://localhost:5000/BankAccountNumber'
while ($true) {
    try {
        Invoke-WebRequest -Uri $goodUrl -UseBasicParsing -TimeoutSec 10 | Out-Null
        Write-Output "[OK]  $goodUrl"
    } catch {
        Write-Output "[ERR] $goodUrl - $($_.Exception.Message)"
    }
    try {
        Invoke-WebRequest -Uri $badUrl -UseBasicParsing -TimeoutSec 10 | Out-Null
        Write-Output "[OK]  $badUrl"
    } catch {
        Write-Output "[ERR] $badUrl - $($_.Exception.Message)"
    }
    Start-Sleep -Seconds 5
}
'@ | Set-Content $simScript

# 11) Register the simulator as a scheduled task (SYSTEM, at boot, runs once)
$simTaskName = "DotnetSampleSimulator"
if (-not (Get-ScheduledTask -TaskName $simTaskName -ErrorAction SilentlyContinue)) {
    $actionSim  = New-ScheduledTaskAction    -Execute "Powershell.exe" `
                   -Argument "-WindowStyle Hidden -File `"$simScript`""
    
    # Create a trigger that starts once at boot (no repetition needed - script has its own loop)
    $triggerSim = New-ScheduledTaskTrigger -AtStartup
    
    # Create settings to ensure it runs indefinitely
    $settings = New-ScheduledTaskSettingsSet
    $settings.ExecutionTimeLimit = "PT0S"  # No time limit (important for infinite loop)
    $settings.RestartCount = 3
    $settings.StartWhenAvailable = $true
    
    Register-ScheduledTask -TaskName     $simTaskName `
                           -Action       $actionSim `
                           -Trigger      $triggerSim `
                           -Settings     $settings `
                           -Description  "Simulate good and bad requests (runs continuously with internal loop)" `
                           -User         "NT AUTHORITY\SYSTEM" `
                           -RunLevel     Highest
}


# 12) Start the process 
Start-Process -FilePath 'Powershell.exe' -ArgumentList "-WindowStyle Hidden -File `"$launcher`""

# 12) Start the simulator 
Start-Process -FilePath 'Powershell.exe' -ArgumentList "-WindowStyle Hidden -File `"$simScript`"" 


Write-Output "All tasks registered. App and simulator will run at system startup."
