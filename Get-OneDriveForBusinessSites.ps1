# Specifies the URL for your organization's SPO admin service
$AdminURI = "https://dclsstaff-admin.sharepoint.com"

# Specifies the User account for an Office 365 global admin in your organization
Write-Host Office 365 Global Admin Credentials
Write-Host -NoNewLine Username:
$AdminAccount = Read-Host
Write-Host -NoNewLine Password:
$AdminPass = Read-Host -asSecureString

# Specifies the location where the list of MySites should be saved
$LogFile = '.\ListOfMysites.txt'
# Begin the process
$loadInfo1 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
$loadInfo2 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")
$loadInfo3 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.UserProfiles")

$creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($AdminAccount, $AdminPass) # Take the AdminAccount and the AdminAccount password, and create a credential

$proxyaddr = "$AdminURI/_vti_bin/UserProfileService.asmx?wsdl"
$UserProfileService= New-WebServiceProxy -Uri $proxyaddr -UseDefaultCredential False # Add the path of the User Profile Service to the SPO admin URL, then create a new webservice proxy to access it
$UserProfileService.Credentials = $creds

# Set variables for authentication cookies
$strAuthCookie = $creds.GetAuthenticationCookie($AdminURI)
$uri = New-Object System.Uri($AdminURI)
$container = New-Object System.Net.CookieContainer
$container.SetCookies($uri, $strAuthCookie)
$UserProfileService.CookieContainer = $container

# Sets the first User profile, at index -1
$UserProfileResult = $UserProfileService.GetUserProfileByIndex(-1)

Write-Host "Starting- This could take a while."

$NumProfiles = $UserProfileService.GetUserProfileCount()
$i = 1

# As long as the next User profile is NOT the one we started with (at -1)...
While ($UserProfileResult.NextValue -ne -1) 
{
  Write-Host "Examining profile $i of $NumProfiles"  
  $Prop = $UserProfileResult.UserProfile | Where-Object { $_.Name -eq "PersonalSpace" } # Look for the Personal Space object in the User Profile and retrieve it (PersonalSpace is the name of the path to a user's OneDrive for Business site. Users who have not yet created a OneDrive for Business site might not have this property set.)
  $Url= $Prop.Values[0].Value
  If ($Url) { # If "PersonalSpace" (which we've copied to $Url) exists, log it to our file...
    $Url | Out-File $LogFile -Append -Force 
  }
  $UserProfileResult = $UserProfileService.GetUserProfileByIndex($UserProfileResult.NextValue) # And now we check the next profile the same way...
  $i++
}

Write-Host "Done!"