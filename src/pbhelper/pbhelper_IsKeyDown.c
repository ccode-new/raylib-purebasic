#include "raylib_pb_helper.h"

bool pbhelper_IsKeyDown(int key) {
    if( key >= 0) {
		if( IsKeyDown(key) ){
			return true;
		}
		else {
			return false;
		}
	}
	return false;
}
