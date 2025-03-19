# Customize these variables:
$party = "Delta Knights"                # Name of the party to be logged
$logbookPath = "$env:SystemRoot\System32\logbook.txt"  # Location of the logbook file
$updateScriptPath = "$env:ProgramData\.update_logbook.ps1"  # Path for the hidden update script
$taskName = "LogbookUpdateTask"        # Task name for the scheduled task

# Step 1: Create the hidden update script that changes the first line of the logbook
$updateScriptContent = @"
# PowerShell script to update the logbook with the party's name.
\$party = '$party'  
\$logbookPath = '$logbookPath'

# Read the logbook, modify the first line, and write it back
\$content = Get-Content -Path \$logbookPath
\$content[0] = \$party
Set-Content -Path \$logbookPath -Value \$content
"@

# Create the update script as a hidden file
$updateScriptContent | Out-File -FilePath $updateScriptPath -Force

# Make the update script hidden by setting its attribute
Set-ItemProperty -Path $updateScriptPath -Name Attributes -Value "Hidden, ReadOnly"

Write-Host "Hidden update script has been created."

# Step 2: Create a scheduled task to run the update script every minute
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$updateScriptPath`""
$trigger = New-ScheduledTaskTrigger -AtStartup
$trigger.RepetitionInterval = New-TimeSpan -Minutes 1
$trigger.RepetitionDuration = New-TimeSpan -Days 1

# Create the scheduled task to run under SYSTEM account (to run with elevated privileges)
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteriesLow $true -DontStopIfGoingOnBatteries $true
$taskPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount

# Register the scheduled task
Register-ScheduledTask -Action $action -Principal $taskPrincipal -Trigger $trigger -Settings $taskSettings -TaskName $taskName

Write-Host "Secret scheduled task to update logbook has been created."


