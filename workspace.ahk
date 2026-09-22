#Requires AutoHotkey v2.0

current_workspace := 1

workspaces := [{
    position: 0,
    windows: []
}, {
    position: 0,
    windows: []
}, {
    position: 0,
    windows: []
}, {
    position: 0,
    windows: []
}]

moveRight() {
    workspace := workspaces[current_workspace]

    if (workspace.position == 0) {
        return
    }

    if (workspace.windows.Length == workspace.position) {
        return
    }

    workspace.position += 1
}

moveLeft() {
    workspace := workspaces[current_workspace]

    if (workspace.position == 0) {
        return
    }

    if (workspace.position == 1) {
        return
    }

    workspace.position -= 1
}

moveDown() {
    global current_workspace

    if (current_workspace == 0) {
        return
    }

    if (workspaces.Length == current_workspace) {
        return
    }

    current_workspace += 1

    if (workspaces[current_workspace].windows.Length == 0) {
        current_workspace -= 1
    }
}

moveUp() {
    global current_workspace

    if (current_workspace == 0) {
        return
    }

    if (current_workspace == 1) {
        return
    }

    current_workspace -= 1
}

addActiveWindow(workspace_id) {
    instance := WinExist("A")
    addWindow(workspace_id, instance)
}

addWindow(workspace_id, window) {
    target_workspace := workspaces[workspace_id]

    if (target_workspace.position == 0) {
        target_workspace.position += 1
    }

    for w in target_workspace.windows {
        if (window == w) {
            return
        }
    }

    target_workspace.windows.Push(window)
}

removeActiveWindow(workspace_id) {
    instance := WinExist("A")
    removeWindow(workspace_id, instance)
}

removeWindow(workspace_id, window) {
    target_workspace := workspaces[workspace_id]

    for i, w in target_workspace.windows {
        if (w == window) {
            if (target_workspace.position == target_workspace.windows.Length) {
                target_workspace.position -= 1
            }

            target_workspace.windows.RemoveAt(i)
            break
        }
    }
}

showDebugWindow() {
    global debugGui, debugText

    debugGui := Gui("+AlwaysOnTop", "Debug")
    debugText := debugGui.Add("Edit", "w500 h300 ReadOnly")
    debugGui.Show()

    SetTimer(updateDebug, 200)
}

updateDebug() {
    global debugText

    debugText.Value := workspacesToString()
}

workspacesToString() {
    global workspaces
    global current_workspace

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
