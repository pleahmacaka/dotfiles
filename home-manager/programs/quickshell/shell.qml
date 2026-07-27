import Quickshell
import Quickshell.Io

ShellRoot {
  Variants {
    model: Quickshell.screens
    Bar {}
  }

  Launcher { id: launcher }
  Clipboard { id: clipboard }

  // Hyprland calls these as: qs ipc call shell <fn>
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
