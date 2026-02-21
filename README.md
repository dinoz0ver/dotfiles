# dotfiles

Hyprland rice shared between PC (`dumbpc`) and laptop.

Uses a bare git repo — no extra tools needed.

## Install on a new machine

```bash
git clone --bare https://github.com/dinoz0ver/dotfiles.git $HOME/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dotfiles config status.showUntrackedFiles no
dotfiles checkout
```

If checkout fails due to existing files, back them up or remove them and retry.

## Set up host-specific configs

```bash
# hyprland (monitors, devices, input)
ln -sf hosts/laptop.conf ~/.config/hypr/host.conf

# hyprlock (primary monitor variable)
ln -sf hosts/laptop-lock.conf ~/.config/hypr/host-lock.conf

# hypridle
ln -sf hosts/laptop-idle.conf ~/.config/hypr/hypridle.conf
```

Edit `~/.config/hypr/hosts/laptop.conf` — run `hyprctl monitors` to get your monitor name.

## Enable services

```bash
systemctl --user enable --now qs.service
systemctl --user enable --now grub-check.timer
```

## Apply colorscheme

```bash
wal -i /path/to/wallpaper
bash ~/Scripts/pywal16.sh
```
