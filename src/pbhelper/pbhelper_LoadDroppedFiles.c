#include "raylib_pb_helper.h"

void pbhelper_LoadDroppedFiles(FilePathList* result) {
	if( result ) *result = LoadDroppedFiles();
}
