#include "raylib_pb_helper.h"

void pbhelper_AttachAudioStreamProcessor(AudioStream* stream, AudioCallback* processor) {
    if( stream ) AttachAudioStreamProcessor(*stream, *processor);
}
