#include "raylib_pb_helper.h"

void pbhelper_rlSetRenderBatchActive(rlRenderBatch *batch) {
    if( batch ) rlSetRenderBatchActive(batch);
    
}
