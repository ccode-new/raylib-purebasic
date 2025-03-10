#include "raylib_pb_helper.h"

bool pbhelper_IsMusicStreamPlaying(Music* music) {
    if( music ) return IsMusicStreamPlaying(*music);
    return false;
}
