#include "raylib_pb_helper.h"

void pbhelper_DrawBillboardPro(Camera* camera, Texture2D* texture, Rectangle* sourceRec, Vector3* position, Vector3* up, Vector2* size, Vector2* origin, float rotation, Color tint) {
    if( camera && texture && sourceRec ) DrawBillboardPro(*camera, *texture, *sourceRec, *position, *up, *size, *origin, rotation, tint);
}
