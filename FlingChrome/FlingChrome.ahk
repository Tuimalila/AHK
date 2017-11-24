#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#HotkeyInterval 2000  ; This is  the default value (milliseconds).
#MaxHotkeysPerInterval 200
#Persistent
#SingleInstance Force
CoordMode, Mouse, Screen
setbatchlines, 10ms ;pauses the script for 10ms every 10ms. minimizes resource use.

/*
This script opens two Chrome windows and 'flings' them to the other monitors
*/

Run, C:\Program Files (x86)\Google\Chrome\Application\chrome.exe --kiosk-printing --new-window https://weburl.com/
Sleep, 1000
Run, C:\Program Files (x86)\Google\Chrome\Application\chrome.exe --kiosk-printing --new-window http://kioskurl.com/
Sleep, 1000
WinGet, id, list,,, Program Manager
Loop, %id%
{
    thisa_id := id%A_Index%	
    WinActivate, ahk_id %thisa_id%
    WinGetClass, thisa_class, ahk_id %thisa_id%
    WinGetTitle, thisa_title, ahk_id %thisa_id%
    if thisa_title = LOGIN - Google Chrome
		Goto MoveCash
}
Return

MoveCash:
id = %thisa_id%
Win__Fling(id,1)
WinMaximize, ahk_id %id%
; Added full screen
Send {F11}
Goto MoveCash2

MoveCash2:
WinGet, id, list,,, Program Manager
Loop, %id%
{
    thisa_id := id%A_Index%	
    WinActivate, ahk_id %thisa_id%
    WinGetClass, thisa_class, ahk_id %thisa_id%
    WinGetTitle, thisa_title, ahk_id %thisa_id%
	if thisa_title = Admin Console - Google Chrome
		Goto MaxmizeCash
}
Return

MaxmizeCash:
id = %thisa_id%
WinMaximize, ahk_id %id%
Sleep, 100000
ExitApp

Win__Fling(WinID, KeepRelativeSize = true, FlingDirection = 1)
{
   ; Figure out which window to move based on the "WinID" function parameter:
   ;   1) The letter "A" means to use the Active window
   ;   2) The letter "M" means to use the window under the Mouse
   ; Otherwise, the parameter value is assumed to be the AHK window ID of the window to use.

   if (WinID = "A")
   {
      ; If the user supplied an "A" as the window ID, we use the Active window
      WinID := WinExist("A")
   }
   else if (WinID = "M")
   {
      ; If the user supplied an "M" as the window ID, we use the window currently under the Mouse
      MouseGetPos, MouseX, MouseY, WinID      ; MouseX & MouseY are retrieved but, for now, not used
   }

   ; Check to make sure we are working with a valid window
   IfWinNotExist, ahk_id %WinID%
   {
      ; Make a short noise so the user knows to stop expecting something fun to happen.
      SoundPlay, *64
      
      ; Debug Support
      ;MsgBox, 16, Window Fling: Error, Specified window does not exist.`nWindow ID = %WinID%

      return 0
   }

   ; Here's where we find out just how many monitors we're dealing with
   SysGet, MonitorCount, MonitorCount

   if (MonitorCount <= 1)
   {
      ; Honestly, there's not much to do in a one-monitor system
      return 1
   }

   ; For each active monitor, we get Top, Bottom, Left, Right of the monitor's
   ;  'Work Area' (i.e., excluding taskbar, etc.). From these values we compute Width and Height.
   ;  Results get put into variables named like "Monitor1Top" and "Monitor2Width", etc.,
   ;  with the monitor number embedded in the middle of the variable name.

   Loop, %MonitorCount%
   {
      SysGet, Monitor%A_Index%, MonitorWorkArea, %A_Index%
      Monitor%A_Index%Width  := Monitor%A_Index%Right  - Monitor%A_Index%Left
      Monitor%A_Index%Height := Monitor%A_Index%Bottom - Monitor%A_Index%Top
   }

   ; Retrieve the target window's original minimized / maximized state
   WinGet, WinOriginalMinMaxState, MinMax, ahk_id %WinID%

   ; We don't do anything with minimized windows (for now... this may change)
   if (WinOriginalMinMaxState = -1)
   {
      ; Debatable as to whether or not this should be flagged as an error
      return 0
   }
   
   ; If the window started out maximized, then the plan is to:
   ;   (a) restore it,
   ;   (b) fling it, then
   ;   (c) re-maximize it on the target monitor.
   ;
   ; The reason for this is so that the usual maximize / restore windows controls
   ; work as you'd expect. You want Windows to use the dimensions of the non-maximized
   ; window when you click the little restore icon on a previously flung (maximized) window.
   
   if (WinOriginalMinMaxState = 1)
   {
      ; Restore a maximized window to its previous state / size ... before "flinging".
      ;
      ; Programming Note: It would be nice to hide the window before doing this ...
      ; the window does some visual calisthenics that the user may construe as a bug.
      ; Unfortunately, if you hide a window then you can no longer work with it. <Sigh>

      WinRestore, ahk_id %WinID%
   }

   ; Retrieve the target window's original (non-maximized) dimensions
   WinGetPos, WinX, WinY, WinW, WinH, ahk_id %WinID%

   ; Find the point at the centre of the target window then use it
   ; to determine the monitor to which the target window belongs
   ; (windows don't have to be entirely contained inside any one monitor's area).
   
   WinCentreX := WinX + WinW / 2
   WinCentreY := WinY + WinH / 2

   CurrMonitor = 0
   Loop, %MonitorCount%
   {
      if (    (WinCentreX >= Monitor%A_Index%Left) and (WinCentreX < Monitor%A_Index%Right )
          and (WinCentreY >= Monitor%A_Index%Top ) and (WinCentreY < Monitor%A_Index%Bottom))
      {
         CurrMonitor = %A_Index%
         break
      }
   }

   ; Compute the number of the next monitor in the direction of the specified fling (+1 or -1)
   ;  Valid monitor numbers are 1..MonitorCount, and we effect a circular fling.
   NextMonitor := CurrMonitor + FlingDirection
   if (NextMonitor > MonitorCount)
   {
      NextMonitor = 1
   }
   else if (NextMonitor <= 0)
   {
      NextMonitor = %MonitorCount%
   }

   ; Scale the position / dimensions of the target window by the ratio of the monitor sizes.
   ; Programming Note: Do multiplies before divides in order to maintain accuracy in the integer calculation.
   WinFlingX := (WinX - Monitor%CurrMonitor%Left) * Monitor%NextMonitor%Width  // Monitor%CurrMonitor%Width  + Monitor%NextMonitor%Left
   WinFlingY := (WinY - Monitor%CurrMonitor%Top ) * Monitor%NextMonitor%Height // Monitor%CurrMonitor%Height + Monitor%NextMonitor%Top
   
   if KeepRelativeSize
   {
	   WinFlingW :=  WinW * Monitor%NextMonitor%Width  // Monitor%CurrMonitor%Width
      WinFlingH :=  WinH * Monitor%NextMonitor%Height // Monitor%CurrMonitor%Height
   }
   else
   {
      WinFlingW := WinW
	   WinFlingH := WinH
   }

   ; It's time for the target window to make its big move
   WinMove, ahk_id %WinID%,, WinFlingX, WinFlingY, WinFlingW, WinFlingH

   ; If the window used to be maximized, maximize it again on its new monitor
   if (WinOriginalMinMaxState = 1)
   {
      WinMaximize, ahk_id %WinID%
   }

   return 1
}