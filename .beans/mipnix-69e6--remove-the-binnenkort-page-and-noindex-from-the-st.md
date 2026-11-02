---
# mipnix-69e6
title: remove the binnenkort page and noindex from the studio-mint.shop apex
status: scrapped
type: task
priority: normal
created_at: 2026-10-16T15:40:06Z
updated_at: 2026-11-02T17:10:35Z
---

The apex repo `mintglasinlood/studio-mint.shop` currently holds a landing page
that says "binnenkort" and carries:

    <meta name="robots" content="noindex">

That is right while the real shop is not there yet, and wrong the moment it is.
Nothing in `restructure-studio-mint-hosting` changes it, and nothing else tracks
it, which is why this exists.

When the real apex site lands:

- drop the `noindex`, or search engines keep ignoring the shop
- replace the "binnenkort" copy
- check whether `site.webmanifest` and the icons still describe the new site

Deploying the change is `nix flake update studio-mint-apex` followed by
`rme deploy_remote durer`, because the repo has no flake of its own and mipnix
pins it by revision.
