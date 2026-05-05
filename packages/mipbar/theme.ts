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
window.Bar .StatusIcon.Camera {
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
window.Bar button:hover,
window.Bar menubutton > button:hover {
  background: rgba(0, 0, 0, 0.15);
}
window.Bar button:active,
window.Bar menubutton > button:active,
window.Bar .WorkspaceButton.focused {
  background: rgba(0, 0, 0, 0.25);
}
window.Bar .StatusIcon.Screenshare {
  color: #cc0000;
}
window.Bar .StatusIcon.Camera {
  color: #cc0000;
}
`

export function getThemeCss(isDark: boolean): string {
  return isDark ? dark : light
}
