# Z-Builder — builder CI para Z-Linux (Artix + CachyOS v3, Labwc/Noctalia, dinit, Limine)

Repo separado para compilar la ISO en GitHub Actions y cachear `pacman`. La definición real del sistema vive en `iso-profiles/zlinux/` (profile, live-overlay, root-overlay, artools-patches).

## Workflow
- `build.yml` corre `buildiso -p zlinux -i dinit` en contenedor `artixlinux/artix --privileged`
- Caché: `/var/cache/pacman/pkg` (key por `zlinux/profile.yaml` + `common/`), evita re-descargar ~4G Cachy
- Artefacto: `zlinux-dinit-*.iso` + `SHA256SUMS` + `MANIFEST.sha256`

## Local (tu Void, builder VM)
```bash
./lanzar-z-builder.sh          # qemu:///session o qemu directo en Dicov
ssh z-builder
cd ~/artools-workspace/iso-profiles && git log --oneline -3
sudo ./artools-patches/aplicar-parches.sh
sudo buildiso -p zlinux -i dinit -x   # chroot only
sudo ./artools-patches/verificar-chroot.sh /var/lib/artools/buildiso/zlinux/dinit/livefs
sudo buildiso -p zlinux -i dinit      # ISO completa → ~/artools-workspace/iso/zlinux/
```

Ver `AGENTS.md` y `errores.md` en el repo original para quirks (x86_64_v3, limine total, dinit seat, etc.).
