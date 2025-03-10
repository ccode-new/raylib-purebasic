#include "raylib_pb_helper.h"

void pbhelper_UpdateMeshBuffer(Mesh* mesh, int index, const void *data, int dataSize, int offset) {
    if( mesh ) UpdateMeshBuffer(*mesh, index, data, dataSize, offset);
}
