#!/bin/bash

# the kylin common post actions on ghost install
# to update bootload

KYARCH=$(archdetect)

### chroot
if [ ! -e /target/dev ]; then
    mkdir -p /target/dev
    chmod 755 /target/dev
fi
if [ ! -e /target/proc ]; then
    mkdir -p /target/proc
    chmod 555 /target/proc
fi
if [ ! -e /target/sys ]; then
    mkdir -p /target/sys
    chmod 555 /target/sys
fi
if [ ! -e /target/run ]; then
    mkdir -p /target/run
    chmod 755 /target/run
fi

mount --bind /dev /target/dev
mount --bind /proc /target/proc
mount --bind /sys /target/sys

distrib_os=`cat /target/etc/lsb-release | grep "DISTRIB_ID" | cut -f 2 -d '='`

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

    if [ -d /boot/efi/EFI/ ]; then
        mkdir -p /boot/efi/EFI/neokylin
        cp -r /boot/efi/EFI/kylin/* /boot/efi/EFI/neokylin/
    fi
elif [ "x${KYARCH}" = "xarm64/generic" ]; then
    chroot /target update-grub
elif [ "x${KYARCH}" = "xmips64el/generic" ]; then
    chroot /target update-grub
fi

umount /target/dev
umount /target/proc
umount /target/sys


###nochroot
#This is abandoned in sp3/v10
#if [ "${KYARCH}" == "aarch64" ];then
#    if [ -d /target/boot/efi ];then
#        mkdir -p /target/boot/efi/boot/grub
#        cp /target/boot/grub/grub.cfg /target/boot/efi/boot/grub
#        cp /target/boot/grub/grub.cfg /target/boot/grub/grub.cfg-old
#        GRUB_DEVICE_BOOT=`grub-probe --target=device /target/boot`
#        GRUB_ROOT=`grub-probe --device $GRUB_DEVICE_BOOT --target=compatibility_hint`
#        GRUB_EFI_CFG="/target/boot/efi/boot/grub/grub.cfg"
#        sed -i "s/set root=(\${root})/set root='$GRUB_ROOT'/g" $GRUB_EFI_CFG
#        sed -i 's#/uImage-ft2000plus#/Image#g' $GRUB_EFI_CFG
#        sed -i 's#/uImage#/Image#g' $GRUB_EFI_CFG
#        sed -i 's/console=ttyS.,115200 earlyprintk=uart8250-32bit,0x28001000//g' $GRUB_EFI_CFG
#        sed -i 's/console=ttyS.,115200 earlycon=uart8250,mmio32,0x80028001000//g' $GRUB_EFI_CFG
#        sed -i '/devicetree/d' $GRUB_EFI_CFG
#        # cp /target/boot/efi/boot/grub/grub.cfg /target/boot/grub/grub.cfg
#    fi
#fi

# amd64/efi should do something

if [ "x${KYARCH}" = "x86_64/efi" ] || [ "x${KYARCH}" = "xamd64/efi" ]; then
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

