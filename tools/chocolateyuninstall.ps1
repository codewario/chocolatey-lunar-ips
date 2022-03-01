$ErrorActionPreference = 'Stop'

# We need to remove the manually generated shim for the 64-bit version
Uninstall-BinFile 'Lunar IPS (64-bit)'

# Remove the start menu shortcuts
"$env:ALLUSERSPROFILE",
$env:AppData | Foreach-Object {
  if ( Test-Path -PathType 'Container' ( $removePath = "$_/Microsoft/Windows/Start Menu/Programs/Lunar IPS" ) ) {
    Write-Host "Removing Start Menu shortcuts from '$removePath'"
    try {
      Remove-Item -Recurse -Force $removePath -EA Stop
    }
    catch {
      # A warning is sufficient in case the user installed as admin and removed as non-admin, or vice versa
      Write-Warning "Unable to remove Start Menu shortcuts from '$removePath': $_"
    }
  }
}