#include "raylib_pb_helper.h"

void pbhelper_GetMonitorPosition(Vector2* result, int monitor) {
    if( result && monitor ) *result = GetMonitorPosition(monitor);
}
