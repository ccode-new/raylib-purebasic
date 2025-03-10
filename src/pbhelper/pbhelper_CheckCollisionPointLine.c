#include "raylib_pb_helper.h"

bool pbhelper_CheckCollisionPointLine(Vector2* point, Vector2* p1, Vector2* p2, int threshold) {
    if( point && p1 && p2 && threshold ) return CheckCollisionPointLine(*point, *p1, *p2, threshold);
	return false;
}
