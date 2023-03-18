$ErrorActionPreference = "SilentlyContinue"

if ((bcdedit /enum `{bootmgr`} | Select-String "flightsigning           Yes") -and (bcdedit /enum `{current`} | Select-String "flightsigning           Yes")) {
    $eb2a422cf90f18f524f7d8f60522468b = $true
} else {
    $eb2a422cf90f18f524f7d8f60522468b = $false
}

function Request-InsiderChannel {
    Clear-Host
    Write-Host "1 - Enroll your device to the Canary Channel in the Windows Insider Program"
    Write-Host "2 - Enroll your device to the Dev Channel in the Windows Insider Program"
    Write-Host "3 - Enroll your device to the Beta Channel in the Windows Insider Program"
    Write-Host "4 - Enroll your device to the Release Preview Channel in the Windows Insider Program"
    Write-Host ""
    Write-Host "5 - Unenroll your device from the Windows Insider Program"
    Write-Host ""
    $3f19013bd546ca04ccb56097a3ed11d7 = Read-Host -Prompt "Choose an option"
    $3f19013bd546ca04ccb56097a3ed11d7 = $3f19013bd546ca04ccb56097a3ed11d7.Trim()
    Get-InsiderChannel
}

function Get-InsiderChannel {
    if ($3f19013bd546ca04ccb56097a3ed11d7 -eq "1") {
        $a5d469653b5174aa156ff2f645cb0a80 = "CanaryChannel"
        $b1e8786f218646f64e02a72e2c310082 = "Canary Channel"
        Write-Host ""
        Write-Host "You are enrolling your device to the $b1e8786f218646f64e02a72e2c310082 in the Windows Insider Program."
    } elseif ($3f19013bd546ca04ccb56097a3ed11d7 -eq "2") {
        $a5d469653b5174aa156ff2f645cb0a80 = "Dev"
        $b1e8786f218646f64e02a72e2c310082 = "Dev Channel"
        Write-Host ""
        Write-Host "You are enrolling your device to the $b1e8786f218646f64e02a72e2c310082 in the Windows Insider Program."
    } elseif ($3f19013bd546ca04ccb56097a3ed11d7 -eq "3") {
        $a5d469653b5174aa156ff2f645cb0a80 = "Beta"
        $b1e8786f218646f64e02a72e2c310082 = "Beta Channel"
        Write-Host ""
        Write-Host "You are enrolling your device to the $b1e8786f218646f64e02a72e2c310082 in the Windows Insider Program."
    } elseif ($3f19013bd546ca04ccb56097a3ed11d7 -eq "4") {
        $a5d469653b5174aa156ff2f645cb0a80 = "ReleasePreview"
        $b1e8786f218646f64e02a72e2c310082 = "Release Preview Channel"
        Write-Host ""
        Write-Host "You are enrolling your device to the $b1e8786f218646f64e02a72e2c310082 in the Windows Insider Program."
    } elseif ($3f19013bd546ca04ccb56097a3ed11d7 -eq "5") {
        Write-Host ""
        Write-Host "You are unenrolling your device from the Windows Insider Program."
        Remove-InsiderChannel
        if ($eb2a422cf90f18f524f7d8f60522468b -eq $true) {
            bcdedit /deletevalue `{bootmgr`} flightsigning | Out-Null
            bcdedit /deletevalue `{current`} flightsigning | Out-Null
        }
        Write-Host ""
        Write-Host "You have unenrolled your device from the Windows Insider Program."
        if ($eb2a422cf90f18f524f7d8f60522468b -eq $true) {
            Request-DeviceRestart
            break
        }
        break
    } else {
        Request-InsiderChannel
        break
    }
    Set-InsiderChannel
}

function Remove-InsiderChannel {
    Remove-Item -Path HKLM:\SOFTWARE\Microsoft\WindowsSelfhost -Recurse -Force
    Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingExternal -Recurse -Force
}

function Set-InsiderChannel {
    Remove-InsiderChannel
    if (-not(Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsSelfhost)) {
        New-Item -Path HKLM:\SOFTWARE\Microsoft\WindowsSelfhost -Force | Out-Null
    }
    if (-not(Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsSelfhost\Applicability)) {
        New-Item -Path HKLM:\SOFTWARE\Microsoft\WindowsSelfhost\Applicability -Force | Out-Null
    }
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsSelfhost\Applicability -Name BranchName -Value $a5d469653b5174aa156ff2f645cb0a80 -Force
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsSelfhost\Applicability -Name ContentType -Value Mainline -Force
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsSelfhost\Applicability -Name IsBuildFlightingEnabled -Value 1 -Force
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsSelfhost\Applicability -Name Ring -Value External -Force
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsSelfhost\Applicability -Name TestFlags -Value 32 -Force
    if (-not(Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsSelfhost\UI)) {
        New-Item -Path HKLM:\SOFTWARE\Microsoft\WindowsSelfhost\UI -Force | Out-Null
    }
    if (-not(Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsSelfhost\UI\Strings)) {
        New-Item -Path HKLM:\SOFTWARE\Microsoft\WindowsSelfhost\UI\Strings -Force | Out-Null
    }
    $6ec2d52d4bd0bd18e0144269240fbdb3 = @"
{"Message": "Your device was enrolled to the $b1e8786f218646f64e02a72e2c310082 in the Windows Insider Program using a script from GitHub. If you would like to change which channel you receive your preview builds from or would like to stop receiving preview builds, please use the script.", "LinkTitle": "", "LinkUrl": "", "DynamicXaml": "<StackPanel xmlns=\"http://schemas.microsoft.com/winfx/2006/xaml/presentation\"><TextBlock Style=\"{StaticResource BodyTextBlockStyle}\">The Windows Insider Program needs your device to send <Run FontWeight=\"SemiBold\">Optional</Run> diagnostic data to receive preview builds. Please check your device's <Run FontWeight=\"SemiBold\">Diagnostics &amp; feedback</Run> settings.</TextBlock><Button Margin=\"0,10,0,0\" Command=\"{StaticResource ActivateUriCommand}\" CommandParameter=\"ms-settings:privacy-feedback\"><TextBlock Style=\"{StaticResource BodyTextBlockStyle}\">Open Diagnostics &amp; feedback</TextBlock></Button></StackPanel>", "Severity": 1}
"@
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsSelfhost\UI\Strings -Name StickyMessage -Value $6ec2d52d4bd0bd18e0144269240fbdb3 -Force
    if (-not(Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsSelfhost\UI\Visibility)) {
        New-Item -Path HKLM:\SOFTWARE\Microsoft\WindowsSelfhost\UI\Visibility -Force | Out-Null
    }
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsSelfhost\UI\Visibility -Name UIHiddenElements_Rejuv -Value 254 -Force
    if (-not(Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingExternal)) {
        New-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingExternal -Force | Out-Null
    }
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingExternal -Name Enabled -Value 1 -Force
    if ($eb2a422cf90f18f524f7d8f60522468b -eq $false) {
        bcdedit /set `{bootmgr`} flightsigning Yes | Out-Null
        bcdedit /set `{current`} flightsigning Yes | Out-Null
    }
    Write-Host ""
    Write-Host "You have enrolled your device to the $b1e8786f218646f64e02a72e2c310082 in the Windows Insider Program."
    if ($eb2a422cf90f18f524f7d8f60522468b -eq $false) {
        Request-DeviceRestart
        break
    }
}

function Request-DeviceRestart {
    Write-Host ""
    Write-Host "Your device needs to be restarted to apply the changes you have made to this device."
    Write-Host ""
    Write-Host "1 - Yes (now)"
    Write-Host "2 - No (later)"
    Write-Host ""
    $ef0034ae337072a1660ded3cc3a42dea = Read-Host -Prompt "Choose an option"
    $ef0034ae337072a1660ded3cc3a42dea = $ef0034ae337072a1660ded3cc3a42dea.Trim()
    if ($ef0034ae337072a1660ded3cc3a42dea -eq 1) {
        shutdown /r /t 0
    } elseif ($ef0034ae337072a1660ded3cc3a42dea -eq 2) {
        exit
    } else {
        Request-DeviceRestart
        break
    }
}

Request-InsiderChannel
