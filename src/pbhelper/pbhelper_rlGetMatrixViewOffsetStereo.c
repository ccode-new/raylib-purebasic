#include "raylib_pb_helper.h"

void pbhelper_rlGetMatrixViewOffsetStereo(Matrix* result, int eye) {
    if( result ) *result = rlGetMatrixViewOffsetStereo(eye);
    
}
