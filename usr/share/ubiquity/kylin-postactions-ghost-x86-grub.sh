#!/bin/bash

# kylin fix x86 ghost install, the device can not mount 
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
