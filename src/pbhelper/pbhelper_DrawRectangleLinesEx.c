#include "raylib_pb_helper.h"

void pbhelper_DrawRectangleLinesEx(Rectangle* rect, float lineThick, Color color) {
    if( rect ) DrawRectangleLinesEx(*rect, lineThick, color);
}
