#Requires -Version 4.0

function Confirm-Administrator {
    [Security.Principal.WindowsPrincipal]$me = [Security.Principal.WindowsIdentity]::GetCurrent()
    $me.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}


function New-StartMenuShortcut {
    Param(
        [ValidateSet('Machine', 'CurrentUser')]
        [string]$ShortcutScope = 'Machine',
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [string]$Path,
        [string]$Arguments,
        [string]$WorkingDirectory,
        [ValidateSet('Default', 'Maximimed', 'Minimized')]
        [string]$WindowStyle = 'Default',
        [string]$IconLocation,
        [string]$Description
    )

    # Get the appdata folder to use based on machine or current user scope
    $useAppData = switch ( $ShortcutScope ) {
        'Machine' {
            $env:ALLUSERSPROFILE
            break
        }

        'CurrentUser' {
            $env:AppData
            break
        }

        default {
            throw 'Invalid ShortcutScope'
        }
    }

    # Shortcut folder path and name 
    $lnkFolder = "$useAppData/Microsoft/Windows/Start Menu/Programs/Lunar IPS"
    $lnkName = "$Name.lnk"
    $lnkFullPath = "$lnkFolder/$lnkName"

    if( Test-Path $lnkFullPath -PathType Leaf ) {
        Write-Warning "Shortcut already exists at '$lnkFullPath'. Removing before creating new shortcut."
        Remove-Item -Force $lnkFullPath
    }

    # Determine correct WindowStyle Value
    # 1 is Default
    # 3 is Minimized
    # 7 is Maximized
    # This was an enum but community packages must be 4.0 compliant
    $useWindowStyle = switch( $WindowStyle ) {
        'Default' { 1; break }
        'Minimized' { 3; break }
        'Maximized' { 7; break }
        default { throw 'Unknown WindowStyle specified' }
    }

    # For some reason the Windows Scripting Host remains the only way to create
    # .lnk files outside of the Win32 API 
    $shell = New-Object -ComObject 'WScript.Shell'

    if ( !( Test-Path $lnkFolder -PathType Container ) ) {
        Write-Warning "Creating folder for Start Menu shortcuts at '$lnkFolder'"
        mkdir $lnkFolder -Force -EA Stop | Out-Null
    }
    $lnk = $Shell.CreateShortcut($lnkFullPath)

    $lnk.TargetPath = $Path
    $lnk.Arguments = $Arguments
    $lnk.WorkingDirectory = $WorkingDirectory
    $lnk.WindowStyle = $useWindowStyle
    $lnk.IconLocation = $IconLocation
    $lnk.Description = $Description
    $lnk.Save()
}