param([switch]$reregister)
$DebugPreference="continue"
$ErrorActionPreference="stop"



cd 'C:\Documents and Settings\adrian\My documents\Projects\grrr-trunk\demos\biginvaders'

$registered = Get-PSSnapin -registered | where {$_.name -ieq "soapyfrog.grrr"}
if ($reregister -or !$registered) {
  if (!$registered) { write-host -f cyan "Not currently registered." }
  write-host -f cyan "Registering..." 
  $iupath = (resolve-path $env:windir\Microsoft.NET\Framework\v2*\installutil.exe | sort path | select -last 1)
  if (!$iupath) { write-error "Can't find installutil.exe" }
  & $iupath "C:\Documents and Settings\adrian\My Documents\Projects\grrr-trunk\grrr-snapin-solution\grrr-snapin\bin\Release\Soapyfrog.Grrr.dll" }

$added = Get-PSSnapin | where {$_.name -ieq "soapyfrog.grrr" }
if (!$added) {
  write-host -f cyan "Adding Snapin..."
  add-pssnapin Soapyfrog.Grrr
}

write-host -f cyan "Snapin added"
