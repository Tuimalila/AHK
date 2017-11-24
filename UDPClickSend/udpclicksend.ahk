#NoEnv
#HotkeyInterval 2000  
#MaxHotkeysPerInterval 200
#SingleInstance Force
#Persistent
CoordMode, Mouse, Screen

; This script sends mouse click coordinates through UDP protocol as JSON string

#include Socket.ahk
myUdpOut := new SocketUDP() 

FileRead, Middlconf, C:\ProgramData\AppInc\Middleware\middleware.config
UsrStr := RegExMatch(Middlconf, "defaultusername=""[a-zA-Z0-9]{2,15}(/\S*)?", Username)
StringSplit, Defuser, Username, `"

~LButton::
    MouseGetPos, x,y
    MouseGetPos, xpos, ypos, id, control
    send_msg={"computer_name":`"%A_ComputerName%`","mw_un":`"%Defuser2%`","x":`"%x%`","y":`"%y%`"}
  if (send_msg="")
    return
  myUdpOut.connect("0.0.0.0", 4791)
  myUdpOut.disableBroadcast() 
  myUdpOut.sendText(send_msg) 
  myUdpOut.disconnect()
return