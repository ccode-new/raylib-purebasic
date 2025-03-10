#include "raylib_pb_helper.h"

void pbhelper_SetMusicPan(Music* music, float pan) {
    if( music ) SetMusicPan(*music, pan);
}
