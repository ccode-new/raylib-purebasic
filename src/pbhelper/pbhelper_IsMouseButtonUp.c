#include "raylib_pb_helper.h"

bool pbhelper_IsMouseButtonUp(int button) {
    if( button >= 0) {
		if( IsMouseButtonUp(button) ){
			return true;
		}
		else {
			return false;
		}
	}
	return false;
}
