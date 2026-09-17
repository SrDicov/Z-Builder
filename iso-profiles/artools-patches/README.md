# artools-patches — Z-Linux

`artools-iso` es de Artix (GRUB). Z-Linux lo parchea para **Limine total** y
detalles live. Estos parches viven en `/usr` del builder y se **pierden con
cada upgrade de artools**: tras `pacman -S artools-iso`, re-aplicar con:

```bash
sudo ./aplicar-parches.sh
```

Serie (orden de aplicación, formato `patch -p1 -d /`):

| Parche | Fichero | Qué hace |
|---|---|---|
| `0001-limine-total-prepare.patch` | `lib/iso/grub.sh` | `prepare_limine()`: menú tematizado Z-Linux (splash, submenu, memtest, `zswap.enabled=0`) |
| `0002-buildiso-limine-label.patch` | `bin/buildiso` | `make_grub()`→limine, etiqueta `ZLINUX_AAAAMM`, ISO sin prefijo `artix`, marcador `.zlinux` |
| `0003-iso-el-torito-limine.patch` | `lib/iso/iso.sh` | El Torito con `limine-bios-cd.bin` (sin `--grub2-boot-info`) |
| `0004-configure-user-zlinux.patch` | `lib/iso/config.sh` | grupo `seat` + `chown` home live (A03/A08) + `locale-gen` + `configure_zlinux` (sudoers 0440, keyring pre-poblado A04, live 100% solo-lectura A05) |
| `0005-initcpio-ventoy-hook.patch` | `lib/iso/initcpio.sh` | fallback versión kernel + inyección del fix Ventoy (B01) |
| `0006-newfiles-zlinux-payload.patch` | `share/artools/zlinux/*` | payload: diff del hook `artix` del initramfs (fallback `/dev/mapper/ventoy`) |
| `0007-user-svc-ln-force.patch` | `lib/iso/services.sh` | `ln -sfn` en user-services dinit (skel trae copias fijas, A22) |

Generados contra `artools-iso 0.39.1-1`. Si un hunk falla con otra versión,
portar el bloque `ZLINUX*` a mano y regenerar con `diff -u`.
