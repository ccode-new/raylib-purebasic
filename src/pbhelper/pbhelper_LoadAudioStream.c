#include "raylib_pb_helper.h"

void pbhelper_LoadAudioStream(AudioStream* result, unsigned int sampleRate, unsigned int sampleSize, unsigned int channels) {
    if( result ) *result = LoadAudioStream(sampleRate, sampleSize, channels);
}
