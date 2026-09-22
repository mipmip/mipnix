---
# mipnix-i4oy
title: replace hyprland screenshot with grim/slurp/satty
status: draft
type: feature
priority: normal
created_at: 2026-09-22T21:19:00Z
updated_at: 2026-09-22T21:20:00Z
---

Use this for region capture but adapt fo my filestructure and include the current notification or make an alternative mathod 

 grim -g "$(slurp)" -t ppm - | satty --filename - --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png
