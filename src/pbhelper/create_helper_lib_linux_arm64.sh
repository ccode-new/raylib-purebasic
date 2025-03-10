#!/bin/sh

rm *.o
rm *.obj
gcc -c -ffreestanding *.c
ar rcs libraylib_linux_pbhelper_arm64.a *.o
rm *.o
rm *.obj
