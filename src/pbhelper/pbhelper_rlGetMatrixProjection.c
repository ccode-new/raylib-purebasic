#include "raylib_pb_helper.h"

void pbhelper_rlGetMatrixProjection(Matrix* result) {
    if( result ) *result = rlGetMatrixProjection();
    
}
