## 1. Client-level reactivity

- [x] 1.1 Add `client-added`, `client-removed`, and `client-moved` signal handlers on the Hyprland singleton in `Workspaces.tsx`
- [x] 1.2 Introduce a `createState` to hold the derived workspace items, refreshed on each client signal and workspace change
- [x] 1.3 Derive the workspace items list reactively so it recomputes on any client or workspace change

## 2. App icon rendering

- [x] 2.1 Extract all clients per workspace (one icon per window, no deduplication)
- [x] 2.2 Render `<image iconName={client.class} />` for each client inside the workspace button, alongside the workspace ID label
- [x] 2.3 Add fallback to `application-x-executable` when a client class is empty

## 3. Tooltip

- [x] 3.1 Set `tooltipText` on each individual `<image>` icon with that window's `client.title`

## 4. Styling

- [x] 4.1 Add CSS for app icons within workspace buttons (size, spacing, vertical alignment)
- [x] 4.2 Ensure workspace buttons grow gracefully with multiple icons while maintaining visual consistency with the bar
