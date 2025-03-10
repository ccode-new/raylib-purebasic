#include "raylib_pb_helper.h"

void pbhelper_UnloadDroppedFiles(FilePathList* files) {
	if( files ) UnloadDroppedFiles(*files);
}
