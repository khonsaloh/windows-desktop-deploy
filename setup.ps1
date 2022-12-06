# script to setup a new machine
$AddNewLine = "`n" #\n
$packages_file = 'https://raw.githubusercontent.com/khonsaloh/windows/master/packages.txt'
$profile_file = 'https://raw.githubusercontent.com/khonsaloh/windows/master/Microsoft.PowerShell_profile.ps1'
$chocolatey_url = "https://community.chocolatey.org/install.ps1"
$File = "packages.txt"

function _install_profile() {
  if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
      try {
          # Detect Version of Powershell & Create Profile directories if they do not exist.
          if ($PSVersionTable.PSEdition -eq "Core" ) { 
              if (!(Test-Path -Path ($env:userprofile + "\Documents\Powershell"))) {
                  New-Item -Path ($env:userprofile + "\Documents\Powershell") -ItemType "directory"
              }
          }
          elseif ($PSVersionTable.PSEdition -eq "Desktop") {
              if (!(Test-Path -Path ($env:userprofile + "\Documents\WindowsPowerShell"))) {
                  New-Item -Path ($env:userprofile + "\Documents\WindowsPowerShell") -ItemType "directory"
              }
          }
  
          Invoke-RestMethod $profile_url -o $PROFILE
          Write-Host "The profile @ [$PROFILE] has been created."
      }
      catch {
          throw $_.Exception.Message
      }
  }
   else {
       $date = Get-Date -Format "o"
  		 Get-Item -Path $PROFILE | Move-Item -Destination Microsoft.Powershell_profile-$date.ps1
  		 Invoke-RestMethod $profile_url -o $PROFILE
  		 Write-Host "The profile @ [$PROFILE] has been created and old profile removed."
   }
}

function _exitscript($ExitReason) {
    Write-Host $ExitReason;
    cmd /c pause 
    exit
}

function _exit_if_not_administrator {
    $CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent());
    if (-Not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        _exitscript "Run as administrator" 
    }
}

function _is_chocolatey_installed {
    try {
        choco
        return $true
    }
    catch {
        return $false
    }
}

function _install_chocolatey {
	Set-ExecutionPolicy Bypass -Scope Process -Force
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
	iex ((New-Object System.Net.WebClient).DownloadString($chocolatey_url))
}

#function _chocolatey_install_menu {
#    $Install = New-Object System.Management.Automation.Host.ChoiceDescription "&Install", "Install chocolatey";
#    $Script = New-Object System.Management.Automation.Host.ChoiceDescription "&Script", "Show chocolatey install script";
#    $Url = New-Object System.Management.Automation.Host.ChoiceDescription "&Url", "Show url for chocolatey install script";
#    $Exit = New-Object System.Management.Automation.Host.ChoiceDescription "&Exit", "Exit script";
#    $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Install, $Script, $Url, $Exit);
#
#    $ChocoInstallScript = (New-Object System.Net.WebClient).DownloadString($ScriptUrl);
#    $ChocolateyInstalled = $false
#
#    $AddNewLine;
#    Do {
#        $Decision = $Host.UI.PromptForChoice("Chocolatey install menu", "Type a command", $Options, 1);
#        switch ($Decision) {
#            0 {
#                Invoke-Expression $ChocoInstallScript;
#                $ChocolateyInstalled = $true
#            }
#            1 {
#                $AddNewLine;
#                Write-Host $ChocoInstallScript -ForegroundColor green;
#            }
#            2 {
#                $AddNewLine;
#                Write-Host $ScriptUrl;
#                $AddNewLine;
#            }
#            3 {
#                exit
#            }
#            default {
#               exit
#            }
#        } 
#    } Until ($ChocolateyInstalled -eq $true)
#
#    _run_script
#}

function _check_packages_file {
    $AddNewLine;
    Write-Warning "Check virus scan results for each package on https://chocolatey.org/ before installing.";

    if (!(Test-Path .\$File)) {
      Invoke-WebRequest $packages_file -OutFile $File
      if (-not $?) { _exitscript "cannot download file containing packages" }
    }
    else (!(Get-Content -Path .\$File)) {
        _exitscript "$File does not contain any packages. Please add one package name on each line.";
    }
#    else {
#     _packages_menu $File;
#   }
}

#function _packages_menu($File) {
#    $Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Install all packages without prompting";
#    $No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Install all packages with prompting";
#    $Exit = New-Object System.Management.Automation.Host.ChoiceDescription "&Exit", "Exit script";
#    $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No, $Exit);
#    $Decision = $Host.UI.PromptForChoice("Ready to install all packages", "Confirm all prompts?", $Options, 1);
#
#    switch ($Decision) {
#        0 {
#            _install_packages $file $true
#        }
#        1 {
#            _install_packages $file $false
#        }
#        2 {
#            exit
#        }
#        Default {
#            exit
#        }
#    }
#}

function _install_packages($file, $acceptAllPrompts) {
    $PackagesToInstall = Get-Content -Path .\$file;
    $FailedToInstallPackages = New-Object System.Collections.Generic.List[System.Object];

    foreach ($line in $PackagesToInstall) {
#  if ($acceptAllPrompts -eq $true) {
            try {
                choco install $line -y
            }
            catch {
                $FailedToInstallPackages.Add($line)
            }
#        }
#       else {
#           try {
#                choco install $line
#           }
#           catch {
#               $FailedToInstallPackages.Add($line)
#           }
#       }
    }

    if ($FailedToInstallPackages.Count -gt 0) {
        $AddNewLine;
        foreach ($FailedPackage in $FailedToInstallPackages) {
            Write-Host "Failed to Install: $FailedPackage" -ForegroundColor Red;
        }
        $AddNewLine;

        if ($FailedToInstallPackages.Count -lt $PackagesToInstall.Length) {
            $TotalInstalled = $PackagesToInstall.Length - $FailedToInstallPackages.Count;
            _exitscript "$($TotalInstalled)/$($PackagesToInstall.Length) packages installed.";
        }
        elseif ($FailedToInstallPackages.Count -eq $PackagesToInstall.Length) {
            _exitscript "All packages failed to install.";
        }
    }
    else {
        _exitscript "All packages installed.";
    }
}

function _run_script { 
    _exit_if_not_administrator

    if (_is_chocolatey_installed -eq $true) {
        _check_packages_file
    }
 else {
   _install_chocolatey
   }
    _install_packages
    _install_profile

    exit
}

_run_script
#If the file does not exist, create it.
