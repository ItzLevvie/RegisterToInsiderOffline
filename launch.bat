@echo off

:CHECK_THIS_DEVICE_FOR_FLIGHT_SIGNING
bcdedit /enum {current} | findstr "flightsigning *Yes" > nul 2>&1

echo [DEBUG] %ERRORLEVEL% is the error level ^(0 = "flightsigning" is enabled on this device; 1 = "flightsigning" is not enabled on this device^).

if %ERRORLEVEL% == 0 (
    echo [DEBUG] "flightsigning" is enabled ^(exists in the boot configuration data store^) on this device.
    echo [DEBUG] Setting the "flightsigning" variable to 1 ^(true^).
    set flightsigning=1
)

if %ERRORLEVEL% == 1 (
    echo [DEBUG] "flightsigning" is not enabled ^(does not exist in the boot configuration data store^) on this device.
    echo [DEBUG] Setting the "flightsigning" variable to 0 ^(false^).
    set flightsigning=0
)

goto :MAIN_MENU

:MAIN_MENU
set option=

echo.
echo 1 - Register this device to the Dev Channel in the Windows Insider Program
echo 2 - Register this device to the Beta Channel in the Windows Insider Program
echo 3 - Register this device to the Release Preview Channel in the Windows Insider Program
echo.
echo 4 - Remove this device from the Windows Insider Program
echo 5 - Close this batch file

echo.
set /p option="Choose an option: "
echo.

if %option% == 1 goto :REGISTER_THIS_DEVICE_TO_THE_DEV_CHANNEL_IN_THE_WINDOWS_INSIDER_PROGRAM
if %option% == 2 goto :REGISTER_THIS_DEVICE_TO_THE_BETA_CHANNEL_IN_THE_WINDOWS_INSIDER_PROGRAM
if %option% == 3 goto :REGISTER_THIS_DEVICE_TO_THE_RELEASE_PREVIEW_CHANNEL_IN_THE_WINDOWS_INSIDER_PROGRAM
if %option% == 4 goto :REMOVE_THIS_DEVICE_FROM_THE_WINDOWS_INSIDER_PROGRAM
if %option% == 5 goto :EOF

goto :MAIN_MENU

:REGISTER_THIS_DEVICE_TO_THE_DEV_CHANNEL_IN_THE_WINDOWS_INSIDER_PROGRAM
set ChannelName=Dev
set FriendlyChannelName=Dev
goto :REGISTER_THIS_DEVICE_IN_THE_WINDOWS_INSIDER_PROGRAM

:REGISTER_THIS_DEVICE_TO_THE_BETA_CHANNEL_IN_THE_WINDOWS_INSIDER_PROGRAM
set ChannelName=Beta
set FriendlyChannelName=Beta
goto :REGISTER_THIS_DEVICE_IN_THE_WINDOWS_INSIDER_PROGRAM

:REGISTER_THIS_DEVICE_TO_THE_RELEASE_PREVIEW_CHANNEL_IN_THE_WINDOWS_INSIDER_PROGRAM
set ChannelName=ReleasePreview
set FriendlyChannelName=Release Preview
goto :REGISTER_THIS_DEVICE_IN_THE_WINDOWS_INSIDER_PROGRAM

:DEREGISTER_THIS_DEVICE_FROM_THE_WINDOWS_INSIDER_PROGRAM
reg delete HKLM\SOFTWARE\Microsoft\WindowsSelfHost /f > nul 2>&1
reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs /f > nul 2>&1
goto :EOF

:REGISTER_THIS_DEVICE_IN_THE_WINDOWS_INSIDER_PROGRAM
echo You are registering this device to the %FriendlyChannelName% Channel in the Windows Insider Program.
echo.

call :DEREGISTER_THIS_DEVICE_FROM_THE_WINDOWS_INSIDER_PROGRAM

reg add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /v BranchName /t REG_SZ /d %ChannelName% /f > nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /v ContentType /t REG_SZ /d Mainline /f > nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /v IsBuildFlightingEnabled /t REG_DWORD /d 1 /f > nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /v Ring /t REG_SZ /d External /f > nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /v TestFlags /t REG_DWORD /d 32 /f > nul 2>&1

reg add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Strings /v StickyXaml /t REG_SZ /d "<StackPanel xmlns="""http://schemas.microsoft.com/winfx/2006/xaml/presentation"""><TextBlock Style="""{StaticResource BodyTextBlockStyle}""">This device has been registered in the Windows Insider Program using a batch file found on GitHub. If you want to change which channel you receive your builds from or if you want to stop receiving builds, please use the batch file.</TextBlock><TextBlock Style="""{StaticResource BodyTextBlockStyle}""" Margin="""0,10,0,0""" FontSize="""20""">Which channel has this device been registered to?</TextBlock><TextBlock Style="""{StaticResource BodyTextBlockStyle}""" Margin="""0,5,0,0""">This device has been registered to the <Run FontWeight="""SemiBold""">%FriendlyChannelName% Channel</Run>.</TextBlock><TextBlock Style="""{StaticResource BodyTextBlockStyle}""" Margin="""0,10,0,0""" FontSize="""20""">Why am I not receiving any builds from the %FriendlyChannelName% Channel?</TextBlock><TextBlock Style="""{StaticResource BodyTextBlockStyle}""" Margin="""0,5,0,0""">The Windows Insider Program requires you to send <Run FontWeight="""SemiBold""">Optional</Run> diagnostic data. Please check your diagnostic data setting in <Run FontWeight="""SemiBold""">Diagnostics &amp; feedback</Run>.</TextBlock><Button Command="""{StaticResource ActivateUriCommand}""" CommandParameter="""ms-settings:privacy-feedback""" Margin="""0,10,0,0"""><TextBlock Style="""{StaticResource BodyTextBlockStyle}""" Margin="""5,0,5,0""">Open Diagnostics &amp; feedback</TextBlock></Button></StackPanel>" /f > nul 2>&1

reg add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility /v UIDisabledElements /t REG_DWORD /d 65535 /f > nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility /v UIErrorMessageVisibility /t REG_DWORD /d 65535 /f > nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility /v UIHiddenElements /t REG_DWORD /d 65535 /f > nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility /v UIServiceDrivenElementVisibility /t REG_DWORD /d 65535 /f > nul 2>&1

reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingExternal /v Enabled /t REG_DWORD /d 1 /f > nul 2>&1

if %flightsigning% == 0 (
    echo [DEBUG] Adding "flightsigning" to the boot configuration data store.
    bcdedit /set {current} flightsigning Yes > nul 2>&1
    echo [DEBUG] Added "flightsigning" to the boot configuration data store.
    echo.
)

echo You have registered this device to the %FriendlyChannelName% Channel in the Windows Insider Program.
echo.

if %flightsigning% == 0 goto :ASK_THE_USER_IF_THEY_WANT_TO_REBOOT_THIS_DEVICE
pause
goto :EOF

:REMOVE_THIS_DEVICE_FROM_THE_WINDOWS_INSIDER_PROGRAM
echo You are removing this device from the Windows Insider Program.

call :DEREGISTER_THIS_DEVICE_FROM_THE_WINDOWS_INSIDER_PROGRAM

if %flightsigning% == 1 (
    echo.
    echo [DEBUG] Removing "flightsigning" from the boot configuration data store.
    bcdedit /deletevalue {current} flightsigning > nul 2>&1
    echo [DEBUG] Removed "flightsigning" from the boot configuration data store.
    echo.
)

echo You have removed this device from the Windows Insider Program.
echo.

if %flightsigning% == 1 goto :ASK_THE_USER_IF_THEY_WANT_TO_REBOOT_THIS_DEVICE
pause
goto :EOF

:ASK_THE_USER_IF_THEY_WANT_TO_REBOOT_THIS_DEVICE
set option=

echo This device needs to be rebooted to apply the changes you have made to this device.
echo.
echo 1 - Yes
echo 2 - No
echo.

set /p option="Do you want to reboot this device now or later? "
if %option% == 1 shutdown /r /t 0
if %option% == 2 goto :EOF

goto :ASK_THE_USER_IF_THEY_WANT_TO_REBOOT_THIS_DEVICE
