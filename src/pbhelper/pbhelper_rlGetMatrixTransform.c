#include "raylib_pb_helper.h"

void pbhelper_rlGetMatrixTransform(Matrix* result) {
    if( result ) *result = rlGetMatrixTransform();
    
}
