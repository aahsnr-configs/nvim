#!/bin/sh

sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf config-manager --enable fedora-cisco-openh264

sudo dnf copr enable solopasha/hyprland
sudo dnf copr enable sneexy/zen-browser
sudo dnf copr enable lukenukem/asus-linux
sudo dnf copr enable errornointernet/quickshell 
sudo dnf update

sudo dnf install -y dnf-automatic cargo copr-selinux dnf-plugins-core fedora-workstation-repositories flatpak gnome-keyring kernel kernel-core kernel-devel kernel-devel-matched kernel-modules kernel-modules-core kernel-modules-extra plymouth-theme-spinner poppler-utils ImageMagick tar unzip aide arpwatch chrony cronie curl fail2ban fdupes PackageKit-command-not-found p7zip psacct rng-tools sysstat wget neovim python3-neovim tree-sitter wl-clipboard deluge-qt ark zen-browser kitty zathura zathura-zsh-completion zathura-pdf-poppler papirus-icon-theme gnome-themes-extra gtk-murrine-engine sassc vulkan xorg-x11-drv-nvidia-cuda-libs nvidia-vaapi-driver libva-utils vdpauinfo autoconf automake binutils bison ccache cmake ctags elfutils flex go gcc gcc-c++ gdb libtool make perf pkgconf strace meson ninja-build setroubleshoot system-config-language alsa-utils pipewire pipewire-alsa pipewire-gstreamer pipewire-pulseaudio pipewire-utils pulseaudio-utils wireplumber egl-wayland greetd pyprland xisxwayland  asusctl power-profiles-daemon supergfxctl asusctl-rog-gui NetworkManager-tui bluez --allowerasing


sudo systemctl enable supergfxd.service power-profiles-daemon

sudo systemctl set-default graphical.target
systemctl --user enable --now wireplumber.service pipewire-pulse.socket pipewire.socket pipewire-pulse.service pipewire.service

