#include "raylib_pb_helper.h"

void pbhelper_GetMouseWheelMoveV(Vector2* result) {
    if( result ) *result = GetMouseWheelMoveV();
}
