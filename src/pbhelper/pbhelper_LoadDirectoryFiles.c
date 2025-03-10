#include "raylib_pb_helper.h"

void pbhelper_LoadDirectoryFiles(FilePathList* result, const char *dirPath) {
	if( result && dirPath ) *result = LoadDirectoryFiles(dirPath);
}
