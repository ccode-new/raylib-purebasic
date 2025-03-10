#include "raylib_pb_helper.h"

void pbhelper_LoadVrStereoConfig(VrStereoConfig* result, VrDeviceInfo* device) {
    if( result && device ) *result = LoadVrStereoConfig(*device);
}
