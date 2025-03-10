#!/bin/sh

rm *.o
rm *.obj
gcc -11 -m64 -c -ffreestanding *.c
ar rcs libraylib_macos_pbhelper_arm64.a *.o
rm *.o
rm *.obj
