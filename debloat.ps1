# =========================================================
# Windows 11 Ultimate Debloat + Privacy Script
# Includes:
# - App Debloat
# - Telemetry Disable
# - Copilot Disable
# - OneDrive Removal
# - Start Menu Ads Disable
# - Widgets Disable
# - Game DVR Disable
# - Temp Cleanup
# - Progress Bar
#
# Run as Administrator
# =========================================================

$ErrorActionPreference = "SilentlyContinue"

# ---------------------------------------------------------
# FUNCTIONS
# ---------------------------------------------------------

function Step {
    param (
        [string]$Message,
        [int]$Percent
    )

    Write-Progress -Activity "Windows 11 Debloat & Privacy Setup" `
        -Status $Message `
        -PercentComplete $Percent

    Write-Host ""
    Write-Host "[$Percent%] $Message" -ForegroundColor Cyan
}

# ---------------------------------------------------------
# START
# ---------------------------------------------------------

Clear-Host

Write-Host ""
Write-Host "===================================================" -ForegroundColor Green
Write-Host "      WINDOWS 11 ULTIMATE DEBLOAT SCRIPT"
Write-Host "===================================================" -ForegroundColor Green
Write-Host ""

# ---------------------------------------------------------
# APPS TO REMOVE
# ---------------------------------------------------------

$apps = @(
    "*3DBuilder*"
    "*549981C3F5F10*"        # Cortana - AI slop
    "*BingFinance*"
    "*BingNews*"
    "*BingSports*"
    "*BingWeather*"
    "*Clipchamp*"
    "*Copilot*"
    "*DevHome*"
    "*Disney*"
    "*Facebook*"
    "*GetHelp*"
    "*Getstarted*"
    "*LinkedIn*"
    "*MicrosoftOfficeHub*"
    "*MicrosoftSolitaireCollection*"
    "*MicrosoftStickyNotes*"
    "*MixedReality*"
    "*MSPaint*"
    "*Office.OneNote*"
    "*OneConnect*"
    "*OutlookForWindows*"
    "*People*"
    "*PowerAutomate*"
    "*QuickAssist*"
    "*SkypeApp*"
    "*Spotify*"
    "*Teams*"
    "*TikTok*"          
    "*Todos*"
    "*WindowsAlarms*"
    "*WindowsCamera*"
    "*windowscommunicationsapps*"
    "*WindowsFeedbackHub*"
    "*WindowsMaps*"
    "*WindowsSoundRecorder*"
    "*Xbox*"
    "*YourPhone*"
    "*ZuneMusic*"
    "*ZuneVideo*"
)

$totalApps = $apps.Count
$currentApp = 0

# ---------------------------------------------------------
# REMOVE APPS
# ---------------------------------------------------------

foreach ($app in $apps) {

    $currentApp++
    $progress = [math]::Round(($currentApp / $totalApps) * 50)

    Step "Removing $app" $progress

    try {

        Get-AppxPackage -AllUsers -Name $app |
            Remove-AppxPackage -AllUsers

        Get-AppxProvisionedPackage -Online |
            Where-Object { $_.DisplayName -like $app } |
            Remove-AppxProvisionedPackage -Online

    } catch {
        Write-Host "Skipped $app" -ForegroundColor DarkGray
    }
}

# ---------------------------------------------------------
# TELEMETRY
# ---------------------------------------------------------

Step "Disabling telemetry..." 55

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
/v AllowTelemetry /t REG_DWORD /d 0 /f | Out-Null

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" `
/v AllowTelemetry /t REG_DWORD /d 0 /f | Out-Null

# ---------------------------------------------------------
# START MENU ADS / SUGGESTIONS
# ---------------------------------------------------------

Step "Disabling Start menu ads and suggestions..." 60

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
/v SubscribedContent-338388Enabled /t REG_DWORD /d 0 /f | Out-Null

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
/v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f | Out-Null

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
/v Start_IrisRecommendations /t REG_DWORD /d 0 /f | Out-Null

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
/v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f | Out-Null

# ---------------------------------------------------------
# WIDGETS
# ---------------------------------------------------------

Step "Disabling Widgets..." 65

reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" `
/v AllowNewsAndInterests /t REG_DWORD /d 0 /f | Out-Null

# ---------------------------------------------------------
# COPILOT
# ---------------------------------------------------------

Step "Disabling Copilot..." 70

reg add "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot" `
/v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f | Out-Null

# ---------------------------------------------------------
# GAME DVR
# ---------------------------------------------------------

Step "Disabling Game DVR..." 75

reg add "HKCU\System\GameConfigStore" `
/v GameDVR_Enabled /t REG_DWORD /d 0 /f | Out-Null

reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" `
/v AppCaptureEnabled /t REG_DWORD /d 0 /f | Out-Null

# ---------------------------------------------------------
# ONEDRIVE
# ---------------------------------------------------------

Step "Removing OneDrive..." 80

taskkill /f /im OneDrive.exe

Start-Process "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" `
"/uninstall" `
-NoNewWindow `
-Wait

# ---------------------------------------------------------
# EDGE BACKGROUND SERVICES
# ---------------------------------------------------------

Step "Disabling Edge background services..." 85

reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" `
/v StartupBoostEnabled /t REG_DWORD /d 0 /f | Out-Null

reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" `
/v BackgroundModeEnabled /t REG_DWORD /d 0 /f | Out-Null

# ---------------------------------------------------------
# HIBERNATION
# ---------------------------------------------------------

Step "Disabling hibernation..." 90

powercfg -h off

# ---------------------------------------------------------
# TEMP FILE CLEANUP
# ---------------------------------------------------------

Step "Cleaning temporary files..." 95

Remove-Item "$env:TEMP\*" -Recurse -Force
Remove-Item "C:\Windows\Temp\*" -Recurse -Force

# ---------------------------------------------------------
# COMPLETE
# ---------------------------------------------------------

Step "Finishing..." 100

Write-Progress -Activity "Windows 11 Debloat & Privacy Setup" -Completed

Write-Host ""
Write-Host "===================================================" -ForegroundColor Green
Write-Host "               COMPLETE"
Write-Host "===================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Recommended:"
Write-Host " - Restart your PC"
Write-Host " - Run Windows Update once"
Write-Host " - Restart again"
Write-Host ""
