$pp = Get-PackageParameters

# Get the specified language from package params, if provided
# Otherwise, defaulting to english
$langParam = if( $pp['Language'] ) {
  $pp['Language']
} else {
  Write-Warning 'No language was provided via package parameters, defaulting to English'
  'English'
}

Write-Host "Installing the $langParam version of Lunar IPS"

$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$unzipLocation = "$toolsDir/LunarIPS"

Import-Module "$toolsDir/LunarIPSInstallerHelper.psm1"

# URL is the same with a lang-specific zip archive
# 64-bit exe is in the same archive. Will do some magic around this later.
$url = "https://fusoya.eludevisibility.org/lips/download/$(switch( $langParam ) {
  'English' { 'lips103.zip'; break }
  'Croatian' { 'lipscr103.zip'; break }
  'Dutch' { 'lipsne103.zip'; break }
  'German' { 'lipsde103.zip'; break }
  'Portuguese' { 'lipsportbrazil103.zip'; break }
  'Spanish' { 'lipsspanish103.zip'; break }
  'Swedish' { 'lipssw103.zip'; break }

  default { throw 'Specified language must be one of the following: English, Croatian, Dutch, German, Portuguese, Spanish, or Swedish'; break }
})"

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $unzipLocation
  url           = $url
}

Install-ChocolateyZipPackage @packageArgs

# 64-bit shim blocked by .ignore files
# Create it manually because it has the same name as the 32-bit exe
$32path = "$unzipLocation/Lunar IPS.exe"
$64path = "$unzipLocation/x64/Lunar IPS.exe"
Install-BinFile 'Lunar IPS (64-bit)' -Path $64path -UseStart

# If admin, create all users icons, otherwise just for the current user
$shortcutScope = if ( Confirm-Administrator ) { 'Machine' } else { 'CurrentUser' }

# Create arguments hashtable and create 32-bit menu item
try {
  $newSMShortcutArgs = @{
    ShortcutScope = $shortcutScope
    Name          = 'Lunar IPS (32-Bit)'
    Path          = $32path
    IconLocation  = "$32path, 0" -replace '/', '\\'
    Description   = 'Lunar IPS Patching Tool by FuSoYa (32-bit)'
  }
  Write-Host 'Creating 32-bit Start Menu shortcut'
  New-StartMenuShortcut @newSMShortcutArgs
}
catch {
  Write-Error $_
  Write-Warning 'The above error is non-fatal, but the Start Menu shortcut failed to be created.'
}

try {
  $newSMShortcutArgs.Name = 'Lunar IPS (64-bit)'
  $newSMShortcutArgs.Path = $64path
  $newSMShortcutArgs.IconLocation = "$64path, 0" -replace '/', '\\'
  $newSMShortcutArgs.Description = 'Lunar IPS Patching Tool by FuSoYa (64-bit)'

  Write-Host 'Creating 64-bit Start Menu shortcut'
  New-StartMenuShortcut @newSMShortcutArgs
}
catch {
  Write-Error $_
  Write-Warning 'The above error is non-fatal, but the Start Menu shortcut failed to be created.'
}