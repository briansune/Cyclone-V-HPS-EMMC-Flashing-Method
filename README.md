# Cyclone V HPS EMMC Flashing Method

Cyclone V SoCFPGA is kind of trobulesome on EMMC flashing.

1) HPS itself only have 1 MMC hardware
2) Some board simply dasy chain SDMMC and EMMC
3) There are no USB or Ethernet boot supported

Based on the above restrictions, a simply and possible

easiest method is proposed to settle EMMC flashing

Methods:

1) QSPI uboot
2) USB blaster debug via DS-5
3) SDMMC runtime hardware hack

### QSPI

This is very common and many examples are provided.

Will not discussed here

### SDMMC Runtime Hack

This is the worst and limited EMMC flashing method.

Simply detached the SDMMC from the dasy chained MMC bus.

Rescan the MMC bus via U-Boot.

### USB Blaster

This is the method we are going to use for EMMC.

Simply build the U-Boot mainstream design and cloned

to Windows OS and use DS-5 to load and bypass the SPL.

Remarks: the &_xxx is simply replaced by 'grep'

After loading it will simply print press to pause boot.

Pause the boot and use U-Boot basic commands to flash EMMC.

We will also rely on USB or Ethernet to pass files to EMMC.

Here is the .ds file:

```
# initialize system
stop
wait 5s
reset
stop
wait 5s
set trust-ro-sections-for-opcodes off

# load SPL and run up until spl_boot_device
loadfile u-boot/spl/u-boot-spl 0x0
start
wait

#
# How to know the address?
# arm-none-eabi-readelf -s spl/u-boot-spl  | grep __bss_en
#

restore u-boot/spl/u-boot-spl.dtb binary 0xFFFFBEB8
thbreak spl_boot_device
continue
wait 30s

# --- stop CPU before loading main U-Boot ---
stop
wait 2s

# --- delete previous breakpoints ---
delete

# --- load main U-Boot ELF into DRAM ---
loadfile u-boot/u-boot
wait 1s

# --- restore U-Boot DTB at numeric _end ---

#
# How to know the address?
# arm-none-eabi-nm -n u-boot | grep _end
#

restore u-boot/u-boot.dtb binary 0x0109D408
start
continue
```

