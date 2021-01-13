#!/usr/bin/env bash

set -e

[ -e "WWW Weltatlas.gme" ] || wget https://ssl-static.ravensburger.de/db/applications/WWW\ Weltatlas.gme

arm-none-eabi-as test.txt -o test.elf
arm-none-eabi-objcopy -O binary test.elf test.bin

diff -u <(xxd OidMain.bin) <(xxd test.bin) || true

# position of Header/Single binary 2/Main3202
pos=0x03EE4FA6
size=7572

dd status=none iflag=skip_bytes,count_bytes count="$((pos))" if="WWW Weltatlas.gme"                                        of="WWW Weltatlas2.gme"
dd status=none iflag=skip_bytes,count_bytes if=test.bin count=$((size))                          conv=notrunc oflag=append of="WWW Weltatlas2.gme"
dd status=none iflag=skip_bytes,count_bytes if=/dev/zero count=$((size - "$(wc -c < test.bin)")) conv=notrunc oflag=append of="WWW Weltatlas2.gme"
dd status=none iflag=skip_bytes,count_bytes skip="$((pos + size))" if="WWW Weltatlas.gme"        conv=notrunc oflag=append of="WWW Weltatlas2.gme"

