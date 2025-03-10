#!/bin/sh

rm *.o
rm *.obj
gcc -m64 -c -ffreestanding *.c
ar rcs libraylib_linux_pbhelper_amd64.a *.o
rm *.o
rm *.obj
