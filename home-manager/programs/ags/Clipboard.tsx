import { App, Astal, Gtk, Gdk } from "astal/gtk4"
import { Variable, exec, execAsync } from "astal"

const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor

type Entry = { id: string; preview: string }
type State = { query: string; items: Entry[] }

const MAX_RESULTS = 8

function loadHistory(): Entry[] {
  try {
    const raw = exec("cliphist list")
    return raw
      .split("\n")
      .filter((l) => l.length > 0)
      .map((line) => {
        const tab = line.indexOf("\t")
        if (tab === -1) return { id: line, preview: line }
        return { id: line.slice(0, tab), preview: line.slice(tab + 1) }
      })
  } catch {
    return []
  }
}

export default function Clipboard() {
  const all = Variable<Entry[]>([])
  const state = Variable<State>({ query: "", items: [] })
  let searchentry: Gtk.Entry

  function refresh() {
    const items = loadHistory()
    all.set(items)
    filter("")
  }

  function filter(text: string) {
    const items = all.get()
    if (text === "") {
      state.set({ query: "", items: items.slice(0, MAX_RESULTS) })
    } else {
      const q = text.toLowerCase()
      state.set({
        query: text,
        items: items.filter((i) => i.preview.toLowerCase().includes(q)).slice(0, MAX_RESULTS),
      })
    }
  }

  function paste(entry?: Entry) {
    if (!entry) return
    win.hide()
    execAsync(["sh", "-c", `cliphist decode ${entry.id} | wl-copy`]).catch(() => {})
  }

  function hide() {
    win.visible = false
  }

  function ItemSlot(index: number) {
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
          onClicked={() => paste(state.get().items[index])}
        >
          <box>
            <image iconName="edit-paste-symbolic" cssClasses={["app-icon"]} />
            <box vertical hexpand valign={Gtk.Align.CENTER}>
              <label
                label={state((s) => s.items[index]?.preview || "")}
                halign={Gtk.Align.START}
                cssClasses={["app-name"]}
                ellipsize={3}
                maxWidthChars={60}
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
      name="clipboard"
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
          refresh()
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
          <image iconName="edit-paste-symbolic" cssClasses={["search-icon"]} />
          <entry
            setup={(self: Gtk.Entry) => {
              searchentry = self
            }}
            onNotifyText={({ text }) => filter(text)}
            placeholderText="Search clipboard..."
            onActivate={() => paste(state.get().items[0])}
            hexpand
          />
        </box>
        <box vertical cssClasses={["results"]}>
          {Array.from({ length: MAX_RESULTS }, (_, i) => ItemSlot(i))}
          <revealer
            hexpand
            transitionType={Gtk.RevealerTransitionType.CROSSFADE}
            transitionDuration={120}
            revealChild={state((s) => s.items.length === 0)}
          >
            <label
              cssClasses={["no-results"]}
              label={state((s) => (s.query === "" ? "Clipboard is empty" : "No results"))}
              halign={Gtk.Align.CENTER}
              hexpand
            />
          </revealer>
        </box>
      </box>
    </window>
  ) as Astal.Window

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

    if (modState & Gdk.ModifierType.ALT_MASK) {
      const num = keyval - Gdk.KEY_1
      if (num >= 0 && num <= 8) {
        paste(state.get().items[num])
        return true
      }
    }

    return false
  })
  win.add_controller(keyController)

  const click = new Gtk.GestureClick()
  click.connect("pressed", () => {
    hide()
  })
  win.add_controller(click)

  return win
}
