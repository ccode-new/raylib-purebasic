#include "raylib_pb_helper.h"

void pbhelper_LoadImageFromTexture(Image* image, Texture2D* texture) {
	if( image && texture ) *image = LoadImageFromTexture(*texture);
}
