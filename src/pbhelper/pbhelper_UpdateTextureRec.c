#include "raylib_pb_helper.h"

void pbhelper_UpdateTextureRec(Texture2D *texture, Rectangle* rec, const void *pixels) {
	if( texture && rec ) UpdateTextureRec(*texture, *rec, pixels);
}
