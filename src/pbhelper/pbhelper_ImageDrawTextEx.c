#include "raylib_pb_helper.h"

void pbhelper_ImageDrawTextEx(Image *dst, Font* font, const char *text, Vector2* position, float fontSize, float spacing, Color color) {
    if( dst && font && text && position ) ImageDrawTextEx(dst, *font, text, *position, fontSize, spacing, color);
}
