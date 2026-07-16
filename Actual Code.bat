@echo off
setlocal enabledelayedexpansion

:: Set specific window size (Columns: 80, Lines: 30)
mode con: cols=80 lines=30
title Parental Control Panel
color 0A

:: Initialize default password and variables
set "PIN=0000"
set "app_count=0"

:AUTH
cls
echo ===========================================
echo       PARENTAL CONTROL AUTHENTICATION
echo ===========================================
echo.
set /p "input_pin=Please enter your PIN: "
if "%input_pin%"=="%PIN%" (
    goto MAIN_MENU
) else (
    echo [!] Incorrect PIN. Access Denied.
    timeout /t 2 >nul
    goto AUTH
)

:MAIN_MENU
cls
echo ===========================================
echo            PARENTAL CONTROL MENU
echo ===========================================
echo  [1] Timer
echo  [2] Apps
echo  [3] Command Line
echo  [4] Protection (File Scanner)
echo  [5] Change Passwords
echo  [6] Undo Everything / Exit
echo ===========================================
echo.
:: 'choice' prevents empty inputs and crashes
choice /C 123456 /N /M "Select an option (1-6): "

:: Errorlevels must be evaluated in descending order
if errorlevel 6 goto MENU_UNDO
if errorlevel 5 goto MENU_CHANGE_PASS
if errorlevel 4 goto MENU_PROTECTION
if errorlevel 3 goto MENU_CMD
if errorlevel 2 goto MENU_APPS
if errorlevel 1 goto MENU_TIMER

:: =====================================
:: 1: TIMER COMPONENT
:: =====================================
:MENU_TIMER
cls
echo ===========================================
echo                   TIMER
echo ===========================================
echo.
set "secs="
set /p "secs=Timer Value (in seconds): "

:: Validate input is not empty and is a number
if "%secs%"=="" goto MENU_TIMER
echo %secs%| findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo [!] Invalid number.
    timeout /t 2 >nul
    goto MENU_TIMER
)

if %secs% lss 20 (
    echo [!] Timer must be at least 20 seconds long to accommodate warnings.
    timeout /t 2 >nul
    goto MENU_TIMER
)

set /a "warning_time=%secs% - 20"
echo.
echo Timer started for %secs% seconds...
echo Press Ctrl+C to force quit, or wait for expiration.
timeout /t %warning_time% /nobreak >nul

:: Create temporary VBScript for the Exclamation Mark + OK Button Box
set "vbsFile=%temp%\parental_msg.vbs"
echo MsgBox "Sorry, Your Time is up. Please return to the menu to abort the timer by typing the pin.", 48, "Parental Control Alert" > "%vbsFile%"
cscript //nologo "%vbsFile%" >nul
del "%vbsFile%"

:TIMER_ABORT_PROMPT
cls
echo ===================================================
echo  CRITICAL WARNING: 20 SECONDS BEFORE OS SHUTDOWN
echo ===================================================
echo.
set /p "abort_pin=Password: "
if "%abort_pin%"=="%PIN%" (
    echo [✓] Timer successfully aborted.
    pause
    goto MAIN_MENU
) else (
    echo [!] Incorrect Password! 
    echo Shutting down system...
    shutdown /s /t 20 /c "Parental Control: Time limit exceeded."
    
    :LOCKOUT
    cls
    echo SYSTEM IS SHUTTING DOWN IN LESS THAN 20 SECONDS.
    set /p "abort_pin2=Enter correct Password to ABORT shutdown: "
    if "%abort_pin2%"=="%PIN%" (
        shutdown /a
        echo [✓] Shutdown canceled.
        pause
        goto MAIN_MENU
    )
    goto LOCKOUT
)

:: =====================================
:: 2: APPS COMPONENT
:: =====================================
:MENU_APPS
cls
echo ===========================================
echo                   APPS
echo ===========================================
if %app_count% equ 0 (
    echo No apps configured yet.
) else (
    for /l %%i in (1,1,%app_count%) do (
        echo  [%%i] !app_name_%%i!
    )
)
echo ===========================================
echo  [A] Add a new browser link
echo  [M] Return to Main Menu
echo.
set "app_choice="
set /p "app_choice=Select an option: "

if /i "%app_choice%"=="M" goto MAIN_MENU
if /i "%app_choice%"=="A" (
    set /a "app_count+=1"
    cls
    echo ===========================================
    echo               ADD NEW APP
    echo ===========================================
    echo.
    set /p "new_url=Enter the website URL (e.g., https://google.com): "
    set /p "new_name=Enter a short name for this link: "
    
    set "app_url_!app_count!=!new_url!"
    set "app_name_!app_count!=!new_name!"
    
    echo [✓] App saved successfully.
    pause
    goto MENU_APPS
)

:: Validate if the user typed an existing app number
echo %app_choice%| findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 0 (
    if %app_choice% leq %app_count% (
        if %app_choice% gtr 0 (
            echo Launching !app_name_%app_choice%!...
            start "" "!app_url_%app_choice%!"
            goto MENU_APPS
        )
    )
)
goto MENU_APPS

:: =====================================
:: 3: COMMAND LINE COMPONENT
:: =====================================
:MENU_CMD
cls
echo ===========================================
echo      PARENTAL CONTROLLER COMMAND LINE
echo ===========================================
echo Type HELP to view commands.
echo.

:CMD_LOOP
set "cmd_input="
set /p "cmd_input=>>> "
if "%cmd_input%"=="" goto CMD_LOOP

:: Parse command string
for /f "tokens=1*" %%a in ("%cmd_input%") do (
    set "base_cmd=%%a"
    set "cmd_args=%%b"
)

if /i "%base_cmd%"=="HELP" (
    echo Available commands:
    echo   MKTXT [filename]   - Creates a blank text file
    echo   CAT [filename]     - Displays the content of a file
    echo   LS                 - Lists files in the current folder
    echo   PASSWD             - Shortcut to change system control PIN
    echo   EXIT               - Return to the main menu
    echo.
    goto CMD_LOOP
)

if /i "%base_cmd%"=="MKTXT" (
    if "%cmd_args%"=="" (echo Usage: MKTXT filename.txt) else (type nul > "%cmd_args%" & echo File "%cmd_args%" created.)
    goto CMD_LOOP
)

if /i "%base_cmd%"=="CAT" (
    if "%cmd_args%"=="" (echo Usage: CAT filename.txt) else (
        if exist "%cmd_args%" (type "%cmd_args%") else (echo File not found.)
    )
    echo.
    goto CMD_LOOP
)

if /i "%base_cmd%"=="LS" (
    dir /b /w
    echo.
    goto CMD_LOOP
)

if /i "%base_cmd%"=="PASSWD" (
    call :INTERNAL_PASS_CHANGE
    goto CMD_LOOP
)

if /i "%base_cmd%"=="EXIT" (
    goto MAIN_MENU
)

echo '%base_cmd%' is not recognized as an internal command.
goto CMD_LOOP

:: =====================================
:: 4: PROTECTION COMPONENT
:: =====================================
:MENU_PROTECTION
cls
echo ===========================================
echo      PROTECTION: DIRECTORY SCANNER
echo ===========================================
echo.
set "scan_dir="
set /p "scan_dir=Enter directory to scan (e.g., C:\Users\Public): "

if not exist "%scan_dir%\" (
    echo [!] Directory not found.
    pause
    goto MAIN_MENU
)

echo.
echo Scanning "%scan_dir%" for executables and scripts...
echo ---------------------------------------------------
set "threat_count=0"

:: Recursively search for common executable and script extensions
for /f "delims=" %%F in ('dir /s /b "%scan_dir%\*.exe" "%scan_dir%\*.bat" "%scan_dir%\*.vbs" 2^>nul') do (
    echo [?] Found: %%~nxF
    set /a threat_count+=1
)

echo ---------------------------------------------------
echo Scan Complete. Found !threat_count! target file(s).
if !threat_count! gtr 0 (
    echo [!] Review the files above to ensure they are safe.
) else (
    echo [✓] System directories appear clean.
)
echo.
pause
goto MAIN_MENU

:: =====================================
:: 5: CHANGE PASSWORD COMPONENT
:: =====================================
:MENU_CHANGE_PASS
cls
call :INTERNAL_PASS_CHANGE
goto MAIN_MENU

:INTERNAL_PASS_CHANGE
echo ===========================================
echo             CHANGE PASSWORD
echo ===========================================
echo.
set /p "old_check=Enter CURRENT PIN: "
if "%old_check%"=="%PIN%" (
    set /p "new_pin=Enter NEW PIN: "
    set /p "new_pin_conf=Confirm NEW PIN: "
    if "!new_pin!"=="!new_pin_conf!" (
        set "PIN=!new_pin!"
        echo [✓] PIN updated successfully.
    ) else (
        echo [!] PINs do not match. Change aborted.
    )
) else (
    echo [!] Authentication failed.
)
pause
goto :eof

:: =====================================
:: 6: UNDO EVERYTHING / EXIT
:: =====================================
:MENU_UNDO
cls
echo ===========================================
echo          UNDO AND RESET UTILITY
echo ===========================================
echo.
echo This function will reset the security PIN to default (0000), 
echo wipe the dynamically mapped App list, and exit the terminal.
echo.
choice /C YN /N /M "Are you sure you want to proceed? (Y/N): "

if errorlevel 2 goto MAIN_MENU
if errorlevel 1 (
    set "PIN=0000"
    for /l %%i in (1,1,%app_count%) do (
        set "app_name_%%i="
        set "app_url_%%i="
    )
    set "app_count=0"
    echo [✓] Configurations wiped. Exiting execution.
    timeout /t 2 >nul
    exit
)
