#!/bin/bash

PROGRAMMER="buspirate_spi"
PORT="/dev/ttyUSB0"
CLIP="SOIC8"
CHIP="MX25L6406E/MX25L6408E"
BACKUP="backup.rom"
COREBOOT="coreboot.rom"
IFDTOOL="ifdtool"
CBFSTOOL="cbfstool"
FLASHROM="flashrom"
COREBOOT_DIR="$HOME/coreboot"
ICH9UTILS_DIR="$HOME/ich9utils"
MAC_ADDRESS="XX:XX:XX:XX:XX:XX"
MICROCODE_URL="https://downloadmirror.intel.com/28039/eng/microcode-20180807.tgz"
MICROCODE_FILE="microcode-20180807/microcode.dat"
VGA_ROM_FILE="pci8086,2a42.rom"
PAYLOAD="seabios"
PAYLOAD_CONFIG="$HOME/.config/seabios.config"

function check_command() {
    command -v $1 >/dev/null 2>&1 || { echo >&2 "Installing $1..."; sudo apt-get install -y $1; }
}
function check_package() {
    [ -f $2 ] || { echo "Downloading $1..."; wget -O $2 $1; }
}
function check_directory() {
    [ -d $2 ] || { echo "Cloning $1..."; git clone $1 $2; }
}
function backup_firmware() {
    echo "Backing up the original firmware..."
    sudo $FLASHROM -p $PROGRAMMER:$PORT -c $CHIP -r $BACKUP
}
function modify_descriptor() {
    echo "Modifying the flash descriptor..."
    cd $COREBOOT_DIR/util/ifdtool
    make -j $(nproc)
    cp $IFDTOOL ~/
    cd ~/
    cp $BACKUP $COREBOOT
    case $CHIP in
        MX25L6406E/MX25L6408E)
            ./ifdtool -n util/ifdtool/layouts/lenovo-x200-4m.layout.txt $COREBOOT ;;
        W25Q64.V)
            ./ifdtool -n util/ifdtool/layouts/lenovo-x200-8m.layout.txt $COREBOOT ;;
        *)
            echo "Unsupported chip model. Please check your chip model and size." ;;
    esac
    ./ifdtool -M 1 $COREBOOT
}
function add_microcode() {
    echo "Adding the CPU microcode update..."
    check_package $MICROCODE_URL microcode.tgz
    tar xzf microcode.tgz
    cd $COREBOOT_DIR/util/cbfstool
    make -j $(nproc)
    cp $CBFSTOOL ~/
    cd ~/
    ./cbfstool $COREBOOT add-intel-microcode $MICROCODE_FILE type=cpu_microcode compress=lzma
}
function add_vga_rom() {
    echo "Adding the VGA option ROM..."
    ./cbfstool $COREBOOT add -f $VGA_ROM_FILE -n pci8086,2a42.rom -t optionrom
}
function add_payload() {
    echo "Adding the payload..."
    case $PAYLOAD in
        seabios)
            make -C payloads/external/SeaBIOS $PAYLOAD_CONFIG
            ./cbfstool $COREBOOT add-payload -f payloads/external/SeaBIOS/seabios/out/bios.bin.elf -n fallback/payload -t payload ;;
        grub2)
            make -C payloads/external/GRUB2
            ./cbfstool $COREBOOT add-payload -f payloads/external/GRUB2/grub2.elf -n fallback/payload -t payload ;;
        *)
            echo "Unsupported payload. Please choose seabios or grub2." ;;
    esac
}
function write_coreboot() {
    echo "Writing the coreboot image..."
    sudo $FLASHROM -p $PROGRAMMER:$PORT -c $CHIP -w $COREBOOT --ifd -i bios
}
function main() {
    check_command git
    check_command make
    check_command wget
    check_command tar
    check_command flashrom
    check_package https://coreboot.org/releases/coreboot-4.14.tar.xz coreboot.tar.xz
    tar xJf coreboot.tar.xz
    mv coreboot-4.14 coreboot
    check_directory https://notabug.org/libreboot/ich9utils.git ich9utils

    backup_firmware

    modify_descriptor

    cd $COREBOOT_DIR
    make crossgcc-i386 CPUS=$(nproc)
    make menuconfig
    make -j $(nproc)
    add_microcode
    add_vga_rom
    add_payload
    write_coreboot
    sudo reboot
}

main
