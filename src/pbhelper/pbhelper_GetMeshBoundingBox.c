#include "raylib_pb_helper.h"

void pbhelper_GetMeshBoundingBox(BoundingBox* result, Mesh* mesh) {
    if( result && mesh ) *result = GetMeshBoundingBox(*mesh);
}
