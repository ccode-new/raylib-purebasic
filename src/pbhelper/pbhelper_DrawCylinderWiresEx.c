#include "raylib_pb_helper.h"

void pbhelper_DrawCylinderWiresEx(Vector3* startPos, Vector3* endPos, float startRadius, float endRadius, int sides, Color color) {
    if( startPos && endPos ) DrawCylinderWiresEx(*startPos, *endPos, startRadius, endRadius, sides, color);
}
