#include "raylib_pb_helper.h"

int pbhelper_GetShaderLocationAttrib(Shader* shader, const char *attribName) {
	if( shader && attribName ) return GetShaderLocationAttrib(*shader, attribName);
	return false;
}
