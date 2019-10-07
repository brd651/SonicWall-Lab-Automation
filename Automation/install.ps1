#Setting up for Selenium

$currentdir = Get-Location

$env:PATH += ";" + $currentdir + "\Selenium" # Adds the path for ChromeDriver.exe to the environmental variable 
$dll = $currentdir + ".\Selenium\WebDriver.dll"
Add-Type -Path $dll  # Adding Selenium's .NET assembly (dll) to access it's classes in this PowerShell session

#Setup for PoSH-SSH
Set-PSrepository -Name PSGallery -InstallationPolicy Trusted
Set-ExecutionPolicy Unrestricted CurrentUser
Install-Module Posh-SSH -RequiredVersion 2.0.2
Import-Module Posh-SSH

<#
Importing the Functions that are using in these scripts, eventually everything will have its own module for use
Plan is to make it so that you can go into Powershell then just do Start-SnwlFacDef 192.168.168.168 and it will go to that unit an factory default
or more in-depth of doing Start-SnwlFacDefnConf -ip 192.168.168.168 -config Full/IP-only or whatever
#>
Import-Module -Name .\Snwl-Automation.psm1 -Verbose
