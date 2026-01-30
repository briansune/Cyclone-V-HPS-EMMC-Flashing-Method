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
restore ~/u-boot/spl/u-boot-spl.dtb binary 0xFFFFBEC8
thbreak spl_boot_device
continue

file ~/u-boot/u-boot
load
restore ~/u-boot/u-boot.dtb binary 0x0109d338
continue
quit

