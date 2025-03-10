#include "raylib_pb_helper.h"

void pbhelper_UnloadDirectoryFiles(FilePathList* files) {
	if( files ) UnloadDirectoryFiles(*files);
}
