#include "raylib_pb_helper.h"

void pbhelper_SetSoundPan(Sound* sound, float pan) {
    if( sound ) SetSoundPan(*sound, pan);
}
