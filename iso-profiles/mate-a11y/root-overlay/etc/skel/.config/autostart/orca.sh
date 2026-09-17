:

xprop -root -remove AT_SPI_BUS
/usr/lib/at-spi-bus-launcher --a11y=1 --screen-reader=1 &
/usr/lib/at-spi2-registryd --use-gnome-session &
orca &
