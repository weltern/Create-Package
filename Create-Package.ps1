<#
.SYNOPSIS
    This script creates either a self-extracting (SFX) package using WinRAR or a Win32 package for Intune deployment.

.DESCRIPTION
    The script automates the creation of a deployment package. Depending on the specified parameters, it can create a 
    self-extracting (SFX) archive using WinRAR or a Win32 package for Intune.

.PARAMETER PackageName
    The name of the package to be created. This is a mandatory parameter.

.PARAMETER PackageSource
    The source directory containing the files to be included in the package. Defaults to "$PSScriptRoot\Source".

.PARAMETER SFXPackage
    Boolean flag indicating whether to create a self-extracting (SFX) package. Part of the "SFX" parameter set.

.PARAMETER winRARPath
    The path to the WinRAR executable. Defaults to "$env:ProgramFiles\WinRAR\WinRAR.exe".

.PARAMETER destinationSFXPackagePath
    The destination directory for the created SFX package. Defaults to "$PSScriptRoot\SFX\Builds".

.PARAMETER winRARWebPath
    The URL to download WinRAR if it is not found on the system. Defaults to "https://www.win-rar.com/fileadmin/winrar-versions/winrar-x64-701.exe".

.PARAMETER winRARSFXPath
    The path to the SFX module for WinRAR. Defaults to "$env:ProgramFiles\WinRAR\Zip.sfx".

.PARAMETER winRarSFXOptions
    The path to the options file for the SFX package. Defaults to "$PSScriptRoot\SFX\sfxoptions.txt".

.PARAMETER icon
    The path to the icon file to be used for the SFX package. Defaults to "$PSScriptRoot\Configuration\RJ-32x32.ico".

.PARAMETER win32Package
    Boolean flag indicating whether to create a Win32 package for Intune. Part of the "Win32" parameter set.

.PARAMETER intuneWinAppUtil
    The path to the Intune Win32 Content Prep Tool executable. Defaults to "$env:ProgramFiles\Intune\IntuneWinAppUtil.exe".

.PARAMETER intuneWinAppUtilWebPath
    The URL to download the Intune Win32 Content Prep Tool if it is not found on the system. 
    Defaults to "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/tags/v1.8.6.zip".

.PARAMETER destinationWin32Package
    The destination directory for the created Win32 package. Defaults to "$PSScriptRoot\Intune\Builds".

.PARAMETER intuneWinAppSetupFile
    The setup file to be used by the Intune Win32 Content Prep Tool. Defaults to "Deploy-Application.exe".

.EXAMPLE
    .\Create-Package.ps1 -PackageName "MyApp" -SFXPackage $true

    Creates a self-extracting package named "MyApp.exe" using the files from the default source directory.

.EXAMPLE
    .\Create-Package.ps1 -PackageName "MyApp" -win32Package $true

    Creates a Win32 package for Intune deployment named "MyApp.intunewin" using the files from the default source directory.

.NOTES
    Ensure that the WinRAR executable and the Intune Win32 Content Prep Tool are accessible or provide valid download URLs.
    The script logs all operations to the Logs directory under the script root.

    Script Author: Nick Welter
    Script Created: 06/11/2024
    Script Update: 06/11/2024
    Script Version: 1.0.0

    Exit Codes:
    1810001 - Failed to download WinRAR
    1810002 - Failed to install WinRAR
    1810003 - SFX Module not found
    1810004 - Failed to download IntuneWinAppUtil
    1810005 - Failed to extract IntuneWinAppUtil
    1810006 - Failed to set intuneWinAppUtil variable
    1810007 - Failed to create SFX package
    1810008 - Failed to create Intune Win32 package
#>

Param(
    [Parameter(Mandatory = $true)]
    [string]$PackageName,
    [Parameter(Mandatory = $false)]
    [string]$PackageSource = "$($PSScriptRoot)\Source",
    [Parameter(Mandatory = $false)]
    [Parameter(ParameterSetName ="SFX", Mandatory = $false)]
    [bool]$SFXPackage = $false,
    [Parameter(ParameterSetName = "SFX", Mandatory = $false)]
    [string]$winRARPath = "$env:ProgramFiles\WinRAR\WinRAR.exe",
    [Parameter(ParameterSetName = "SFX", Mandatory = $false)]
    [string]$destinationSFXPackagePath = "$($PSScriptRoot)\SFX\Builds",
    [Parameter(ParameterSetName = "SFX", Mandatory = $false)]
    [string]$winRARWebPath = "https://www.win-rar.com/fileadmin/winrar-versions/winrar-x64-701.exe",
    [Parameter(ParameterSetName = "SFX", Mandatory = $false)]
    [string]$winRARSFXPath = "$env:ProgramFiles\WinRAR\Zip.sfx",
    [Parameter(ParameterSetName = "SFX", Mandatory = $false)]
    [string]$winRarSFXOptions = "$($PSScriptRoot)\SFX\sfxoptions.txt",
    [Parameter(ParameterSetName = "SFX", Mandatory = $false)]
    [string]$icon = "$($PSScriptRoot)\Configuration\YourIcon.ico",
    [Parameter(ParameterSetName ="Win32",Mandatory = $false)]
    [bool]$win32Package = $false,
    [Parameter(ParameterSetName = "Win32", Mandatory = $false)]
    [string]$intuneWinAppUtil = "$env:ProgramFiles\Intune\IntuneWinAppUtil.exe",
    [Parameter(ParameterSetName = "Win32", Mandatory = $false)]
    [string]$intuneWinAppUtilWebPath = "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/tags/v1.8.6.zip",
    [Parameter(ParameterSetName = "Win32", Mandatory = $false)]
    [string]$destinationWin32Package = "$($PSScriptRoot)\Intune\Builds",
    [Parameter(ParameterSetName = "Win32", Mandatory = $false)]
    [string]$intuneWinAppSetupFile = "Deploy-Application.exe"
)
Begin {
    #- SFX Configuration
    if ($SFXPackage) {
        # Setup WinRAR variables
        $destinationSFXPackage = "$($destinationSFXPackagePath)\$PackageName.exe"
        $winRARXFXArgs = "a -x@""$($PSScriptRoot)\SFX\sfxexclude.txt"" -afzip -cfg- -ed -ep1 -k -m5 -r -tl -iicon""$icon"" ""-sfx$winRARSFXPath"" ""-z$winRarSFXOptions"" ""$destinationSFXPackage"" ""$($PSScriptRoot)\Source\*"""

        # Ensure required directories exist
        if (-not (Test-Path -Path $destinationSFXPackagePath)) {
            New-Item -ItemType Directory -Path $destinationSFXPackagePath -Force | Out-Null
        }

        #- Validate toolsets
        if (!(Test-Path $winRARPath -ErrorAction SilentlyContinue)) {
            Write-Verbose -Message "WinRAR not found, attempting to download from the web"
            Try { Invoke-WebRequest -URI "$winRARWebPath" -OutFile "$($PSScriptRoot)\Configuration\Downloads\WinrarInstaller.exe" -ErrorAction Stop }
            Catch { 
                Throw "Failed to download WinRAR. Error: $($_.Exception.Message)" 
                exit 1810001
            }
            Write-Verbose -Message "Download complete, attempting to install"
            $winRARInstallArgs = "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART"
            try {
                Start-Process -FilePath "$($PSScriptRoot)\Configuration\Downloads\WinrarInstaller.exe" -ArgumentList $winRARInstallArgs -Wait
            }
            catch {
                Throw "Failed to install WinRAR. Error: $($_.Exception.Message)" 
                exit 1810002
            }
        }
        
        if (!(Test-Path $winRARSFXPath -ErrorAction SilentlyContinue)) {
            Throw "SFX Module not found in $($winRARSFXPath). Please verify Zip.SFX is in the specified location."
            exit 1810003
        }
    }
    
    #- Intune Win32 Configuration
    if ($win32Package) {
        # Setup intuneWinAppUtilArgs
        $intuneWinAppUtilArgs = "-c ""$($PSScriptRoot)\Source"" -s $intuneWinAppSetupFile -o ""$($destinationWin32Package)"" -q"

        # Ensure required directories exist
        if (-not (Test-Path -Path $destinationWin32Package)) {
            New-Item -ItemType Directory -Path $destinationWin32Package -Force | Out-Null
        }

        if (!(Test-Path $intuneWinAppUtil -ErrorAction SilentlyContinue)) {
            Write-Verbose -Message "IntuneWinAppUtil.exe not found, attempting to from the web"
            Try { Invoke-WebRequest -Uri "$intuneWinAppUtilWebPath" -OutFile "$($PSScriptRoot)\Configuration\Downloads\IntuneWinAppUtil.zip" -ErrorAction Stop }
            Catch { 
                Throw "Failed to download IntuneWinAppUtil. Error: $($_.Exception.Message)"
                exit 1810004
            }

            Write-Verbose -Message "Download complete, Attmepts to extract Zip folder"
            try {
                Expand-Archive -Path "$($PSScriptRoot)\Configuration\Downloads\IntuneWinAppUtil.zip" -DestinationPath "$($PSScriptRoot)\Intune\" -Force
            }
            catch {
                Throw "Failed to extract IntuneWinAppUtil. Error: $($_.Exception.Message)"
                exit 1810005
            }

            Write-Verbose -Message "Extraction Complete"
            $intuneWinAppUtil = "$($PSScriptRoot)\Intune\Microsoft-Win32-Content-Prep-Tool-1.8.6\IntuneWinAppUtil.exe"
            if (!(Test-Path $intuneWinAppUtil -ErrorAction SilentlyContinue)){
                throw "Failed to set intuneWinAppUtil variable"
                exit 1810006
            }
        }
    }
}
Process {
    #- Build SFX Package
    if ($SFXPackage) {
        Write-Verbose -Message "Building SFX Package..."
        $Proc = Start-Process -FilePath $winRARPath -ArgumentList $winRARXFXArgs -RedirectStandardOutput "$($PSScriptRoot)\Logs\$PackageName-SFX.log" -RedirectStandardError "$($PSScriptRoot)\Logs\$PackageName-SFX-Error.log" -Wait -PassThru
        if ($Proc.ExitCode -ne 0) {
            Throw "Failed to create SFX package. Error Code: $($Proc.ExitCode)"
            exit 1810007
        }
    }

    if ($win32Package) {
        Write-Verbose -Message "Building Win32 Package..."
        $Proc = Start-Process -FilePath $intuneWinAppUtil -ArgumentList $intuneWinAppUtilArgs -RedirectStandardOutput "$($PSScriptRoot)\Logs\$PackageName-Win32.log" -RedirectStandardError "$($PSScriptRoot)\Logs\$PackageName-Win32-Error.log" -Wait -PassThru
        if ($Proc.ExitCode -ne 0) {
            Throw "Failed to create Intune Win32 package. Error Code: $($Proc.ExitCode)"
            exit 1810008
        }
    }
}
End {
    if ($SFXPackage) { Write-Host "SFX Package can be found here: $($destinationSFXPackage)" -ForegroundColor Green }
    if ($win32Package) { Write-Host "Intune Win32 package can be found here: $($destinationWin32Package)" -ForegroundColor Green }
}