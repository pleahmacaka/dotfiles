import { App } from "astal/gtk4"
import style from "./style.scss"
import Applauncher from "./Applauncher"

const applauncher = Applauncher()

App.start({
  css: style,
  requestHandler(request, res) {
    switch (request) {
      case "toggle":
        applauncher.visible = !applauncher.visible
        return res("ok")
      default:
        return res("unknown command")
    }
  },
  main() {
    App.add_window(applauncher)
  },
})
