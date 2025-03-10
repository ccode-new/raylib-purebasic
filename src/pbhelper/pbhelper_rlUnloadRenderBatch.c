#include "raylib_pb_helper.h"

void pbhelper_rlUnloadRenderBatch(rlRenderBatch *batch) {
    if( batch ) rlUnloadRenderBatch(*batch);
    
}
