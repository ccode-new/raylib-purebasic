#include "raylib_pb_helper.h"

void pbhelper_LoadMusicStreamFromMemory(Music* result, const char *fileType, const unsigned char *data, int dataSize) {
    if( result && fileType ) *result = LoadMusicStreamFromMemory(fileType, data, dataSize);
}
