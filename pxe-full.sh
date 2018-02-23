#!/bin/bash

set -e

: "${IFACE:?Set IFACE variable to name of Ethernet interface to use}"
: "${ISOPATH:?Set ISOPATH variable to path to .iso file}"

if [[ ! -f "$ISOPATH" ]]; then
	echo "File $ISOPATH doesn't exist"
	exit 1;
fi;

echo "interface=$IFACE" > "./dnsmasq-pxe.conf"
cat << 'EOF' >> "./dnsmasq-pxe.conf"
port=0
bind-interfaces
dhcp-range=192.168.0.50,192.168.0.150,12h
dhcp-boot=/arch/boot/syslinux/lpxelinux.0
dhcp-option-force=209,boot/syslinux/archiso.cfg
dhcp-option-force=210,/arch/
dhcp-option-force=66,192.168.0.1
enable-tftp
tftp-root=./tftp/iso
EOF

mkdir -p ./tftp/iso
mount -o loop,ro "$ISOPATH" ./tftp/iso


# Undo everything (for testing)
umount ./tftp/iso
rmdir ./tftp/iso
