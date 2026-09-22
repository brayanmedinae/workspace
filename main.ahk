#Requires AutoHotkey v2.0+
#SingleInstance Force

#Include workspace.ahk

RButton::RButton
MButton::MButton

RButton & f:: moveRight()
RButton & s:: moveLeft()
RButton & d:: moveDown()
RButton & e:: moveUp()