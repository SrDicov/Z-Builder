#!/bin/sh
# ZRAM Z Linux: nunca falla el arranque (exit 0 siempre)
modprobe zram num_devices=1 2>/dev/null || true
i=0; while [ $i -lt 40 ]; do [ -e /sys/block/zram0/disksize ] && break; sleep 0.2; i=$((i+1)); done
[ -e /sys/block/zram0/disksize ] || exit 0
if [ -e /dev/zram0 ]; then swapoff /dev/zram0 2>/dev/null || true; fi
if grep -q zstd /sys/block/zram0/comp_algorithm 2>/dev/null; then
  echo zstd > /sys/block/zram0/comp_algorithm 2>/dev/null || true
fi
RAM_KB=$(awk "/MemTotal/ {print \$2}" /proc/meminfo 2>/dev/null || echo 0)
[ "$RAM_KB" -gt 0 ] 2>/dev/null || exit 0
echo "$((RAM_KB * 1024 / 2))" > /sys/block/zram0/disksize 2>/dev/null || exit 0
mkswap /dev/zram0 >/dev/null 2>&1 || exit 0
swapon -p 100 /dev/zram0 2>/dev/null || exit 0
