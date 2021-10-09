#!/bin/bash

# kylin common install post actions
# the bootload configure, 
# to uefi mode, efi file and grub.cfg
# legacy update grub.cfg
# and last oem config to firstboot run oem

KYARCH=$(archdetect)

distrib_os=`cat /target/etc/lsb-release | grep "DISTRIB_ID" | cut -f 2 -d '='`

### chroot
if [ "x${KYARCH}" = "xarm64/efi" ]; then
    if [ -f /target/usr/sbin/grub-install ]; then
        echo "${KYARCH}: chroot /target grub-install... "
        chroot /target grub-install
    fi

    if [ -f /target/usr/sbin/update-grub ]; then
        echo "${KYARCH}: chroot /target update-grub... "
        chroot /target update-grub
    fi

    if [ "x$distrib_os" = "xKylin" ]; then
        if [ -f /target/boot/efi/EFI/kylin/grubaa64.efi ]; then
            echo "${KYARCH}: chroot /target cp... "
            mkdir -p /target/boot/efi/EFI/boot /target/boot/efi/EFI/neokylin
            cp /target/boot/efi/EFI/kylin/grubaa64.efi /target/boot/efi/EFI/boot/bootaa64.efi
            cp /target/boot/efi/EFI/kylin/grubaa64.efi /target/boot/efi/EFI/boot/grubaa64.efi
            cp /target/boot/efi/EFI/kylin/grubaa64.efi /target/boot/efi/EFI/neokylin/
        fi
    elif [ "x$distrib_os" = "xNeoKylin" ]; then
        if [ -f /target/boot/efi/EFI/neokylin/grubaa64.efi ]; then
            echo "${KYARCH}: chroot /target cp... "
            mkdir -p /target/boot/efi/EFI/boot
            cp /target/boot/efi/EFI/neokylin/grubaa64.efi /target/boot/efi/EFI/boot/bootaa64.efi
            cp /target/boot/efi/EFI/neokylin/grubaa64.efi /target/boot/efi/EFI/boot/grubaa64.efi
        fi
    elif [ "x$distrib_os" = "xPKSKylin" ]; then
        if [ -f /target/boot/efi/EFI/pkskylin/grubaa64.efi ]; then
            echo "${KYARCH}: chroot /target cp... "
            mkdir -p /target/boot/efi/EFI/boot /target/boot/efi/EFI/neokylin
            cp /target/boot/efi/EFI/pkskylin/grubaa64.efi /target/boot/efi/EFI/boot/bootaa64.efi
            cp /target/boot/efi/EFI/pkskylin/grubaa64.efi /target/boot/efi/EFI/boot/grubaa64.efi
            cp /target/boot/efi/EFI/pkskylin/grubaa64.efi /target/boot/efi/EFI/neokylin/
        fi
    fi
elif [ "x${KYARCH}" = "xarm64/generic" ]; then
    chroot /target update-grub
elif [ "x${KYARCH}" = "xmips64el/generic" ]; then
    chroot /target update-grub
elif [ "x${KYARCH}" = "xx86_64/efi" ] || [ "x${KYARCH}" = "xamd64/efi" ]; then
    if [ "x$distrib_os" = "xKylin" ]; then
        if [ -f /target/boot/efi/EFI/kylin/grubx64.efi ]; then
            mkdir -p /target/boot/efi/EFI/boot
            cp /target/boot/efi/EFI/kylin/grubx64.efi /target/boot/efi/EFI/boot/bootx64.efi
        fi
    elif [ "x$distrib_os" = "xNeoKylin" ]; then
        if [ -f /target/boot/efi/EFI/neokylin/grubx64.efi ]; then
            mkdir -p /target/boot/efi/EFI/boot
            cp /target/boot/efi/EFI/neokylin/grubx64.efi /target/boot/efi/EFI/boot/bootx64.efi
        fi
    fi
fi

### OEM or QC
if ! grep -q 'QC=true' /proc/cmdline; then
    echo "OEM config: "
    if [ -f /target/usr/sbin/oem-config-prepare ]; then
        chroot /target /usr/sbin/oem-config-prepare
    fi
fi

# TODO, repeat code
### Install third-party software packages for local
if [ -d /home/kylin/third-party ]; then
    rsync -aHA /home/kylin/third-party /target/tmp
    chroot /target /bin/sh -c 'find /tmp/third-party -name "*.deb" >/tmp/third-party/packages.list'
    count=$(cat /target/tmp/third-party/packages.list | wc -l)
    if [ $count -ne 0 ]; then
        chroot /target /bin/sh -c 'unset DEBIAN_HAS_FRONTEND && UCF_FORCE_CONFFNEW=YES dpkg -i $(cat /tmp/third-party/packages.list | xargs)'
    fi
    rm -rf /target/tmp/third-party
fi

### Install third-party software packages
if [ -d /cdrom/third-party ]; then
    rsync -aHA /cdrom/third-party /target/tmp
    chroot /target /bin/sh -c 'find /tmp/third-party -name "*.deb" >/tmp/third-party/packages.list'
    count=$(cat /target/tmp/third-party/packages.list | wc -l)
    if [ $count -ne 0 ]; then
        chroot /target /bin/sh -c 'unset DEBIAN_HAS_FRONTEND && UCF_FORCE_CONFFNEW=YES dpkg -i $(cat /tmp/third-party/packages.list | xargs)'
    fi
    rm -rf /target/tmp/third-party
fi

### automatically install the packages listed in the /cdrom/.kylin-post-packages 
if [ -f /cdrom/.kylin-post-packages ]; then
    chroot /target /bin/sh -c "unset DEBIAN_HAS_FRONTEND && apt-get install -y $(cat /cdrom/.kylin-post-packages | xargs)"
fi
