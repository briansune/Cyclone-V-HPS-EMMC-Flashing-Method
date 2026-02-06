# arm-none-eabi-readelf -s spl/u-boot-spl  | grep __bss_end
# arm-none-eabi-nm -n u-boot | grep _end

set architecture arm
set remotetimeout 20000
set confirm off
set pagination off

target remote localhost:3333

monitor reset halt
file ~/u-boot/spl/u-boot-spl
load
restore ~/u-boot/spl/u-boot-spl-dtb.bin binary 0xffff0000
thbreak spl_boot_device
continue

file ~/u-boot/u-boot
load
restore ~/u-boot/u-boot.dtb binary &_end
continue
quit

