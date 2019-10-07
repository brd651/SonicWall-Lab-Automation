#SonicWall Connection related Variables
$Snwlip = "10.1.1.227"  #This is the IP that you will be connecting to 
$SnwlUN = "admin"
$SnwlPass = "password" | ConvertTo-SecureString -AsPlainText -Force
$Snwlcreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SnwlUN, $SnwlPass

#SonicWall Factory Default Creds
$FacDefSnwlUN = "admin"
$FacDefSPass = "password" | ConvertTo-SecureString -AsPlainText -Force
$FacDefScreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SnwlUN, $SnwlPass

#MySonicWall Credentials Variables
$mswUN = "test@test.com"
$mswPass = "password" | ConvertTo-SecureString -AsPlainText -Force

#FTP Server releated Variables
$ftpIP = "192.168.168.62"  #put the IP of the FTP server
$ftpUN = "snwl"
$ftpPass = "password"

#Selenium Variables
$dll = ".\Selenium\WebDriver.dll"
Add-Type -Path $dll  # Adding Selenium's .NET assembly (dll) to access it's classes in this PowerShell session
