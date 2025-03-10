#include "raylib_pb_helper.h"

void pbhelper_rlGetMatrixModelview(Matrix* result) {
    if( result ) *result = rlGetMatrixModelview();
    
}
