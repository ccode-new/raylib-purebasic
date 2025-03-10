#include "raylib_pb_helper.h"

void pbhelper_DrawTriangleStrip3D(Vector3* points, int pointCount, Color color) {
    if( points ) DrawTriangleStrip3D(points, pointCount, color);
}
