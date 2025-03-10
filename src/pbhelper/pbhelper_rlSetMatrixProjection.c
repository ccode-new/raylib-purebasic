#include "raylib_pb_helper.h"

void pbhelper_rlSetMatrixProjection(Matrix* proj) {
    if( proj ) rlSetMatrixProjection(*proj);
    
}
