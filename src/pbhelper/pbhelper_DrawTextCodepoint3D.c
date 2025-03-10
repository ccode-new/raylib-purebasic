#include "raylib_pb_helper.h"
#include "rlgl.h"
#include <math.h>

// Draw codepoint at specified position in 3D space
void pbhelper_DrawTextCodepoint3D(Font* font, int codepoint, Vector3 position, float fontSize, bool backface, Color tint)
{
    // Character index position in sprite font
    // NOTE: In case a codepoint is not available in the font, index returned points to '?'
    int index = GetGlyphIndex(*font, codepoint);
    float scale = fontSize/(float)font->baseSize;

    // Character destination rectangle on screen
    // NOTE: We consider charsPadding on drawing
    position.x += (float)(font->glyphs[index].offsetX - font->glyphPadding)/(float)font->baseSize*scale;
    position.z += (float)(font->glyphs[index].offsetY - font->glyphPadding)/(float)font->baseSize*scale;

    // Character source rectangle from font texture atlas
    // NOTE: We consider chars padding when drawing, it could be required for outline/glow shader effects
    Rectangle srcRec = { font->recs[index].x - (float)font->glyphPadding, font->recs[index].y - (float)font->glyphPadding,
                         font->recs[index].width + 2.0f*font->glyphPadding, font->recs[index].height + 2.0f*font->glyphPadding };

    float width = (float)(font->recs[index].width + 2.0f*font->glyphPadding)/(float)font->baseSize*scale;
    float height = (float)(font->recs[index].height + 2.0f*font->glyphPadding)/(float)font->baseSize*scale;

    if (font->texture.id > 0)
    {
        const float x = 0.0f;
        const float y = 0.0f;
        const float z = 0.0f;

        // normalized texture coordinates of the glyph inside the font texture (0.0f -> 1.0f)
        const float tx = srcRec.x/font->texture.width;
        const float ty = srcRec.y/font->texture.height;
        const float tw = (srcRec.x+srcRec.width)/font->texture.width;
        const float th = (srcRec.y+srcRec.height)/font->texture.height;

        //if (0) DrawCubeWiresV((Vector3){ position.x + width/2, position.y, position.z + height/2}, (Vector3){ width, 0.25, height }, VIOLET);

        rlCheckRenderBatchLimit(4 + 4*backface);
        rlSetTexture(font->texture.id);

        rlPushMatrix();
            rlTranslatef(position.x, position.y, position.z);

            rlBegin(RL_QUADS);
                rlColor4ub(tint.r, tint.g, tint.b, tint.a);

                // Front Face
                rlNormal3f(0.0f, 1.0f, 0.0f);                                   // Normal Pointing Up
                rlTexCoord2f(tx, ty); rlVertex3f(x,         y, z);              // Top Left Of The Texture and Quad
                rlTexCoord2f(tx, th); rlVertex3f(x,         y, z + height);     // Bottom Left Of The Texture and Quad
                rlTexCoord2f(tw, th); rlVertex3f(x + width, y, z + height);     // Bottom Right Of The Texture and Quad
                rlTexCoord2f(tw, ty); rlVertex3f(x + width, y, z);              // Top Right Of The Texture and Quad

                if (backface)
                {
                    // Back Face
                    rlNormal3f(0.0f, -1.0f, 0.0f);                              // Normal Pointing Down
                    rlTexCoord2f(tx, ty); rlVertex3f(x,         y, z);          // Top Right Of The Texture and Quad
                    rlTexCoord2f(tw, ty); rlVertex3f(x + width, y, z);          // Top Left Of The Texture and Quad
                    rlTexCoord2f(tw, th); rlVertex3f(x + width, y, z + height); // Bottom Left Of The Texture and Quad
                    rlTexCoord2f(tx, th); rlVertex3f(x,         y, z + height); // Bottom Right Of The Texture and Quad
                }
            rlEnd();
        rlPopMatrix();

        rlSetTexture(0);
    }
}
