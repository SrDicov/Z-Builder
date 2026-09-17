#!/bin/bash
# Z-Linux: re-aplica los parches artools tras instalar/actualizar artools-iso.
# Uso (en el builder, como root): ./aplicar-parches.sh
# Idempotente: cada parche tiene un marcador; si ya esta aplicado, se salta.
set -u
D="$(cd "$(dirname "$0")" && pwd)"
fails=0

pacman -Q artools-iso >/dev/null 2>&1 || { echo "ERROR: artools-iso no instalado"; exit 1; }
mkdir -p /usr/share/artools/zlinux   # destino del payload (parche 0006)

apply() { # $1=parche $2=fichero-destino $3=marcador-grep
    local p="$D/$1" f="$2" mark="$3"
    if grep -q "$mark" "$f" 2>/dev/null; then
        echo "   ya aplicado, salto: $1"
        return 0
    fi
    echo "== aplicando $1"
    if patch -p1 -d / --forward --silent --input="$p"; then
        echo "   ok"
    else
        # --forward falla si un hunk ya estaba aplicado (upgrade 0004 con
        # comentarios viejos). Si el marcador ya aparece tras el intento,
        # consideramos que el parche quedo funcional.
        if grep -q "$mark" "$f" 2>/dev/null; then
            echo "   ok (actualizado, hunks previos ya aplicados)"
        else
            echo "   FALLO (¿artools nuevo? portar a mano y regenerar)"
            fails=$((fails+1))
        fi
    fi
}

apply 0001-limine-total-prepare.patch  /usr/share/artools/lib/iso/grub.sh     'interface_branding: Z-Linux'
apply 0002-buildiso-limine-label.patch /usr/bin/buildiso                      'ZLINUX_$(date'
apply 0003-iso-el-torito-limine.patch  /usr/share/artools/lib/iso/iso.sh      'limine-bios-cd.bin'
apply 0004-configure-user-zlinux.patch /usr/share/artools/lib/iso/config.sh   'configure_zlinux'
apply 0005-initcpio-ventoy-hook.patch  /usr/share/artools/lib/iso/initcpio.sh 'ZLINUX-VENTOY'
apply 0006-newfiles-zlinux-payload.patch /usr/share/artools/zlinux/artix-hook-ventoy.diff 'ZLINUX-VENTOY'
apply 0007-user-svc-ln-force.patch /usr/share/artools/lib/iso/services.sh 'ln -sfn /etc/dinit.d/"$svc" /etc/dinit.d/boot.d/'

echo "== sintaxis"
for f in /usr/bin/buildiso /usr/share/artools/lib/iso/*.sh; do bash -n "$f" || { echo "SYNTAX FAIL: $f"; fails=$((fails+1)); }; done
echo "bash -n: ok"

[[ $fails -eq 0 ]] && echo "TODO OK" || { echo "FALLOS: $fails"; exit 1; }
