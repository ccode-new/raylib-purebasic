#include "raylib_pb_helper.h"

void pbhelper_LoadImageAnim(Image* image, const char *fileName, int *frames) {
	if( image && fileName && frames) *image = LoadImageAnim(fileName, frames);
}
