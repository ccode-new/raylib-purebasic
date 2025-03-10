#include "raylib_pb_helper.h"

bool pbhelper_IsKeyUp(int key) {
    if( key >= 0) {
		if( IsKeyUp(key) ){
			return true;
		}
		else {
			return false;
		}
	}
	return false;
}
