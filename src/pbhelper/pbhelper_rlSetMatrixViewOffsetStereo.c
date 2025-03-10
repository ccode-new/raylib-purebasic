#include "raylib_pb_helper.h"

void pbhelper_rlSetMatrixViewOffsetStereo(Matrix* right, Matrix* left) {
    if( right && left ) rlSetMatrixViewOffsetStereo(*right, *left);
    
}
