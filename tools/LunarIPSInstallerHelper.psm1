using namespace System
using namespace System.Security.Principal

#Requires -Version 5.1

enum WindowStyle {
    Default = 1
    Maximized = 3
    Minimized = 7
}

function Confirm-Administrator {
    [WindowsPrincipal]$me = [Security.Principal.WindowsIdentity]::GetCurrent()
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
        [WindowStyle]$WindowStyle = [WindowStyle]::Default,
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
    $lnk.WindowStyle = $WindowStyle
    $lnk.IconLocation = $IconLocation
    $lnk.Description = $Description
    $lnk.Save()
}