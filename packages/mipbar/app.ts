import app from "ags/gtk4/app"
import { exec } from "ags/process"
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

app.start({
  css: style,
  main() {
    app.get_monitors().map(Bar)

    // Apply initial theme
    app.apply_css(getThemeCss(isDark()))

    // Watch for color scheme changes
    subprocess(
      "gsettings monitor org.gnome.desktop.interface color-scheme",
      () => applyTheme(),
    )
  },
})
