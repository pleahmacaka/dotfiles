import { App, Astal, Gtk, Gdk } from "astal/gtk4";
import { Variable } from "astal";
import AstalApps from "gi://AstalApps";

const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor;

const SEARCH_LIMIT = 30;
const KEY_LIMIT = 9;

export default function Applauncher() {
  const apps = new AstalApps.Apps();
  const items = Variable<AstalApps.Application[]>([]);
  const query = Variable<string>("");
  let searchentry: Gtk.Entry;

  function refresh(text: string) {
    query.set(text);
    if (text === "") {
      const all = [...apps.list].sort((a, b) => a.name.localeCompare(b.name));
      items.set(all);
    } else {
      items.set(apps.fuzzy_query(text).slice(0, SEARCH_LIMIT));
    }
  }

  function launch(app?: AstalApps.Application) {
    if (app) {
      win.hide();
      app.launch();
    }
  }

  function hide() {
    win.visible = false;
  }

  function renderItem(app: AstalApps.Application, index: number) {
    return (
      <button
        cssClasses={["app-item"]}
        widthRequest={500}
        heightRequest={56}
        onClicked={() => launch(app)}
      >
        <box>
          <image
            iconName={app.iconName || "application-x-executable"}
            cssClasses={["app-icon"]}
          />
          <box vertical hexpand valign={Gtk.Align.CENTER}>
            <label
              label={app.name}
              halign={Gtk.Align.START}
              cssClasses={["app-name"]}
              ellipsize={3}
              maxWidthChars={40}
            />
            <label
              label={app.description || ""}
              visible={!!app.description}
              halign={Gtk.Align.START}
              cssClasses={["app-desc"]}
              ellipsize={3}
              maxWidthChars={50}
            />
          </box>
          {index < KEY_LIMIT ? (
            <label
              valign={Gtk.Align.CENTER}
              cssClasses={["app-shortcut"]}
              label={`Alt+${index + 1}`}
            />
          ) : null}
        </box>
      </button>
    );
  }

  const showNoResults = Variable.derive(
    [items, query],
    (it, q) => it.length === 0 && q !== "",
  );

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
          apps.reload();
          searchentry?.set_text("");
          refresh("");
          searchentry?.grab_focus();
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
          <image
            iconName="system-search-symbolic"
            cssClasses={["search-icon"]}
          />
          <entry
            setup={(self: Gtk.Entry) => {
              searchentry = self;
            }}
            onNotifyText={({ text }) => refresh(text)}
            placeholderText="Search applications..."
            onActivate={() => launch(items.get()[0])}
            hexpand
          />
        </box>
        <scrolledwindow
          hscrollbarPolicy={Gtk.PolicyType.NEVER}
          vscrollbarPolicy={Gtk.PolicyType.AUTOMATIC}
          heightRequest={520}
        >
          <box vertical cssClasses={["results"]}>
            {items((list) => list.map((app, i) => renderItem(app, i)))}
          </box>
        </scrolledwindow>
        <revealer
          hexpand
          transitionType={Gtk.RevealerTransitionType.CROSSFADE}
          transitionDuration={120}
          revealChild={showNoResults((v) => v)}
        >
          <label
            cssClasses={["no-results"]}
            label="No results"
            halign={Gtk.Align.CENTER}
            hexpand
          />
        </revealer>
      </box>
    </window>
  ) as Astal.Window;

  const keyController = new Gtk.EventControllerKey();
  keyController.connect(
    "key-pressed",
    (
      _self: Gtk.EventControllerKey,
      keyval: number,
      _keycode: number,
      modState: number,
    ) => {
      if (keyval === Gdk.KEY_Escape) {
        hide();
        return true;
      }
      if (modState & Gdk.ModifierType.ALT_MASK) {
        const num = keyval - Gdk.KEY_1;
        if (num >= 0 && num <= 8) {
          launch(items.get()[num]);
          return true;
        }
      }
      return false;
    },
  );
  win.add_controller(keyController);

  const click = new Gtk.GestureClick();
  click.connect("pressed", () => {
    hide();
  });
  win.add_controller(click);

  return win;
}
