import { App, Astal, Gtk, Gdk } from "astal/gtk4"
import { Variable, bind, execAsync } from "astal"
import AstalHyprland from "gi://AstalHyprland"
import AstalTray from "gi://AstalTray"
import AstalBattery from "gi://AstalBattery"

const { TOP, BOTTOM, LEFT } = Astal.WindowAnchor

function Workspaces() {
  const hypr = AstalHyprland.get_default()
  return (
    <box cssClasses={["workspaces"]} orientation={Gtk.Orientation.VERTICAL}>
      {bind(hypr, "workspaces").as((wss) =>
        wss
          .filter((ws) => ws.id > 0)
          .sort((a, b) => a.id - b.id)
          .map((ws) => (
            <button
              cssClasses={bind(hypr, "focusedWorkspace").as((fw) =>
                fw?.id === ws.id ? ["ws", "ws-active"] : ["ws"],
              )}
              tooltipText={`${ws.id}`}
              onClicked={() => ws.focus()}
              halign={Gtk.Align.CENTER}
              valign={Gtk.Align.CENTER}
              hexpand={false}
              vexpand={false}
            />
          )),
      )}
    </box>
  )
}

function Clock() {
  const hhmm = Variable("").poll(1000, () => {
    const d = new Date()
    const h = d.getHours() % 12 || 12
    const m = `${d.getMinutes()}`.padStart(2, "0")
    return `${h}:${m}`
  })
  const ampm = Variable("").poll(1000, () => (new Date().getHours() < 12 ? "AM" : "PM"))
  const date = Variable("").poll(60000, () => {
    const d = new Date()
    const wd = d.toLocaleString("ko-KR", { weekday: "short" })
    return `${wd} ${d.getMonth() + 1}/${d.getDate()}`
  })
  let popover: Gtk.Popover | null = null
  return (
    <button
      cssClasses={["clock"]}
      onClicked={(self) => {
        if (!popover) {
          const cal = new Gtk.Calendar({ cssClasses: ["clock-calendar"] })
          popover = new Gtk.Popover({ child: cal, autohide: true, hasArrow: true })
          popover.set_position(Gtk.PositionType.RIGHT)
          popover.set_parent(self)
        }
        popover.popup()
      }}
    >
      <box orientation={Gtk.Orientation.VERTICAL}>
        <label cssClasses={["clock-time"]} label={hhmm()} />
        <label cssClasses={["clock-period"]} label={ampm()} />
        <label cssClasses={["clock-date"]} label={date()} />
      </box>
    </button>
  )
}

function Notifications() {
  let popover: Gtk.Popover | null = null
  const list = Variable<string[]>([])

  function refresh() {
    execAsync(["sh", "-c", "makoctl history 2>/dev/null"])
      .then((out) => {
        try {
          const parsed = JSON.parse(String(out))
          const items = (parsed?.data?.[0] ?? []) as Array<{ summary?: { data: string }; body?: { data: string } }>
          list.set(
            items
              .slice(-20)
              .reverse()
              .map((it) => {
                const s = it.summary?.data ?? ""
                const b = it.body?.data ?? ""
                return b ? `${s}\n${b}` : s
              }),
          )
        } catch {
          list.set([])
        }
      })
      .catch(() => list.set([]))
  }

  return (
    <button
      cssClasses={["notifications"]}
      tooltipText="알림 기록"
      onClicked={(self) => {
        refresh()
        if (!popover) {
          const content = (
            <box cssClasses={["notif-list"]} orientation={Gtk.Orientation.VERTICAL}>
              {bind(list).as((items) =>
                items.length === 0
                  ? [<label cssClasses={["notif-empty"]} label="기록 없음" />]
                  : items.map((text) => <label cssClasses={["notif-item"]} label={text} wrap maxWidthChars={32} xalign={0} />),
              )}
              <button
                cssClasses={["notif-clear"]}
                onClicked={() => execAsync(["makoctl", "dismiss", "--all"]).then(refresh).catch(() => void 0)}
              >
                <label label="모두 닫기" />
              </button>
            </box>
          ) as Gtk.Widget
          popover = new Gtk.Popover({ child: content, autohide: true, hasArrow: true })
          popover.set_position(Gtk.PositionType.RIGHT)
          popover.set_parent(self)
        }
        popover.popup()
      }}
    >
      <image iconName="notification-symbolic" />
    </button>
  )
}

function Tray() {
  const tray = AstalTray.get_default()
  return (
    <box cssClasses={["tray"]} orientation={Gtk.Orientation.VERTICAL}>
      {bind(tray, "items").as((items) =>
        items.map((item) => (
          <button
            cssClasses={["tray-item"]}
            tooltipMarkup={bind(item, "tooltipMarkup")}
            onClicked={(self) => {
              if (!item.menuModel) return
              const menu = new Gtk.PopoverMenu({ menuModel: item.menuModel })
              menu.set_position(Gtk.PositionType.RIGHT)
              self.insert_action_group("dbusmenu", item.actionGroup)
              menu.set_parent(self)
              menu.popup()
            }}
          >
            <image gicon={bind(item, "gicon")} />
          </button>
        )),
      )}
    </box>
  )
}

function Battery() {
  const bat = AstalBattery.get_default()
  return (
    <box
      cssClasses={["battery"]}
      orientation={Gtk.Orientation.VERTICAL}
      visible={bind(bat, "isPresent")}
      tooltipText={bind(bat, "percentage").as((p) => `${Math.round(p * 100)}%`)}
    >
      <image iconName={bind(bat, "iconName")} />
      <label label={bind(bat, "percentage").as((p) => `${Math.round(p * 100)}%`)} />
    </box>
  )
}

export default function Bar(gdkmonitor: Gdk.Monitor) {
  return (
    <window
      name="bar"
      namespace="bar"
      visible
      cssClasses={["bar-window"]}
      gdkmonitor={gdkmonitor}
      anchor={TOP | BOTTOM | LEFT}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      layer={Astal.Layer.TOP}
      application={App}
    >
      <centerbox cssClasses={["bar-content"]} orientation={Gtk.Orientation.VERTICAL}>
        <box valign={Gtk.Align.START} orientation={Gtk.Orientation.VERTICAL}>
          <Workspaces />
        </box>
        <box valign={Gtk.Align.CENTER} orientation={Gtk.Orientation.VERTICAL}>
          <Clock />
        </box>
        <box valign={Gtk.Align.END} orientation={Gtk.Orientation.VERTICAL}>
          <Tray />
          <Notifications />
          <Battery />
        </box>
      </centerbox>
    </window>
  ) as Astal.Window
}
