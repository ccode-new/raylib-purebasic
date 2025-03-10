#include "raylib_pb_helper.h"

void pbhelper_DrawTriangle3D(Vector3* v1, Vector3* v2, Vector3* v3, Color color) {
    if( v1 && v2 && v3 ) DrawTriangle3D(*v1, *v2, *v3, color);
}
