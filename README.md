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

<img width="1920" height="1080" alt="2026-08-28-144926_hyprshot" src="https://github.com/user-attachments/assets/d0663bbe-4f9b-4b38-8c38-be08d4764e0b" />
<img width="1919" height="1080" alt="2026-08-28-144853_hyprshot" src="https://github.com/user-attachments/assets/78713912-0407-42fd-b984-189a4149616b" />

https://github.com/user-attachments/assets/0b027259-d450-432e-b0cf-901f3ae2c2b4

