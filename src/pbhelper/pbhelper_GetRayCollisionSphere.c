#include "raylib_pb_helper.h"

void pbhelper_GetRayCollisionSphere(RayCollision* result, Ray* ray, Vector3* center, float radius) {
    if( result && ray && center ) *result = GetRayCollisionSphere(*ray, *center, radius);
}
