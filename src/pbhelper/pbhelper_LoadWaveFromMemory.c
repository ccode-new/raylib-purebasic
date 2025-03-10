#include "raylib_pb_helper.h"

void pbhelper_LoadWaveFromMemory(Wave* result, const char *fileType, const unsigned char *fileData, int dataSize) {
    if( result && fileType ) *result = LoadWaveFromMemory(fileType, fileData, dataSize);
}
