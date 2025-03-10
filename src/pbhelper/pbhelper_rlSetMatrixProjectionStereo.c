#include "raylib_pb_helper.h"

void pbhelper_rlSetMatrixProjectionStereo(Matrix* right, Matrix* left) {
    if( right && left ) rlSetMatrixProjectionStereo(*right, *left);
    
}
