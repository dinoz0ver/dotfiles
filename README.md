# dotfiles

my hyprland rice is made with quickshell.
uses a bare git repo.

## install on a new machine

```bash
git clone --bare https://github.com/dinoz0ver/dotfiles.git $HOME/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dotfiles config status.showUntrackedFiles no
dotfiles checkout
```

## set up host-specific configs

```bash
# hyprland (monitors, devices, input)
ln -sf hosts/laptop.conf ~/.config/hypr/host.conf

# hyprlock (primary monitor variable)
ln -sf hosts/laptop-lock.conf ~/.config/hypr/host-lock.conf

# hypridle
ln -sf hosts/laptop-idle.conf ~/.config/hypr/hypridle.conf
```

edit `~/.config/hypr/hosts/laptop.conf` — run `hyprctl monitors` to get your monitor name.

## enable services

```bash
systemctl --user enable --now qs.service
systemctl --user enable --now grub-check.timer
```

## apply colorscheme and set wallpaper

```bash
./Scripts/wallpapermenu.sh
```
