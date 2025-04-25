##############################################################################
# All Code blocks go in this function v2.0
##############################################################################
    
function RunScripts {
    #Write-Host "`n####################"

    if($Script:Blocks[0]){
        #Put Script Block 1 code here
        Write-Host "`n Installing Keystone"
        InstallKeystone
        Start-Sleep -Seconds 30
    }

    if($Script:Blocks[1]){
        #Put Script Block 2 code here
        Write-Host "`n Installing ECC Service"
        InstallECCS
        Start-Sleep -Seconds 30
    }

    if($Script:Blocks[2]){
        #Put Script Block 3 code here
        Write-Host "`n Install Interface Manager"
        InstallIM
        Start-Sleep -Seconds 15
    }

    if($Script:Blocks[3]){
        #Put Script Block 4 code here
        Write-Host "`n IM Commerce Installer"
        IMCInstaller
    }

    if($Script:Blocks[4]){
        #Put Script Block 5 code here
        Write-Host "`n UpdateKeystone.exe Installer"
        UpdateKeystone
    }

    if($Script:Blocks[5]){
        #Put Script Block 6 code here
        Write-Host "`n Sumatra PDF Installer"
        InstallSumatra
    }
}

##############################################################################
# Form generation function
##############################################################################

function GenerateForm {
    ##############################################################################
    # CHANGE ALL DESIRED VARIABLES HERE!
    ##############################################################################
    
    $NumofCheckBoxes = 6 #Set the number of checkboxes you would like

    $yPos = 12 #The starting Y position of the checkboxes

    $Script:Blocks = @($null) * $NumofCheckBoxes #Array of boolean toggles
    $ContentList = @($null) * $NumofCheckBoxes #Array of the checkbox display text

    #Set the displayed text of each checkbox below (add/remove lines as needed):
    $ContentList[0] = "Keystone"
    $ContentList[1] = "ECC Service"
    $ContentList[2] = "IM"
    $ContentList[3] = "IM Commerce"
    $ContentList[4] = "UpdateKeystone.exe"
    $ContentList[5] = "Sumatra PDF"

    function InstallKeystone {
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
            Write-Host "Installing Keystone" -ForegroundColor Green
            C:\DIS\comp1803p.exe /auto .\keystone
          }
          function KeystoneDownload {
            Write-Host "Downloading Comp1803p to C:\DIS\..." -ForegroundColor Green
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
          function StartInavigator {
            Start-Sleep -Seconds 10
            Start-Process cwbunnav.exe
          }
          function StartIfs {
            Start-Sleep -Seconds 10
            Start-Process \\KEYSTONE
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

        CheckDis
        Comp1803pExist
        PendingFileRename
        PauseInstaller
        #InstallerExist
        #StartInstall
        #KeystoneDownload
        #InstallSumatra
        KeymappingFolder
        SetAcl
        #UpdateKeystone
        StartIfs
        StartInavigator
                
        }
        function UpdateKeystone {
            Write-Host 'Downloading UpdateKeystone.exe and creating shortcut...' -ForegroundColor Green
            $URI = 'http://www.dis-corp.com/weblog/updates/UpdateKeystone.exe'
            $Path= 'C:\DIS\UpdateKeystone.exe'            
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
          function InstallSumatra {
            $URI = "https://www.sumatrapdfreader.org/dl/rel/3.4.6/SumatraPDF-3.4.6-64-install.exe"
            $Path= "C:\DIS\SumatraPDF-install.exe"
            Invoke-WebRequest -URI $URI -OutFile $Path 
            C:\DIS\SumatraPDF-install.exe -s --all-users
            Write-Host "SumatraPDF installed.." -ForegroundColor Green
          }

          function ExitScript {
            exit
          }     
    function InstallECCS {
        ## 
        ## Powershell script to automate ECC Service install. v0.1d
        ##
        # Create C:\DIS directory
        if (-not (test-path "C:\DIS") ) {
            Write-Host "Creating directory C:\DIS\..." -ForegroundColor Red
            New-Item -Path "C:\" -Name "DIS" -ItemType "directory"
        } else {
            write-host "C:\DIS exists" -ForegroundColor Green
        }
        #
        #Download Java32 and install
        Write-Host "Downloading and installing Java32 --silent" -ForegroundColor Green
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest https://javadl.oracle.com/webapps/download/AutoDL?BundleId=250127_d8aa705069af427f9b83e66b34f5e380 -OutFile "C:\DIS\Java32-Offline-Installer.exe"
        #
        #Start the installer
        Write-Host "Starting Java32 installation.." -ForegroundColor Green
        C:\DIS\Java32-Offline-Installer.exe /s
        #
        #Download ECC Service to C:\DIS
        Write-Host "Downloading ECCService to C:\DIS\..." -ForegroundColor Green
        $URI = "https://dis-ts-files.s3.us-west-2.amazonaws.com/Public/im/im41921e.exe"
        $Path= "C:\DIS\im41921e.exe"
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -URI $URI -OutFile $Path
        
        C:\DIS\im41921e.exe
        #
        #Set IMCommand and IMCommerce as Admin
        Write-Host "Setting IMCommece and IMCommand as Admin in registry.." -ForegroundColor Green
        New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers' -Name 'C:\Program Files (x86)\DIS\ECC\ECCCommand.exe'
        New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers' -Name 'C:\Program Files (x86)\DIS\ECC\ECCService.exe'
        New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers' -Name 'C:\Program Files (x86)\DIS\ECC\ECCCommand.exe' -Value '~ RUNASADMIN' -PropertyType 'String' -Force
        New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers' -Name 'C:\Program Files (x86)\DIS\ECC\ECCService.exe' -Value '~ RUNASADMIN' -PropertyType 'String' -Force
    }
    
    function InstallIM {
        ## Powershell script to automate IM install. v0.1c##
        # Create C:\DIS directory
        if (-not (test-path "C:\DIS") ) {
            Write-Host "Creating directory C:\DIS\..." -ForegroundColor Red
            New-Item -Path "C:\" -Name "DIS" -ItemType "directory"
        } else {
            write-host "C:\DIS exists" -ForegroundColor Green
        }
        #
        #Download Interface Manager to C:\DIS
        Write-Host "Downloading Interface Manager to C:\DIS\..." -ForegroundColor Green
        $URI = "https://www.dis-corp.com/updates/im/im21910p.exe"
        $Path= "C:\DIS\im21910p.exe"
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -URI $URI -OutFile $Path
        
        Start-process C:\DIS\im21910p.exe
    }

    function IMCInstaller {
        ## 
        ## Powershell script to automate IMCommerce install. v0.3
        ##
        # Create C:\DIS directory
        if (-not (test-path "C:\DIS") ) {
            Write-Host "Creating directory C:\DIS\..." -ForegroundColor Red
            New-Item -Path "C:\" -Name "DIS" -ItemType "directory"
        } else {
            write-host "C:\DIS exists" -ForegroundColor Green
        }
        #
        #Download Java32 and install
        Write-Host "Downloading and installing Java32 --silent" -ForegroundColor Green
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest https://javadl.oracle.com/webapps/download/AutoDL?BundleId=250127_d8aa705069af427f9b83e66b34f5e380 -OutFile "C:\DIS\Java32-Offline-Installer.exe"
        #
        #Start the installer
        Write-Host "Starting Java32 installation.." -ForegroundColor Green
        C:\DIS\Java32-Offline-Installer.exe /s
        #
        #Download IMCommerce to C:\DIS
        Write-Host "Downloading IMCommerce to C:\DIS\..." -ForegroundColor Green
        $URI = "https://www.dis-corp.com/updates/im/im31627p.exe"
        $Path= "C:\DIS\im31627p.exe"
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -URI $URI -OutFile $Path
        C:\DIS\im31627p.exe
        #
        #Set IMCommand and IMCommerce as Admin
        Write-Host "Setting IMCommece and IMCommand as Admin in registry.." -ForegroundColor Green
        New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers' -Name 'C:\Program Files (x86)\DIS\IM\IMCommand.exe'
        New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers' -Name 'C:\Program Files (x86)\DIS\IM\IMCommerce.exe'
        New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers' -Name 'C:\Program Files (x86)\DIS\IM\IMCommand.exe' -Value '~ RUNASADMIN' -PropertyType 'String' -Force
        New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers' -Name 'C:\Program Files (x86)\DIS\IM\IMCommerce.exe' -Value '~ RUNASADMIN' -PropertyType 'String' -Force
    }

    ##############################################################################
    # Creates the form and all of its contents
    ##############################################################################
    
    [reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
    [reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
    
    $form1 = New-Object System.Windows.Forms.Form
    $button1 = New-Object System.Windows.Forms.Button
    $listBox1 = New-Object System.Windows.Forms.ListBox
    $InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState

    if($null -eq $ContentList[0]) { $ContentList[0] = 'checkBox1' }

    $CheckBoxes = @($null) * $NumofCheckBoxes #The array of checkboxes
    $longestName = $ContentList[0].length
    $saveIndex = 0
    
    for($i = 0; $i -lt $NumofCheckBoxes; $i++){
        if( ($null -eq $ContentList[$i]) -and ($i -ne 0) ) { $ContentList[$i] = 'checkBox' + ($i+1) }

        if(($i -ne 0) -and ($ContentList[$i].length -gt $longestName)) { 
            $longestName = $ContentList[$i].length 
            $saveIndex = $i 
        }

        $BoxObj = New-Object System.Windows.Forms.CheckBox
        $CheckBoxes[$i] = $BoxObj
    }
    
    ##############################################################################
    # Form Settings such as size and name
    ##############################################################################

    $form1.Name = "form1"
    $form1.Text = "DIS Quick Installer"
    $form1.DataBindings.DefaultDataSourceUpdateMode = 0
    $form1.AutoSizeMode = 1
    $form1.AutoSize = $True
    $form1.Padding = 5

    ##############################################################################
    # Updates the Listbox and activates/deactivates blocks of code
    ##############################################################################

    $handler_updateList_Click= {
        $listBox1.Items.Clear()

        foreach($obj in $CheckBoxes){
            if ($obj.Checked) {
                $listBox1.Items.Add($obj.Text + ' install')
                $listBox1.Items.Add('')
                $Script:Blocks[$obj.TabIndex] = $True
            } else {
                $Script:Blocks[$obj.TabIndex] = $False
            }
        }

        if($listBox1.Items.Count -eq 0){ $listBox1.Items.Add("No CheckBoxes selected....") }
        $listBox1.Update()
    }

    $handler_button1_Click= { RunScripts } #Runs the script blocks that are enabled

    ##############################################################################
    # Centers the form in the middle of the primary monitor and preserves its state
    ##############################################################################

    $OnLoadForm_StateCorrection= { 
        $theScreen = [System.Windows.Forms.Screen]::AllScreens | Where-Object{$_.Primary -eq $True}

        $formXLoc = ($theScreen.Bounds.Width - $form1.Width) / 2
        $formYLoc = ($theScreen.Bounds.Height - $form1.Height) / 2
        $form1.SetDesktopLocation($formXLoc,$formYLoc)

        $form1.WindowState = $InitialFormWindowState
    }

    ##############################################################################
    # CheckBox Settings such as size, location, and name
    ##############################################################################

    $lbYPos = $yPos
    $index = 0

    $CheckBoxes[$saveIndex].Text = $ContentList[$saveIndex]
    $CheckBoxes[$saveIndex].AutoSize = $True

    foreach($obj in $CheckBoxes){
        $obj.Name = 'checkBox' + ($index+1)
        $obj.Text = $ContentList[$index]
        $obj.TabIndex = $index
        $obj.UseVisualStyleBackColor = $True
        $obj.DataBindings.DefaultDataSourceUpdateMode = 0
        
        if($index -ne $saveIndex) { $obj.Size = $CheckBoxes[$saveIndex].Size }
        if($index -ne 0) { $yPos = ($yPos + $CheckBoxes[$saveIndex].Height) + 10 }

        $obj.Padding = 5
        $obj.Location = New-Object System.Drawing.Point(25, $yPos) #(X-Value, (relative)Y-Value)
        $obj.add_Click($handler_updateList_Click) #Calls the click event handler to update the listbox in real time

        $form1.Controls.Add($obj)
        $index++
    }

    ##############################################################################
    # Button Settings such as size, location, and name
    ##############################################################################
    
    $button1.Name = "button1"
    $button1.Text = "Install"
    $button1.TabIndex = $NumofCheckBoxes
    $button1.UseVisualStyleBackColor = $True
    $button1.DataBindings.DefaultDataSourceUpdateMode = 0
    $button1.add_Click($handler_button1_Click) #Calls the button click event handler
    $button1.AutoSize = $True

    $btnYPos = $yPos = ($yPos + $CheckBoxes[-1].Height) + 5 
    $btnXPos = ($CheckBoxes[-1].Location.X + 18)

    $button1.Location = New-Object System.Drawing.Point($btnXPos, $btnYPos)
    $button1.Size = New-Object System.Drawing.Size(($button1.Width + 50), ($button1.Height + 10))

    $form1.Controls.Add($button1)
    
    ##############################################################################
    # ListBox Settings such as size, location, and name
    ##############################################################################

    $listBox1.Name = "listBox1"
    $listBox1.TabIndex = ($NumofCheckBoxes + 1)
    $listBox1.FormattingEnabled = $True
    $listBox1.DataBindings.DefaultDataSourceUpdateMode = 0

    $reloadList= { #When the form loads, clears the list and "saves" the size
        $lbW = $listbox1.Width
        $lbH = $listbox1.Height
        $listBox1.MinimumSize = New-Object System.Drawing.Size($lbW, $lbH)
        $listBox1.Items.Clear()
    }
    
    #Fills the listbox with every item to autosize it accordingly
    foreach($obj in $CheckBoxes){
        $listBox1.Items.Add($obj.Text + ' is checked') | Out-Null
        $listBox1.Items.Add('') | Out-Null
    }

    $listBox1.AutoSize = $True
    $lbXPos = ($CheckBoxes[$saveIndex].Right + 10)
    $listBox1.Location = New-Object System.Drawing.Point($lbXPos, $lbYPos)

    $form1.Controls.Add($listBox1)
    $form1.add_Load($reloadList)

    ##############################################################################
    # Loads the form onto the screen
    ##############################################################################

    $InitialFormWindowState = $form1.WindowState #Save the initial state of the form
    
    $form1.add_Load($OnLoadForm_StateCorrection) #Start the OnLoad event to correct the initial state of the form

    $form1.ShowDialog()| Out-Null #Show the Form
}

    
##############################################################################
# Clears the screen and generates the form
##############################################################################

Clear-Host
GenerateForm
#ExitScript