#include "raylib_pb_helper.h"

void pbhelper_DrawCylinderEx(Vector3* startPos, Vector3* endPos, float startRadius, float endRadius, int sides, Color color) {
    if( startPos && endPos ) DrawCylinderEx(*startPos, *endPos, startRadius, endRadius, sides, color);
}
