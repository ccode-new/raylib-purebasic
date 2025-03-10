#include "raylib_pb_helper.h"

void pbhelper_SetAudioStreamPan(AudioStream* stream, float pan) {
    if( stream ) SetAudioStreamPan(*stream, pan);
}
