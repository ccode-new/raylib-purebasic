#include "raylib_pb_helper.h"

void pbhelper_UpdateCameraPro(Camera* camera, Vector3* movement, Vector3* rotation, float zoom){
    if( camera ) UpdateCameraPro(camera, *movement, *rotation, zoom);
}
