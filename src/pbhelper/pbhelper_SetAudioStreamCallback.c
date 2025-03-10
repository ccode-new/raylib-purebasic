#include "raylib_pb_helper.h"

void pbhelper_SetAudioStreamCallback(AudioStream* stream, AudioCallback* callback) {
    if( stream ) SetAudioStreamCallback(*stream, *callback);
}
