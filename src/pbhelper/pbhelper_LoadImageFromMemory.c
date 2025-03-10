#include "raylib_pb_helper.h"

void pbhelper_LoadImageFromMemory(Image* image, const char *fileType, const unsigned char *fileData, int dataSize) {
	if( image ) *image = LoadImageFromMemory(fileType, fileData, dataSize);
}
