from setuptools import setup

setup(
	name='pxenow',
	version='0.0.1',
	url='https://github.com/WEEE-Open/pxenow',
	license='MIT',
	author='lvps',
	author_email='',
	description='Start a PXE server (proxy DHCP + TFTP + NFS) now, just supply the ISO files',
	install_requires=['netifaces']
)
