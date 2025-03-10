#include "raylib_pb_helper.h"

void pbhelper_GetRayCollisionBox(RayCollision* result, Ray* ray, BoundingBox* box) {
    if( result && ray && box ) *result = GetRayCollisionBox(*ray, *box);
}
