#include "raylib_pb_helper.h"

void pbhelper_DrawPolyLinesEx(Vector2* center, int sides, float radius, float rotation, float lineThick, Color color) {
    if( center ) DrawPolyLinesEx(*center, sides, radius, rotation, lineThick, color);
}
