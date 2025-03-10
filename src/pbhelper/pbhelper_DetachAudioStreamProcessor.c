#include "raylib_pb_helper.h"

void pbhelper_DetachAudioStreamProcessor(AudioStream* stream, AudioCallback* processor) {
    if (stream) DetachAudioStreamProcessor(*stream, *processor);
}
