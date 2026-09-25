#Requires AutoHotkey v2.0+
#SingleInstance Force

#Include workspace.ahk

#WheelUp:: Send "{Ctrl down}{LWin down}{Left}{LWin up}{Ctrl up}"
#WheelDown:: Send "{Ctrl down}{LWin down}{Right}{LWin up}{Ctrl up}"

RButton::RButton
MButton::MButton

RButton & f:: moveRight()
RButton & s:: moveLeft()
RButton & d:: moveDown()
RButton & e:: moveUp()

MButton & 1:: addActiveWindow(1)
MButton & 2:: addActiveWindow(2)
MButton & 3:: addActiveWindow(3)
MButton & 4:: addActiveWindow(4)

#HotIf GetKeyState("Shift", "P")
MButton & 1:: removeActiveWindow(1)
MButton & 2:: removeActiveWindow(2)
MButton & 3:: removeActiveWindow(3)
MButton & 4:: removeActiveWindow(4)
#HotIf

showDebugWindow()