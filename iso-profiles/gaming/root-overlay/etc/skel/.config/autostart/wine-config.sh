#!/bin/sh

cd ${WINEPREFIX:-~/.wine}/drive_c/windows/Fonts && for i in /usr/share/fonts/**/*.{ttf,otf}; do ln -s "$i"; done
[ $(hostname) = 'artix-live' ] || {
    winetricks fontsmooth=rgb
#    winetricks gmdls dsound directmusic   # if no timidity
}

rm -f ~/.config/autostart/wine-config.*
