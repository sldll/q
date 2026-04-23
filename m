#!/bin/bash
read -p "WIPE DISK...?"
read -p "THIS SCRIPT WIPES DISK..."
sgdisk -Z /dev/nvme0n1
sgdisk -n 0::+512M -n 0::+80G /dev/nvme0n1
mkfs.fat /dev/nvme0n1p1
mkfs.ext4 -f /dev/nvme0n1p2
mount /dev/nvme0n1p2 /mnt
mount -m /dev/nvme0n1p1 /mnt/boot
pacstrap -KP /mnt base networkmanager sudo vi vim alacritty inetutils exfatprogs ntfs-3g ripgrep jq bc less eza bat fzf zoxide acpi net-tools zip unzip brightnessctl playerctl fuzzel firefox firefox-ublock-origin btop niri wl-clipboard linux linux-firmware-intel
efibootmgr -c -d "/dev/nvme0n1" -p 1 -l '\vmlinuz-linux' -u "root=/dev/nvme0n1p2 rw initrd=\initramfs-linux.img"
arch-chroot /mnt bash <<😈
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
cat <<EOF > /etc/bash.bashrc
source <(fzf --bash)
source <(zoxide init bash)
EOF
systemctl enable NetworkManager fstrim.timer
echo
echo "💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀💀"
echo
😈
arch-chroot /mnt
