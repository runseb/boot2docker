#!/bin/bash
set -e

mkdir -p /tmp/iso/isolinux

cat > /tmp/iso/isolinux/isolinux.cfg <<EOH
serial 0

ui menu.c32
prompt 1
menu title $(head -1 /tmp/iso/version)
timeout 10
EOH

commonAppend='console=ttyS0 console=tty0 boot=live'
extraAppend='cgroup_enable=memory swapaccount=1'

declare -A inits=(
	[sysvinit]='/lib/sysvinit/init'
	[systemd]='/lib/systemd/systemd'
)
for init in systemd sysvinit; do # add '' here to just use /sbin/init
	cat >> /tmp/iso/isolinux/isolinux.cfg <<EOE

label docker${init:+-$init}
	menu label Docker${init:+ ($init)}
	linux /live/vmlinuz
	initrd /live/initrd.img
	append${init:+ init=${inits[$init]}} $commonAppend $extraAppend loglevel=3
EOE
done

cat >> /tmp/iso/isolinux/isolinux.cfg <<EOE

label docker-safe
	menu label Docker (recovery mode)
	linux /live/vmlinuz
	initrd /live/initrd.img
	append $commonAppend single

label docker-bootdebug
	menu label Docker (systemd boot debug)
	linux /live/vmlinuz
	initrd /live/initrd.img
	append init=${inits[systemd]} $commonAppend $extraAppend systemd.log_level=debug systemd.log_target=console debug=vc
EOE

build-rootfs.sh

mkdir -p /tmp/iso/live

echo >&2 'Updating initrd.img ...'
update-initramfs -k all -u
ln -L /vmlinuz /initrd.img /tmp/iso/live/

# volume IDs must be 32 characters or less
volid="$(head -1 /tmp/iso/version | sed 's/ version / v/')"
if [ ${#volid} -gt 32 ]; then
	volid="$(printf '%-32.32s' "$volid")"
fi

echo >&2 'Building the ISO ...'
xorriso \
	-as mkisofs \
	-A 'Docker' \
	-V "$volid" \
	-l -J -rock -joliet-long \
	-isohybrid-mbr /tmp/isohdpfx.bin \
	-partition_offset 16 \
	-b isolinux/isolinux.bin \
	-c isolinux/boot.cat \
	-no-emul-boot \
	-boot-load-size 4 \
	-boot-info-table \
	-o /tmp/docker.iso \
	/tmp/iso

rm -rf /tmp/iso/live /tmp/rootfs.tar.xz
