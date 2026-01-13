# Nix, NixOS and Home Manager for mipmip's machine park

This is my mono-repository for my machines configuration and my dotfiles.

## Features

- multi machine
- flakes
- Custom patched Suckless Terminal (st)

## Usage

clone:

```
cd ~
git clone git@github.com:mipmip/mipnix.git
```

nixos-rebuild:

```
./RUNME.sh up_machine
```

Home Manager:

```
./RUNME.sh up_home
```

### Add Agenix file

1. add file registration in secrets/secrets.nix
2. cd secrets
3. create file or edit file `agenix -e aws-credentials-copy.age`
4. add file purpose to modules/nix-agenix.nix

example: `agenix -i ~/.ssh/id_ed25519 -e aws-credentials-copy.age`

## Features

### Linux Desktop Highlights

I use GNOME as desktop environment with a few extensions to give me some
features I'm used too from the time I used macOS as primary OS.

# Pine Phone Pesto

## Build Image

Build from any nix machine with:

```sh
nix build './#pinephone-img'
```

If nix complains about some "experimental features", then add to the host's nix
config: `nix.extraOptions = "experimental-features = nix-command flakes";`

flash with:
```sh
sudo dd if=$(readlink result) of=/dev/sdb bs=4M oflag=direct conv=sync status=progress
```

Then insert the SD card, battery into your pinephone and hold the power button
for a few seconds until the power LED turns red. after releasing the power
button, the LED should turn yellow, then green. you'll see the "mobile NixOS"
splash screen and then be dropped into a TTY login prompt.


## Update with copy-closure

build on host machine

```
nix build .\#nixosConfigurations.pinephone.config.system.build.toplevel --print-out-paths
```

copy to pinephone

```
nix-copy-closure --to root@192.168.13.103 ./result
```

on pinephone 

```
/nix/store/nid92px7zybggpxh5j6bwzcpmjh10p8h-nixos-system-nixos-22.05.20220520.dfd8298/bin/switch-to-configuration switch
```

# Nix-on-Droid (fairPhone)

## Setup nix-on-droid

ln -s ~/nixos/nix-on-droid ~/.config/

## Apply nix config

nix-on-droid switch -F ~/.config/nix-on-droid/flake.nix

## SSH Connect

ssh nix-on-droid@xxxxx -p8022
