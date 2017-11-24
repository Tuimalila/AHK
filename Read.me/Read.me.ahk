#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force   ; Skips the dialog box and replaces the old instance automatically
SetKeyDelay, 90         ; Any number you want (milliseconds)
CoordMode,Mouse,Screen  ; Initial state is Relative
CoordMode,Pixel,Screen  ; Initial state is Relative. 
SetBatchLines, -1       ; Never sleep (i.e. have the script run at maximum speed).
SetRegView 64  			; Requires v1.1.08+
DetectHiddenWindows, On	; Determines whether invisible windows are "seen" by the script.
SetTitleMatchMode, 2    ; A window's title can contain WinTitle anywhere inside it to be a match. 
#InstallKeybdHook		; Hooks required to get A_TimeIdlePhysical
#InstallMouseHook		; Hooks required to get A_TimeIdlePhysical
SetTimer, CloseButton, 60000 ; Set timer check every minute to check for idleness
SetTimer, RepeatBeri, 60000  ; Set timer check every minute whether to repeat the test after half an hour
; End of directives
; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; 
; This script opens a webpage and disables keyboard combinations to close it - after 10 minutes of activity it displays the exit button to sleep the script.
; After half an hour, if the script was not terminated, it runs the browser in full screen again and after 10 minutes of activitiy it displays the exit button to sleep the script again.
; To terminate this script you need to press the key combination: CTRL+ALT+q
; 
; -----------------
; Open this webpage
; -----------------
OutputVar="file:///C:/Users/uiser/Desktop/read.me/ReadMobile/ReadMobile.html"
; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Open Chrome in full screen on 1st monitor
; Run, C:\Program Files (x86)\Google\Chrome\Application\chrome.exe --kiosk-printing --new-window %OutputVar%
Run, C:\Program Files (x86)\Google\Chrome\Application\chrome.exe --chrome --kiosk %OutputVar% --start-fullscreen --disable-pinch --overscroll-history-navigation=0
WinWait, Google Chrome
Gosub MoveChrome
Gosub diskey
Return

; Disable Alt+F4,Ctrl+Esc,Left&Right Windows keys and set keycombo ctrl+alt+q to quit
diskey:
LWin::return 		; disable left Windows key
RWin::return 		; disable right Windows key
!F4::return			; disable ALT+F4
!Tab::return		; disable ALT+TAB
!Escape::return		; disable ALT+ESC
^Escape::return 	; disable CTRL+ESC
+^Escape::return 	; disable SHIFT+CTRL+ESC
F11::return			; disable F11
!^q:: 				; enable CTRL+ALT+q to exit
goto ExitBeri
Return

; Move Chrome to primary monitor and put it in full screen mode
MoveChrome:
BlockInput, On
SysGet, primary_monitor, Monitor, 1
WinGetPos, chrome_x, chrome_y, chrome_width, chrome_height, ahk_class Chrome_WidgetWin_1
chromeplus := chrome_y + 4

if primary_monitortop = 0
{
	if chromeplus >= %primary_monitortop% ; ce je y vecji od 0 je Chrome na spodnjem ekranu, zato kar na fullscreen z njim!
		{
			
		WinActivate, Google Chrome
		Send {F11}
		}
	else if chromeplus < %primary_monitortop% ; ce je Chrome na zgornjem
		{
		WinActivate, Google Chrome
		WinMove, A, , 0, 50
		Send {F11}
		}
}
else if primary_monitortop = -1080
{
	if chrome_y >= 0 ; ce je y vecji od 0 je Chrome na spodnjem ekranu, zato kar na fullscreen z njim!
		{
		WinActivate, Google Chrome
		Send {F11}
		}
	else if chrome_y < 0 ; ce je Chrome na zgornjem
		{
		WinActivate, Google Chrome
		WinMove, A, , 0, 50
		Send {F11}
		}
}
else if primary_monitortop = -1024
{
	if chrome_y >= 0 ; ce je y vecji od 0 je Chrome na spodnjem ekranu, zato kar na fullscreen z njim!
		{
		WinActivate, Google Chrome
		Send {F11}
		}
	else if chrome_y < 0 ; ce je Chrome na zgornjem
		{
		WinActivate, Google Chrome
		WinMove, A, , 0, 50
		Send {F11}
		}
}
else if primary_monitortop = -1050
{
	if chrome_y >= 0 ; ce je y vecji od 0 je Chrome na spodnjem ekranu, zato kar na fullscreen z njim!
		{
		WinActivate, Google Chrome
		Send {F11}
		}
	else if chrome_y < 0 ; ce je Chrome na zgornjem
		{
		WinActivate, Google Chrome
		WinMove, A, , 0, 50
		Send {F11}
		}
}
else
{
	if chrome_y >= 0 ; ce je y vecji od 0 je Chrome na spodnjem ekranu, zato kar na fullscreen z njim!
		{
		WinActivate, Google Chrome
		Send {F11}
		}
	else if chrome_y < 0 ; ce je Chrome na zgornjem
		{
		WinActivate, Google Chrome
		WinMove, A, , 0, 50
		Send {F11}
		}	
}
BlockInput, Off
WinActivate, Google Chrome
Return

; After 10 minutes of activity the close/exit button appears on top right corner of primary screen
CloseButton:
If (A_TimeIdlePhysical < 60000) ; edited this line as per below
	ActiveTime++
Else
	IdleTime++
If (ActiveTime >= 10)
{
    SetTimer, CloseButton, Off
	if primary_monitorright = 1680
		{
		Gui, Color, Black
		Gui, -caption +toolwindow +AlwaysOnTop
		Gui, font, s 10 normal, Verdana
		Gui, Add, Button, h50 vCLOSEWB gCLOSEWB, Exit!
		Gui, Show, % "x" A_ScreenWidth -95 " y" A_ScreenHeight-1030 , EXITB
		WinSet, AlwaysOnTop, on
		WinSet, TransColor, White, EXITB
		Return
		}
	else if (primary_monitorright = 1920 and primary_monitortop = -1200)
		{
		Gui, Color, Black
		Gui, -caption +toolwindow +AlwaysOnTop
		Gui, font, s 10 normal, Verdana
		Gui, Add, Button, h50 vCLOSEWB gCLOSEWB, Exit!
		Gui, Show, % "x" A_ScreenWidth-100 " y" A_ScreenHeight-1180 , EXITB
		WinSet, AlwaysOnTop, on
		WinSet, TransColor, White, EXITB
		Return
		}
	else if (primary_monitorright = 1920 and primary_monitortop = -1080)
		{
		Gui, Color, Black
		Gui, -caption +toolwindow +AlwaysOnTop
		Gui, font, s 10 normal, Verdana
		Gui, Add, Button, h50 vCLOSEWB gCLOSEWB, Exit!
		Gui, Show, % "x" A_ScreenWidth-100 " y" A_ScreenHeight-1050 , EXITB
		WinSet, AlwaysOnTop, on
		WinSet, TransColor, White, EXITB
		Return
		}
	else if (primary_monitorright = 1920 and primary_monitortop = 0)
		{
		Gui, Color, Black
		Gui, -caption +toolwindow +AlwaysOnTop
		Gui, font, s 10 normal, Verdana
		Gui, Add, Button, h50 vCLOSEWB gCLOSEWB, Exit!
		Gui, Show, % "x" A_ScreenWidth-100 " y" A_ScreenHeight-1050 , EXITB
		WinSet, AlwaysOnTop, on
		WinSet, TransColor, White, EXITB
		Return
		}
	else if primary_monitorright = 1280
		{
		Gui, Color, Black
		Gui, -caption +toolwindow +AlwaysOnTop
		Gui, font, s 10 normal, Verdana
		Gui, Add, Button, h50 vCLOSEWB gCLOSEWB, Exit!
		Gui, Show, % "x" A_ScreenWidth-95 " y" A_ScreenHeight-1000 , EXITB
		WinSet, AlwaysOnTop, on
		WinSet, TransColor, White, EXITB
		Return
		}
	else 
		{
		Gui, Color, Black
		Gui, -caption +toolwindow +AlwaysOnTop
		Gui, font, s 10 normal, Verdana
		Gui, Add, Button, h50 vCLOSEWB gCLOSEWB, Exit!
		Gui, Show, % "x" A_ScreenWidth-95 " y" A_ScreenHeight-1000 , EXITB
		WinSet, AlwaysOnTop, on
		WinSet, TransColor, White, EXITB
		Return
		}
}
else
Return

; Function to repeat Beri.me tests
RepeatBeri:
if Iterate=1 ; if test are done at least once, wait half an hour and repeat them
	{
	IterateTime++
		if IterateTime>=30
		{
			Run, C:\Program Files (x86)\Google\Chrome\Application\chrome.exe --chrome --kiosk %OutputVar% --start-fullscreen --disable-pinch --overscroll-history-navigation=0
			WinWait, Google Chrome
			ActiveTime=0
			IdleTime=0
			Iterate=0
			IterateTime=0
			Gosub MoveChrome
			SetTimer, CloseButton, On
			Return
		}
		else
			return
	}
else	
Return

; Function to exit
ExitBeri:
IfWinExist, Google Chrome
	WinClose
Exitapp	
Return

; Function to sleep
CloseWB:
Iterate=0 				; Variable to check if initial test was done
IfWinExist, Google Chrome
	WinClose
Gosub GuiClose
Iterate++
Return

GuiClose:
Gui,destroy
Return