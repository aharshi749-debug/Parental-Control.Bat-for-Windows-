#--HELLO



Parental Control System for Windows (Batch Script)
hello, ever wanted somebody to get off your damn PC or device when you said so? well look here , a simple bat script that you can set up quickly before the Guest starts using it!
the passcode is 0000
go ahead and change it to anything else, maybe Dr.PeePeeDiahreahsteinPoopypantsEsquire, idk lol

Overview

This project is a Parental Control Panel written entirely in Windows Batch (.bat). It provides a menu-driven interface for managing timers, app whitelists, a custom command line, directory scanning, password management, and reset utilities. Designed to run directly in the Windows Command Prompt, it simulates a lightweight parental control operating system.

Features

Authentication system → PIN gate before accessing the menu.

Timer enforcement → Configurable countdown with warnings and forced shutdown if exceeded.

App launcher → Whitelist browser links for controlled access.

Custom command line → ASCII shell with commands like MKTXT, CAT, LS, and PASSWD.

Protection module → Directory scanner for .exe, .bat, and .vbs files.

Password management → Change PIN with confirmation checks.

Undo/Exit utility → Wipes configurations, resets PIN, and exits cleanly.

Setup

Copy the batch script into a .bat file (e.g., ParentalControl.bat).

Run the script in Windows Command Prompt.

Default PIN is 0000. Enter this to access the main menu.

Usage

Timer → Set a countdown; warns 20 seconds before shutdown.

Apps → Add and launch whitelisted browser links.

Command Line → Use custom commands (MKTXT, CAT, LS, PASSWD, EXIT).

Protection → Scan directories for executable/script files.

Change Password → Update the system PIN.

Undo/Exit → Reset PIN and app list, then exit.

Example Session

Please enter your PIN: 0000

[1] Timer
[2] Apps
[3] Command Line
[4] Protection
[5] Change Passwords
[6] Undo Everything / Exit
