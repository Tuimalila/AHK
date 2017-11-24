#NoEnv                  ;Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn                 ;Enable warnings to assist with detecting common errors.
SendMode Input          ;Recommended for new scripts due to its superior speed and reliability.
;SetWorkingDir %A_Temp% ;Ensures a consistent starting directory.
#SingleInstance force   ;Skips the dialog box and replaces the old instance automatically
SetKeyDelay, 90         ;Any number you want (milliseconds)
CoordMode,Mouse,Screen  ;Initial state is Relative
CoordMode,Pixel,Screen  ;Initial state is Relative. Frustration awaits if you set Mouse to Screen and then use GetPixelColor because you forgot this line. There are separate ones for: Mouse, Pixel, ToolTip, Menu, Caret
settimer, emptymem, 600000 ;calls emptymem subroutine every 10 minutes.
settimer, vncest, 3000  ;check active VNC sessions every three seconds. 
FileInstall, C:\Users\user\Desktop\ahk\InfoPanel\vnc250.bmp, %A_ScriptDir%\vnc250.bmp, 1 ;VNC established connection message for second screen
FileInstall, C:\Users\user\Desktop\ahk\InfoPanel\Mortal.mp3, %A_ScriptDir%\Mortal.mp3, 1 ;Easter Egg
#Include JSON_ToObj.ahk ;Needed for parsing JSON server responses
SetBatchLines, -1       ;Testing this mode 
#InstallKeybdHook       ;Testing this mode 
vncactive = 0
; End of directives

; Display an InfoPanel on second screen with info and quick actions

FileRead, Middlconf, C:\ProgramData\AppInc\Middleware\middleware.config
  if not ErrorLevel  ; Successfully loaded.
      {
    ;Read Middleware.config
      NewStr := RegExMatch(Middlconf, "primarybrowserurl=""(https?://|http://)[a-zA-Z0-9\-\.\@\:]+\.[a-zA-Z]{2,3}(/\S*)?", SubPat1)
      SecStr := RegExMatch(Middlconf, "secondarybrowserurl=""(https?://|http://)[a-zA-Z0-9\-\.\@\:]+\.[a-zA-Z]{2,3}(/\S*)?", SubPat2)
      ThrdStr := RegExMatch(Middlconf, "handler=""(https?://|http://)[a-zA-Z0-9\-\.\@\:\{\}]+\.[a-zA-Z]{2,3}(/\S*)?", SubPat3)
      FrthStr := RegExMatch(Middlconf, "defaultusername=""[a-zA-Z0-9]{2,15}(/\S*)?", SubPat4)
    ;Read installed Middleware version from registry
      RegRead, MWVerzija, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\f4ea1c07c1edd2d4, DisplayVersion
      RegRead, MWURL, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\f4ea1c07c1edd2d4, UrlUpdateInfo
    ;Tail Middleware logs
      FormatTime, TimeString,, yyyy_M_d
      Log1String = C:\ProgramData\AppInc\Middleware\logs\log_%TimeString%.txt
      Log2String = C:\ProgramData\AppInc\Middleware\printer_log\log_%TimeString%.txt
      Log3String = C:\ProgramData\AppInc\Middleware\transactions_log\log_%TimeString%.txt
      Log4String = C:\ProgramData\AppInc\Middleware\devices_log\log_%TimeString%.txt
      FileRead, log1, %Log1String%
      FileRead, log2, %Log2String%
      FileRead, log3, %Log3String%
      FileRead, log4, %Log4String%
      StrTail(k,str)
      	{
            Loop,Parse,str,`n
            {
            i := Mod(A_Index,k)
            L%i% = %A_LoopField%
            }
        L := L%i%
        Loop,% k-1
            {
            If i < 1
			SetEnv,i,%k%
            i-- ;Mod does not work here 
            L := L%i% "`n" L
            }
        Return L
        }
    ; Look for failed deposits in last 24 hours
      dateCut := A_Now
      EnvAdd, dateCut, -1, days       ; sets a date -24 hours from now
      loop, C:\ProgramData\AppInc\Middleware\failures\*.*, 1, 1   ; change the folder name 
        {   
        if (A_LoopFileTimeModified >= dateCut)
        str .= A_LoopFileFullPath "`n"
        } 
    ;Create InfoPanel Display
    scrw := A_ScreenWidth-35
      Gui 1:Default
      Gui, Color, Black
      Gui, -caption +toolwindow +AlwaysOnTop
      Gui, font, s 15 bold, Courier
      Gui, add, text, cYellow TransColor, % "IP1: " A_IPAddress2 "  IP2: " A_IPAddress1
      Gui, font, s 10 bold, Verdana
      Gui, Add, Button, x+35 h50 vREFRESH gREFRESH, Refresh info logs
	  Gui, font, s 10 normal, Verdana
      Gui, Add, Button, x+10 h50 vDISLAN gDISLAN, Disable/Enable`nLAN interface
      Gui, Add, Button, x+10 h50 vADMINWEB gADMINWEB, MW Admin
	  Gui, Add, Button, x+10 h50 vNETIFACE gNETIFACE, Send IP to Fleep
      Gui, Add, Button, x+10 h50 vKILL gKILL, Kill Middleware!
      Gui, Add, Button, x+10 h50 vSTART gSTART,Start / Restart`Middleware
      Gui, Add, Button, x+10 h50 vAUTOTEST gAUTOTEST, Start AutoTest!
      Gui, Add, Button, x+10 h50 vGUI gGUI center,Change Middleware`nEnvironment and Users
      Gui, Add, Button, x+10 h50 vCLOSEWB gCLOSEWB, Exit!
      Gui, font, s 10 bold, Verdana
      Gui, add, text, xs+0 ys+20 TransColor cGreen,Program version date: 2016.11.09.002
      Gui, font, s 18 normal, Verdana
      Gui, add, text, cRed TransColor, %SubPat4%`nMiddleware Version: %MWVerzija%`nMiddleware Install URL: %MWURL%
      Gui, font, s 13 normal, Courier
      Gui, add, text, cWhite TransColor, %SubPat1%`n%SubPat2%`n%SubPat3%
    Gui, Add, GroupBox, xm  ym+220  Section w%scrw% h110
      Gui, font, s 13 underline cWhite, Verdana 
      Gui, add, text, xs+10  ys+20 TransColor gMainLog, Main Log
      Gui, font, s 13 normal cGray, Courier 
      Gui, add, text, xs+10  ys+40 TransColor, % StrTail(4,log1)
    Gui, Add, GroupBox, xm  ym+320  Section w%scrw% h110
      Gui, font, s 13 normal underline cWhite, Verdana 
      Gui, add, text, xs+10  ys+15 TransColor gPRINTERLog, Printer Log
      Gui, font, s 13 normal cGray, Courier  
      Gui, add, text, xs+10  ys+40 TransColor, % StrTail(4,log2)
    Gui, Add, GroupBox, xm  ym+420  Section w%scrw% h110
      Gui, font, s 13 normal underline cWhite, Verdana 
      Gui, add, text, xs+10  ys+15 TransColor gDevLog, Devices Log
      Gui, font, s 13 normal cGray, Courier  
      Gui, add, text, xs+10  ys+40 TransColor cGray, % StrTail(4,log4)
    Gui, Add, GroupBox, xm  ym+520  Section w%scrw% h110
      Gui, font, s 13 normal underline cWhite, Verdana 
      Gui, add, text, xs+10  ys+15 TransColor gTransLog, Transactions Log
      Gui, font, s 13 normal cGray, Courier  
      Gui, add, text, xs+10  ys+40 TransColor cGray, % StrTail(4,log3)
    Gui, Add, GroupBox, xm  ym+620  Section w%scrw% h110
      Gui, font, s 13 normal underline cWhite, Verdana 
      Gui, add, text, xs+10  ys+15 TransColor gFailLog, Failed deposits in last 24 hours
      Gui, font, s 13 normal cGray, Courier  
      Gui, add, text, xs+10  ys+40 TransColor cGray, %str%
      ;set it to the right screen position
FileRead, type, C:\tools\status\terminal_type.txt
  if type = Touch4Bet
    Gui, Show, % "x" 0 " y" A_ScreenHeight-1980 ,TRANS-WIN
  else if type = happybox
	Gui, Show, % "x" 0 " y" A_ScreenHeight-1830 ,TRANS-WIN
  else if type = HD22
	Gui, Show, % "x" 0 " y" A_ScreenHeight-1830 ,TRANS-WIN
  else if type = BetStation
    Gui, Show, % "x" 0 " y" A_ScreenHeight-1980 ,TRANS-WIN
  else
    Gui, Show, % "x" A_ScreenWidth-1678 " y" A_ScreenHeight-1802 ,TRANS-WIN
      WinSet, AlwaysOnTop, on
      ;WinSet, TransColor, White, TRANS-WIN
      Contents =  ; Free the memory.
      }	
   Else
      {
    ;Error if there is no Middleware.config
      RegRead, MWVerzija, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\f4ea1c07c1edd2d4, DisplayVersion
      RegRead, MWURL, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\f4ea1c07c1edd2d4, UrlUpdateInfo
      Gui, Color, Black
      Gui, -caption +toolwindow +AlwaysOnTop
      Gui, font, s30, TimesNewRoman
      Gui, add, text, cWhite TransColor, % "IP1: " A_IPAddress2 "  IP2: " A_IPAddress1 
      Gui, add, text, cRed TransColor, No Midlleware.config found!`n`nMW Version: %MWVerzija%`nMW Install URL: %MWURL%
      Gui, Show, % "x" A_ScreenWidth-1700 " y" A_ScreenHeight-1350 ,TRANS-WIN
      WinSet, AlwaysOnTop, on
      ;WinSet, TransColor, White, TRANS-WIN
      Contents =  ; Free the memory.
      }

;This part of the script generates a VNC address file at location C:\Users\Admin\ownCloud\LabVNC\
objWMIService := ComObjGet("winmgmts:{impersonationLevel = impersonate}!\\.\root\cimv2")
colItems := objWMIService.ExecQuery("Select * from Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")._NewEnum
while colItems[objItem]
{
    if objItem.IPAddress[0] = A_IPAddress3
    {
		mac1 := objItem.MACAddress
		ip1 := objItem.IPAddress[0]
		ip61 := objItem.IPAddress[1]
		des1 := objItem.Description[0]
	}
	if objItem.IPAddress[0] = A_IPAddress2
    {
		mac2 := objItem.MACAddress
		ip2 := objItem.IPAddress[0]
		ip62 := objItem.IPAddress[1]
		des2 := objItem.Description[0]
	}
	if objItem.IPAddress[0] = A_IPAddress1
    {
		mac3 := objItem.MACAddress
		ip3 := objItem.IPAddress[0]
		ip63 := objItem.IPAddress[1]
		des3 := objItem.Description[0]
    }
}
; Create a VNC connection file
StringReplace, alo, mac1, :, -, All
FileRead, Tertypestring, C:\tools\status\type.txt
FileRead, Partnerstring, C:\tools\status\partner.txt
FileRead, Computerstring, C:\tools\status\computername.txt
FileDelete, C:\Users\Admin\ownCloud\LabVNC\%Tertypestring%-(%Partnerstring%)-(%Computerstring%).vnc
FileAppend,`[Connection`]`nHost=%ip3%`nUserName=`nPassword=some_hash`nEncryption=Server`nSecurityNotificationTimeout=2500`nSelectDesktop=`nProxyServer=`nProxyType=`nProxyUserName=`nProxyPassword=`nSingleSignOn=1`n`[Options`]`nUseLocalCursor=1`nFullScreen=0`nRelativePtr=0`nFullColor=0`nColorLevel=pal8`nPreferredEncoding=ZRLE`nAutoSelect=1`nShared=1`nSendPointerEvents=1`nSendKeyEvents=1`nClientCutText=1`nServerCutText=1`nShareFiles=1`nEnableChat=1`nEnableRemotePrinting=0`nChangeServerDefaultPrinter=0`nPointerEventInterval=0`nPointerCornerSnapThreshold=30`nScaling=None`nMenuKey=F8`nEnableToolbar=1`nAutoReconnect=1`nProtocolVersion=`nAcceptBell=1`nScalePrintOutput=1`nPasswordFile=`nVerifyId=2`nIdHash=`nWarnUnencrypted=1`nDotWhenNoCursor=1`nFullScreenChangeResolution=0`nUseAllMonitors=0`nEmulate3=0`nSendSpecialKeys=1`nSuppressIME=1`nMonitor=`n`[Signature`]`nDotVncFileSignature=long_string,C:\Users\lAdmin\ownCloud\LabVNC\%Tertypestring%-(%Partnerstring%)-(%Computerstring%).vnc

; This section exits InfoPanel if it detects prodblock.txt file in status dir indicating a production account installed on the machine
FileRead, prodblock, C:\tools\status\problock.txt
   if not ErrorLevel  ; Successfully loaded.
    {
      ; Moves the message box to the first monitor
      nPosX:=700, nPosY:=450
      setTimer, watchMsgBox, 10 ; jumps to label watchMsgBox and..
      MsgBox, 4100, , ProdGUIPanel was not exited by close button as there is a prodblocking file @ location C:\tools\status\problock.txt`n`nInfopanel will exit now. Do you want to run ProdGUIPanel?, 20  ; 20-second timeout.
        IfMsgBox, No
          goto GuiEscape
        IfMsgBox, Timeout
          goto GuiEscape
        IfMsgBox, Yes
          FileRead, prodgui, C:\Users\%A_UserName%\Desktop\ProdGUIPanel.exe
            if not ErrorLevel  ; Successfully loaded.
          Run, C:\Users\%A_UserName%\Desktop\ProdGUIPanel.exe        
    }
    else
Return
Return

MainLog:
Run, C:\Windows\notepad.exe C:\ProgramData\AppInc\Middleware\logs\log_%TimeString%.txt
Return

PRINTERLog:
Run, C:\Windows\notepad.exe C:\ProgramData\AppInc\Middleware\printer_log\log_%TimeString%.txt
Return

TransLog:
Run, C:\Windows\notepad.exe C:\ProgramData\AppInc\Middleware\transactions_log\log_%TimeString%.txt
Return

DevLog:
Run, C:\Windows\notepad.exe C:\ProgramData\AppInc\Middleware\devices_log\log_%TimeString%.txt
Return

FailLog:
Run, C:\Windows\explorer.exe C:\ProgramData\AppInc\Middleware\failures\
Return

check_window:
  IfWinActive, TRANS-WIN
     WinActivate, TRANS-WIN
      WinSet, AlwaysOnTop, On, TRANS-WIN
Return

DisLan:
adapter:="Local Area Connection 2" ; set to the adapter name
if(t:=!t)
    runwait,netsh interface set interface "%adapter%" disable,,hide
else
    runwait,netsh interface set interface "%adapter%" enable,,hide
return

Adminweb:
FileRead, Middlconf, C:\ProgramData\AppInc\Middleware\middleware.config
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

/*
nPosX:=700, nPosY:=450
setTimer, watchMsgBox, 10 ; jumps to label watchMsgBox and..
MsgBox, Full Response = %response%
*/

strJson := response
objJson := json_toobj(strJson)
mwadminbcode := objJson["mwadmin_bar_code"]
uname := objJson["mw_un"]
pword := objJson["mw_pw"]

;MsgBox, Code is %mwadminbcode%, username is %uname%, and password is %pword% 
;MsgBox, % objJson["mwadmin_bar_code"]
;nPosX:=700, nPosY:=450
;setTimer, watchMsgBox, 10 ; jumps to label watchMsgBox and..

if response = {"mwadmin_bar_code":"","success":"true","error":""}
	{
	;MsgBox, There is no MW_Bar_Code!
	Goto OfflineAdmin
	;ExitApp
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
WinActivate Middleware
Else
{
Run, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
WinActivate, Middleware
}
if mwadminbcode =
{
x1 = change_password
x = change_password
}
else
{
x = (%mwadminbcode%(
x1 = *%mwadminbcode%*
}
FileRead, type, C:\tools\status\terminal_type.txt
  if type = T
  send %x1%
  else
  send %x%
Send {Enter}
Sleep, 100
Send %uname%
Sleep 100
Send {Tab}
Sleep 100
SendInput % pword
}
Return

OfflineAdmin:
{
IfWinExist, Middleware
WinActivate Middleware
Else
Run, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
WinWait, Middleware, , 3
WinActivate, Middleware
x1 = change_password
x = change_password
FileRead, type, C:\tools\status\terminal_type.txt
  if type = T
  send %x1%
  else
  send %x%
Send {Enter}
Sleep, 100
user = admin
Send %user%
Send {Tab}
Sleep 100
pass = 12345
SendInput % pass
}
Return

NoNet:
; Moves the message box to the first monitor
  nPosX:=700, nPosY:=450
  setTimer, watchMsgBox, 10 ; jumps to label watchMsgBox and..
MsgBox, There was a problem with network connection
return

Refresh:
{
      Gui, Destroy  
      Reload 
}
Return

Kill:
{
  SoundPlay,  %A_ScriptDir%\Mortal.mp3
  ; Moves the message box to the first monitor
  nPosX:=700, nPosY:=450
  setTimer, watchMsgBox, 10 ; jumps to label watchMsgBox and..
  MsgBox, 4100, , Would you like to kill MW?, 10  ; 10-second timeout.
  IfMsgBox, No
    Return  ; User pressed the "No" button.
  IfMsgBox, Timeout
    Return ; Timed out.
  IfWinExist, Middleware
  WinClose
}
Return

Start:
{
  ; Moves the message box to the first monitor
  nPosX:=700, nPosY:=450
  setTimer, watchMsgBox, 10 ; jumps to label watchMsgBox and..
  MsgBox, 4100, , Would you like to Re/Start MW?, 10  ; 10-second timeout.
    IfMsgBox, No
    Return  ; User pressed the "No" button.
    IfMsgBox, Timeout
    Return ; Timed out.
    IfWinExist, Middleware
    WinClose
    FileRead, test, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
		if not ErrorLevel  ; Successfully loaded.
		{
		Run, C:\Users\%A_UserName%\Desktop\Middleware.appref-ms
        Sleep 15000
		}
	Else
		{
    ; Moves the message box to the first monitor
    nPosX:=700, nPosY:=450
    setTimer, watchMsgBox, 10 ; jumps to label watchMsgBox and..
	Msgbox,,RESULT, Terminal Middleware is not installed.
		}
}
Return

GUI:
{
IfWinExist, Change Middleware Environment and Users
WinActivate
Else
   FileRead, guji, C:\Users\%A_UserName%\Desktop\gui3.exe
   if not ErrorLevel  ; Successfully loaded.
        Run, "C:\Users\Admin\Desktop\gui3.exe"
    else
        Run, "C:\Users\Admin\Desktop\gui3.6.exe"
}
Return

Autotest:
FileRead, autotd, C:\Users\Admin\Desktop\AutoTest\autotest.exe
if not ErrorLevel  ; Successfully loaded.
   Run, "C:\Users\Admin\Desktop\AutoTest\autotest.exe"
   else
    FileRead, autot, C:\Users\Admin\ownCloud\Ahk various\autotest.exe
    if not ErrorLevel  ; Successfully loaded.
      {
      FileCreateDir,C:\Users\Admin\Desktop\AutoTest\
      FileCopy, C:\Users\Admin\ownCloud\Ahk various\autotest.exe, C:\Users\Admin\Desktop\AutoTest\autotest.exe
      FileCopy, C:\Users\Admin\ownCloud\Ahk various\LowerClicks.FV830.txt,  C:\Users\Admin\Desktop\AutoTest\LowerClicks.FV.txt
      FileCopy, C:\Users\Admin\ownCloud\Ahk various\allxly.csv, C:\Users\Admin\Desktop\AutoTest\allxly.csv
      Sleep, 1500
      Run, "C:\Users\Admin\Desktop\AutoTest\autotest.exe"
      }
    else
      MsgBox, Install Owncloud to synchronize autotest.exe to this computer!
Return

Netiface:
; This script collects details of network interfaces and sends IP to Fleep (DELETED-and sends it as JSON to the server.)
; First it enumerates network interfaces
objWMIService := ComObjGet("winmgmts:{impersonationLevel = impersonate}!\\.\root\cimv2")
colItems := objWMIService.ExecQuery("Select * from Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")._NewEnum
while colItems[objItem]
{
    if objItem.IPAddress[0] = A_IPAddress3
    {
		mac1 := objItem.MACAddress
		ip1 := objItem.IPAddress[0]
		ip61 := objItem.IPAddress[1]
		des1 := objItem.Description[0]
	}
	if objItem.IPAddress[0] = A_IPAddress2
    {
		mac2 := objItem.MACAddress
		ip2 := objItem.IPAddress[0]
		ip62 := objItem.IPAddress[1]
		des2 := objItem.Description[0]
	}
	if objItem.IPAddress[0] = A_IPAddress1
    {
		mac3 := objItem.MACAddress
		ip3 := objItem.IPAddress[0]
		ip63 := objItem.IPAddress[1]
		des3 := objItem.Description[0]
    }
}
;Send data to fleep
Log1String = C:\tools\status\type.txt
Log2String = C:\tools\status\partner.txt
FileRead, log1, %Log1String%
FileRead, log2, %Log2String%
PartString = C:\tools\status\partner.txt
FileRead, InputVar, %PartString%
StringMid, OutputVar, InputVar, 1, 2
StringMid, OutputVar2, InputVar, 3, 2
Fleep = Hostname: %A_ComputerName%`nTerminal_Type: %log1% | Partner: %OutputVar2% | Country: %OutputVar%`nIP: %ip1%`nIP: %ip2%`nIP: %ip3%`nSent from InfoPanel
Run, C:\tools\cygwin64\bin\curl.exe -X POST "https://fleep.io/hook/hook_id" -d 'message=%Fleep%' ; Terminal testing
Return

vncest:
FileDelete, vnc.txt
RunWait, %comspec% /c netstat -an | find "ESTABLISHED" | find ":5900" >> "vnc.txt", , hide
FileRead, vnc, vnc.txt
IfInString, vnc, ESTABLISHED
{
if vncactive = 0
{
FileRead, type, C:\tools\status\type.txt
if type = T
{
	SplashImage, On
	SplashImage, vnc250.bmp, b1 Y-1100 cwBlack
}
else
{
	SplashImage, On
	SplashImage, vnc250.bmp, b1 Y-1020 cwBlack
}
vncactive = 1
}
else if vncactive = 1
Return
}
else
  {
	SplashImage, Off
	vncactive = 0
  }
Return

; Moves the message box to the first monitor
watchMsgBox:
  winMove, ahk_class #32770,, nPosX, nPosY ; ..moves the msgbox to coordinates.
  winGetPos, mbX, mbY,,, ahk_class #32770 ; checks to see msgbox position.
  if ( mbX=nPosX && mbY=nPosY ) ; if msgbox position = coordinates..
    setTimer, watchMsgBox, off ; ..stop jumping to label.
Return

emptymem: ;reduces ram used by the script.
 {
   dllcall("psapi.dll\EmptyWorkingSet", "UInt", -1)
 }
Return

CloseWB:
Gui,destroy
Gui,2:destroy
Gui,3:destroy
Gui,4:destroy
Exitapp	
Return

GuiEscape:
ExitApp
Return