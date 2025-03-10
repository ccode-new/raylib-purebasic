#include "raylib_pb_helper.h"
#include "rlgl.h"
#include <math.h>

// Draw a 2D text in 3D space
void pbhelper_DrawText3D(Font* font, const char *text, Vector3* position, float fontSize, float fontSpacing, float lineSpacing, bool backface, Color tint)
{
    int length = TextLength(text);          // Total length in bytes of the text, scanned by codepoints in loop

    float textOffsetY = 0.0f;               // Offset between lines (on line break '\n')
    float textOffsetX = 0.0f;               // Offset X to next character to draw

    float scale = fontSize/(float)font->baseSize;

    for (int i = 0; i < length;)
    {
        // Get next codepoint from byte string and glyph index in font
        int codepointByteCount = 0;
        int codepoint = GetCodepoint(&text[i], &codepointByteCount);
        int index = GetGlyphIndex(*font, codepoint);

        // NOTE: Normally we exit the decoding sequence as soon as a bad byte is found (and return 0x3f)
        // but we need to draw all of the bad bytes using the '?' symbol moving one byte
        if (codepoint == 0x3f) codepointByteCount = 1;

        if (codepoint == '\n')
        {
            // NOTE: Fixed line spacing of 1.5 line-height
            // TODO: Support custom line spacing defined by user
            textOffsetY += scale + lineSpacing/(float)font->baseSize*scale;
            textOffsetX = 0.0f;
        }
        else
        {
            if ((codepoint != ' ') && (codepoint != '\t'))
            {
                pbhelper_DrawTextCodepoint3D(font, codepoint, (Vector3){ position->x + textOffsetX, position->y, position->z + textOffsetY }, fontSize, backface, tint);
            }

            if (font->glyphs[index].advanceX == 0) textOffsetX += (float)(font->recs[index].width + fontSpacing)/(float)font->baseSize*scale;
            else textOffsetX += (float)(font->glyphs[index].advanceX + fontSpacing)/(float)font->baseSize*scale;
        }

        i += codepointByteCount;   // Move text bytes counter to next codepoint
    }
}
