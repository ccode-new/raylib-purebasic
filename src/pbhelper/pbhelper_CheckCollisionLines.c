#include "raylib_pb_helper.h"

bool pbhelper_CheckCollisionLines(Vector2* startPos1, Vector2* endPos1, Vector2* startPos2, Vector2* endPos2, Vector2* collisionPoint) {
    if( startPos1 && endPos1 && startPos2 && endPos2 && collisionPoint ) return CheckCollisionLines(*startPos1, *endPos1, *startPos2, *endPos2, collisionPoint);
	return false;
}
