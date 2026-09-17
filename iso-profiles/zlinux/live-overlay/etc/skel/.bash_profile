if [[ "$(tty)" == "/dev/tty1" ]]; then
  export XDG_RUNTIME_DIR=/run/user/$(id -u)
  if ls /dev/dri/card* >/dev/null 2>&1; then
    exec labwc >/tmp/labwc-tty1.log 2>&1
  else
    echo "Z Linux: sin GPU DRM (/dev/dri/card* ausente), escritorio no iniciado."
  fi
fi
