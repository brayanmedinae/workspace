#Requires AutoHotkey v2.0+
#SingleInstance Force

#Include workspace.ahk

RButton::RButton
MButton::MButton

RButton & f:: moveRight()
RButton & s:: moveLeft()
RButton & d:: moveDown()
RButton & e:: moveUp()

MButton & 1:: addCurrentWindow(1)
MButton & 2:: addCurrentWindow(2)
MButton & 3:: addCurrentWindow(3)
MButton & 4:: addCurrentWindow(4)