#include "raylib_pb_helper.h"

void pbhelper_DrawRectangleRoundedLinesEx(Rectangle* rect, float roundness, int segments, float lineThick, Color color) {
    if( rect ) DrawRectangleRoundedLinesEx(*rect, roundness, segments, lineThick, color);
}
