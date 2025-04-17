
function CheckDis {
    if (test-path "C:\DIS") {
        Write-host "C:\DIS exists" -ForegroundColor Green
      } else {
        Write-Host "Creating directory C:\DIS\..." -ForegroundColor Red
        New-Item -Path "C:\" -Name "DIS" -ItemType "directory"
      }
  }
  function Comp1803pExist {
    if (Test-path C:\DIS\Components\COMP1803\Setup.exe) {
        Write-host "C:\DIS\Components\COMP1803\Setup.exe exists" -ForegroundColor Green
        Write-host "Starting install" -ForegroundColor Green
        Start-process "C:\DIS\Components\COMP1803\Setup.exe"
     } else {
        Write-host "C:\DIS\Components\COMP1803\Setup.exe does not exist or old version" -ForegroundColor Red
        Remove-item "C:\DIS\Components" -Recurse -Force -ErrorAction SilentlyContinue
        InstallerExist
     }
  }
     function InstallerExist {
    if (test-path "C:\DIS\comp1803p.exe") {
        Write-host "C:\DIS\comp1803p.exe exists" -ForegroundColor Green
        StartInstall
    } else {
        Write-host "C:\DIS\comp1803p.exe does not exist" -ForegroundColor Red
        KeystoneDownload
        StartInstall
    }       
  }
    function StartInstall {
    # Starts the install after a download  
    C:\DIS\comp1803p.exe /auto .\keystone
  }
  function KeystoneDownload {
    Write-Host "Downloading Comp1803p to C:\DIS\..." -ForegroundColor Red
    $URI = "https://dis-ts-files.s3.us-west-2.amazonaws.com/Public/im/comp1803p.exe"
    $Path= "C:\DIS\comp1803p.exe"
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -URI $URI -OutFile $Path
  }
  function PendingFileRename {
    Write-Host "Removing PendingFileRename from Registry" -ForegroundColor Green
    Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue
  }
  function KeymappingFolder {
    $folderPath = "C:\Users\$env:username\AppData\Roaming\Rocket Software\LegaSuite Windows Client"
    if (Test-Path $folderPath) {
    Write-Host "Checking for keymap folder in path... Folder exists, skipping" -ForegroundColor Green
    } else {
    #Create Keymap folder
    Write-Host "Legasuite Windows Client Folder not found." -ForegroundColor Red
    Write-Host "Creating path C:\Users\$env:username\AppData\Roaming\Rocket Software\LegaSuite Windows Client" -ForegroundColor Green
    New-Item -Path "C:\Users\$env:username\AppData\Roaming\Rocket Software" -Name "LegaSuite Windows Client" -ItemType "directory"
    }
  }
  function SetAcl {
    Write-Host "Backing up ACL and setting User Full contol on C:\Program Files (x86)\DIS\" -ForegroundColor Green
    Set-location "C:\Program Files (x86)\DIS"
    icacls ./ /save "C:\DIS\BUILTIN-Users-DIS-perms.txt" /t /c /q
    icacls "C:\Program Files (x86)\DIS" /grant "BUILTIN\Users:(OI)(CI)F" /t /q
  }
  function UpdateKeystone {
    Write-Host "Downloading UpdateKeystone.exe and creating shortcut..." -ForegroundColor Green
    $URI = "https://github.com/XerionXavier/ks/blob/main/UpdateKeystone.exe?raw=true"
    $Path= "C:\DIS\UpdateKeystone.exe"
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -URI $URI -OutFile $Path
    #Create Desktop shortcut to UpdateKeystone.exe
    $TargetFile = "C:\DIS\UpdateKeystone.exe"
    $ShortcutFile = "$env:Public\Desktop\UpdateKeystone - Run After DIS System Update.lnk"
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
    $Shortcut.TargetPath = $TargetFile
    $Shortcut.Save()
  }
  function StartInavigator {
    Start-Process cwbunnav.exe
  }
  function StartIfs {
    Start-Process \\KEYSTONE
  }
  function ExitScript {
    exit
  }
  function PauseInstaller {
    Add-Type -AssemblyName System.Windows.Forms
$response = [System.Windows.Forms.MessageBox]::Show("When the Keystone install completes click OK", "Confirmation", `
[System.Windows.Forms.MessageBoxButtons]::OKCancel, `
[System.Windows.Forms.MessageBoxIcon]::Question)
if ($response -eq 'OK') {
} else {
   Write-Host "Script execution cancelled."
  break
  }
}

# Functions to call
CheckDis
Comp1803pExist
PendingFileRename
PauseInstaller
#InstallerExist
#StartInstall
#KeystoneDownload
KeymappingFolder
SetAcl
UpdateKeystone
StartIfs
StartInavigator
ExitScript


