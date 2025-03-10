#include "raylib_pb_helper.h"

void pbhelper_rlGetMatrixProjectionStereo(Matrix* result, int eye) {
    if( result ) *result = rlGetMatrixProjectionStereo(eye);
    
}
