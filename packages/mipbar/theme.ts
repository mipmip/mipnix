const dark = `
window.Bar {
  color: #ffffff;
}
window.Bar > centerbox {
  background: #242424;
}
window.Bar button.AppLauncher:hover,
window.Bar .WorkspaceButton:hover {
  background: rgba(255, 255, 255, 0.1);
}
window.Bar button.AppLauncher:active,
window.Bar .WorkspaceButton:active,
window.Bar .WorkspaceButton.focused {
  background: rgba(255, 255, 255, 0.2);
}
window.Bar .StatusIcon.Screenshare {
  color: #ff4444;
}
`

const light = `
window.Bar {
  color: #1e1e1e;
}
window.Bar > centerbox {
  background: #fafafa;
}
window.Bar button.AppLauncher:hover,
window.Bar .WorkspaceButton:hover {
  background: rgba(0, 0, 0, 0.08);
}
window.Bar button.AppLauncher:active,
window.Bar .WorkspaceButton:active,
window.Bar .WorkspaceButton.focused {
  background: rgba(0, 0, 0, 0.15);
}
window.Bar .StatusIcon.Screenshare {
  color: #cc0000;
}
`

export function getThemeCss(isDark: boolean): string {
  return isDark ? dark : light
}
