#!/bin/bash

# Remove unconfigured sessions
rm -f /usr/share/{wayland-,x}sessions/{openbox,kodi*,plasma*}.desktop
sed -i 's/^display-setup-script/#display-setup-scipt/' /etc/lightdm/lightdm.conf

rm -f $0
