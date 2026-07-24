FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# linux-yocto has a COMPATIBLE_MACHINE whitelist and needs a known BSP
# definition. Declare our machine compatible and base its kernel config on
# oe-core's genericarm64 BSP (broad mainline arm64 config that already carries
# the Tegra platform); our tegra210.cfg fragment + KERNEL_DEVICETREE narrow it
# to the Jetson Nano.
COMPATIBLE_MACHINE:p3450-mainline = "p3450-mainline"
KMACHINE:p3450-mainline = "genericarm64"

# Tegra210 bring-up config fragment (applied via the tegra210 SoC override)
SRC_URI:append:tegra210 = " file://tegra210.cfg"
