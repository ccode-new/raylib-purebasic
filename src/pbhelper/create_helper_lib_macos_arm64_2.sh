#!/bin/sh

rm *.o
rm *.obj

MACOSX_DEPLOYMENT_TARGET=11
clang -mmacosx-version-min=11 -c -ffreestanding *.c

#libtool -static -o libraylib_macos_pbhelper_arm64.a *.o

ar rcs libraylib_macos_pbhelper_arm64.a *.o
rm *.o
rm *.obj
