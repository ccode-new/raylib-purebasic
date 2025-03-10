#include "raylib_pb_helper.h"

void pbhelper_GetMouseDelta(Vector2* result) {
    if( result ) *result = GetMouseDelta();
}
