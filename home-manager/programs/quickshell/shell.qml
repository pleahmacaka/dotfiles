import Quickshell
import Quickshell.Io

ShellRoot {
  // One bar per monitor (matches the old App.get_monitors() loop).
  Variants {
    model: Quickshell.screens
    Bar {}
  }

  Launcher { id: launcher }
  Clipboard { id: clipboard }

  // Replaces `ags request`. Hyprland calls: qs ipc call shell <fn>
  IpcHandler {
    target: "shell"
    function toggleLauncher(): void {
      clipboard.hide();
      launcher.toggle();
    }
    function toggleClipboard(): void {
      launcher.hide();
      clipboard.toggle();
    }
  }
}
