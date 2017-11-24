#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force    ;Skips the dialog box and replaces the old instance automatically
SetKeyDelay, 90          ;Any number you want (milliseconds)
CoordMode,Mouse,Screen   ;Initial state is Relative
CoordMode,Pixel,Screen   ;Initial state is Relative. Frustration awaits if you set Mouse to Screen and then use GetPixelColor because you forgot this line. There are separate ones for: Mouse, Pixel, ToolTip, Menu, Caret
MouseGetPos, xpos, ypos  ;Save initial position of mouse
WinGet, SavedWinId, ID, A     ;Save our current active window
SetBatchLines, -1 
SetRegView 64  ; Requires v1.1.08+
#Include JSON_ToObj.ahk
EnvSet,RSYNC_PASSWORD, change_password
; End of directives
; -----------------
; This script is used for printing admin tickets
; Usage primer: Auto_bar_code.ahk COMPUTER_NAME_OF_TERMINAL will print two admin tickets for provided terminal name
; Version 2 adds option to print barcode without providing parameter COMPUTER_NAME_OF_TERMINAL - it will print Admin ticket of the current user
; Version 3 adds option to print barcode from provided text file of usernames you need admin ticket - text file should be in the same dir with name admin.txt and the 
; script should be run with admin.txt parameter: $ Auto_bar_code.ahk admin.txt
; -----------------
mycommand=%1%
If mycommand = 
{
	Goto LocalAdmin
}
else if mycommand = admin.txt
{
	Goto admintxt
}
else
{
	Goto RemoteAdmin
}

admintxt:
Loop, read, admin.txt
{
	Clipboard = %A_LoopReadLine%
	GoSub, AutoAdminPre
}
Return

AutoAdminPre:
Run, c:\tools\cygwin64\bin\rsync -avc --progress --chown=Administrators --chmod=ugo=rwx  rsync://admin@0.0.0.0/Prod/%Clipboard%/middleware.config  /cygdrive/c/ProgramData/AppInc/Middleware/middleware.config 
Sleep, 1500
FileRead, Middlconf, C:\ProgramData\AppInc\Middleware\middleware.config
		if not ErrorLevel  ; Successfully loaded.
		{
		NewStr := RegExReplace(Middlconf, "autologin=""[a-zA-Z0-9]{2,15}(/\S*)?", "autologin=""false")
		NewStr1 := RegExReplace(NewStr, "type=""0", "type=""1")
		FileDelete, C:\ProgramData\AppInc\Middleware\middleware.config
		FileAppend, %NewStr1%, C:\ProgramData\AppInc\Middleware\middleware.config
		Contents =  ; Free the memory.
		Sleep, 12000
		}
Gosub AutoAdminweb
Return

RemoteAdmin:	
Run, c:\tools\cygwin64\bin\rsync -avc --progress --chown=Administrators --chmod=ugo=rwx  rsync://admin@0.0.0.0/Prod/%1%/middleware.config  /cygdrive/c/ProgramData/AppInc/Middleware/middleware.config 
Sleep, 5000
FileRead, Middlconf, C:\ProgramData\AppInc\Middleware\middleware.config
		if not ErrorLevel  ; Successfully loaded.
		{
		NewStr := RegExReplace(Middlconf, "autologin=""[a-zA-Z0-9]{2,15}(/\S*)?", "autologin=""false")
		NewStr1 := RegExReplace(NewStr, "type=""0", "type=""1")
		FileDelete, C:\ProgramData\AppInc\Middleware\middleware.config
		FileAppend, %NewStr1%, C:\ProgramData\AppInc\Middleware\middleware.config
		Contents =  ; Free the memory.
		}
Sleep, 1000
Goto Adminweb
Return

LocalAdmin:
FileRead, Middlconf, C:\ProgramData\AppInc\Middleware\middleware.config
		if not ErrorLevel  ; Successfully loaded.
		{
		NewStr := RegExReplace(Middlconf, "autologin=""[a-zA-Z0-9]{2,15}(/\S*)?", "autologin=""false")
		FileDelete, C:\ProgramData\AppInc\Middleware\middleware.config
		FileAppend, %NewStr%, C:\ProgramData\AppInc\Middleware\middleware.config
		Contents =  ; Free the memory.
		}
Goto Adminweb
Return

AutoAdminweb:
UsrStr := RegExMatch(Middlconf, "defaultusername=""([0-9A-Z]*)""", username)
JSONString1 = {"t_un":"%username1%"}
WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
timedOut := False
	try
	{
	WebRequest.Open("POST", "http://0.0.0.0/getmwauth")
	}
catch error
	goto NoNet
	try
	{
	WebRequest.Send(JSONString1)
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

strJson := response
objJson := json_toobj(strJson)
mwadminbcode := objJson["mwadmin_bar_code"]
uname := objJson["mw_un"]
pword := objJson["mw_pw"]

if response = {"mwadmin_bar_code":"","success":"true","error":""}
	{
	Gosub OfflineAdmin
	}
else
	{
	Gosub AutoAdmin
	}
Return

AutoAdmin:
{
IfWinExist, Middleware
    WinClose
Run, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
WinWait, Middleware, , 3
Sleep, 4000
WinActivate, Middleware, , 3
Send %uname%
Sleep 400
Send {Tab}
Sleep 400
SendInput % pword
Sleep 1000
MouseClick, left, 850, 650 
}
Gosub AdminTicket
Return

Adminweb:
UsrStr := RegExMatch(Middlconf, "defaultusername=""([0-9A-Z]*)""", username)
JSONString1 = {"t_un":"%username1%"}
WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
timedOut := False
	try
	{
	WebRequest.Open("POST", "http://0.0.0.0/getmwauth")
	}
catch error
	goto NoNet
	try
	{
	WebRequest.Send(JSONString1)
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

strJson := response
objJson := json_toobj(strJson)
mwadminbcode := objJson["mwadmin_bar_code"]
uname := objJson["mw_un"]
pword := objJson["mw_pw"]

;MsgBox, Code is %mwadminbcode%, username is %uname%, and password is %pword% 
;MsgBox, % objJson["mwadmin_bar_code"]

if response = {"mwadmin_bar_code":"","success":"true","error":""}
	{
	;MsgBox, There is no MW_Bar_Code!
	Goto OfflineAdmin
	}
else
	{
	;MsgBox, Barcode Found!
	Goto Admin
	}
Return

Admin:
{
IfWinExist, Middleware
    WinClose
Run, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
WinWait, Middleware, , 3
Sleep, 4000
Send %uname%
Sleep 400
Send {Tab}
Sleep 400
SendInput % pword
Sleep 1000
MouseClick, left, 850, 650 
}
Goto AdminTicket
Return

OfflineAdmin:
{
;MsgBox, There was no UN/PW in the database for this terminal.`nI will use 'admin' user to login instead.
IfWinExist, Middleware
    WinClose
Run, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
WinWait, Middleware, , 3
user = admin
Send %user%
Sleep 400
Send {Tab}
Sleep 400
pass = change_password
SendInput % pass
Sleep 1000
Send {Enter}
}
Goto AdminTicket
Return

NoNet:
;MsgBox, There was a problem with network connection!`nPlease connect VPN factory and retry.
ExitApp

AdminTicket:
Sleep, 15000
MouseClick, left, 715, 60
Sleep, 2000
MouseClick, left, 840, 466
Sleep, 5000
If mycommand = 
{
	Goto LocalMwConf
}
else if mycommand = admin.txt
{
	Return
}
else
{
	Goto RemoteMwConf
}
Return

RemoteMwConf:
Sleep, 1500
IfWinExist, Middleware
    WinClose
Run, c:\tools\cygwin64\bin\rsync -avc --progress --chown=Administrators --chmod=ugo=rwx  rsync://admin@0.0.0.0/Prod/%1%/middleware.config  /cygdrive/c/ProgramData/AppInc/Middleware/middleware.config 
ExitApp

LocalMwConf:
Sleep, 1500
IfWinExist, Middleware
    WinClose
FileRead, Middlconf, C:\ProgramData\AppInc\Middleware\middleware.config
		if not ErrorLevel  ; Successfully loaded.
		{
		NewStr := RegExReplace(Middlconf, "autologin=""[a-zA-Z0-9]{2,15}(/\S*)?", "autologin=""true")
		FileDelete, C:\ProgramData\AppInc\Middleware\middleware.config
		FileAppend, %NewStr%, C:\ProgramData\AppInc\Middleware\middleware.config
		Contents =  ; Free the memory.
		}
ExitApp