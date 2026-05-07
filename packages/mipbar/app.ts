import app from "ags/gtk4/app"
import { exec, execAsync } from "ags/process"
import { subprocess } from "ags/process"
import style from "./style.scss"
import { getThemeCss } from "./theme"
import Bar from "./widget/Bar"

function isDark(): boolean {
  const result = exec("gsettings get org.gnome.desktop.interface color-scheme")
  return result.includes("prefer-dark")
}

function applyTheme() {
  app.reset_css()
  app.apply_css(style)
  app.apply_css(getThemeCss(isDark()))
}

function isLaptop(connector: string): boolean {
  return connector.startsWith("eDP")
}

function getPreferredMonitor() {
  const monitors = app.get_monitors()
  return monitors.find((m) => !isLaptop(m.get_connector() || "")) ?? monitors[0] ?? null
}

app.start({
  css: style,
  main() {
    // Create bar on preferred monitor only
    const preferred = getPreferredMonitor()
    if (preferred) Bar(preferred)

    // Apply initial theme
    app.apply_css(getThemeCss(isDark()))

    // Watch for color scheme changes
    subprocess(
      "gsettings monitor org.gnome.desktop.interface color-scheme",
      () => applyTheme(),
    )

    // Watch for monitor changes via hyprctl
    subprocess(
      ["bash", "-c", "socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | grep --line-buffered monitoradded"],
      () => {
        // External monitor added — restart to pick it up
        setTimeout(() => {
          execAsync("bash -c 'mipbar &'")
          app.quit()
        }, 3000)
      },
    )

    // Handle monitor removal — show laptop bar
    app.connect("notify::monitors", () => {
      const monitors = app.get_monitors()
      const hasExternal = monitors.some((m) => !isLaptop(m.get_connector() || ""))

      if (!hasExternal) {
        // External gone — all bars become stale, restart for laptop bar
        execAsync("bash -c 'sleep 0.5 && mipbar &'")
        app.quit()
      }
    })
  },
})
