#Requires AutoHotkey v2.0+

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
    focusCurrentWindow()
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
    focusCurrentWindow()
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

    focusCurrentWindow()
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
    focusCurrentWindow()
}

focusCurrentWindow() {
    workspace := workspaces[current_workspace]
    window := workspace.windows[workspace.position]

    if WinExist(window) {
        WinActivate(window)
    } else {
        removeWindow(current_workspace, window)
        focusCurrentWindow()
    }
}

addActiveWindow(workspace_id) {
    instance := WinExist("A")
    addWindow(workspace_id, instance)
}

addWindow(workspace_id, window) {
    global current_workspace
    target_workspace := workspaces[workspace_id]

    for w in target_workspace.windows {
        if (window == w) {
            return
        }
    }

    target_workspace.windows.Push(window)
    target_workspace.position := target_workspace.windows.Length
    current_workspace := workspace_id
    focusCurrentWindow()
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

moveWindowToWorkspace(window, source_id, target_id, target_position := 0) {
    global current_workspace

    source_position := 0
    for index, source_window in workspaces[source_id].windows {
        if (source_window == window) {
            source_position := index
            break
        }
    }

    removeWindow(source_id, window)
    target_workspace := workspaces[target_id]

    for index, existing_window in target_workspace.windows {
        if (existing_window == window) {
            target_workspace.position := index
            current_workspace := target_id
            focusCurrentWindow()
            return
        }
    }

    if (source_id == target_id && source_position && source_position < target_position)
        target_position -= 1

    if (target_position < 1)
        target_position := target_workspace.windows.Length + 1
    target_position := Min(target_position, target_workspace.windows.Length + 1)

    target_workspace.windows.InsertAt(target_position, window)
    target_workspace.position := target_position
    current_workspace := target_id
    focusCurrentWindow()
}

removeClosedWindows() {
    for workspace_id, workspace in workspaces {
        index := workspace.windows.Length
        while (index >= 1) {
            if !WinExist("ahk_id " workspace.windows[index])
                removeWindow(workspace_id, workspace.windows[index])
            index -= 1
        }
    }
}
