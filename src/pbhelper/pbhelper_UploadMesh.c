#include "raylib_pb_helper.h"

void pbhelper_UploadMesh(Mesh* mesh, bool dynamic) {
    if( mesh ) UploadMesh(mesh, dynamic);
}
