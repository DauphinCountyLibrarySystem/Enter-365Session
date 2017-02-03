Write-Host Importing 'C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell'
Import-Module 'C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell'
Write-Host Importing 'C:\Users\lbodnyk\AppData\Local\Apps\SharePointPnPPowerShellOnline\Modules\SharePointPnPPowerShellOnline'
Import-Module 'C:\Users\lbodnyk\AppData\Local\Apps\SharePointPnPPowerShellOnline\Modules\SharePointPnPPowerShellOnline'

# Write-Host "the following credential needs to be entered as <username>@<domain>"
# Write-Host "Press any key to continue ..."
# $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# $UserCredential = Get-Credential
Write-Host Using current user and '.\string.txt' to create credentials...
[string]$user = [Environment]::UserName+'@'+(Get-ADDomain).DNSRoot
$pass = cat $PSScriptRoot'\string.txt' | ConvertTo-SecureString
$UserCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user,$pass
Write-Host Trying to connect to SharePoint Online...
Try {
  
  # Connect-PnPOnline -Url https://dclsstaff-admin.sharepoint.com -Credential $UserCredential
  Connect-PnPOnline -Url https://dclsstaff.sharepoint.com -Credential $UserCredential

  # Connect-SPOService -Url https://dclsstaff-admin.sharepoint.com -Credential $UserCredential

  # $global:Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/?proxymethod=rps -Credential $UserCredential -Authentication Basic -AllowRedirection
  # Import-PSSession $global:Session
  
} Catch {
  
  Write-Error $_.Exception
  Exit
  
}

Write-Output " "
# Write-Output .
# Write-Output 'Remember to close session with: Get-PSSession `| Remove-PSSession'

Function Global:prompt {
	Write-Host '[SharePoint] &'$pwd.ProviderPath -NoNewLine -ForegroundColor "DarkGray"
	Write-Host "`n>" -NoNewLine -ForegroundColor "DarkGray"
	Return ' '
}