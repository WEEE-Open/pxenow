# pxenow

Start an impromptu PXE server immediately, here, now, right in current working directory.

Currently **work in progress**, although it can already boot memtest86+.

Requires Python 3, dnsmasq, pxelinux (`syslinux` package on Arch Linux) and netifaces (`pip install netifaces`).
DHCP is configured in proxy mode, so it should work even on networks with an existing DHCP server.

Note that other, more refined solutions exits, e.g. [this one](https://github.com/piffall/PXESetupWizard).

## Usage

See `pxenow -h`

## License

MIT.
