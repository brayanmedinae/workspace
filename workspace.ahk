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
}]

moveRight() {
    workspace := workspaces[current_workspace]

    if (workspace.windows.Length == workspace.position) {
        return
    }

    workspace.position += 1
}

moveLeft() {
    workspace := workspaces[current_workspace]

    if (workspace.position == 1) {
        return
    }

    workspace.position -= 1
}

moveDown() {
    global current_workspace

    if (workspaces.Length == current_workspace) {
        return
    }

    current_workspace += 1
}

moveUp() {
    global current_workspace

    if (current_workspace == 1) {
        return
    }

    current_workspace -= 1
}
