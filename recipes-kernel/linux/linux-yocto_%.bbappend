FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Tegra210 bring-up config fragment (only applied for this machine)
SRC_URI:append:tegra210 = " file://tegra210.cfg"

# Make sure the in-tree Tegra210 platform + our drivers are configured.
KERNEL_FEATURES:append:tegra210 = ""
