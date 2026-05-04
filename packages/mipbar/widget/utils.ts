import Gio from "gi://Gio"
import GioUnix from "gi://GioUnix"

const iconCache = new Map<string, string>()

export function lookupIcon(wmClass: string): string {
  if (iconCache.has(wmClass)) return iconCache.get(wmClass)!

  const attempts = [
    wmClass,
    wmClass.toLowerCase(),
  ]

  for (const id of attempts) {
    for (const suffix of ["", ".desktop"]) {
      const appInfo = GioUnix.DesktopAppInfo.new(id + suffix)
      if (appInfo) {
        const icon = appInfo.get_icon()
        const iconName = icon?.to_string() ?? wmClass
        iconCache.set(wmClass, iconName)
        return iconName
      }
    }
  }

  const allApps = Gio.AppInfo.get_all() as GioUnix.DesktopAppInfo[]
  for (const app of allApps) {
    if (typeof app.get_startup_wm_class !== "function") continue
    const appWmClass = app.get_startup_wm_class()
    if (appWmClass && appWmClass.toLowerCase() === wmClass.toLowerCase()) {
      const icon = app.get_icon()
      const iconName = icon?.to_string() ?? wmClass
      iconCache.set(wmClass, iconName)
      return iconName
    }
  }

  iconCache.set(wmClass, wmClass)
  return wmClass
}
