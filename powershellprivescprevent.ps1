# Ensure the base registry path exists
if (-not (Test-Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer')) {
    New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Force
}

# Ensure the DisallowRun key exists
if (-not (Test-Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun')) {
    New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun' -Force
}

# Set the DisallowRun policy to 1 (enabled)
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'DisallowRun' -Value 1

# Add "powershell.exe" to the DisallowRun list to prevent running PowerShell
New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun' -Name "powershell.exe" -Value "powershell.exe" -PropertyType String -Force

Write-Host "PowerShell has been successfully restricted for the user."
