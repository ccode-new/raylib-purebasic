#include "raylib_pb_helper.h"

void pbhelper_ImageDrawText(Image *dst, const char *text, int posX, int posY, int fontSize, Color color) {
    if( dst && text ) ImageDrawText(dst, text, posX, posY, fontSize, color);
}
