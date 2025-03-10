#include "raylib_pb_helper.h"

void pbhelper_BeginVrStereoMode(VrStereoConfig* config) {
	if( config ) BeginVrStereoMode(*config);
}
