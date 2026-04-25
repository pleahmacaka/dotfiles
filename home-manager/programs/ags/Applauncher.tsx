import { App, Astal, Gtk, Gdk } from "astal/gtk4"
import { Variable } from "astal"
import AstalApps from "gi://AstalApps"

const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor

type State = { query: string; items: AstalApps.Application[] }

const MAX_RESULTS = 8

export default function Applauncher() {
  const apps = new AstalApps.Apps()
  const state = Variable<State>({ query: "", items: [] })
  let searchentry: Gtk.Entry

  function search(text: string) {
    if (text === "") state.set({ query: "", items: [] })
    else state.set({ query: text, items: apps.fuzzy_query(text).slice(0, MAX_RESULTS) })
  }

  function launch(app?: AstalApps.Application) {
    if (app) {
      win.hide()
      app.launch()
    }
  }

  function hide() {
    win.visible = false
  }

  function AppSlot(index: number) {
    return (
      <revealer
        transitionType={Gtk.RevealerTransitionType.CROSSFADE}
        transitionDuration={120}
        revealChild={state((s) => index < s.items.length)}
      >
        <button
          cssClasses={["app-item"]}
          widthRequest={500}
          heightRequest={56}
          onClicked={() => launch(state.get().items[index])}
        >
          <box>
            <image
              iconName={state((s) => s.items[index]?.iconName || "application-x-executable")}
              cssClasses={["app-icon"]}
            />
            <box vertical hexpand valign={Gtk.Align.CENTER}>
              <label
                label={state((s) => s.items[index]?.name || "")}
                halign={Gtk.Align.START}
                cssClasses={["app-name"]}
                ellipsize={3}
                maxWidthChars={40}
              />
              <label
                label={state((s) => s.items[index]?.description || "")}
                visible={state((s) => !!s.items[index]?.description)}
                halign={Gtk.Align.START}
                cssClasses={["app-desc"]}
                ellipsize={3}
                maxWidthChars={50}
              />
            </box>
            <label
              valign={Gtk.Align.CENTER}
              cssClasses={["app-shortcut"]}
              label={`Alt+${index + 1}`}
            />
          </box>
        </button>
      </revealer>
    )
  }

  const win = (
    <window
      name="launcher"
      namespace="launcher"
      cssClasses={["launcher-window"]}
      anchor={TOP | BOTTOM | LEFT | RIGHT}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.EXCLUSIVE}
      layer={Astal.Layer.OVERLAY}
      application={App}
      visible={false}
      onNotifyVisible={({ visible }) => {
        if (visible) {
          searchentry?.set_text("")
          state.set({ query: "", items: [] })
          searchentry?.grab_focus()
        }
      }}
    >
      <box
        cssClasses={["launcher-content"]}
        valign={Gtk.Align.START}
        halign={Gtk.Align.CENTER}
        vertical
      >
        <box cssClasses={["search-box"]}>
          <image iconName="system-search-symbolic" cssClasses={["search-icon"]} />
          <entry
            setup={(self: Gtk.Entry) => { searchentry = self }}
            onNotifyText={({ text }) => search(text)}
            placeholderText="Search applications..."
            onActivate={() => launch(state.get().items[0])}
            hexpand
          />
        </box>
        <box vertical cssClasses={["results"]}>
          {Array.from({ length: MAX_RESULTS }, (_, i) => AppSlot(i))}
          <revealer
            hexpand
            transitionType={Gtk.RevealerTransitionType.CROSSFADE}
            transitionDuration={120}
            revealChild={state((s) => s.items.length === 0 && s.query !== "")}
          >
            <label
              cssClasses={["no-results"]}
              label="No results"
              halign={Gtk.Align.CENTER}
              hexpand
            />
          </revealer>
        </box>
      </box>
    </window>
  ) as Astal.Window

  // keyboard handler
  const keyController = new Gtk.EventControllerKey()
  keyController.connect("key-pressed", (
    _self: Gtk.EventControllerKey,
    keyval: number,
    _keycode: number,
    modState: number,
  ) => {
    if (keyval === Gdk.KEY_Escape) {
      hide()
      return true
    }

    // Alt+N to launch Nth result
    if (modState & Gdk.ModifierType.ALT_MASK) {
      const num = keyval - Gdk.KEY_1
      if (num >= 0 && num <= 8) {
        launch(state.get().items[num])
        return true
      }
    }

    return false
  })
  win.add_controller(keyController)

  // click outside to close
  const click = new Gtk.GestureClick()
  click.connect("pressed", () => { hide() })
  win.add_controller(click)

  return win
}
