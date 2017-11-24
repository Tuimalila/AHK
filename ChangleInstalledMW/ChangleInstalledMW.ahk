#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
;SetWorkingDir %A_Temp%  ; Ensures a consistent starting directory.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force    ;Skips the dialog box and replaces the old instance automatally
SetKeyDelay, 90          ;Any number you want (milliseconds)
CoordMode,Mouse,Screen   ;Initial state is Relative
CoordMode,Pixel,Screen   ;Initial state is Relative. Frustration awaits if you set Mouse to Screen and then use GetPixelColor because you forgot this line. There are separate ones for: Mouse, Pixel, ToolTip, Menu, Caret
MouseGetPos, xpos, ypos  ;Save initial position of mouse
WinGet, SavedWinId, ID, A     ;Save our current active window
SetBatchLines, -1 

EnvSet,RSYNC_PASSWORD, Change_password

Run, c:\tools\cygwin64\bin\rsync -avc --progress --chown=Administrators --chmod=ugo=rwx rsync://admin@0.0.0.0/ProdCopy/accounts.txt /%A_ScriptDir%/accounts.txt
Sleep, 2000

Gui, Show, h710 w360, Change Middleware Environment and Users
Gui, Font, cBlack
  ListBox_Text = ;initialize empty variable
  Loop, Read, %A_ScriptDir%\accounts.txt
    {
	StringSplit, listout, A_LoopReadLine, `,
	ListBox_Text .= listout1 "`t" "`t" listout2 "`t" "`t" listout3 "`t" "`t" "`t" listout4 "`t" listout5 "|" ;append a line of text
	}
  Gui, Add, ListBox, x6 y10 w355 h370 vMyListBox gDbleClick, %ListBox_Text%
  Gui, Add, UpDown, x196 y80 w160 h-60 , UpDown
  Gui, Font, cBlue bold
  Gui, Add, Checkbox, Checked x40 vOpt1, Also install appropriate Middleware
  Gui, Font, cBlack normal
  Gui, Add, Button, x100 y400 w150 h30 vBUTTONCopy gBUTTONCopy, Copy Selected User and/or Middleware
  Gui, Add, Text, x5 y437 w350 h1 0x7  ;Horizontal Line > Black
  Gui, Font, cGreen bold
  Gui, Add, Text, x10 y450 w290 Left,Select which primary-browser you want to use?
  Gui, Font, cBlack normal
  Gui, Add, ListBox, h60 vUIChoice, Prod-AT|Prod-DE|Prod-Copy-AT|Prod-Copy-DE
  Gui, Add, Button, x175 y480 w70 vChange gChange, Select User Interface
  Gui, Font, cRed underline bold
  Gui, Add, GroupBox, x5 y541 w291 h166,Advanced options
  Gui, Font, cBlack normal
  Gui, Add, Text, x10 y563 w290 Left,Here you can change Middleware installed
  Gui, Add, ListBox, h130 vEnvChoice, ProdCopy|ProdCopy-2|TestV2.0|ProductionA|ProductionD|ProductionH|ProductionS|ProductionB|ProductionDE|ProductionAT
  Gui, Add, Button, x165 y620 w90 vUPGRADE gUPGRADE, Install selected`nMiddleware
  Gui, Font, cBlack bold
  Gui, Add, Text, x150 y690, Version: 05.10.2016
  Gui, Font, cBlack normal
  Gui, Add, GroupBox, x294 y450 w62 h99 , Start/Stop
  Gui, Add, Button, x300 y470 w50 h30 vKILL gKILL, Kill MW
  Gui, Add, Button, x300 y510 w50 h30 vSTART gSTART, Start MW
  Gui, Add, Button, x300 y575 w50 vPURGE gPURGE, Delete MW if there are errors!
  Gui, Add, Button, x300 y672 w50 h30 , Close
return

UninstallMW:
BlockInput, on
;Close MW if it is running and open Control Panel to uninstall MW
Process, Close, Middleware.exe
Run, control appwiz.cpl
;WinWait, Programs and Features
Sleep 1000
Send {Tab}
Sleep 1000
Send {Tab}
Sleep 1000
Send {Tab} 									; Go to search box
Send Term 									; Find Middleware
Send {Enter}
Send {Tab}
Sleep 100
Send {Tab}
Sleep 100
Send {Tab}
Sleep 100
Send {Tab}
Sleep 100
Send {Tab}
Sleep 100
Send {Tab}
Sleep 100
Send {Space}
Sleep 100
Send {Enter} 								; Send uninstall command
WinWait, Middleware Maintenance 	; Wait till uninstall appears
Send {Left}
Send {Enter} 								; Uninstall Middleware
WinClose, Term - Programs and Features
WinClose, Term - Control Panel\All Control Panel Items\Programs and Features
Sleep, 3000
BlockInput, off
Return

Kill:
{
	IfWinExist, Middleware
    WinClose
}
Return

Start:
{
	FileRead, test, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
		if not ErrorLevel  ; Successfully loaded.
		{
		Run, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
		}
	else
		{
	Msgbox,,RESULT, Middleware is not installed.
		}
Return
}

Purge:
{
IfWinExist, Middleware
WinClose
FileRead, test, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
if not ErrorLevel  ; Successfully loaded.
	{
		Gosub, UninstallMW
		FileRemoveDir, C:\Users\%A_UserName%\AppData\Local\Apps\2.0\, 1
	}
else
	{
		Msgbox,,RESULT, Will delete all Middleware installation files.
		FileRemoveDir, C:\Users\%A_UserName%\AppData\Local\Apps\2.0\, 1
	}
	return
}	
	Msgbox,,RESULT, Succesfuly deleted all Middleware installation files.
Return

DbleClick:
IfNotEqual A_GuiControlEvent,DoubleClick
    return
  else
GuiControlGet, LineContents,,MyListBox
Rcmd = %LineContents%
StringSplit, Rcmdout, Rcmd, `t
;MsgBox, 1=%Rcmdout1%2=%Rcmdout2%3=%Rcmdout3%4=%Rcmdout4%5=%Rcmdout5%6=%Rcmdout6%7=%Rcmdout7%8=%Rcmdout8%9=%Rcmdout9%10=%Rcmdout10%
IfWinExist, Middleware
WinClose
IfEqual, Rcmdout3, prod-test
{
	;MsgBox, You've selected PROD-TEST and %Rcmdout5%
	Run, c:\tools\cygwin64\bin\rsync -avc --progress --chown=Administrators --chmod=ugo=rwx  rsync://admin@0.0.0.0/Prod/%Rcmdout5%/middleware.config  /cygdrive/c/ProgramData/AppInc/Middleware/middleware.config 
	GuiControlGet, Opt1
	If (Opt1 = 1)
		{
			UrlDownloadToFile, %Rcmdout8%, c:\tools\setup-p.exe
			FileRead, test, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
			if not ErrorLevel  ; Successfully loaded.
				{
				Gosub, UninstallMW
				BlockInput, on
				Run, c:\tools\setup-p.exe
				WinWait,Application Install - Security Warning 	; Wait till install appears
				Send {Left}
				Send {Enter}
				FileDelete, c:\tools\setup-p.exe
				BlockInput, off
				}
			else
				{
				BlockInput, on	
				Run, c:\tools\setup-p.exe
				WinWait,Application Install - Security Warning 	; Wait till install appears
				Send {Left}
				Send {Enter}
				FileDelete, c:\tools\setup-p.exe
				BlockInput, off
				}
		}
	else 
	;MsgBox, Won't install TerminalMiddleware
	Return
}
else
{
	;MsgBox, You've selected PROD-COPY and %Rcmdout5%	
	Run, c:\tools\cygwin64\bin\rsync -avc --progress --chown=Administrators --chmod=ugo=rwx rsync://admin@0.0.0.0/ProdCopy/%Rcmdout5%/middleware.config  /cygdrive/c/ProgramData/AppInc/Middleware/middleware.config
	GuiControlGet, Opt1
	If (Opt1 = 1)
	{
		UrlDownloadToFile, %Rcmdout8%, c:\tools\setup-pc.exe
		FileRead, test, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
		if not ErrorLevel  ; Successfully loaded.
				{
				Gosub, UninstallMW
				BlockInput, on
				Run, c:\tools\setup-pc.exe
				WinWait,Application Install - Security Warning 	; Wait till install appears
				Send {Left}
				Send {Enter}
				FileDelete, c:\tools\setup-pc.exe
				BlockInput, off
				}
			else
				{
				BlockInput, on
				Run, c:\tools\setup-pc.exe
				WinWait,Application Install - Security Warning 	; Wait till install appears
				Send {Left}
				Send {Enter}
				FileDelete, c:\tools\setup-pc.exe
				BlockInput, off
				}
	}
	else 
	;MsgBox, Won't install TerminalMiddleware
	Return
}
Return

BUTTONCopy:
GuiControlGet, LineContents,,MyListBox
Rcmd = %LineContents% 
StringSplit, Rcmdout, Rcmd, `t
IfWinExist, Middleware
WinClose
IfEqual, Rcmdout3, prod-test
{
	;MsgBox, You've selected PROD-TEST and %Rcmdout5%
	Run, c:\tools\cygwin64\bin\rsync -avc --progress --chown=Administrators --chmod=ugo=rwx rsync://admin@0.0.0.0/Prod/%Rcmdout5%/middleware.config  /cygdrive/c/ProgramData/AppInc/Middleware/middleware.config
	GuiControlGet, Opt1
	If (Opt1 = 1)
		{
			UrlDownloadToFile, %Rcmdout8%, c:\tools\setup-p.exe
			FileRead, test, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
			if not ErrorLevel  ; Successfully loaded.
				{
				Gosub, UninstallMW
				BlockInput, on
				Run, c:\tools\setup-p.exe
				WinWait,Application Install - Security Warning 	; Wait till install appears
				Send {Left}
				Send {Enter}
				FileDelete, c:\tools\setup-p.exe
				BlockInput, off
				}
			else
				{
				BlockInput, on
				Run, c:\tools\setup-p.exe
				WinWait,Application Install - Security Warning 	; Wait till install appears
				Send {Left}
				Send {Enter}
				FileDelete, c:\tools\setup-p.exe
				BlockInput, off
				}
		}
	else 
	;MsgBox, Won't install TerminalMiddleware
	Return
}
else
{
	;MsgBox, You've selected PROD-COPY and %Rcmdout5%	
	Run, c:\tools\cygwin64\bin\rsync -avc --progress --chown=Administrators --chmod=ugo=rwx rsync://admin@0.0.0.0/ProdCopy/%Rcmdout5%/middleware.config  /cygdrive/c/ProgramData/AppInc/Middleware/middleware.config
	GuiControlGet, Opt1
	If (Opt1 = 1)
	{
		UrlDownloadToFile, %Rcmdout8%, c:\tools\setup-pc.exe
		FileRead, test, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
		if not ErrorLevel  ; Successfully loaded.
				{
				Gosub, UninstallMW
				BlockInput, on
				Run, c:\tools\setup-pc.exe
				WinWait,Application Install - Security Warning 	; Wait till install appears
				Send {Left}
				Send {Enter}
				FileDelete, c:\tools\setup-pc.exe
				BlockInput, off
				}
			else
				{
				BlockInput, on
				Run, c:\tools\setup-pc.exe
				WinWait,Application Install - Security Warning 	; Wait till install appears
				Send {Left}
				Send {Enter}
				FileDelete, c:\tools\setup-pc.exe
				BlockInput, off
				}
	}
	else 
	;MsgBox, Won't install TerminalMiddleware
	Return
}
Return

UPGRADE:
{
Gui, Submit, NoHide
IfWinExist, Middleware
    WinClose
if EnvChoice = ProductionAT
	{
	MsgBox,,RESULT, Will set up Production AT from 0.0.0.0/middleware
	UrlDownloadToFile, http://0.0.0.0/middleware/setup.exe, c:\tools\setup-p.exe
	FileRead, test, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
	if not ErrorLevel  ; Successfully loaded.
		{
		Gosub, UninstallMW
		BlockInput, on
		Run, c:\tools\setup-p.exe
		WinWait,Application Install - Security Warning 	; Wait till install appears
		Send {Left}
		Send {Enter}
		FileDelete, c:\tools\setup-p.exe
		BlockInput, off
		}
	else
		{
		BlockInput, on
		Run, c:\tools\setup-p.exe
		WinWait,Application Install - Security Warning 	; Wait till install appears
		Send {Left}
		Send {Enter}
		FileDelete, c:\tools\setup-p.exe
		BlockInput, off
		}
	}	
else if EnvChoice = ProdCopy
	{
	MsgBox,,RESULT, Will set up ProdCopy from 0.0.0.0/middleware_prodcopy
	UrlDownloadToFile, http://0.0.0.0/middleware_prodcopy/setup.exe, c:\tools\setup-pc.exe
	FileRead, test, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
	if not ErrorLevel  ; Successfully loaded.
		{
		Gosub, UninstallMW
		BlockInput, on
		Run, c:\tools\setup-pc.exe
		WinWait,Application Install - Security Warning 	; Wait till install appears
		Send {Left}
		Send {Enter}
		FileDelete, c:\tools\setup-pc.exe
		BlockInput, off
		}
	else
		{
		BlockInput, on
		Run, c:\tools\setup-pc.exe
		WinWait,Application Install - Security Warning 	; Wait till install appears
		Send {Left}
		Send {Enter}
		FileDelete, c:\tools\setup-pc.exe
		BlockInput, off
		}
	}
else if EnvChoice = ProdCopy-B
	{
	MsgBox,,RESULT, Will set up ProdCopy from 0.0.0.0/middleware_prodcopy
	UrlDownloadToFile, http://0.0.0.0/middleware_prodcopy/setup.exe, c:\tools\setup-pc.exe
	FileRead, test, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
	if not ErrorLevel  ; Successfully loaded.
		{
		Gosub, UninstallMW
		BlockInput, on
		Run, c:\tools\setup-pc.exe
		WinWait,Application Install - Security Warning 	; Wait till install appears
		Send {Left}
		Send {Enter}
		FileDelete, c:\tools\setup-pc.exe
		BlockInput, off
		}
	else
		{
		BlockInput, on
		Run, c:\tools\setup-pc.exe
		WinWait,Application Install - Security Warning 	; Wait till install appears
		Send {Left}
		Send {Enter}
		FileDelete, c:\tools\setup-pc.exe
		BlockInput, off
		}
	}
else if EnvChoice = ProductionDE
	{
	MsgBox,,RESULT, Will set up ProductionDE from DE0.0.0.0/middleware
	UrlDownloadToFile, http://0.0.0.0/middleware/setup.exe, c:\tools\setup-de.exe
	FileRead, test, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
	if not ErrorLevel  ; Successfully loaded.
		{
		Gosub, UninstallMW
		BlockInput, on
		Run, c:\tools\setup-de.exe
		WinWait,Application Install - Security Warning 	; Wait till install appears
		Send {Left}
		Send {Enter}
		FileDelete, c:\tools\setup-de.exe
		BlockInput, off
		}
	else
		{
		BlockInput, on
		Run, c:\tools\setup-de.exe
		WinWait,Application Install - Security Warning 	; Wait till install appears
		Send {Left}
		Send {Enter}
		FileDelete, c:\tools\setup-de.exe
		BlockInput, off
		}
	}
else if EnvChoice = Productionh
	{
	MsgBox,,RESULT, Will set up Productionh from h0.0.0.0/middleware
	UrlDownloadToFile, http://0.0.0.0/middleware/setup.exe, c:\tools\setup-cro.exe
	FileRead, test, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
	if not ErrorLevel  ; Successfully loaded.
		{
		Gosub, UninstallMW
		BlockInput, on
		Run, c:\tools\setup-cro.exe
		WinWait,Application Install - Security Warning 	; Wait till install appears
		Send {Left}
		Send {Enter}
		FileDelete, c:\tools\setup-cro.exe
		BlockInput, off
		}
	else
		{
		BlockInput, on
		Run, c:\tools\setup-cro.exe
		WinWait,Application Install - Security Warning 	; Wait till install appears
		Send {Left}
		Send {Enter}
		FileDelete, c:\tools\setup-cro.exe
		BlockInput, off
		}
	}
else if EnvChoice = Productions
	{
	MsgBox,,RESULT, Will set up Productions from s0.0.0.0/middleware
	UrlDownloadToFile, http://0.0.0.0/middleware/setup.exe, c:\tools\setup-s.exe
	FileRead, test, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
	if not ErrorLevel  ; Successfully loaded.
		{
		Gosub, UninstallMW
		BlockInput, on
		Run, c:\tools\setup-s.exe
		WinWait,Application Install - Security Warning 	; Wait till install appears
		Send {Left}
		Send {Enter}
		FileDelete, c:\tools\setup-s.exe
		BlockInput, off
		}
	else
		{
		BlockInput, on
		Run, c:\tools\setup-s.exe
		WinWait,Application Install - Security Warning 	; Wait till install appears
		Send {Left}
		Send {Enter}
		FileDelete, c:\tools\setup-s.exe
		BlockInput, off
		}
	}
else if EnvChoice = ProductionBE
	{
	MsgBox,,RESULT, Will set up ProductionBE from begp0.0.0.0/middleware
	UrlDownloadToFile, http://0.0.0.0/middleware/setup.exe, c:\tools\setup-be.exe
	FileRead, test, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
	if not ErrorLevel  ; Successfully loaded.
		{
		Gosub, UninstallMW
		BlockInput, on
		Run, c:\tools\setup-be.exe
		WinWait,Application Install - Security Warning 	; Wait till install appears
		Send {Left}
		Send {Enter}
		FileDelete, c:\tools\setup-be.exe
		BlockInput, off
		}
	else
		{
		BlockInput, on
		Run, c:\tools\setup-be.exe
		WinWait,Application Install - Security Warning 	; Wait till install appears
		Send {Left}
		Send {Enter}
		FileDelete, c:\tools\setup-be.exe
		BlockInput, off
		}
	}	
else if EnvChoice = Productionde
	{
	MsgBox,,RESULT, Will set up Productionde from de0.0.0.0/middleware
	UrlDownloadToFile, http://0.0.0.0/middleware/setup.exe, c:\tools\setup-de.exe
	FileRead, test, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
	if not ErrorLevel  ; Successfully loaded.
		{
		Gosub, UninstallMW
		BlockInput, on
		Run, c:\tools\setup-de.exe
		WinWait,Application Install - Security Warning 	; Wait till install appears
		Send {Left}
		Send {Enter}
		FileDelete, c:\tools\setup-de.exe
		BlockInput, off
		}
	else
		{
		BlockInput, on
		Run, c:\tools\setup-de.exe
		WinWait,Application Install - Security Warning 	; Wait till install appears
		Send {Left}
		Send {Enter}
		FileDelete, c:\tools\setup-de.exe
		BlockInput, off
		}
	}	
else if EnvChoice = Productionat
	{
	MsgBox,,RESULT, Will set up Productionat from at0.0.0.0/middleware
	UrlDownloadToFile, http://0.0.0.0/middleware/setup.exe, c:\tools\setup-at.exe
	FileRead, test, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
	if not ErrorLevel  ; Successfully loaded.
		{
		Gosub, UninstallMW
		BlockInput, on
		Run, c:\tools\setup-at.exe
		WinWait,Application Install - Security Warning 	; Wait till install appears
		Send {Left}
		Send {Enter}
		FileDelete, c:\tools\setup-at.exe
		BlockInput, off
		}
	else
		{
		BlockInput, on
		Run, c:\tools\setup-at.exe
		WinWait,Application Install - Security Warning 	; Wait till install appears
		Send {Left}
		Send {Enter}
		FileDelete, c:\tools\setup-at.exe
		BlockInput, off
		}
	}
else if EnvChoice = TestV2.0
	{
	MsgBox,,RESULT, Will set up Test from 0.0.0.0/middleware_prodcopy
	UrlDownloadToFile, http://0.0.0.0/middleware_prodcopy/setup.exe, c:\tools\setup-test.exe
	FileRead, test, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
	if not ErrorLevel  ; Successfully loaded.
		{
		Gosub, UninstallMW
		BlockInput, on
		Run, c:\tools\setup-test.exe
		WinWait,Application Install - Security Warning 	; Wait till install appears
		Send {Left}
		Send {Enter}
		FileDelete, c:\tools\setup-test.exe
		BlockInput, off
		}
	else
		{
		BlockInput, on
		Run, c:\tools\setup-test.exe
		WinWait,Application Install - Security Warning 	; Wait till install appears
		Send {Left}
		Send {Enter}
		FileDelete, c:\tools\setup-test.exe
		BlockInput, off
		}
	}
else
	{
	msgbox,,RESULT, Please select enviroment to install.
	}
Return
}
Return

Change:
{
Gui, Submit, NoHide
IfWinExist, Middleware
    WinClose
if UIChoice = Prod-DE
	{
	FileRead, Middlconf, C:\ProgramData\AppInc\Middleware\middleware.config
		if not ErrorLevel  ; Successfully loaded.
		{
		NewStr := RegExReplace(Middlconf, "primarybrowserurl=""(https?://|http://)[a-zA-Z0-9\-\.\@\:]+\.[a-zA-Z]{2,3}(/\S*)?", "primarybrowserurl=""http://0.0.0.0""")
		SecStr := RegExReplace(NewStr, "secondarybrowserurl=""(https?://|http://)[a-zA-Z0-9\-\.\@\:]+\.[a-zA-Z]{2,3}(/\S*)?", "secondarybrowserurl=""http://0.0.0.0""")
		FileDelete, C:\ProgramData\AppInc\Middleware\middleware.config
		FileAppend, %SecStr%, C:\ProgramData\AppInc\Middleware\middleware.config
		Contents =  ; Free the memory.
		MsgBox,,RESULT, Set the primary browser url to:`n`n0.0.0.0`n`n`nAnd secondary to:`n`nhttp://0.0.0.0
		}	
	}
else if UIChoice = Prod-AT
	{
	FileRead, Middlconf, C:\ProgramData\AppInc\Middleware\middleware.config
		if not ErrorLevel  ; Successfully loaded.
		{
		NewStr := RegExReplace(Middlconf, "primarybrowserurl=""(https?://|http://)[a-zA-Z0-9\-\.\@\:]+\.[a-zA-Z]{2,3}(/\S*)?", "primarybrowserurl=""http://0.0.0.0""")
		SecStr := RegExReplace(NewStr, "secondarybrowserurl=""(https?://|http://)[a-zA-Z0-9\-\.\@\:]+\.[a-zA-Z]{2,3}(/\S*)?", "secondarybrowserurl=""http://0.0.0.0""")
		FileDelete, C:\ProgramData\AppInc\Middleware\middleware.config
		FileAppend, %SecStr%, C:\ProgramData\AppInc\Middleware\middleware.config
		Contents =  ; Free the memory.
		MsgBox,,RESULT, Set the primary browser url to:`n`nhttp://0.0.0.0`n`n`nAnd secondary to:`n`nhttp://0.0.0.0
		}	
	}
else if UIChoice = Prod-Copy-AT
	{
	FileRead, Middlconf, C:\ProgramData\AppInc\Middleware\middleware.config
		if not ErrorLevel  ; Successfully loaded.
		{
		NewStr := RegExReplace(Middlconf, "primarybrowserurl=""(https?://|http://)[a-zA-Z0-9\-\.\@\:]+\.[a-zA-Z]{2,3}(/\S*)?", "primarybrowserurl=""http://0.0.0.0""")
		SecStr := RegExReplace(NewStr, "secondarybrowserurl=""(https?://|http://)[a-zA-Z0-9\-\.\@\:]+\.[a-zA-Z]{2,3}(/\S*)?", "secondarybrowserurl=""http://0.0.0.0""")
		FileDelete, C:\ProgramData\AppInc\Middleware\middleware.config
		FileAppend, %SecStr%, C:\ProgramData\AppInc\Middleware\middleware.config
		Contents =  ; Free the memory.
		MsgBox,,RESULT, Set the primary browser url to:`n`nhttp://0.0.0.0`n`n`nAnd secondary to:`n`nhttp://0.0.0.0
		}	
	}
else if UIChoice = Prod-Copy-DE
	{
	FileRead, Middlconf, C:\ProgramData\AppInc\Middleware\middleware.config
		if not ErrorLevel  ; Successfully loaded.
		{
		NewStr := RegExReplace(Middlconf, "primarybrowserurl=""(https?://|http://)[a-zA-Z0-9\-\.\@\:]+\.[a-zA-Z]{2,3}(/\S*)?", "primarybrowserurl=""http://0.0.0.0""")
		SecStr := RegExReplace(NewStr, "secondarybrowserurl=""(https?://|http://)[a-zA-Z0-9\-\.\@\:]+\.[a-zA-Z]{2,3}(/\S*)?", "secondarybrowserurl=""http://0.0.0.0""")
		FileDelete, C:\ProgramData\AppInc\Middleware\middleware.config
		FileAppend, %SecStr%, C:\ProgramData\AppInc\Middleware\middleware.config
		Contents =  ; Free the memory.
		MsgBox,,RESULT, Set the primary browser url to:`n`nhttp://0.0.0.0`n`n`nAnd secondary to:`n`nhttp://0.0.0.0
		}	
	}
else
{
	msgbox,,RESULT, Please choose MW to set up.
}
Return
}
Return

BUTTONClose:
gui Cancel
ExitApp
Return

GuiClose:
ExitApp
Return