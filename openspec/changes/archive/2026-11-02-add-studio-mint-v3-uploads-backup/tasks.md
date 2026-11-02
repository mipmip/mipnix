# Tasks

Schema: tinychange (https://github.com/speclib/openspec-tinychange-schema)

v3 now stores uploaded images in `/var/lib/studio-mint-v3/uploads` (v3 change `media-storage`). The database refers to them by directory, so they belong in the same snapshot as the dump.

## 1. Implementation

- [x] 1.1 Add `/var/lib/studio-mint-v3/uploads` to the paths of `durer-studio-mint-v3` in `modules/HOSTS/durer-server/configuration.nix`, and bump the `studio-mint-v3` input to the release with media storage

## 2. Verification

- [x] 2.1 Verify the durer closure builds, deploy with `rme deploy_remote durer`, and check that `/var/lib/studio-mint-v3/uploads` exists with mode 0750, that `https://v3.studio-mint.shop/media/does-not-exist.webp` answers 404 from nginx, and that a manual run of the backup saves a snapshot that includes the uploads path
