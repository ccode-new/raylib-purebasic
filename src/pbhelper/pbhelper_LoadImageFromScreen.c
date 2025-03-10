#include "raylib_pb_helper.h"

void pbhelper_LoadImageFromScreen(Image* image) {
	if( image ) *image = LoadImageFromScreen();
}
