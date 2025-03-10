#include "raylib_pb_helper.h"

void pbhelper_GetRayCollisionQuad(RayCollision* result, Ray* ray, Vector3* p1, Vector3* p2, Vector3* p3, Vector3* p4) {
    if( result && ray && p1 && p2 && p3 && p4 ) *result = GetRayCollisionQuad(*ray, *p1, *p2, *p3, *p4);
}
