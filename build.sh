#!/bin/bash

#set -e

## Copy this script inside the kernel directory
KERNEL_DEFCONFIG=neutrino_llvm_defconfig
export PATH="$HOME/proton-clang/bin:$PATH"
export ARCH=arm64
export SUBARCH=arm64

# Speed up build process
MAKE="./makeparallel"

BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

read -p "Cleanup ? (yes (y) or no (n)): " option

case $option in
    yes | y)
        mkdir -p out
        make O=out CC=clang clean
        echo "cleaned successfully."
        ;;
    none | n)
        echo "Ingnored successfully."
        ;;
    *)
        echo "Invalid option."
        ;;
esac

echo "**** Kernel defconfig is set to $KERNEL_DEFCONFIG ****"
echo -e "$blue***********************************************"
echo "          BUILDING KERNEL          "
echo -e "***********************************************$nocol"
make $KERNEL_DEFCONFIG CC=clang O=out
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC=clang \
                      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                      NM=llvm-nm \
                      OBJCOPY=llvm-objcopy \
                      OBJDUMP=llvm-objdump \
                      STRIP=llvm-strip