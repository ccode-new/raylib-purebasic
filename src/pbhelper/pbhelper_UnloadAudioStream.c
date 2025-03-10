#include "raylib_pb_helper.h"

void pbhelper_UnloadAudioStream(AudioStream* stream) {
    if( stream ) UnloadAudioStream(*stream);
}
