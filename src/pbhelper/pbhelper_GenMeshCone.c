#include "raylib_pb_helper.h"

void pbhelper_GenMeshCone(Mesh* result, float radius, float height, int slices) {
    if( result ) *result = GenMeshCone(radius, height, slices);
}
