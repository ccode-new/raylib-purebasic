#!/bin/sh

rm *.o
rm *.obj
gcc -c -ffreestanding *.c
ar rcs libraylib_macos_pbhelper_x64.a *.o
rm *.o
rm *.obj
