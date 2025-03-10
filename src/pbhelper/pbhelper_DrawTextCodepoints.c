#include "raylib_pb_helper.h"

void pbhelper_DrawTextCodepoints(Font* font, const int *codepoints, int count, Vector2* position, float fontSize, float spacing, Color tint) {
    if( font ) DrawTextCodepoints(*font, codepoints, count, *position, fontSize, spacing, tint);
}
