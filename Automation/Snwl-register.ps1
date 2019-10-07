#Dot sourcing the variables from the variables PS file
. .\variables.ps1

#Getting MySonicWall Creds
Function Get-Creds {
    while ([string]::IsNullOrEmpty($mswUN)) {
        $mswUN = Read-Host -Prompt "MySonicWall.com Username"
    }

    $tempasshold = $null

    while ([string]::IsNullOrEmpty($tempasshold)) {
        if ($null -eq $mswPass) {
            $mswPass = Read-Host -Prompt "MySonicWall.com Password" -AsSecureString
        }
        $creds = New-Object System.Management.Automation.PSCredential("username", $mswPass) # changing password to cleartext via PScred object to see if it has a value
        $tempasshold = $creds.GetNetworkCredential().Password
    }
    return  $mswUN, $tempasshold
}

while ([string]::IsNullOrEmpty($Snwlip)) {
    $Snwlip = Read-Host -Prompt "What is the IP of your SonicWall"
}

#execute Get-Creds for getting the MSW info
$mswUN, $mswPass = Get-Creds
# MswInput is the function for handling the input of creds for MySonicWall.com and handling the Registration pages
Function MswInput {
    Start-Sleep 5

    $ChromeDriver.FindElementByName('login').SendKeys($mswUN)
    $ChromeDriver.FindElementByName("pwd").SendKeys($mswPass)
    $ChromeDriver.FindElementByName("Submit").Click()

    Start-Sleep 5
    if ($ChromeDriver.Url -match "servlet/dea/register") {
        $ChromeDriver.Navigate().GoToURL("https://" + $Snwlip + "/main.html")
    }
    else {
        $ChromeDriver.FindElementByClassName("snwl-btn snwl-btn-primary").Click()
    }
}

# Invoke Selenium into our script!
$ChromeDriver.Navigate().GoToURL("https://" + $Snwlip + "/auth.html") # Ensuring that the script ends up on the Login Page, using default X0 IP

Start-Sleep 2 # Just waiting 2 seconds to make sure the page loads before moving forward

$ChromeDriver.SwitchTo().Frame('authFrm') # on auth.html the login box is within an iFrame, need to set that to focus
$ChromeDriver.FindElementByName("userName").SendKeys("admin") # Default Username after Factory Default
$ChromeDriver.FindElementByName("pwd").SendKeys("password") # Default Password after Factory Default
$ChromeDriver.FindElementByName("Submit").Click()

Start-Sleep 5

if ($ChromeDriver.Url -match "/main.html" ) {
    $ChromeDriver.Navigate().GoToURL("https://" + $Snwlip + "/Security_Services/Registration.html")
    MswInput
}
else {
    $ChromeDriver.FindElementById("regNowButt").Click() # sometimes there is a Registration screen that will appear at first login, this clicks the Register Button
    MswInput
}

Start-Sleep 5

#Checking for Error Messages when Trying to Register the SonicWall Appliance
# Will implement this error checking later, for now on JUST ENTER THE PROPER CREDS FOR YOUR BOX
######################################################
#NEED TO CHECK THIS I THINK THIS PART DOESNT NOT WORK#
######################################################

# $ChromeDriver.FindElementByXPath("dfsfdsafdas").

# if ($ChromeDriver.PageSource().contains("MySonicWall username/email or Password is incorrect")) {
#     Write-Host "MySonicWall username/email or Password is incorrect"
#     $mswUN, $mswPass = $null
#     Get-Creds
# }
# elseif ($ChromeDriver.PageSource().contains("The Serial Number is not associated with this user.")) {
#     Write-Host "The Serial Number is not associated with this user"
#     $mswUN, $mswPass = $null
#     Get-Creds
# }

#Double-checking to make sure the box is actually licesned, if there is no table on this page then that means the box didn't successfully license

$ChromeDriver.Navigate().GoToURL("https://" + $Snwlip + "/activationView.html")

Pause
Function Stop-ChromeDriver { Get-Process -Name chromedriver -ErrorAction SilentlyContinue | Stop-Process -ErrorAction SilentlyContinue }
$ChromeDriver.Close() # Close selenium browser session method
$ChromeDriver.Quit() # End ChromeDriver process method
Stop-ChromeDriver # Just making sure that the process is truly ended just in case the Quit did not kill the process
