# Define the secure passwords (assuming already securely set)
$BloodhunterPassword = ConvertTo-SecureString "peper0nc1nohydrangeadiox1de" -AsPlainText -Force
$LCoramarPassword = ConvertTo-SecureString "austra1iapengu1nkagur@" -AsPlainText -Force

# Secure the "bloodhunter" user
Set-LocalUser -Name "bloodhunter" -PasswordNeverExpires $false   # Ensure password expires
Set-LocalUser -Name "bloodhunter" -Password $BloodhunterPassword # Ensure the password is securely set
Set-LocalUser -Name "bloodhunter" -CannotChangePassword $false   # Allow user to change their password (change to $true if needed)

# Secure the "LCoramar" admin user
Set-LocalUser -Name "LCoramar" -PasswordNeverExpires $false    # Ensure password expires
Set-LocalUser -Name "LCoramar" -Password $LCoramarPassword    # Ensure the password is securely set
Set-LocalUser -Name "LCoramar" -CannotChangePassword $true    # Prevent admin from changing their password (adjust as needed)

# Enforce strong password complexity requirement (if not already enabled via Group Policy)
# This will ensure passwords must meet complexity requirements: upper/lowercase, numbers, and symbols
secpol.msc  # Opens the Local Security Policy (manual verification)

# Set account lockout policy: lock account after 3 failed attempts
net accounts /lockoutthreshold:3
net accounts /lockoutduration:30
net accounts /lockoutwindow:30

# Disable the local "Guest" account
Write-Host "Disabling the 'Guest' account..."
Disable-LocalUser -Name "Guest"

# Disable the local "Administrator" account
Write-Host "Disabling the 'Administrator' account..."
Disable-LocalUser -Name "Administrator"

# Review and verify the created users and groups
Write-Host "Review created users and groups:"
Get-LocalUser
Get-LocalGroupMember -Group "Administrators"
Get-LocalGroupMember -Group "Users"



