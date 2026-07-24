# meta-tegra210-mainline

A **headless, mainline-kernel** BSP layer for the NVIDIA Jetson Nano (Tegra210 /
Tegra X1) on Yocto **wrynose (6.0)**.

This layer exists to run a **modern wrynose userspace** on the Jetson Nano when
you do **not** need the NVIDIA stack. It deliberately avoids `meta-tegra` and the
end-of-life L4T R32.7.x binaries.

## What you get / don't get

| Works | Does **not** work |
|-------|-------------------|
| Mainline kernel (linux-yocto 6.x) | ❌ CUDA / TensorRT (needs the proprietary L4T driver, kernel-4.9-only) |
| Full wrynose package feed / your deps | ❌ GPU 3D acceleration (nouveau not enabled here) |
| Serial console, SD/eMMC, USB | ❌ Hardware video decode/encode (NVDEC/NVENC) |
| On-board GbE *(verify — see kernel fragment)* or USB-ethernet | |
| systemd, SSH, containers | |

If you need CUDA or GPU, this layer is the wrong tool — stay on
`meta-tegra` `kirkstone-l4t-r32.7.x`, which is the only combination where the
Tegra210 GPU stack works.

## Boot model (important)

```
BootROM ──▶ NVIDIA early firmware (mb1 / BPMP / TOS / cboot) ──▶ U-Boot ──▶ extlinux ──▶ mainline kernel
            └─ flashed ONCE to SPI/boot partitions, host-side ─┘        └─ this layer's SD image ─┘
```

The low-level NVIDIA firmware is **firmware, not userspace** — it has no
glibc/libstdc++ ABI coupling, so it coexists with a wrynose rootfs. You flash it
(plus U-Boot) to the board **once**; after that every kernel/rootfs update is
just re-writing the microSD.

### One-time firmware flash

Use NVIDIA's L4T R32.7.x flashing package (or the U-Boot you already built in the
kirkstone image) to write the boot chain to the Nano's SPI/boot partitions:

```
# from the L4T Linux_for_Tegra/ directory, Nano in recovery mode (USB)
sudo ./flash.sh p3450-0000 mmcblk0p1
```

You only need this to install U-Boot + early firmware. From then on, U-Boot's
`extlinux` distro-boot loads the kernel from the microSD produced by this layer.

## Building (EmbedForge / bitbake)

- `MACHINE = "p3450-mainline"`  (the Nano's carrier part number; named to stay
  clear of tooling that auto-attaches the L4T `meta-tegra` BSP for `jetson*`/`nano`
  machine names — this path deliberately does not use meta-tegra)
- Layers: this layer + poky (openembedded-core, meta-poky, meta-yocto-bsp).
  Add `meta-openembedded` (meta-oe/meta-python/meta-networking) if your packages
  need it.
- Image: `core-image-base` (or your own image) + your packages.
- Output: `*.wic` / `*.wic.bmap` — write to the microSD with `bmaptool`/`dd`.

## Status: bring-up scaffold

This is a **starting point**, not a turnkey BSP. The two things expected to need
iteration against the first boot log:

1. **`recipes-kernel/linux/linux-yocto/tegra210.cfg`** — the config fragment.
   Confirm serial console, SD, USB, and especially **on-board ethernet** come up.
2. **extlinux / DTB path** in `conf/machine/p3450-mainline.conf` — verify
   U-Boot finds `/boot/extlinux/extlinux.conf` and loads the `nvidia/` DTB.

Iterate using build logs + the board's serial console.
