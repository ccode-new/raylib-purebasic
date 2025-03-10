#include "raylib_pb_helper.h"

bool pbhelper_ExportFontAsCode(Font* font, const char *fileName) {
    if( font && fileName ) return ExportFontAsCode(*font, fileName);
    return false;
}
