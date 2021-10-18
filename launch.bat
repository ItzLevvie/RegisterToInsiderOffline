@echo off

cls

bcdedit /enum {current} | findstr "flightsigning *Yes" > nul 2>&1

if %ERRORLEVEL% == 0 set flightsigning=1
if %ERRORLEVEL% == 1 set flightsigning=0

goto :MENU

:MENU
set option=

echo 1 - Register your device to the Dev Channel in the Windows Insider Program
echo 2 - Register your device to the Beta Channel in the Windows Insider Program
echo 3 - Register your device to the Release Preview Channel in the Windows Insider Program
echo.
echo 4 - Remove your device from the Windows Insider Program
echo.
echo 5 - Close this batch file

echo.
set /p option="Please choose an option: "
echo.

if %option% == 1 goto :REGISTER_DEVICE_TO_DEV_CHANNEL
if %option% == 2 goto :REGISTER_DEVICE_TO_BETA_CHANNEL
if %option% == 3 goto :REGISTER_DEVICE_TO_RELEASE_PREVIEW_CHANNEL
if %option% == 4 goto :REMOVE_DEVICE
if %option% == 5 goto :EOF

goto :MENU

:REGISTER_DEVICE_TO_DEV_CHANNEL
set name=Dev
set fname=Dev

goto :REGISTER_DEVICE

:REGISTER_DEVICE_TO_BETA_CHANNEL
set name=Beta
set fname=Beta

goto :REGISTER_DEVICE

:REGISTER_DEVICE_TO_RELEASE_PREVIEW_CHANNEL
set name=ReleasePreview
set fname=Release Preview

goto :REGISTER_DEVICE

:DEREGISTER_DEVICE
reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost /f > nul 2>&1
reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingExternal /f > nul 2>&1

goto :EOF

:REGISTER_DEVICE
echo You are registering your device to the %fname% Channel in the Windows Insider Program.
echo.

call :DEREGISTER_DEVICE

reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /v BranchName /t REG_SZ /d %name% /f > nul 2>&1
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /v ContentType /t REG_SZ /d Mainline /f > nul 2>&1
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /v IsBuildFlightingEnabled /t REG_DWORD /d 1 /f > nul 2>&1
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /v Ring /t REG_SZ /d External /f > nul 2>&1
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /v TestFlags /t REG_DWORD /d 32 /f > nul 2>&1

reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Strings /v StickyMessage /t REG_SZ /d "{\"Message\": \"Your device was registered to the %fname% Channel in the Windows Insider Program using a script from GitHub. If you would like to change which channel you receive your preview builds from or would like to stop receiving preview builds, please use the script.\", \"LinkTitle\": \"\", \"LinkUrl\": \"\", \"DynamicXaml\": \"^<StackPanel xmlns=\\\"http://schemas.microsoft.com/winfx/2006/xaml/presentation\\\"^>^<TextBlock Style=\\\"{StaticResource BodyTextBlockStyle}\\\"^>The Windows Insider Program needs your device to send ^<Run FontWeight=\\\"SemiBold\\\"^>Optional^</Run^> diagnostic data to receive preview builds. Please check your device's ^<Run FontWeight=\\\"SemiBold\\\"^>Diagnostics ^&amp; feedback^</Run^> settings.^</TextBlock^>^<Button Margin=\\\"0,10,0,0\\\" Command=\\\"{StaticResource ActivateUriCommand}\\\" CommandParameter=\\\"ms-settings:privacy-feedback\\\"^>^<TextBlock Style=\\\"{StaticResource BodyTextBlockStyle}\\\"^>Open Diagnostics ^&amp; feedback^</TextBlock^>^</Button^>^</StackPanel^>\", \"Severity\": 1}" /f

reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfhost\UI\Visibility /v UIHiddenElements_Rejuv /t REG_DWORD /d 254 /f > nul 2>&1

reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingExternal /v Enabled /d 1 /f > nul 2>&1

if %flightsigning% == 0 bcdedit /set {current} flightsigning Yes > nul 2>&1

echo You have registered your device to the %fname% Channel in the Windows Insider Program.
echo.

if %flightsigning% == 0 goto :RESTART_DEVICE
pause
goto :EOF

:REMOVE_DEVICE

call :DEREGISTER_DEVICE

if %flightsigning% == 1 bcdedit /deletevalue {current} flightsigning > nul 2>&1

echo You have removed your device from the Windows Insider Program.
echo.

if %flightsigning% == 1 goto :RESTART_DEVICE
pause
goto :EOF

:RESTART_DEVICE
set option=

echo Your device needs to be restarted to apply the changes you have made to this device.
echo.
echo 1 - Yes ^(now^)
echo 2 - No ^(later^)
echo.

set /p option="Do you want to restart your device now or later? "

if %option% == 1 (
    shutdown /r /t 0
    goto :EOF
)

if %option% == 2 goto :EOF

goto :RESTART_DEVICE
