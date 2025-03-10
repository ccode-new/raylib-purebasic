#include "raylib_pb_helper.h"

void pbhelper_rlSetUniformMatrix(int locIndex, Matrix* mat) {
    if( mat ) rlSetUniformMatrix(locIndex, *mat);
    
}
