#!/usr/bin/env bash

set -e

arm-none-eabi-as test.txt -o test.elf
arm-none-eabi-objcopy -O binary test.elf test.bin

dd status=none iflag=skip_bytes,count_bytes count="$((0x0256130A))" if="WWW Europa.gme" of="WWW Europa2.gme"
dd status=none if=test.bin conv=notrunc oflag=append of="WWW Europa2.gme"
dd status=none iflag=skip_bytes,count_bytes skip="$((0x0256130A + 2828))" if="WWW Europa.gme" conv=notrunc oflag=append of="WWW Europa2.gme"


