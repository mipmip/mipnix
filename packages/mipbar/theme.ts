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
window.Bar .WorkspaceButton.laptop {
  background: rgba(100, 140, 255, 0.12);
}
window.Bar .WorkspaceButton.laptop.focused {
  background: rgba(100, 140, 255, 0.28);
}
window.Bar .StatusIcon.Screenshare {
  color: #ff4444;
}
window.Bar .StatusIcon.Camera {
  color: #ff4444;
}
.ScreenPicker > contents {
  background: #18181e;
  border: 1px solid #323238;
  box-shadow: 0 18px 44px -10px rgba(0, 0, 0, 0.6);
}
.ScreenPicker .ScreenPickerHeader {
  color: #85858c;
}
.ScreenPicker .ScreenRow {
  background: #242328;
  border-color: #323238;
}
.ScreenPicker .ScreenModel {
  color: #f1f1f4;
}
.ScreenPicker .ScreenSpec {
  color: #85858c;
}
.ScreenPicker .ConnectorTag {
  color: #85858c;
}
.DisplaysPopover .DisplaysHeader label,
.DisplaysPopover .ResolutionHeader {
  color: #85858c;
}
.DisplaysPopover .DisplayCard {
  background: #242328;
  border-color: #323238;
}
.DisplaysPopover .DisplayModel {
  color: #f1f1f4;
}
.DisplaysPopover .DisplaySpec {
  color: #b9b9c0;
}
.DisplaysPopover .DisplayScale,
.DisplaysPopover .DisplayState,
.DisplaysPopover .ConnectorTag,
.DisplaysPopover .DisplayPos {
  color: #85858c;
}
.DisplaysPopover .ResolutionRow {
  color: #d8d8de;
}
.DisplaysPopover .ResolutionRow:hover {
  background: rgba(255, 255, 255, 0.08);
}
.DisplaysPopover .ResolutionRow .ResolutionRate {
  color: #85858c;
}
.DisplaysPopover .NativeTag {
  color: #6fbf8f;
}
.DisplaysPopover .ScaleWarn {
  color: #e0a44a;
}
.DisplaysPopover .ActionSmall {
  color: #d8d8de;
  background: rgba(255, 255, 255, 0.07);
}
.DisplaysPopover .ActionSmall:hover {
  background: rgba(255, 255, 255, 0.14);
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
window.Bar .Workspaces {
  background: rgba(0, 0, 0, 0.06);
}
window.Bar .WorkspaceButton.laptop {
  background: rgba(60, 100, 220, 0.10);
}
window.Bar .WorkspaceButton.laptop.focused {
  background: rgba(60, 100, 220, 0.25);
}
window.Bar .StatusIcon.Screenshare {
  color: #cc0000;
}
window.Bar .StatusIcon.Camera {
  color: #cc0000;
}
.ScreenPicker > contents {
  background: #ffffff;
  border: 1px solid #ece8e0;
  box-shadow: 0 18px 44px -10px rgba(20, 20, 40, 0.38);
}
.ScreenPicker .ScreenPickerHeader {
  color: #a7a299;
}
.ScreenPicker .ScreenRow {
  background: #f6f6f9;
  border-color: #e7e7ea;
}
.ScreenPicker .ScreenModel {
  color: #2d2d35;
}
.ScreenPicker .ScreenSpec {
  color: #8a857c;
}
.ScreenPicker .ConnectorTag {
  color: #b3aea4;
}
.DisplaysPopover .DisplaysHeader label,
.DisplaysPopover .ResolutionHeader {
  color: #a7a299;
}
.DisplaysPopover .DisplayCard {
  background: #f6f6f9;
  border-color: #e7e7ea;
}
.DisplaysPopover .DisplayModel {
  color: #2d2d35;
}
.DisplaysPopover .DisplaySpec {
  color: #5f5b54;
}
.DisplaysPopover .DisplayScale,
.DisplaysPopover .DisplayState,
.DisplaysPopover .ConnectorTag,
.DisplaysPopover .DisplayPos {
  color: #8a857c;
}
.DisplaysPopover .ResolutionRow {
  color: #3a3a42;
}
.DisplaysPopover .ResolutionRow:hover {
  background: rgba(0, 0, 0, 0.07);
}
.DisplaysPopover .ResolutionRow .ResolutionRate {
  color: #8a857c;
}
.DisplaysPopover .NativeTag {
  color: #2e8b57;
}
.DisplaysPopover .ScaleWarn {
  color: #a86412;
}
.DisplaysPopover .ActionSmall {
  color: #3a3a42;
  background: rgba(0, 0, 0, 0.06);
}
.DisplaysPopover .ActionSmall:hover {
  background: rgba(0, 0, 0, 0.12);
}
`

export function getThemeCss(isDark: boolean): string {
  return isDark ? dark : light
}
