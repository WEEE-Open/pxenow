# pxenow

Start an impromptu PXE server immediately, here, now, right in current working directory.

## Features

* Configures dnsmasq to DHCP in proxy mode: it should work even on networks with an existing DHCP server
* Provides squashfs via NFS, not TFTP + memdisk: no need to fit the entire ISO in RAM
* ISO files are mounted/unmounted automatically and symlinks created when necessary
* Syslinux/pxelinux boot menu with options to start Memtest86+, HDT, PLoP and netboot.xyz, in addition to user-specified ISOs
* Downloads Memtest86+, PLoP and netboot.xyz executables automatically if not found

## Limitations

* Currently supports only BIOS systems, no UEFI
* Syslinux config can be reliably generated only for *live* Ubuntu and derivatives, but should be easy to add
more distros or the installer (see the `get_syslinux_config_for` function)
* Many commands require root privileges. There's an option (`-S`) to call `sudo` automatically, but it hasn't been
tested extensively
* Tested only on Arch Linux, some commands may fail on other distros

## Requirements

- Python 3.6
- dnsmasq
- NFS
- pxelinux (`syslinux` package on Arch Linux)
- netifaces (`pip install netifaces`), optional, or use the `-s` and `-n` parameters

## TODO (pull requests welcome)

- Support Ubuntu and derivatives installer, too (generate another config for each ISO)
- Get Arch Linux boot working
- Docker container or Vagrant VM, maybe?
- Support for more distros
- Support for UEFI systems
- Support IPv6?
- More PXE options in DHCP offer, for clients too old/broken/new?

## Usage

```
usage: pxenow [-h] [-i INTERFACE] [-n NETMASK] [-s SERVER] [-k KEYMAPS] [-N]
              [-S]
              [iso [iso ...]]

Create a PXE server right here, right now.

positional arguments:
  iso                   Path to ISO images

optional arguments:
  -h, --help            show this help message and exit
  -i INTERFACE, --interface INTERFACE
                        Interface to bind, e.g. enp3s0
  -n NETMASK, --netmask NETMASK
                        Netmask, used only if -s is also used
  -s SERVER, --server SERVER
                        IP address of current machine, used as TFTP, DHCP and
                        NFS server
  -k KEYMAPS, --keymaps KEYMAPS
                        Comma-separated list of keymaps
  -N, --nfs             Blindly overwrite /etc/exports and manage NFS server
  -S, --sudo            Use sudo for commands that require root permissions
```

Specify `-s` and `-n` if you haven't installed netifaces. If `-i` is given, `-s` and `-n` are ignored.
If none of these is specified, the script will try to guess the interface and address to use.

With `-N` the script starts/stops the `nfs-server` service automatically and completely **overwrites**
/etc/exports if needed. Without `-N` it outputs the correct exports and you'll have to copy them into
/etc/exports and manually manage the NFS service.

When using `-S`/`--sudo` note that it won't use `sudo` to write the `/etc/exports` file, so you'll need
to add write permissions to "others" to get that working.

## License

MIT.