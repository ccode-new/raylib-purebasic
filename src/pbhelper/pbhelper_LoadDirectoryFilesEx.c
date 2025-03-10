#include "raylib_pb_helper.h"

void pbhelper_LoadDirectoryFilesEx(FilePathList* result, const char *basePath, const char *filter, bool scanSubdirs) {
	if( result && basePath && filter ) *result = LoadDirectoryFilesEx(basePath, filter, scanSubdirs);
}
