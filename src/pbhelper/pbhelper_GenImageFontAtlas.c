#include "raylib_pb_helper.h"

void pbhelper_GenImageFontAtlas(Image* result, const GlyphInfo *chars, Rectangle **recs, int glyphCount, int fontSize, int padding, int packMethod) {
    if( result && chars && recs ) *result = GenImageFontAtlas(chars, recs, glyphCount, fontSize, padding, packMethod);
}
