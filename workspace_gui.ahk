#Requires AutoHotkey v2.0+

global debugGui := ""
global debugText := ""
global configGui := ""
global configCards := Map()
global configSelectedWindow := 0
global configSelectedWorkspace := 0
global configDragWindow := 0
global configDragWorkspace := 0
global configDragTitle := ""

toggleWindowConfig() {
    global configGui

    if (configGui)
        closeWindowConfig()
    else
        showWindowConfig()
}

showWindowConfig(*) {
    global configGui, configCards

    removeClosedWindows()
    configCards := Map()
    configGui := Gui("+AlwaysOnTop", "Configurar ventanas")
    configGui.BackColor := "1E1E24"
    configGui.SetFont("s10 cF2F2F2", "Segoe UI")
    configGui.OnEvent("Close", closeWindowConfig)
    configGui.OnEvent("Escape", closeWindowConfig)

    configGui.Add("Text", "x14 y12 w500 h25 cFFFFFF", "Arrastra una ventana a otro workspace")
    configGui.SetFont("s9 cB8B8C0", "Segoe UI")
    configGui.Add("Text", "x14 y39 w500 h22", "Click: seleccionar  •  Doble click: activar  •  Escape: cerrar")

    maxWindows := 0
    for workspace in workspaces
        maxWindows := Max(maxWindows, workspace.windows.Length)

    guiWidth := Max(760, Min(1200, 225 + maxWindows * 190))
    guiHeight := 625

    removeButton := configGui.Add("Button", "x" (guiWidth - 274) " y14 w125 h34", "Quitar")
    removeButton.OnEvent("Click", removeSelectedConfigWindow)
    cleanButton := configGui.Add("Button", "x" (guiWidth - 139) " y14 w125 h34", "Limpiar cerradas")
    cleanButton.OnEvent("Click", refreshWindowConfig)

    loop workspaces.Length
        drawWorkspaceRow(A_Index, 70 + (A_Index - 1) * 125, guiWidth)

    configGui.Add("Text", "x14 y585 w" (guiWidth - 28) " h24 vConfigStatus cB8B8C0",
    "Selecciona una tarjeta o arrástrala a otra fila.")
    configGui.Show("w" guiWidth " h" guiHeight)
}

drawWorkspaceRow(workspaceId, y, guiWidth) {
    global configGui, configCards, current_workspace

    accent := workspaceId == current_workspace ? " c8FD3FF" : " cFFFFFF"
    configGui.Add("GroupBox", "x14 y" y " w" (guiWidth - 28) " h115" accent, "Workspace " workspaceId)

    activateButton := configGui.Add("Button", "x28 y" (y + 35) " w145 h34", workspaceId == current_workspace ? "Activo" :
        "Activar workspace")
    activateButton.OnEvent("Click", activateConfigWorkspace.Bind(workspaceId))

    cardX := 190
    for window in workspaces[workspaceId].windows {
        title := getWindowLabel(window)
        card := configGui.Add("Text", "x" cardX " y" (y + 25) " w178 h62 +Border Background30303A cFFFFFF +0x100 +0x200",
        "  " title)
        configCards[card.Hwnd] := { window: window, workspace: workspaceId, title: title }
        cardX += 190
    }

    if (workspaces[workspaceId].windows.Length == 0)
        configGui.Add("Text", "x190 y" (y + 36) " w250 h44 c777780 Center", "Suelta una ventana aquí")
}

getWindowLabel(window) {
    try title := WinGetTitle("ahk_id " window)
    catch
        title := "Ventana cerrada"

    try process := WinGetProcessName("ahk_id " window)
    catch
        process := ""

    if (title == "")
        title := "Sin título"
    if (StrLen(title) > 24)
        title := SubStr(title, 1, 23) "…"

    return title (process != "" ? "`n  " process : "")
}

configMouseDown(wParam, lParam, msg, hwnd) {
    global configCards, configDragWindow, configDragWorkspace, configDragTitle

    if (!configCards.Has(hwnd))
        return

    card := configCards[hwnd]
    configDragWindow := card.window
    configDragWorkspace := card.workspace
    configDragTitle := StrReplace(card.title, "`n", " — ")
    selectConfigWindow(card.window, card.workspace)
    SetTimer(trackConfigDrag, 20)
}

configDoubleClick(wParam, lParam, msg, hwnd) {
    global configCards, current_workspace

    if (!configCards.Has(hwnd))
        return

    card := configCards[hwnd]
    current_workspace := card.workspace
    for index, window in workspaces[card.workspace].windows {
        if (window == card.window) {
            workspaces[card.workspace].position := index
            break
        }
    }

    closeWindowConfig()
    if WinExist("ahk_id " card.window)
        WinActivate("ahk_id " card.window)
}

trackConfigDrag() {
    global configDragWindow, configDragWorkspace, configDragTitle

    if (!configDragWindow) {
        SetTimer(trackConfigDrag, 0)
        return
    }

    previousMouseMode := A_CoordModeMouse
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mouseX, &mouseY)
    CoordMode("Mouse", previousMouseMode)
    if GetKeyState("LButton", "P") {
        dropTarget := configDropTargetAt(mouseX, mouseY)
        destination := dropTarget
            ? "`nWorkspace " dropTarget.workspace ", posición " dropTarget.position
                : ""
        previousToolTipMode := A_CoordModeToolTip
        CoordMode("ToolTip", "Screen")
        ToolTip("Mover: " configDragTitle destination, mouseX + 18, mouseY + 18)
        CoordMode("ToolTip", previousToolTipMode)
        return
    }

    ToolTip()
    SetTimer(trackConfigDrag, 0)
    dropTarget := configDropTargetAt(mouseX, mouseY)

    if (dropTarget)
        moveWindowFromConfig(configDragWindow, configDragWorkspace, dropTarget.workspace, dropTarget.position)

    configDragWindow := 0
    configDragWorkspace := 0
    configDragTitle := ""
}

configWorkspaceAt(mouseX, mouseY) {
    global configGui

    if (!configGui)
        return 0

    WinGetPos(&guiX, &guiY, &guiW, &guiH, "ahk_id " configGui.Hwnd)
    localX := mouseX - guiX
    localY := mouseY - guiY

    if (localY < 70 || localY >= 570 || localX < 14 || localX > guiW - 14)
        return 0

    workspaceId := Floor((localY - 70) / 125) + 1
    return workspaceId >= 1 && workspaceId <= workspaces.Length ? workspaceId : 0
}

configDropTargetAt(mouseX, mouseY) {
    global configGui

    workspaceId := configWorkspaceAt(mouseX, mouseY)
    if (!workspaceId)
        return 0

    WinGetPos(&guiX, , , , "ahk_id " configGui.Hwnd)
    localX := mouseX - guiX
    targetPosition := 1

    for index, window in workspaces[workspaceId].windows {
        cardCenter := 190 + (index - 1) * 190 + 89
        if (localX < cardCenter)
            return { workspace: workspaceId, position: index }
        targetPosition := index + 1
    }

    return { workspace: workspaceId, position: targetPosition }
}

moveWindowFromConfig(window, sourceId, targetId, targetPosition) {
    global configSelectedWorkspace, configSelectedWindow

    moveWindowToWorkspace(window, sourceId, targetId, targetPosition)
    configSelectedWindow := window
    configSelectedWorkspace := targetId
    rebuildWindowConfig()

    if WinExist("ahk_id " window)
        WinActivate("ahk_id " window)
}

selectConfigWindow(window, workspaceId) {
    global configSelectedWindow, configSelectedWorkspace, configGui

    configSelectedWindow := window
    configSelectedWorkspace := workspaceId
    if (configGui)
        configGui["ConfigStatus"].Value := "Seleccionada en workspace " workspaceId ": " StrReplace(getWindowLabel(
            window), "`n", " — ")
}

removeSelectedConfigWindow(*) {
    global configSelectedWindow, configSelectedWorkspace

    if (!configSelectedWindow || !configSelectedWorkspace)
        return

    removeWindow(configSelectedWorkspace, configSelectedWindow)
    configSelectedWindow := 0
    configSelectedWorkspace := 0
    rebuildWindowConfig()
}

activateConfigWorkspace(workspaceId, *) {
    global current_workspace

    current_workspace := workspaceId
    if (workspaces[workspaceId].windows.Length > 0) {
        if (workspaces[workspaceId].position < 1)
            workspaces[workspaceId].position := 1
        focusCurrentWindow()
    }
    rebuildWindowConfig()
}

refreshWindowConfig(*) {
    removeClosedWindows()
    rebuildWindowConfig()
}

rebuildWindowConfig() {
    global configGui

    if (configGui)
        configGui.Destroy()
    configGui := ""
    showWindowConfig()
}

closeWindowConfig(*) {
    global configGui, configCards, configDragWindow

    SetTimer(trackConfigDrag, 0)
    ToolTip()
    if (configGui)
        configGui.Destroy()
    configGui := ""
    configCards := Map()
    configDragWindow := 0
}

OnMessage(0x0201, configMouseDown)
OnMessage(0x0203, configDoubleClick)

toggleDebugWindow() {
    global debugGui

    if (debugGui)
        closeDebugWindow()
    else
        showDebugWindow()
}

showDebugWindow() {
    global debugGui, debugText

    debugGui := Gui("+AlwaysOnTop", "Debug")
    debugText := debugGui.Add("Edit", "w500 h300 ReadOnly")
    debugGui.Show()
    SetTimer(updateDebug, 200)
}

closeDebugWindow(*) {
    global debugGui, debugText

    SetTimer(updateDebug, 0)
    debugGui.Destroy()
    debugGui := ""
    debugText := ""
}

updateDebug() {
    global debugText
    debugText.Value := workspacesToString()
}

workspacesToString() {
    global workspaces, current_workspace

    result := "Current workspace:" current_workspace "`n`n"

    for i, workspace in workspaces {
        result .= "Workspace " i ":`n"
        result .= "  position: " workspace.position "`n"
        result .= "  windows: ["

        for j, window in workspace.windows {
            result .= window
            if j < workspace.windows.Length
                result .= ", "
        }

        result .= "]`n"
        if i < workspaces.Length
            result .= "`n"
    }

    return result
}
