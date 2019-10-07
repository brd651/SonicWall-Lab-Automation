#Dot sourcing the variables from the variables PS file
. .\variables.ps1

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
