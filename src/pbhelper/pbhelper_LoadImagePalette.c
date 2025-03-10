#include "raylib_pb_helper.h"

void pbhelper_LoadImagePalette(Color *result, Image* image, int maxPaletteSize, int *colorCount) {
	if( result && image ) result = LoadImagePalette(*image, maxPaletteSize, colorCount);
}
