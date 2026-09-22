#Requires AutoHotkey v2.0

current_workspace := 1

workspaces := [{
    position: 1,
    windows: [
        'window1',
        'window2'
    ]
}, {
    position: 1,
    windows: [
        'window3',
    ]
}, {
    position: 1,
    windows: [
        'window4',
        'window5',
    ]
}, {
    position: 1,
    windows: [
        'window6',
    ]
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

addCurrentWindow(workspace_id) {
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
