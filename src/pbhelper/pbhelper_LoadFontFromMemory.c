#include "raylib_pb_helper.h"

void pbhelper_LoadFontFromMemory(Font* result, const char *fileType, const unsigned char *fileData, int dataSize, int fontSize, int *fontChars, int glyphCount) {
    if( result && fileType ) *result = LoadFontFromMemory(fileType, fileData, dataSize, fontSize, fontChars, glyphCount);
}
