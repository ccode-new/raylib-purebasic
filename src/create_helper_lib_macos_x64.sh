#!/bin/sh

cd out
rm *.o
rm *.obj
gcc -11 -m64 -c -ffreestanding ../pbhelper/*.c
cd ..
ar rcs ../bin/libraylib_macos_pbhelper_x64.a out/*.o
rm *.o
rm *.obj
