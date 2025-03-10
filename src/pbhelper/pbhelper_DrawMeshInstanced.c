#include "raylib_pb_helper.h"

void pbhelper_DrawMeshInstanced(Mesh* mesh, Material* material, const Matrix *transforms, int instances) {
    if( mesh && material ) DrawMeshInstanced(*mesh, *material, transforms, instances);
}
