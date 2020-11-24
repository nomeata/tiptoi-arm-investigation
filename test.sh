#!/usr/bin/env bash

set -e

arm-none-eabi-as test.txt -o test.elf
arm-none-eabi-objcopy -O binary test.elf test.bin

# diff -u <(xxd OidMain.bin) <(xxd test.bin) || true

dd status=none iflag=skip_bytes,count_bytes count="$((0x0256130A))" if="WWW Europa.gme"                                    of="WWW Europa2.gme"
dd status=none iflag=skip_bytes,count_bytes if=test.bin count=2828                               conv=notrunc oflag=append of="WWW Europa2.gme"
dd status=none iflag=skip_bytes,count_bytes if=/dev/zero count=$((2828 - "$(wc -c < test.bin)")) conv=notrunc oflag=append of="WWW Europa2.gme"
dd status=none iflag=skip_bytes,count_bytes skip="$((0x0256130A + 2828))" if="WWW Europa.gme"    conv=notrunc oflag=append of="WWW Europa2.gme"

