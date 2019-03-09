try
{
add-type -path "C:\Users\Adrian\source\repos\soapyfrog\grrr\grrr-snapin-solution\grrr-snapin\bin\Release\Soapyfrog.Grrr.dll"
}
catch [System.Reflection.ReflectionTypeLoadException]
{
   Write-Host "Message: $($_.Exception.Message)"
   Write-Host "StackTrace: $($_.Exception.StackTrace)"
   Write-Host "LoaderExceptions: $($_.Exception.LoaderExceptions)"
}