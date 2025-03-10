#include "raylib_pb_helper.h"

void pbhelper_LoadImageColors(Color *result, Image* image) {
	if( result && image ) result = LoadImageColors(*image);
}
