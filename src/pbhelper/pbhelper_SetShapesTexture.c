#include "raylib_pb_helper.h"

void pbhelper_SetShapesTexture(Texture2D* texture, Rectangle* sourceRec) {
    if( texture && sourceRec ) SetShapesTexture(*texture, *sourceRec);
}
