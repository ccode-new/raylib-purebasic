#include "raylib_pb_helper.h"

void pbhelper_GetGlyphAtlasRec(Rectangle* result, Font* font, int codepoint) {
    if( result && font ) *result = GetGlyphAtlasRec(*font, codepoint);
}
