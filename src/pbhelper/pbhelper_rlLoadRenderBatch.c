#include "raylib_pb_helper.h"

void pbhelper_rlLoadRenderBatch(rlRenderBatch* result, int numBuffers, int bufferElements) {
    if( result ) *result = rlLoadRenderBatch(numBuffers, bufferElements);
    
}
