#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force
#persistent

{
      Gui, Color, Black
      Gui, -caption +toolwindow +AlwaysOnTop
      Gui, font, s 10 normal, Verdana
      Gui, Add, Button, h50 vSCREEN gSCREEN, Take Screenshot`n  of the Ticket!
      Gui, Show, % "x" A_ScreenWidth-1685 " y" A_ScreenHeight-1030 ,TRANS-WIN
      WinSet, AlwaysOnTop, on
      Contents =  ; Free the memory.
      }
  return


Screen:
;  crop= x  y  width height
F1=%A_Desktop%\ScreenShots\%A_now%_screenshot.jpg
PR=C:\Program Files\IrfanView\i_view64.exe
AA=/capture=0 /crop=(1275,1050,400,1000) /convert=%F1%
runwait,%PR% %AA%
run,%F1%
return
ExitApp