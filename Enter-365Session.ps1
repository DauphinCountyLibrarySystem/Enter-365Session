# Write-Host "the following credential needs to be entered as <username>@<domain>"
# Write-Host "Press any key to continue ..."
# $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# $UserCredential = Get-Credential
$ErrorActionPreference = "Stop"


[string]$user = [Environment]::UserName+'@'+(Get-ADDomain).DNSRoot

Try {
  $pass = cat $PSScriptRoot'\securestring.txt' | ConvertTo-SecureString
} Catch {
  Write-Output " "
  Write-Output "Failed to retrieve passsword from securestring.txt. Maybe try a new password?"
  Read-Host " " -AsSecureString | ConvertFrom-SecureString | Out-File $PSScriptRoot'\securestring.txt'
  Try {
    $pass = cat $PSScriptRoot'\securestring.txt' | ConvertTo-SecureString
    } Catch {
      Write-Output "Well clearly that didn't work."
      Write-Error $_.Exception
    }
}

$UserCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user,$pass

Try {
  
  $global:Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/?proxymethod=rps -Credential $UserCredential -Authentication Basic -AllowRedirection
  Import-PSSession $global:Session
  
} Catch {
  
  Write-Error $_.Exception
  Write-Output Exiting.
  Exit
  
}

Write-Output " "
Write-Output .
Write-Output 'Remember to close session with: Get-PSSession | Remove-PSSession'

Function Global:prompt {
  Write-Host '[Office365] &'$pwd.ProviderPath -NoNewLine -ForegroundColor "DarkGray"
  Write-Host "`n>" -NoNewLine -ForegroundColor "DarkGray"
  Return ' '
}