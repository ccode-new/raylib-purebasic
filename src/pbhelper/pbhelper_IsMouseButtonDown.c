#include "raylib_pb_helper.h"

bool pbhelper_IsMouseButtonDown(int button) {
    if( button >= 0 ) {
		if( IsMouseButtonDown(button) ){
			return true;
		}
		else {
			return false;
		}
	}
	return false;
}
