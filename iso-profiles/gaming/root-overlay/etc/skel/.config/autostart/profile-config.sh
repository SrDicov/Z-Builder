#!/bin/sh

[ $(hostname) != 'artix-live' ] && {
    cd /usr/share/applications/
    cp com.heroicgameslauncher.hgl.desktop net.lutris.Lutris.desktop steam.desktop ~/Desktop
    chmod +x ~/Desktop/*.desktop
    for conf in ~/.dosbox/*.conf; do sed -i 's/^midiconfig=.*/midiconfig=128:0/' $conf; done
}

rm -f ~/.config/autostart/profile-config.*
