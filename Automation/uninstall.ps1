#Removes and uninstalls anything that was implemented

Remove-Module Posh-SSH
Remove-Module Snwl-Automation

Uninstall-Module Posh-SSH
Unregister-PSRepository -Name PSGallery
