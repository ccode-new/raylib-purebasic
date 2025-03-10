#include "raylib_pb_helper.h"

void pbhelper_GetGlyphInfo(GlyphInfo* result, Font* font, int codepoint) {
    if( result && font ) *result = GetGlyphInfo(*font, codepoint);
}
