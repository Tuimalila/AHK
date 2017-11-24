#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CoordMode, Mouse, Screen
#singleinstance, force ;prevents multiple instances of the script.
#persistent ;tells the script to continue running permanently.
setbatchlines, 10ms ;pauses the script for 10ms every 10ms. minimizes resource use.
settimer, time, 1500 ;check current date and time every second and a half.
settimer, time2, 5000 ; make block button and middleware topmost windows every 5sec
#Include json.ahk
FileInstall, C:\Users\user\Desktop\ahk\TimeLimit\disabled.png, %A_ScriptDir%\disabled.png, 1
FileInstall, C:\Users\user\Desktop\ahk\TimeLimit\black.png, %A_ScriptDir%\black.png, 1
bactive = 0
24hactive = 0
devdis = 0
tcount = 0
hcount = 0
; End of directives

; This script displays blocking graphic in defined time ranges
	
FileRead, tlog, TimeLimitLog.txt
if not ErrorLevel
	tlog=1
else
FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%		TimeLimit.exe was started for the first time on this computer (%A_ComputerName%)`n, TimeLimitLog.txt 

if A_ComputerName = blank	; If computer is not yet in production we don't know where it is going to be placed, so we don't run this script yet
	{
	FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%		Computer name was blank - exiting..`n, TimeLimitLog.txt 
	ExitApp
	}
	
; This section determines if this program should run on this terminal (database field is _____)
data = `{`"Hostname`":`"%A_ComputerName%`"`}	
WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
timedOut := False
	try
	{
	WebRequest.Open("POST", "http://0.0.0.0/gettimelimit")
	}
catch error
	goto NoNet
	try
	{
	WebRequest.Send(data)
	}
catch error
	goto NoNet
response := WebRequest.ResponseText
ComObjError(False)
WinHttpReq.Status
If (A_LastError) ;if WinHttpReq.Status was not set (no response received yet)
    timedOut := True
ComObjError(True)
If (timedOut)
    goto NoNet
amiblocked := JSON.Load(response)
str1 := JSON.Dump(amiblocked, Func("myReplacer"))

if str1 = {"time_limit":"false"}
	Goto WriteINIFalse
else if str1 = {"time_limit":"true"}
	Goto WriteINI
Return ; designates the end of the auto-execute section.

NoNet:
;MsgBox, There was no VPN connection
FileRead, tlimit, C:\tools\status\timelimited.txt
	if not ErrorLevel
	{
		FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%		There was no net`, going to read the ini file.`n, TimeLimitLog.txt 
		Goto ReadINI
	}
	else
	{
		FileRead, 24h, C:\tools\status\timelimit24h.txt
		if not ErrorLevel
			Goto task3
		else
		{
			FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%		There was no net`, no ini file and no timelimit24h.txt. Exiting..`n, TimeLimitLog.txt 
			ExitApp
		}
	}
Return

WriteINI:
FileRead, tlimit, C:\tools\status\timelimited.txt
if not ErrorLevel
	{
		FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%		Ini file already exits.`n, TimeLimitLog.txt 
		Return
	}
	else
	{
		IniWrite, 1, C:\tools\status\timelimited.txt, HOST, Hostname
		FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%		Writing ini file - timelimit exists for this terminal (%A_ComputerName%)!`n, TimeLimitLog.txt 
	}
Return

WriteINIFalse:
FileRead, tlimit, C:\tools\status\timelimited.txt
if not ErrorLevel
		{
		FileRead, 24h, C:\tools\status\timelimit24h.txt
		if not ErrorLevel
			Goto task3
		else
			{
			FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%		Server says this terminal (%A_ComputerName%) is not timelimited and there is no timelimit24.txt. Exiting..`n, TimeLimitLog.txt
			ExitApp
			}
		}
	else
		{
		IniWrite, 0, C:\tools\status\timelimited.txt, HOST, Hostname
		FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%		Writing ini file - timelimit does NOT exists for this terminal (%A_ComputerName%)!`n, TimeLimitLog.txt 
		FileRead, 24h, C:\tools\status\timelimit24h.txt
		if not ErrorLevel
			Goto task3
		else
			{
			FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%		Timelimit does not exists for this terminal (%A_ComputerName%) and there is no timelimit24h.txt. Exiting..`n, TimeLimitLog.txt 
			Exitapp
			}
		}
Return

ReadINI:
IniRead, OutputVar, C:\tools\status\timelimited.txt, HOST, Hostname
		if (OutputVar = "1")
			{
				FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%		This terminal (%A_ComputerName%) is timelimited according to the ini file`, seems computer has been restarted or TimeLimit.exe was run for the first time`n, TimeLimitLog.txt
				Return
			}
		else if (OutputVar = "0")
			{
			FileRead, 24h, C:\tools\status\timelimit24h.txt
			if not ErrorLevel
				Goto task3
			else
				{
				FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%		There is no net`, but this terminal (%A_ComputerName%) is not timelimited according to the ini file - and there is no timelimit24h.txt. Exiting..`n, TimeLimitLog.txt 
				Exitapp
				}
			}
Return

time:	; Main logic of the script gets called every second and a half to check:
tcount++	; but first make a log entry every 4 hours
If (Mod(tcount, 9600) = 0)
{
	hcount++
	Runtime := (hcount * 4)
	FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%		Been runing for %runtime% hours since last restart.`n, TimeLimitLog.txt 
}
FileRead, 24h, C:\tools\status\timelimit24h.txt
if not ErrorLevel  	; Successfully loaded file called timelimit24h.txt in \tools\status 
	Goto task3		; so task3 blocks betting 24h and disables devices (also restarts MW)
	else
 {
	if devdis = 1	; Script will enable devices only if there is no timelimit24h.txt any more
		gosub Enabledev
	Gui, 3:destroy	; 24h block
	Gui, 4:destroy	; 24h block
	24hactive = 0
	IfWinExist, AdminWindow
		admin = 1
	else
		admin = 0
   formattime, time, , HH:mm:ss ; provides current system time in 24 hour format
   if (admin = 0 AND bactive = 0 AND time > "00:00:00" AND time < "08:59:59") ; task1 enables blocking every day after 00:00:00
      goto, task1
   else if admin = 1	; if there is an admin window open disable blocking
      goto, task2
   else if (bactive = 1 AND time > "09:00:00") ; task2 disables blocking every day at 09:00:00
      goto, task2
 }
Return


time2:	; Makes sure nothing covers the blocked buttons
If (bactive = 0 AND 24hactive = 0)
	Return
else if (bactive = 1 AND 24hactive = 0)
	{
	WinActivate, Middleware		; hides possible taskbar
	WinSet, AlwaysOnTop, on
	WinActivate, BlockBet
	WinSet, AlwaysOnTop, on
	WinActivate, BlockBar
	WinSet, AlwaysOnTop, on
	}
else if (bactive = 0 AND 24hactive = 1)
	{
	WinActivate, Middleware		; hides possible taskbar
	WinSet, AlwaysOnTop, on
	WinActivate, BlockBet2
	WinSet, AlwaysOnTop, on
	WinActivate, BlockBar2
	WinSet, AlwaysOnTop, on
	}	
Return

task1:	; Display blocking graphic in between 24h an 9h
If bactive = 1
	Return
	{
	  Gui 1:Default
	  Gui, Color, Black
      Gui, -caption +toolwindow +AlwaysOnTop
      Gui, font, s 14 bold, Verdana
	  Gui, Add, Picture, w400 h135 x0 y0 gScreen, disabled.png
	  Gui, Add, Text, x80 y45 +BackgroundTrans, Disabled
      Gui, Show, % "x" A_ScreenWidth-400 " y" A_ScreenHeight-137, BlockBet
      WinSet, AlwaysOnTop, on
      WinSet, TransColor, White, BlockBet
	  
	  Gui 2:Default
	  Gui, Color, Black
      Gui, -caption +toolwindow +AlwaysOnTop
      Gui, Add, Picture, w1270 h5 x0 y0, black.png
      Gui, Show, % "x" A_ScreenWidth-1680 " y" A_ScreenHeight-10, BlockBar
	  WinSet, AlwaysOnTop, on
      WinSet, TransColor, White, BlockBar
	  bactive = 1
	  FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%		Enabled blocking from 00:00 until 09:00!`n, TimeLimitLog.txt 
	}
Return

task2:	; Disable overlay button
if (bactive = 0 AND 24hactive = 0)
	Return
else
 {
   Gui, destroy
   Gui, 2:destroy
   Gui, 3:destroy
   Gui, 4:destroy
   bactive = 0
   24hactive = 0
   ;Gosub Enabledev - we don't disable devices from 24-09 so we don't need to enable them here
   FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%		Disabled blocking!`n, TimeLimitLog.txt 
 }
Return

task3:	; Display blocking graphic for 24 hours and disable devices
IfWinExist, AdminWindow 
		admin = 1
	else
		admin = 0
if admin = 1
      goto, task2 ; but remove blocking graphic when admin window is open
else if (admin = 0 AND 24hactive = 1)
	Return
else
	{
	  Gui, destroy
	  Gui, 2:destroy
	  
	  Gui 3:Default
	  Gui, Color, Black
      Gui, -caption +toolwindow +AlwaysOnTop
      Gui, font, s 14 bold, Verdana
	  Gui, Add, Picture, w400 h135 x0 y0 gScreen2, disabled.png
	  Gui, Add, Text, x80 y55 +BackgroundTrans, Disabled
      Gui, Show, % "x" A_ScreenWidth-400 " y" A_ScreenHeight-137, BlockBet2
      WinSet, AlwaysOnTop, on
      WinSet, TransColor, White, BlockBet2
	  
	  Gui 4:Default
	  Gui, Color, Black
      Gui, -caption +toolwindow +AlwaysOnTop
      Gui, Add, Picture, w1270 h5 x0 y0, black.png
      Gui, Show, % "x" A_ScreenWidth-1680 " y" A_ScreenHeight-10, BlockBar2
	  WinSet, AlwaysOnTop, on
      WinSet, TransColor, White, BlockBet2
	  24hactive = 1
	  FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%		Enabled 24h blocking!`n, TimeLimitLog.txt 
	  if devdis = 1
		return
		else
			gosub Disabledev
	}
Return

Enabledev:
FileRead, devices, C:\ProgramData\AppInc\Middleware\devices.config
	if not ErrorLevel
		{
		NewStr := RegExReplace(devices, "enable=""false", "enable=""true")
		NewStr1 := RegExReplace(NewStr, "enable=""False", "enable=""true")
		FileDelete, C:\ProgramData\AppInc\Middleware\devices.config
		FileAppend, %NewStr1%, C:\ProgramData\AppInc\Middleware\devices.config
		Contents =  ; Free the memory.
		}
devdis = 0
IfWinExist, Middleware
    WinClose
Sleep, 1000
Run, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%		Enabled devices.config back to "True" and restarted Middleware.`n, TimeLimitLog.txt 
Return

Disabledev:
FileRead, devices, C:\ProgramData\AppInc\Middleware\devices.config
	if not ErrorLevel
		{
		NewStr := RegExReplace(devices, "enable=""true", "enable=""false")
		NewStr1 := RegExReplace(NewStr, "enable=""True", "enable=""false")
		FileDelete, C:\ProgramData\AppInc\Middleware\devices.config
		FileAppend, %NewStr1%, C:\ProgramData\AppInc\Middleware\devices.config
		Contents =  ; Free the memory.
		}
devdis = 1
IfWinExist, Middleware
    WinClose
Sleep, 1000
Run, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%		Disabled devices.config to "False" and restarted Middleware.`n, TimeLimitLog.txt 
Return

Screen:
SoundPlay, %A_WinDir%\Media\Windows Exclamation.wav
FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%		Somebody touched the blocking graphic in vain only to hear Windows Exclamation.wav`n, TimeLimitLog.txt 
Return

Screen2:
SoundPlay, %A_WinDir%\Media\Windows Exclamation.wav
FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%		Somebody touched the blocking graphic in vain only to hear Windows Exclamation.wav`n, TimeLimitLog.txt 
Return

myReplacer(this, key, value*) {
	; Initially 'replacer' gets called with an empty key("") representing the object being stringified. Make sure to return the root object as is.
	if (key == "" || key == "time_limit")
		return value[1] ; on v1.1, if var contains a number(cached integer), 'return var' stringifies the return value -> 0 becomes "0"
	return JSON.Undefined ; see line 336 of JSON.ahk
}