#include "raylib_pb_helper.h"
#include "rlgl.h"

void pbhelper_DrawTextPro(Font* font, const char *text, Vector2* position, Vector2* origin, float rotation, float fontSize, float spacing, Color tint) {
    //if( font && text && position && origin) 
    
    //DrawTextEx(*font, text, *position, fontSize, spacing, tint);
    if( font && text && position && origin) //DrawTextEx(*font, text, *position, fontSize, spacing, tint);
    rlPushMatrix();

        rlTranslatef(position->x, position->y, 0.0f);
        rlRotatef(rotation, 0.0f, 0.0f, 1.0f);
        rlTranslatef(-origin->x, -origin->y, 0.0f);
        rlTranslatef(origin->x, origin->x, 0.0f);

        DrawTextEx(*font, text, (Vector2){ 0.0f, 0.0f }, fontSize, spacing, tint);

    rlPopMatrix();
}
