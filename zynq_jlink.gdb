# openocd -f ./tcl/interface/jlink.cfg -f ./tcl/target/zynq_7000.cfg  -c "init" -c "halt"

set confirm off
set architecture arm

target extended-remote :3333
# monitor reset
monitor halt

file spl/u-boot-spl
restore spl/u-boot-spl-dtb.bin binary 0x00000000
set $pc = 0x00000000
hb spl_boot_device
continue

delete breakpoints
file u-boot
restore u-boot-dtb.bin binary 0x04000000
set $pc = 0x04000000

echo === Starting U-Boot! Check your UART serial console ===\n

monitor resume
detach
quit


