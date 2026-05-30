#!/bin/bash

sleep 0.2

read -p "WIPE DISK...?"
read -p "THIS SCRIPT WIPES DISK..."

#AUDIO

#pactl set-card-profile  alsa_card.pci-0000_00_03.0  output:hdmi-stereo
#pactl set-default-sink alsa_output.pci-0000_00_03.0.hdmi-stereo
#pactl set-card-profile   alsa_card.pci-0000_00_1b.0  output:analog-stereo
#pactl set-default-sink alsa_output.pci-0000_00_1b.0.analog-stereo

#AUDIO-END

#TV

#atheros
#output eDP-1 resolution 1366x768 position 0 0
#output HDMI-A-2 resolution 1280x720 position 1280 0
#idle off
#bluetooth on

#TV-END

#CHROOT

#sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
#sed -i 's/^#nl_NL.UTF-8 UTF-8/nl_NL.UTF-8 UTF-8/' /etc/locale.gen
#locale-gen
#echo -e "LANG=en_US.UTF-8\nLC_TIME=nl_NL.UTF-8\nLC_MONETARY=nl_NL.UTF-8" > /etc/locale.conf

#sed -i '/Docked/c\HandleLidSwitchDocked=suspend' /etc/systemd/logind.conf

#cat << 'EOF' > /etc/sysctl.d/99-custom.conf
#fs.suid_dumpable=0
#kernel.kptr_restrict=2
#kernel.kexec_load_disabled=1
#kernel.unprivileged_bpf_disabled=1
#net.core.bpf_jit_harden=2
#kernel.dmesg_restrict=1
#kernel.yama.ptrace_scope=2
#vm.mmap_rnd_bits=32
#vm.mmap_rnd_compat_bits=16
#EOF

#mkdir -p /etc/systemd/coredump.conf.d/
#echo -e "[Coredump]\nStorage=none\nProcessSizeMax=0" > /etc/systemd/coredump.conf.d/custom.conf
#echo "[Coredump]" >> /etc/systemd/coredump.conf.d/custom.conf
#echo "Storage=none" >> /etc/systemd/coredump.conf.d/custom.conf
#echo "ProcessSizeMax=0" >> /etc/systemd/coredump.conf.d/custom.conf

#sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect microcode modconf keyboard block encrypt filesystems)/' /etc/mkinitcpio.conf

#--unicode 'root=/dev/nvme0n1p2 rw initrd=\initramfs-linux.img'

#CHROOT-END

sgdisk -Z /dev/nvme0n1
#sgdisk -Z /dev/sda

#sgdisk -n 1::+500M -t 1:EF00 -c 1:"EFI" /dev/nvme0n1
#sgdisk -n 2::+80G  -t 2:8300 -c 2:"ROOT" /dev/nvme0n1
sgdisk -n 0::+512M -n 0:: /dev/nvme0n1
#sgdisk -n 0::+512M -n 0:: /dev/sda

reflector \
	-c "NL" \
	-p https \
	--age 4 \
	--latest 15 \
	--save /etc/pacman.d/mirrorlist

sed -i 's/#Color/Color\nILoveCandy/' /etc/pacman.conf
#sed -i 's/^SigLevel.*/SigLevel = Never/' /etc/pacman.conf

#cryptsetup luksFormat \
#	--type luks2 \
#	--cipher aes-xts-plain64 \
#	--key-size 512 \
#	--hash sha512 \
#	--pbkdf argon2id \
#	--pbkdf-memory 2097152 \
#	--pbkdf-parallel 4 \
#	--pbkdf-force-iterations 6 \
#	--batch-mode /dev/nvme0n1p2
cryptsetup luksFormat --batch-mode /dev/nvme0n1p2
#cryptsetup luksFormat --batch-mode /dev/sda2
#cryptsetup open /dev/sda2 ct
cryptsetup open /dev/nvme0n1p2 ct

#mkfs.fat /dev/sda1
mkfs.fat /dev/nvme0n1p1
#mkfs.ext4 /dev/nvme0n1p2
mkfs.ext4 /dev/mapper/ct

mount /dev/mapper/ct /mnt
mount -o umask=0077 -m /dev/nvme0n1p1 /mnt/boot
#mount -o umask=0077 -m /dev/sda1 /mnt/boot

fallocate -l 8G /mnt/sf
chmod 600 /mnt/sf
mkswap /mnt/sf
swapon -p 10 /mnt/sf

mkdir -p /mnt/etc/mkinitcpio.conf.d/
cat > /mnt/etc/mkinitcpio.conf.d/c.conf <<😈
HOOKS=(base udev autodetect microcode modconf keyboard block encrypt filesystems)
😈

pacstrap -KP /mnt base
#pacstrap -KP /mnt base base-devel networkmanager sudo vi vim alacritty ttf-nerd-fonts-symbols noto-fonts-emoji terminus-font caja mako openssh inetutils git ripgrep jq bc less eza bat fzf zoxide acpi net-tools zip unzip zram-generator intel-media-driver vulkan-intel intel-gmmlib pipewire pipewire-alsa pipewire-jack pipewire-pulse otf-font-awesome ttf-terminus-nerd terminus-font noto-fonts-emoji brightnessctl playerctl rofi fuzzel firefox firefox-ublock-origin chromium btop mousepad man tldr imagemagick swaylock niri gammastep wl-clipboard linux linux-firmware-intel intel-ucode
#pacstrap -KP /mnt base networkmanager sudo vi vim alacritty ttf-nerd-fonts-symbols noto-fonts-emoji terminus-font mako openssh inetutils exfatprogs ripgrep jq bc less eza bat fzf zoxide net-tools zram-generator intel-media-driver vulkan-intel intel-gmmlib pipewire pipewire-alsa pipewire-jack pipewire-pulse brightnessctl playerctl rofi fuzzel waybar chromium firefox firefox-ublock-origin btop mousepad flatpak swaylock niri wl-clipboard linux linux-firmware-intel linux-firmware-atheros intel-ucode

genfstab -U /mnt >> /mnt/etc/fstab

efibootmgr \
	--create \
	--disk "/dev/nvme0n1" \
	--part 1 \
	--loader '\vmlinuz-linux' \
	--unicode "cryptdevice=/dev/nvme0n1p2:ct root=/dev/mapper/ct rw initrd=\initramfs-linux.img"
#efibootmgr -c -d "/dev/nvme0n1" -p 1 -l "\vmlinuz-linux" -u "cryptdevice=/dev/nvme0n1p2:ct root=/dev/mapper/ct rw initrd=\initramfs-linux.img"
#efibootmgr -c -d "/dev/sda" -p 1 -l "\vmlinuz-linux" -u "cryptdevice=/dev/sda2:ct root=/dev/mapper/ct rw initrd=\initramfs-linux.img"

arch-chroot /mnt bash <<😈

pacman -Sy --noconfirm mkinitcpio

curl -LO https://github.com/sldll/q/raw/main/p
grep -v '^\s*#' p | pacman -S --needed --noconfirm -

sed -i 's/fmask=0077/noauto,fmask=0077/' /etc/fstab
sed -i '/\bext4\b/ s/\brelatime\b/noatime/g' /etc/fstab

echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
echo "vm.swappiness=10" >> /etc/sysctl.d/99-swappiness.conf

cat << 'EOF' > /etc/systemd/zram-generator.conf

[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF

cat <<EOF > /etc/bash.bashrc
source <(fzf --bash)
source <(zoxide init bash)
EOF

echo "hostnamelol" >> /etc/hostname

ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc

systemctl enable NetworkManager fstrim.timer

echo
echo "💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀"
echo
😈
arch-chroot /mnt
