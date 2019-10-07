#Dot sourcing the variables from the variables PS file
. .\variables.ps1

$firmware = "tz-300_6.5.4.4_44n.sig" #Select-Firmware

$ftpserver = "ftp://" + $ftpUN + ":" + $ftpPass + "@" + $ftpIP + "/" + $firmware

New-SSHSession -ComputerName $Snwlip -AcceptKey -Credential $Snwlcreds | Out-Null
$session = Get-SSHSession -Index 0
$stream = $session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)

#there are a lot of sleeps after every command cause the reads happen instantly 
#and there is like a .4 second delay in execution so gotta wait a second before reading output
Start-Sleep 1
$verout = $stream.read() 
Write-Host $verout

if ($verout -match ">") {
    $stream.write("conf`n")
    Start-Sleep 1
}

Start-sleep 1 
$preemptcheck = $stream.read()
write-host $preemptcheck
Start-Sleep 1

if ($preemptcheck -match "preempt") {
    $stream.write("yes`n")
}

Start-Sleep 1 
$stream.write("`n")
Start-Sleep 1 
$mgmtcheck = $stream.read()

if ($mgmtcheck -match "#") {      
    Write-Host "Importing Firmware"
    $stream.write("import firmware ftp " + $ftpserver + "`n")
    Start-Sleep 15
}

$wait = "a"
# Just waiting to make sure the firmware gets uploaded, this should take like less than 30 seconds but if the connection is slow this will take longer
while ($wait -ne "b") {
    $stream.write("`n")
    Start-Sleep 1 
    $firmcheck = $stream.read()
    write-host $firmcheck

    if ($firmcheck -match "successfully") {
        Start-Sleep 1
        write-host "booting"
        $stream.write("boot uploaded factory-default`n")
        Start-sleep 1
        $stream.write("yes`n")
        Start-sleep 600
        $wait = "b"
    }
    else {
        Start-Sleep 5
        write-host "more time neded"
    }
}

<# 
This is too make sure the session does not get closed early, 
if it does it may brick the box then you will have to go into the X0 
and upload firmware again and then boot to factory default because 
the box is messed up
REMINDER: DO NOT USE THIS SCRIPT IN PRODUCTION THIS IS FOR LAB USE ONLY!!!!!! YOU HAVE BEEN WARNED AGAIN!!!!
#>
while ($wait -ne "c") {
    $stream.write("`n")
    $bootchk = $stream.read()
    if ($bootchk -match "User:") {
        $wait = "c"
    }
    else {
        Start-Sleep 15
    }
}

#Session Clean Up
Remove-SSHSession 0 | Out-Null
