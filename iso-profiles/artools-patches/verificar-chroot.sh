#!/bin/bash
# Z-Linux: verifica el chroot livefs tras `buildiso -x` (errores.md A01-A26).
# Uso en el builder: sudo ./verificar-chroot.sh /var/lib/artools/buildiso/zlinux/artix/livefs
# Codigo de salida = nº de fallos (0 = todo ok).
M="${1:?ruta del chroot livefs como argumento}"
fail=0
t(){ if eval "$2" >/dev/null 2>&1; then echo "OK    $1"; else echo "FALLO $1"; fail=$((fail+1)); fi; }

echo "== chroot: $M"
t "A01/A02 sin libsystemd linkado" \
  "! grep -rl 'libsystemd\.so\.0' $M/usr/lib $M/usr/bin $M/bin $M/sbin 2>/dev/null | grep -q ."
t "A01/A02 IgnorePkg de 21 en pacman.conf" \
  "grep -E '^IgnorePkg' $M/etc/pacman.conf | grep -q libassuan"
t "A03 home live es de zlinux" \
  "[ \"\$(stat -c %u:%g $M/home/zlinux)\" = 1000:1000 ]"
t "A03 .cache/.local creables (home escribible)" \
  "[ -w $M/home/zlinux ]"
t "A03b .cache/.local de esqueleto (skel y home live)" \
  "[ -d $M/etc/skel/.cache ] && [ -d $M/etc/skel/.local/share ] && [ -d $M/home/zlinux/.cache ] && [ -d $M/home/zlinux/.local/share ]"
t "A04 keyring cachyos pre-poblado (sin z-locales en vivo)" \
  "pacman -r $M -Q cachyos-keyring >/dev/null && [ -d $M/etc/pacman.d/gnupg ]"
t "A05 live sin z-locales (solo-lectura, locales precompilados)" \
  "[ ! -e $M/etc/dinit.d/z-locales ] && [ ! -e $M/usr/local/bin/z-locales-once ]"
t "A05b locales precompilados (locale-archive)" \
  "[ -f $M/usr/lib/locale/locale-archive ]"
t "A06 locale.conf valido" \
  "grep -q '^LANG=es_ES.UTF-8\$' $M/etc/locale.conf"
t "A07 sudoers.d sera 0440 en runtime (nota, viene 644 de git)" \
  "[ -f $M/etc/sudoers.d/g_wheel ]"
t "A08 zlinux en grupo seat" \
  "grep -E '^seat:' $M/etc/group | grep -q zlinux"
t "targets /etc/dinit.d/user existen" \
  "[ -e $M/etc/dinit.d/user/pipewire ] && [ -e $M/etc/dinit.d/user/wireplumber ] && [ -e $M/etc/dinit.d/user/pipewire-pulse ] && [ -e $M/etc/dinit.d/user/dbus ]"
t "A12 mirrorlists at.* primero" \
  "head -3 $M/etc/pacman.d/cachyos-v3-mirrorlist | grep -q at.cachyos.org"
t "A14 mkinitcpio sin autodetect" \
  "! grep -E '^HOOKS=' $M/etc/mkinitcpio.conf | grep -q autodetect"
t "A16 memtest viaja en el chroot" \
  "[ -f $M/boot/memtest86+/memtest.bin ]"
t "A18 pkgs nuevos instalados" \
  "pacman -r $M -Q rtkit tumbler alsa-utils mesa-utils vulkan-tools ffmpegthumbnailer poppler-glib cups power-profiles-daemon pipewire-pulse-dinit"
t "A19 servicios cupsd+power habilitados" \
  "[ -L $M/etc/dinit.d/boot.d/cupsd ] && [ -L $M/etc/dinit.d/boot.d/power-profiles-daemon ]"
t "A21 via .bash_profile en skel" \
  "[ -f $M/etc/skel/.bash_profile ]"
t "A22 links pipewire/wireplumber en skel resuelven" \
  "[ -e $M/etc/skel/.config/dinit.d/boot.d/pipewire ] && [ -e $M/etc/skel/.config/dinit.d/boot.d/wireplumber ]"
t "user-services dbus/pipewire*/wireplumber en home live" \
  "[ -L $M/home/zlinux/.config/dinit.d/boot.d/dbus ] && [ -L $M/home/zlinux/.config/dinit.d/boot.d/pipewire ]"
t "targets /etc/dinit.d/user existen" \
  "[ -e $M/etc/dinit.d/user/pipewire ] && [ -e $M/etc/dinit.d/user/wireplumber ]"
t "kernel bore instalado" \
  "ls $M/boot/vmlinuz-linux-cachyos-bore >/dev/null"
t "os-release Z-Linux" \
  "grep -q '^ID=zlinux\$' $M/etc/os-release"
t "issue Z-Linux" \
  "grep -q 'Z-Linux' $M/etc/issue $M/etc/issue.live"
t "modulo DRM bochs presente (nombre real: bochs, no bochs_drm)" \
  "find $M/usr/lib/modules -iname '*bochs*' | grep -q ."

echo "== fallos: $fail"
exit $fail
