#include "raylib_pb_helper.h"

void pbhelper_GetRayCollisionMesh(RayCollision* result, Ray* ray, Mesh* mesh, Matrix* transform) {
    if( result && ray && mesh && transform ) *result = GetRayCollisionMesh(*ray, *mesh, *transform);
}
