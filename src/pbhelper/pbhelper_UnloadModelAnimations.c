#include "raylib_pb_helper.h"

void pbhelper_UnloadModelAnimations(ModelAnimation* anim, unsigned int count) {
    if( anim ) UnloadModelAnimations(anim, count);
}
