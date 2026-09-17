#!/bin/bash

yaml_array() {
    local array

    for entry in "$@"; do
        array="${array:-}${array:+,} ${entry}"
    done
    printf "%s\n" "[${array}]"
}

read_from_list() {
    local list="$1"
    local _space="s| ||g"
    local _clean='/^$/d'
    local _com_rm="s|#.*||g"
    mapfile -t pkgs < <(sed "$_com_rm" "$list" \
            | sed "$_space" \
            | sed "$_clean" | sort -u)
}

profiles=(
    cinnamon
    community-gtk
    community-qt
    lxde
    lxqt
    mate
    xfce
    moksha
)

cd ..

for p in "${profiles[@]}"; do

    if [[ -f "$p"/profile.conf ]]; then

        cp -v common/profile.yaml.template "$p"/profile.yaml

        . "$p"/profile.conf

        sv="$(yaml_array ${SERVICES[@]})"
        auto="$AUTOLOGIN" \
        sv="$sv" \
        yq -P '
            with(
            .live-session;
                .services = env(sv) |
                .autologin = env(auto))' -i "$p"/profile.yaml

    fi

    if [[ -e "$p"/Packages-Root ]]; then
        read_from_list "$p"/Packages-Root
        p="$(yaml_array ${pkgs[@]})" \
        yq -P '.rootfs.packages = env(p)' -i "$p"/profile.yaml

    fi

    if [[ -e "$p"/Packages-Live ]]; then
        read_from_list "$p"/Packages-Live
        p="$(yaml_array ${pkgs[@]})" \
        yq -P '.livefs.packages = env(p)' -i "$p"/profile.yaml
    fi

    # git add "$p"
    # git commit -m "yamilize profiles"
done
