# Cyclone V HPS EMMC Flashing Method

Cyclone V SoCFPGA is kind of trobulesome on EMMC flashing.

1) HPS itself only have 1 MMC hardware
2) Some board simply dasy chain SDMMC and EMMC
3) There are no USB or Ethernet boot supported

Based on the above restrictions, a simply and possible

easiest method is proposed to settle EMMC flashing

Methods:

- QSPI uboot
- USB Blaster debug
  - DS-5
  - OpenOCD+GDB
- SDMMC runtime hardware hack

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

For TFTP or USB, please do it small section as a time.

DDR size and EMMC write might not that good on big slices.

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

Here is the .gdb

```
set architecture arm
set remotetimeout 20000
target remote localhost:3333
monitor halt
file ~/u-boot/spl/u-boot-spl
load ~/u-boot/spl/u-boot-spl
restore ~/u-boot/spl/u-boot-spl.dtb binary 0xFFFFBEB8
thbreak spl_boot_device
continue
file ~/u-boot/u-boot
load ~/u-boot/u-boot
restore ~/u-boot/u-boot.dtb binary 0x0109D408
monitor resume
```

# U-Boot TFTP

On Linux side

```
split -b 32M -d --additional-suffix="" ac550.img ac550.part
```

On U-Boot side

```
// ========================================================================
// UBOOT Run A
// ========================================================================

setenv ipaddr 192.168.2.150
setenv serverip 192.168.2.100
ping ${serverip}

mmc dev 0

setenv i 0
setenv blk 0
setenv blkper 0x10000
setenv img ac550.part
setenv loadaddr 0x03000000


while itest ${i} -le 0xd2; do
  if itest ${i} -lt 10; then
    setenv part ${img}0${i}
  else
    setenv part ${img}${i}
  fi
  echo Loading ${part} to block ${blk}
  tftp ${loadaddr} ${part}
  mmc write ${loadaddr} ${blk} ${blkper}
  setexpr blk ${blk} + ${blkper}
  setexpr i ${i} + 1
done

// ========================================================================
// UBOOT Run B
// ========================================================================

setenv part ${img}${i}
echo Loading ${part} to block ${blk}
tftp ${loadaddr} ${part}
mmc write ${loadaddr} ${blk} 0x5000
```

