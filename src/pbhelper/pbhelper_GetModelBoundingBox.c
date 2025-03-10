#include "raylib_pb_helper.h"

void pbhelper_GetModelBoundingBox(BoundingBox* result, Model* model) {
    if( result && model ) *result = GetModelBoundingBox(*model);
}
