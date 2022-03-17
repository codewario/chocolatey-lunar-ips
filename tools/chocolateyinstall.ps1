$pp = Get-PackageParameters

# Get the specified language from package params, if provided
# Otherwise, defaulting to english
$langParam = if ( $pp['Language'] ) {
  $pp['Language']
}
else {
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
# Calculated checksum is SHA-512
$filename, $checksum = switch( $langParam ) {
  'English' { 'lips103.zip', '39fe9614d9f4a2793f778a0c41eeda1681a953ef9b6cc4a41c2ce518dc55465e1257ee7b97d7ff005770468ef31a9f0a8b2c58fb36a61fcc3faab3b8f23a636d'; break }
  'Croatian' { 'lipscr103.zip', '46e9279f2cd329e7c5f07f44fffc58273e71b11b58c9356699b48c1452acb7e7da4b2ddc6ca5eb364e4a080c57714a50c60c7fc28c730271e691ad4b0ab0443c'; break }
  'Dutch' { 'lipsne103.zip', 'bae670232e0ab45f9bbd992f08932d2719fe24ee8685e21e371b6905862947b6cf05ed9bb903d95bf5f4d6a297cbe5faa794beb6e2ec4ce4fa27a28ca272dfe3'; break }
  'German' { 'lipsde103.zip', 'fd807ec3b529d27eea476a0bc39ac7711366e893c9364d33125f6a726129b91d099247f49d87988d0141f5ea1daecd43619ec0b000365d266a2ca0431a795afb'; break }
  'Portuguese' { 'lipsportbrazil103.zip', 'f7586a37418484ad055a21c2ab5c2935a222d452d47056516e2531b468c13590ec349e104a6d6c41f9e1621c87d2e2d3b056ef5209c83d1682a52a7c5b6bf5d1'; break }
  'Spanish' { 'lipsspanish103.zip', '005e0d05795f26a4fa7a1facf33f8036f8a5ae3c49a2dfe84e46592b35653b90f254ac40b36015e1e154319b1f7221b74b0c3a422556c7c2c68835439039f49b'; break }
  'Swedish' { 'lipssw103.zip', '8b2929c3c920529f49b6167c36b670587c33b2c98a009ce0ef146c33a754583668af7f834183db9c9e9ea83024d9eef20ab5ea52ef40e87c08dd71bb90d56831'; break }

  default { throw 'Specified language must be one of the following: English, Croatian, Dutch, German, Portuguese, Spanish, or Swedish'; break }
}

$url = "https://fusoya.eludevisibility.org/lips/download/$filename"

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $unzipLocation
  url           = $url
  checksum      = $checksum
  checksumType  = 'sha512'
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