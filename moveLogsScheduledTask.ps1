#Create the C:\DIS\moveLogs400.ps1
$filePath = "C:\DIS\moveLogs400.ps1"
$multiLineContent = @"
#Copies the ECCS Logs to the IFS and C:\DIS dir
function copyLogs {
#Copy ECCS Logs to the C:\DIS folder
Copy-Item -Path "C:\ProgramData\dis\im\logs" -Destination "C:\DIS" -Recurse
Compress-Archive -Path "C:\DIS\logs" -DestinationPath "C:\DIS\ECCSlogs.zip" -Update
Copy-Item "C:\DIS\ECCSlogs.zip" \\keystone\keystone\DI_Logs -Force
Remove-Item "C:\DIS\logs" -Recurse
#Copy IM Logs to the C:\DIS folder
Copy-Item -Path "C:\Program Files (x86)\DIS\Interface Manager\IMLogs" -Destination "C:\DIS" -Recurse
Compress-Archive -Path "C:\DIS\IMlogs" -DestinationPath "C:\DIS\IMlogs.zip" -Update
Copy-Item "C:\DIS\IMlogs.zip" \\keystone\keystone\DI_Logs -Force
Remove-Item "C:\DIS\IMlogs" -Recurse
#Copy IM Archive Logs to the C:\DIS folder
Copy-Item -Path "C:\Program Files (x86)\DIS\Interface Manager\Archive" -Destination "C:\DIS" -Recurse
Compress-Archive -Path "C:\DIS\Archive" -DestinationPath "C:\DIS\IMArchivelogs.zip" -Update
Copy-Item "C:\DIS\IMArchivelogs.zip" \\keystone\keystone\DI_Logs -Force
Remove-Item "C:\DIS\Archive" -Recurse
}
Function checkPath {
  if (test-path "\\KEYSTONE\KEYSTONE\DI_Logs") {
    } else {
      New-Item -Path "\\KEYSTONE\KEYSTONE\" -Name "DI_Logs" -ItemType "directory"
    }
}  
checkPath
copyLogs
"@
#Create the task in Task scheduler to run for 15 days.
#Create the PS script that moves the logs to the 400.
Set-Content -Path $filePath -Value $multiLineContent
# Define the action to be performed
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File C:\DIS\moveLogs400.ps1"
# Define the trigger (e.g., daily at 7 AM)
$trigger = New-ScheduledTaskTrigger -Daily -At 7am
# Create the schedule and set delete time out
$settings = New-ScheduledTaskSettingsSet -DeleteExpiredTaskAfter (New-TimeSpan -Seconds 1)
#Sets the number of days (15) until the task expires and is removed.
$trigger.EndBoundary = (Get-Date).AddDays(15).ToString("s")
#Creates the Task
$task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings
# Register the scheduled task
Register-ScheduledTask -TaskName "MoveECCLogs400" -InputObject $task -TaskPath "\Event Viewer Tasks\"
