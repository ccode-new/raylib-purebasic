#include "raylib_pb_helper.h"

void pbhelper_LoadShaderFromMemory(Shader* result, const char *vsCode, const char *fsCode) {
	if( result && vsCode && fsCode ) *result = LoadShaderFromMemory(vsCode, fsCode);
}
