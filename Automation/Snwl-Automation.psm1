#set this for now will need to change back later
. .\variables.ps1

function Get-LoginWeb {
    $ChromeDriver = New-Object OpenQA.Selenium.Chrome.ChromeDriver
    # Invoke Selenium into our script!
    $ChromeDriver.Navigate().GoToURL("https://" + $Snwlip + "/auth.html") # Ensuring that the script ends up on the Login Page, using default X0 IP

    Start-Sleep 2 # Just waiting 2 seconds to make sure the page loads before moving forward

    $ChromeDriver.SwitchTo().Frame('authFrm') # on auth.html the login box is within an iFrame, need to set that to focus
    $ChromeDriver.FindElementByName("userName").SendKeys("admin") # Default Username after Factory Default
    $ChromeDriver.FindElementByName("pwd").SendKeys("password") # Default Password after Factory Default
    $ChromeDriver.FindElementByName("Submit").Click()

    Start-Sleep 5
}

function Close-LoginWeb {
    Function Stop-ChromeDriver { Get-Process -Name chromedriver -ErrorAction SilentlyContinue | Stop-Process -ErrorAction SilentlyContinue }
    $ChromeDriver.Close() # Close selenium browser session method
    $ChromeDriver.Quit() # End ChromeDriver process method
    Stop-ChromeDriver # Just making sure that the process is truly ended just in case the Quit did not kill the process
}

function Start-SnwlSSH {
    New-SSHSession -ComputerName $Snwlip -AcceptKey -Credential $Snwlcreds | Out-Null
    $session = Get-SSHSession -Index 0
    return $session
}

function Set-SwnlConfigFiles {

    Add-Type -AssemblyName System.Windows.Forms
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') }
    $FileBrowser.Multiselect = "true"
    $FileBrowser.Filter = "Text (*.txt)|*.txt"
    $FileBrowser.Title = "Select Config Text Files"
    $null = $FileBrowser.ShowDialog()

    return $FileBrowser.FileNames

    # foreach ($f in $FileBrowser.FileNames) {
    #     write-host $f
    # }
}

function Send-CurFacDef {
    
    New-SSHSession -ComputerName $Snwlip -AcceptKey -Credential $Snwlcreds | Out-Null

    $session = Get-SSHSession -Index 0

    for ( $stream = $session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)) {

        $verout = $stream.read() 
    
        if ($verout -match ">") {
            $stream.write("conf`n")
            Start-Sleep 1
        }

        $stream.write("boot current factory-default`n")
        Start-Sleep 1
        $Stream.write("yes`n")
    }

}

function Send-UploadedFacDef {
    
}

function Send-FirmwareUpgrade {

}

function Select-Firmware {
    Add-Type -AssemblyName System.Windows.Forms
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') }
    $FileBrowser.Multiselect = "true"
    $FileBrowser.Filter = "Firmware (*.sig)|*.sig"
    $FileBrowser.Title = "Select Firmware Sig File"
    $null = $FileBrowser.ShowDialog()

    return $FileBrowser.SafeFileName
}
