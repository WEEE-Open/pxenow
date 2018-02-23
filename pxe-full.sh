#!/bin/bash

set -e

DNSMASQCONF="./dnsmasq-pxe.conf"

: "${IFACE:?Set IFACE variable to name of Ethernet interface to use}"
: "${ISOPATH:?Set ISOPATH variable to path to Lubuntu .iso file}"

echo "Configuring interface ${IFACE}..."
ip link set "${IFACE}" up
ip addr flush dev "${IFACE}"
ip addr add 10.80.7.1/24 dev "${IFACE}"
echo "Interface up!"

if [[ ! -f "./tftp/boot/iso/lubuntu.iso" ]]; then
	mkdir -p "./tftp/boot/iso"
	if [[ ! -f "$ISOPATH" ]]; then
		echo "File $ISOPATH doesn't exist"
		exit 1;
	fi;
	echo "Linking ISO..."
	ln -s "$ISOPATH" "./tftp/boot/iso/lubuntu.iso"
	chmod o+r "$ISOPATH"
	chmod o+r "./tftp/boot/iso/lubuntu.iso"
else
	echo "ISO already linked"
fi;

if [[ ! -f "./tftp/boot/iso/memtest" ]]; then
	echo "Getting memtest86+..."
	if [[ ! -f "./tftp/memtest.zip" ]]; then
		curl -L -o "./tftp/memtest.zip" http://www.memtest.org/download/5.01/memtest86+-5.01.zip
	fi;
	unzip "./tftp/memtest.zip" -d "./tftp/boot/iso/"
	mv "./tftp/boot/iso/memtest86+-5.01.bin" "./tftp/boot/iso/memtest"
else
	echo "Memtest present"
fi

echo "Generating dnsmasq configuration..."
# useful stuff: https://wiki.archlinux.org/index.php/Dnsmasq#PXE_server
{
echo "interface=${IFACE}"
echo port=0 
echo bind-interfaces
echo dhcp-range=10.80.7.50,10.80.7.150,3h
echo dhcp-boot=boot/lpxelinux.0 
echo dhcp-option-force=209,"pxelinux.cfg/default" 
#echo dhcp-option-force=210,/arch/  # TODO: do we need PathPrefix? (See RFC 5071)
echo dhcp-option-force=66,10.80.7.0.1 
echo enable-tftp 
echo tftp-root=$(pwd)/tftp
} > "${DNSMASQCONF}"
dnsmasq -d --test -C "${DNSMASQCONF}"
echo "Dnsmasq config valid"

if [[ ! -d "./tftp/boot" ]]; then
	echo "Copying pxelinux files..."
	mkdir -p "./tftp/boot"
	cp /usr/lib/syslinux/bios/{l,}pxelinux.0 "./tftp/boot"
	cp /usr/lib/syslinux/bios/ldlinux.c32 "./tftp/boot"
	cp /usr/lib/syslinux/bios/menu.c32 "./tftp/boot"
	cp /usr/lib/syslinux/bios/libutil.c32 "./tftp/boot"
	cp /usr/lib/syslinux/bios/memdisk "./tftp/boot"
else
	echo "Pxelinux files already copied."
fi;

echo "Gerating syslinux default config..."
mkdir -p "./tftp/boot/pxelinux.cfg"
cat <<'EOF' > "./tftp/boot/pxelinux.cfg/default"
DEFAULT menu.c32
TIMEOUT 600
PROMPT 0

MENU TITLE Yay PXE boot!

LABEL Memtest
  MENU LABEL Memtest86+
  TEXT HELP
    Test da' RAM with Memtest86+ v5.01
  ENDTEXT 
  kernel iso/memtest

LABEL lubuntu_memdisk
  MENU LABEL Lubuntu (memdisk)
  TEXT HELP
    Load Lubuntu ISO into RAM and boot, if it fits
  ENDTEXT 
  KERNEL memdisk
  APPEND initrd=iso/lubuntu.iso

label disk0
  localboot 0
  MENU LABEL Boot disk (0x80)
  TEXT HELP
    Boot first hard disk
  ENDTEXT 
EOF

dnsmasq -d -C $DNSMASQCONF


#mount -o loop,ro "$ISOPATH" ./tftp/boot/iso
#umount ./tftp/boot/iso
