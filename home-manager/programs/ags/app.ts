import { App, Astal } from "astal/gtk4"
import style from "./style.scss"
import Applauncher from "./Applauncher"
import Clipboard from "./Clipboard"
import Bar from "./Bar"

let applauncher: Astal.Window
let clipboard: Astal.Window

App.start({
  css: style,
  requestHandler(request, res) {
    switch (request) {
      case "toggle":
        clipboard.visible = false
        applauncher.visible = !applauncher.visible
        return res("ok")
      case "clipboard-toggle":
        applauncher.visible = false
        clipboard.visible = !clipboard.visible
        return res("ok")
      default:
        return res("unknown command")
    }
  },
  main() {
    applauncher = Applauncher()
    clipboard = Clipboard()
    for (const monitor of App.get_monitors()) {
      Bar(monitor)
    }
  },
})
