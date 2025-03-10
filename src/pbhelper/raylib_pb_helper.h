#include "raylib.h"

#include "rlgl.h"

#ifndef RAYLIB_PB_HELPER_H_INCLUDED
#define RAYLIB_PB_HELPER_H_INCLUDED

#ifdef __cplusplus
   extern “C” {
#endif

// Configuration structure for waving the text
typedef struct WaveTextConfig {
    Vector3 waveRange;
    Vector3 waveSpeed;
    Vector3 waveOffset;
} WaveTextConfig;


typedef void (*pbTraceLogCallback)(int logType, const char *text);
void pbhelper_RaylibTraceLogCallback(int logType, const char *text, va_list args);
void pbhelper_SetTraceLogCallback(pbTraceLogCallback p);

void pbhelper_SetWindowIcon(Image* image);
void pbhelper_GetWindowPosition(Vector2* result);
void pbhelper_BeginMode2D(Camera2D* camera);
void pbhelper_BeginMode3D(Camera3D* camera);
void pbhelper_BeginTextureMode(RenderTexture2D* target);

void pbhelper_GetMonitorPosition(Vector2* result, int monitor);
void pbhelper_GetWindowScaleDPI(Vector2* result);

void pbhelper_BeginVrStereo(VrStereoConfig* config);
void pbhelper_LoadVrStereoConfig(VrStereoConfig* result, VrDeviceInfo* device);
void pbhelper_UnloadVrStereoConfig(VrStereoConfig* config);

void pbhelper_LoadShaderFromMemory(Shader* result, const char *vsCode, const char *fsCode);
int pbhelper_GetShaderLocationAttrib(Shader* shader, const char *attribName);

void pbhelper_LoadDirectoryFiles(FilePathList* result, const char *dirPath);
void pbhelper_LoadDirectoryFilesEx(FilePathList* result, const char *basePath, const char *filter, bool scanSubdirs);
void pbhelper_UnloadDirectoryFiles(FilePathList* files);


void pbhelper_LoadDroppedFiles(FilePathList* result);
void pbhelper_UnloadDroppedFiles(FilePathList* files);

bool pbhelper_IsKeyDown(int key);
bool pbhelper_IsKeyUp(int key);

bool pbhelper_IsMouseButtonDown(int button);
bool pbhelper_IsMouseButtonUp(int button);

void pbhelper_GetMousePosition(Vector2* result);
void pbhelper_GetTouchPosition(Vector2* result, int index);

void pbhelper_GetMouseDelta(Vector2* result);
void pbhelper_GetMouseWheelMoveV(Vector2* result);

void pbhelper_GetGestureDragVector(Vector2* result);
void pbhelper_GetGesturePinchVector(Vector2* result);

//void pbhelper_SetCameraMode(Camera* camera, int mode);

void pbhelper_GetMouseRay(Ray* ray, Vector2* mousePosition, Camera* camera);
void pbhelper_GetCameraMatrix(Matrix* result, Camera* camera);
void pbhelper_GetCameraMatrix2D(Matrix* result, Camera2D* camera);
void pbhelper_GetWorldToScreen(Vector2* result, Vector3* position, Camera* camera);
void pbhelper_GetWorldToScreenEx(Vector2* result, Vector3* position, Camera* camera,  int width, int height);
void pbhelper_GetWorldToScreen2D(Vector2* result, Vector2* position, Camera2D* camera);
void pbhelper_GetScreenToWorld2D(Vector2* result, Vector2* position, Camera2D* camera);

void pbhelper_UpdateCamera(Camera* camera, int mode);
void pbhelper_UpdateCameraPro(Camera* camera, Vector3* movement, Vector3* rotation, float zoom);

void     pbhelper_ColorNormalize(Vector4* result, int color);
long int pbhelper_ColorFromNormalized(Vector4* normalized);
void     pbhelper_ColorToHSV(Vector3* result, int color);

void pbhelper_SetShapesTexture(Texture2D* texture, Rectangle* source);

void pbhelper_DrawPixelV(Vector2* position, Color color);

void pbhelper_DrawLineV(Vector2* startPos, Vector2* endPos, Color color);
void pbhelper_DrawLineEx(Vector2* startPos, Vector2* endPos, float thick, Color color);
void pbhelper_DrawLineBezier(Vector2* startPos, Vector2* endPos, float thick, Color color);

void pbhelper_DrawCircleSector(Vector2* center, float radius, int startAngle, int endAngle, int segments, Color color);
void pbhelper_DrawCircleSectorLines(Vector2* center, float radius, int startAngle, int endAngle, int segments, Color color);
void pbhelper_DrawCircleV(Vector2* center, float radius, Color color);

void pbhelper_DrawRing(Vector2* center, float innerRadius, float outerRadius, int startAngle, int endAngle, int segments, Color color);
void pbhelper_DrawRingLines(Vector2* center, float innerRadius, float outerRadius, int startAngle, int endAngle, int segments, Color color);

void pbhelper_DrawRectangleV(Vector2* position, Vector2* size, Color color);
void pbhelper_DrawRectangleRec(Rectangle* rect, Color color);
void pbhelper_DrawRectanglePro(Rectangle* rect, Vector2* origin, float rotation, Color color);
void pbhelper_DrawRectangleGradientEx(Rectangle* rect, Color col1, Color col2, Color col3, Color col4);
void pbhelper_DrawRectangleLinesEx(Rectangle* rect, float lineThick, Color color);
void pbhelper_DrawRectangleRounded(Rectangle* rect, float roundness, int segments, Color color);
void pbhelper_DrawRectangleRoundedLines(Rectangle* rect, float roundness, int segments, Color color);
void pbhelper_DrawRectangleRoundedLinesEx(Rectangle* rect, float roundness, int segments, float lineThick, Color color);

void pbhelper_DrawTriangle(Vector2* v1, Vector2* v2, Vector2* v3, Color color);
void pbhelper_DrawTriangleLines(Vector2* v1, Vector2* v2, Vector2* v3, Color color);

void pbhelper_DrawPoly(Vector2* center, int sides, float radius, float rotation, Color color);
void pbhelper_DrawPolyLines(Vector2* center, int sides, float radius, float rotation, Color color);

//void pbhelper_DrawLineBezierQuad(Vector2* startPos, Vector2* endPos, Vector2* controlPos, float thick, Color color);
//void pbhelper_DrawLineBezierCubic(Vector2* startPos, Vector2* endPos, Vector2* startControlPos, Vector2* endControlPos, float thick, Color color);
void pbhelper_DrawPolyLinesEx(Vector2* center, int sides, float radius, float rotation, float lineThick, Color color);

bool pbhelper_CheckCollisionRecs(Rectangle* rect1, Rectangle* rect2);
bool pbhelper_CheckCollisionCircles(Vector2* center1, float radius1, Vector2* center2, float radius2);
bool pbhelper_CheckCollisionCircleRec(Vector2* center, float radius, Rectangle* rect);
void pbhelper_GetCollisionRec(Rectangle* result, Rectangle* rect1, Rectangle* rect2);
bool pbhelper_CheckCollisionPointRec(Vector2* point, Rectangle* rect);
bool pbhelper_CheckCollisionPointCircle(Vector2* point, Vector2* center, float radius);
bool pbhelper_CheckCollisionPointTriangle(Vector2* point, Vector2* p1, Vector2* p2, Vector2* p3);

bool pbhelper_CheckCollisionLines(Vector2* startPos1, Vector2* endPos1, Vector2* startPos2, Vector2* endPos2, Vector2* collisionPoint);
bool pbhelper_CheckCollisionPointLine(Vector2* point, Vector2* p1, Vector2* p2, int treshold);

void pbhelper_LoadImage(Image* image, const char *fileName);
//void pbhelper_LoadImageEx(Image* image, Color *pixels, int width, int height);
//void pbhelper_LoadImagePro(Image* image, void *data, int width, int height, int format);
void pbhelper_LoadImageRaw(Image* image, const char *fileName, int width, int height, int format, int headerSize);
void pbhelper_LoadImageAnim(Image* image, const char *fileName, int *frames);
void pbhelper_LoadImageFromMemory(Image* image, const char *fileType, const unsigned char *fileData, int dataSize);
void pbhelper_LoadImageFromTexture(Image* image, Texture2D* texture);
void pbhelper_LoadImageFromScreen(Image* image);
void pbhelper_UnloadImage(Image* image);
void pbhelper_ExportImage(Image* image, const char *fileName);
void pbhelper_ExportImageAsCode(Image* image, const char *fileName);

void pbhelper_GenImageColor(Image* image, int width, int height, Color color);
//void pbhelper_GenImageGradientV(Image* image, int width, int height, Color top, Color bottom);
//void pbhelper_GenImageGradientH(Image* image, int width, int height, Color left, Color right);
void pbhelper_GenImageGradientRadial(Image* image, int width, int height, float density, Color inner, Color outer);
void pbhelper_GenImageChecked(Image* image, int width, int height, int checksX, int checksY, Color col1, Color col2);
void pbhelper_GenImageWhiteNoise(Image* image, int width, int height, float factor);
//void pbhelper_GenImagePerlinNoise(Image* image, int width, int height, int offsetX, int offsetY, float scale);
void pbhelper_GenImageCellular(Image* image, int width, int height, int tileSize);

void pbhelper_ImageCopy(Image* out_copy, Image* in_source);
void pbhelper_ImageFromImage(Image* out_image, Image* in_image, Rectangle* rect);
void pbhelper_ImageText(Image* out_image, const char *text, int fontSize, Color color);
void pbhelper_ImageTextEx(Image* out_image, Font* font, const char *text, float fontSize, float spacing, Color tint);
void pbhelper_ImageAlphaMask(Image* inout_image, Image* alphaMask);
void pbhelper_ImageCrop(Image *inout_image, Rectangle* crop);

void pbhelper_LoadImageColors(Color *result, Image* image);
void pbhelper_LoadImagePalette(Color *result, Image* image, int maxPaletteSize, int *colorCount);

void pbhelper_UnloadImageColors(Color* colors);
void pbhelper_UnloadImagePalette(Color* colors);

void pbhelper_GetImageAlphaBorder(Rectangle* out_rect, Image* in_image, float threshold);

void pbhelper_ImageDrawPixelV(Image *dst, Vector2* position, Color color);
void pbhelper_ImageDrawLineV(Image *dst, Vector2* start, Vector2* end, Color color);
void pbhelper_ImageDrawCircleV(Image *dst, Vector2* center, int radius, Color color);
void pbhelper_ImageDrawRectangleV(Image *dst, Vector2* position, Vector2* size, Color color);
void pbhelper_ImageDrawRectangleRec(Image *dst, Rectangle* rec, Color color);
void pbhelper_ImageDrawRectangleLines(Image *dst, Rectangle* rec, int thick, Color color);
void pbhelper_ImageDraw(Image *dst, Image* src, Rectangle* srcRec, Rectangle* dstRec, Color tint);
void pbhelper_ImageDrawText(Image *dst, const char *text, int posX, int posY, int fontSize, Color color);
void pbhelper_ImageDrawTextEx(Image *dst, Font* font, const char *text, Vector2* position, float fontSize, float spacing, Color color);

void pbhelper_LoadTexture(Texture2D* result, const char *fileName);
void pbhelper_LoadTextureFromImage(Texture2D* result, Image* image);
void pbhelper_LoadTextureCubemap(TextureCubemap* result, Image* image, int layoutType);
void pbhelper_LoadRenderTexture(RenderTexture2D* result, int width, int height);
void pbhelper_UnloadTexture(Texture2D* texture);
void pbhelper_UnloadRenderTexture(RenderTexture2D* target);
void pbhelper_UpdateTexture(Texture2D* texture, const void *pixels);
void pbhelper_GetTextureData(Image* result, Texture2D* texture);
void pbhelper_GetScreenData(Image* result);

void pbhelper_UpdateTextureRec(Texture2D* texture, Rectangle* rec, const void *pixels);

void pbhelper_SetTextureFilter(Texture2D* texture, int filterMode);
void pbhelper_SetTextureWrap(Texture2D* texture, int wrapMode);

void pbhelper_DrawTexture(Texture2D* texture, int posX, int posY, Color tint);
void pbhelper_DrawTextureV(Texture2D* texture, Vector2* position, Color tint);
void pbhelper_DrawTextureEx(Texture2D* texture, Vector2* position, float rotation, float scale, Color tint);
void pbhelper_DrawTextureRec(Texture2D* texture, Rectangle* sourceRec, Vector2* position, Color tint);
//void pbhelper_DrawTextureQuad(Texture2D* texture, Vector2* tiling, Vector2* offset, Rectangle* quad, Color tint);
void pbhelper_DrawTexturePro(Texture2D* texture, Rectangle* sourceRec, Rectangle* destRec, Vector2* origin, float rotation, Color tint);
void pbhelper_DrawTextureNPatch(Texture2D* texture, NPatchInfo* nPatchInfo, Rectangle* destRec, Vector2* origin, float rotation, Color tint);

void pbhelper_DrawTextureTiled(Texture2D* texture, Rectangle* source, Rectangle* dest, Vector2* origin, float rotation, float scale, Color tint);
void pbhelper_DrawTexturePoly(Texture2D* texture, Vector2* center, Vector2 *points, Vector2 *texcoords, int pointCount, Color tint);

void pbhelper_GetFontDefault(Font* result);
void pbhelper_LoadFont(Font* result, const char *fileName);
void pbhelper_LoadFontEx(Font* result, const char *fileName, int fontSize, int *fontChars, int charsCount);
void pbhelper_LoadFontFromImage(Font* result, Image* image, Color key, int firstChar);

void pbhelper_LoadFontFromMemory(Font* result, const char *fileType, const unsigned char *fileData, int dataSize, int fontSize, int *fontChars, int GlyphCount);

void pbhelper_GenImageFontAtlas(Image* result, const GlyphInfo *chars, Rectangle **recs, int charsCount, int fontSize, int padding, int packMethod);
void pbhelper_UnloadFont(Font* font);

bool pbhelper_ExportFontAsCode(Font* font, const char *fileName);

void pbhelper_DrawTextEx(Font* font, const char *text, Vector2* position, float fontSize, float spacing, Color tint);
void pbhelper_DrawTextRec(Font* font, const char *text, Rectangle* rec, float fontSize, float spacing, bool wordWrap, Color tint);
void pbhelper_DrawTextRecEx(Font* font, const char *text, Rectangle* rec, float fontSize, float spacing, bool wordWrap, Color tint, int selectStart, int selectLength, Color selectTint, Color selectBackTint);
void pbhelper_DrawTextCodepoint(Font* font, int codepoint, Vector2* position, float scale, Color tint);

void pbhelper_DrawTextCodepoints(Font* font, const int *codepoints, int count, Vector2* position, float fontSize, float spacing, Color tint);

void pbhelper_DrawTextPro(Font* font, const char *text, Vector2* position, Vector2* origin, float rotation, float fontSize, float spacing, Color tint);

int  pbhelper_MeasureText(const char *text, int fontSize);
void pbhelper_MeasureTextEx(Vector2* result, Font* font, const char *text, float fontSize, float spacing);
int  pbhelper_GetGlyphIndex(Font* font, int codepoint);

void pbhelper_GetGlyphInfo(GlyphInfo* result, Font* font, int codepoint);
void pbhelper_GetGlyphAtlasRec(Rectangle* result, Font* font, int codepoint);

void pbhelper_DrawLine3D(Vector3* startPos, Vector3* endPos, Color color);
void pbhelper_DrawPoint3D(Vector3* position, Color color);
void pbhelper_DrawCircle3D(Vector3* center, float radius, Vector3* rotationAxis, float rotationAngle, Color color);
void pbhelper_DrawCube(Vector3 *position, float width, float height, float length, Color color);
void pbhelper_DrawCubeV(Vector3* position, Vector3* size, Color color);
void pbhelper_DrawCubeWires(Vector3 *position, float width, float height, float length, Color color);
void pbhelper_DrawCubeWiresV(Vector3* position, Vector3* size, Color color);
//void pbhelper_DrawCubeTexture(Texture2D* texture, Vector3* position, float width, float height, float length, Color color);
void pbhelper_DrawSphere(Vector3* centerPos, float radius, Color color);
void pbhelper_DrawSphereEx(Vector3* centerPos, float radius, int rings, int slices, Color color);
void pbhelper_DrawSphereWires(Vector3* centerPos, float radius, int rings, int slices, Color color);
void pbhelper_DrawCylinder(Vector3* position, float radiusTop, float radiusBottom, float height, int slices, Color color);
void pbhelper_DrawCylinderWires(Vector3* position, float radiusTop, float radiusBottom, float height, int slices, Color color);
void pbhelper_DrawPlane(Vector3* centerPos, Vector2* size, Color color);
void pbhelper_DrawRay(Ray* ray, Color color);

void pbhelper_DrawTriangle3D(Vector3* v1, Vector3* v2, Vector3* v3, Color color);
void pbhelper_DrawTriangleStrip3D(Vector3* points, int pointCount, Color color);
//void pbhelper_DrawCubeTextureRec(Texture2D* texture, Rectangle* source, Vector3* position, float width, float height, float length, Color color);
void pbhelper_DrawCylinderEx(Vector3* startPos, Vector3* endPos, float startRadius, float endRadius, int sides, Color color);
void pbhelper_DrawCylinderWiresEx(Vector3* startPos, Vector3* endPos, float startRadius, float endRadius, int sides, Color color);

void pbhelper_LoadModel(Model* result, const char *fileName);
void pbhelper_LoadModelFromMesh(Model* result, Mesh* mesh);
void pbhelper_UnloadModel(Model* model);

void pbhelper_ExportMesh(Mesh* mesh, const char *fileName);
void pbhelper_UnloadMesh(Mesh* mesh);

//void pbhelper_UnloadModelKeepMeshes(Model* model);

void pbhelper_GetModelBoundingBox(BoundingBox* result, Model* model);

void pbhelper_LoadMaterialDefault(Material* result);
void pbhelper_UnloadMaterial(Material* material);
void pbhelper_SetMaterialTexture(Material* material, int mapType, Texture2D* texture);

void pbhelper_UpdateModelAnimation(Model* model, ModelAnimation* anim, int frame);
void pbhelper_UnloadModelAnimation(ModelAnimation* anim);

void pbhelper_UnloadModelAnimations(ModelAnimation* anim, unsigned int count);

bool pbhelper_IsModelAnimationValid(Model* model, ModelAnimation* anim);

void pbhelper_GenMeshPoly(Mesh* result, int sides, float radius);
void pbhelper_GenMeshPlane(Mesh* result, float width, float length, int resX, int resZ);
void pbhelper_GenMeshCube(Mesh* result, float width, float height, float length);
void pbhelper_GenMeshSphere(Mesh* result, float radius, int rings, int slices);
void pbhelper_GenMeshHemiSphere(Mesh* result, float radius, int rings, int slices);
void pbhelper_GenMeshCylinder(Mesh* result, float radius, float height, int slices);
void pbhelper_GenMeshTorus(Mesh* result, float radius, float size, int radSeg, int sides);
void pbhelper_GenMeshKnot(Mesh* result, float radius, float size, int radSeg, int sides);
void pbhelper_GenMeshHeightmap(Mesh* result, Image* heightmap, Vector3* size);
void pbhelper_GenMeshCubicmap(Mesh* result, Image* cubicmap, Vector3* cubeSize);

void pbhelper_UploadMesh(Mesh* mesh, bool dynamic);
void pbhelper_UpdateMeshBuffer(Mesh* mesh, int index, const void *data, int dataSize, int offset);

void pbhelper_GetMeshBoundingBox(BoundingBox* result, Mesh* mesh);
void pbhelper_GenMeshTangents(Mesh* mesh);
void pbhelper_GenMeshCone(Mesh* result, float radius, float height, int slices);

void pbhelper_DrawModel(Model* model, Vector3* position, float scale, Color tint);
void pbhelper_DrawModelEx(Model* model, Vector3* position, Vector3* rotationAxis, float rotationAngle, Vector3* scale, Color tint);
void pbhelper_DrawModelWires(Model* model, Vector3* position, float scale, Color tint);
void pbhelper_DrawModelWiresEx(Model* model, Vector3* position, Vector3* rotationAxis, float rotationAngle, Vector3* scale, Color tint);
void pbhelper_DrawBoundingBox(BoundingBox* box, Color color);
void pbhelper_DrawBillboard(Camera* camera, Texture2D* texture, Vector3* center, float size, Color tint);
void pbhelper_DrawBillboardRec(Camera* camera, Texture2D* texture, Rectangle* sourceRec, Vector3* position, Vector2* size, Color tint);

void pbhelper_DrawBillboardPro(Camera* camera, Texture2D* texture, Rectangle* sourceRec, Vector3* position, Vector3* up, Vector2* size, Vector2* origin, float rotation, Color tint);

void pbhelper_DrawMeshInstanced(Mesh* mesh, Material* material, const Matrix* transforms, int instances);

bool pbhelper_CheckCollisionSpheres(Vector3* centerA, float radiusA, Vector3* centerB, float radiusB);
bool pbhelper_CheckCollisionBoxes(BoundingBox* box1, BoundingBox* box2);
bool pbhelper_CheckCollisionBoxSphere(BoundingBox* box, Vector3* center, float radius);

void pbhelper_GetRayCollisionSphere(RayCollision* result, Ray* ray, Vector3* center, float radius);
void pbhelper_GetRayCollisionBox(RayCollision* result, Ray* ray, BoundingBox* box);
void pbhelper_GetRayCollisionMesh(RayCollision* result, Ray* ray, Mesh* mesh, Matrix* transform);
void pbhelper_GetRayCollisionTriangle(RayCollision* result, Ray* ray, Vector3* p1, Vector3* p2, Vector3* p3);
void pbhelper_GetRayCollisionQuad(RayCollision* result, Ray* ray, Vector3* p1, Vector3* p2, Vector3* p3, Vector3* p4);

void pbhelper_LoadShader(Shader* result, const char *vsFileName, const char *fsFileName);
void pbhelper_LoadShaderCode(Shader* result, const char *vsCode, const char *fsCode);
void pbhelper_UnloadShader(Shader* shader);
void pbhelper_GetShaderDefault(Shader* result);
void pbhelper_GetTextureDefault(Texture2D* result);
void pbhelper_GetShapesTexture(Texture2D* result);
void pbhelper_GetShapesTextureRec(Rectangle* result);
void pbhelper_SetShapesTexture(Texture2D* texture, Rectangle* source);

int  pbhelper_GetShaderLocation(Shader* shader, const char *uniformName);
void pbhelper_SetShaderValue(Shader* shader, int uniformLoc, const void *value, int uniformType);
void pbhelper_SetShaderValueV(Shader* shader, int uniformLoc, const void *value, int uniformType, int count);
void pbhelper_SetShaderValueMatrix(Shader* shader, int uniformLoc, Matrix* mat);
void pbhelper_SetShaderValueTexture(Shader* shader, int uniformLoc, Texture2D* texture);
void pbhelper_SetMatrixProjection(Matrix* proj);
void pbhelper_SetMatrixModelview(Matrix* view);
void pbhelper_GetMatrixModelview(Matrix* result);
void pbhelper_GetMatrixProjection(Matrix* result);

void pbhelper_GenTextureCubemap(Texture2D* result, Shader* shader, Texture2D* map, int size);
void pbhelper_GenTextureIrradiance(Texture2D* result, Shader* shader, Texture2D* cubemap, int size);
void pbhelper_GenTexturePrefilter(Texture2D* result, Shader* shader, Texture2D* cubemap, int size);
void pbhelper_GenTextureBRDF(Texture2D* result, Shader* shader, int size);

void pbhelper_BeginShaderMode(Shader* shader);

void pbhelper_SetVrConfiguration(VrDeviceInfo* info, Shader* distortion);

void pbhelper_LoadWave(Wave* result, const char *fileName);
void pbhelper_LoadSound(Sound* result, const char *fileName);
void pbhelper_LoadSoundFromWave(Sound* result, Wave* wave);
void pbhelper_UpdateSound(Sound* sound, const void *data, int samplesCount);
void pbhelper_UnloadWave(Wave* wave);
void pbhelper_UnloadSound(Sound* sound);
void pbhelper_ExportWave(Wave* wave, const char *fileName);
void pbhelper_ExportWaveAsCode(Wave* wave, const char *fileName);

void pbhelper_LoadWaveFromMemory(Wave* result, const char *fileType, const unsigned char *fileData, int dataSize);

void pbhelper_PlaySound(Sound* sound);
void pbhelper_StopSound(Sound* sound);
void pbhelper_PauseSound(Sound* sound);
void pbhelper_ResumeSound(Sound* sound);
//void pbhelper_PlaySoundMulti(Sound* sound);

bool pbhelper_IsSoundPlaying(Sound* sound);
void pbhelper_SetSoundVolume(Sound* sound, float volume);
void pbhelper_SetSoundPitch(Sound* sound, float pitch);

void pbhelper_SetSoundPan(Sound* sound, float pan);

void pbhelper_WaveCopy(Wave* result, Wave* wave);
float* pbhelper_GetWaveData(Wave* wave);

void pbhelper_LoadMusicStream(Music* result, const char *fileName);
void pbhelper_UnloadMusicStream(Music* music);
void pbhelper_PlayMusicStream(Music* music);
void pbhelper_UpdateMusicStream(Music* music);
void pbhelper_StopMusicStream(Music* music);
void pbhelper_PauseMusicStream(Music* music);
void pbhelper_ResumeMusicStream(Music* music);
bool pbhelper_IsMusicStreamPlaying(Music* music);
void pbhelper_SetMusicVolume(Music* music, float volume);
void pbhelper_SetMusicPitch(Music* music, float pitch);
void pbhelper_SetMusicLoopCount(Music* music, int count);
float pbhelper_GetMusicTimeLength(Music* music);
float pbhelper_GetMusicTimePlayed(Music* music);

void pbhelper_LoadMusicStreamFromMemory(Music* result, const char *fileType, const unsigned char *data, int dataSize);
void pbhelper_SetMusicPan(Music* music, float pan);

void pbhelper_LoadAudioStream(AudioStream* result, unsigned int sampleRate, unsigned int sampleSize, unsigned int channels);
void pbhelper_UpdateAudioStream(AudioStream* stream, const void *data, int samplesCount);
void pbhelper_UnloadAudioStream(AudioStream* stream);
bool pbhelper_IsAudioStreamProcessed(AudioStream* stream);
void pbhelper_PlayAudioStream(AudioStream* stream);
void pbhelper_PauseAudioStream(AudioStream* stream);
void pbhelper_ResumeAudioStream(AudioStream* stream);
bool pbhelper_IsAudioStreamPlaying(AudioStream* stream);
void pbhelper_StopAudioStream(AudioStream* stream);
void pbhelper_SetAudioStreamVolume(AudioStream* stream, float volume);
void pbhelper_SetAudioStreamPitch(AudioStream* stream, float pitch);
void pbhelper_SetAudioStreamPan(AudioStream* stream, float pan);

void pbhelper_SetAudioStreamCallback(AudioStream* stream, AudioCallback* callback);
void pbhelper_AttachAudioStreamProcessor(AudioStream* stream, AudioCallback* processor);
void pbhelper_DetachAudioStreamProcessor(AudioStream* stream, AudioCallback* processor);

// Special_Functions

// Draw text using font inside rectangle limits
void pbhelper_DrawTextBoxedSelectable(Font* font, const char *text, Rectangle* rec, float fontSize, float spacing, bool wordWrap, Color tint, int selectStart, int selectLength, Color selectTint, Color selectBackTint);

// Draw a codepoint in 3D space
void pbhelper_DrawTextCodepoint3D(Font* font, int codepoint, Vector3 position, float fontSize, bool backface, Color tint);
// Draw a 2D text in 3D space
void pbhelper_DrawText3D(Font* font, const char *text, Vector3* position, float fontSize, float fontSpacing, float lineSpacing, bool backface, Color tint);
// Measure a text in 3D. For some reason `MeasureTextEx()` just doesn't seem to work so i had to use this instead.
void pbhelper_MeasureText3D(Vector3* result, Font* font, const char *text, float fontSize, float fontSpacing, float lineSpacing);

// Draw a 2D text in 3D space and wave the parts that start with `~~` and end with `~~`.
// This is a modified version of the original code by @Nighten found here https://github.com/NightenDushi/Raylib_DrawTextStyle
void pbhelper_DrawTextWave3D(Font* font, const char *text, Vector3* position, float fontSize, float fontSpacing, float lineSpacing, bool backface, WaveTextConfig* config, float time, Color tint);
// Measure a text in 3D ignoring the `~~` chars.
void pbhelper_MeasureTextWave3D(Vector3* result, Font* font, const char* text, float fontSize, float fontSpacing, float lineSpacing);

// Generates a nice color with a random hue
void pbhelper_GenerateRandomColor(Color *result, float s, float v);


// Partikel-Engine

//float pbhelper_GetRandomFloat(float min, float max);
//void pbhelper_NormalizeV2(Vector2* result, Vector2* v);
//void pbhelper_RotateV2(Vector2* result, Vector2* v, float degrees);
//long int pbhelper_LinearFade(Color c1, Color c2, float fraction);

/*
bool pbhelper_Particle_DeactivatorAge(Particle* p);

void pbhelper_Particle_New(Particle* result, bool (*deactivatorFunc)(struct Particle *));
void pbhelper_Particle_Free(Particle* p);
void pbhelper_Particle_Init(Particle* p, EmitterConfig *cfg);
void pbhelper_Particle_Update(Particle *p, float dt);

void pbhelper_Emitter_New(Emitter* result, EmitterConfig cfg);
bool pbhelper_Emitter_Reinit(Emitter *e, EmitterConfig cfg);
void pbhelper_Emitter_Start(Emitter *e);
void pbhelper_Emitter_Stop(Emitter *e);
void pbhelper_Emitter_Free(Emitter *e);
void pbhelper_Emitter_Burst(Emitter *e);
unsigned long pbhelper_Emitter_Update(Emitter *e, float dt);
void pbhelper_Emitter_Draw(Emitter *e);

void pbhelper_ParticleSystem_New(ParticleSystem* result);
bool pbhelper_ParticleSystem_Register(ParticleSystem *ps, Emitter *emitter);
bool pbhelper_ParticleSystem_Deregister(ParticleSystem *ps, Emitter *emitter);
void pbhelper_ParticleSystem_SetOrigin(ParticleSystem *ps, Vector2 origin);
void pbhelper_ParticleSystem_Start(ParticleSystem *ps);
void pbhelper_ParticleSystem_Stop(ParticleSystem *ps);
void pbhelper_ParticleSystem_Burst(ParticleSystem *ps);
void pbhelper_ParticleSystem_Draw(ParticleSystem *ps);
unsigned long pbhelper_ParticleSystem_Update(ParticleSystem *ps, float dt);
void pbhelper_ParticleSystem_Free(ParticleSystem *ps);
*/

//gl
void pbhelper_rlLoadRenderBatch(rlRenderBatch* result, int numBuffers, int bufferElements); // Load a render batch system
void pbhelper_rlUnloadRenderBatch(rlRenderBatch *batch); // Unload render batch system
void pbhelper_rlDrawRenderBatch(rlRenderBatch *batch); // Draw render batch data (Update->Draw->Reset)
void pbhelper_rlSetRenderBatchActive(rlRenderBatch *batch); // Set the active render batch for rlgl (NULL for default internal)

void pbhelper_rlSetUniformMatrix(int locIndex, Matrix* mat); // Set shader value matrix

void pbhelper_rlGetMatrixModelview(Matrix* result); // Get internal modelview matrix
void pbhelper_rlGetMatrixProjection(Matrix* result); // Get internal projection matrix
void pbhelper_rlGetMatrixTransform(Matrix* result); // Get internal accumulated transform matrix
void pbhelper_rlGetMatrixProjectionStereo(Matrix* result, int eye); // Get internal projection matrix for stereo render (selected eye)
void pbhelper_rlGetMatrixViewOffsetStereo(Matrix* result, int eye); // Get internal view offset matrix for stereo render (selected eye)
void pbhelper_rlSetMatrixProjection(Matrix* proj); // Set a custom projection matrix (replaces internal projection matrix)
void pbhelper_rlSetMatrixModelview(Matrix* view); // Set a custom modelview matrix (replaces internal modelview matrix)
void pbhelper_rlSetMatrixProjectionStereo(Matrix* right, Matrix* left); // Set eyes projection matrices for stereo rendering
void pbhelper_rlSetMatrixViewOffsetStereo(Matrix* right, Matrix* left); // Set eyes view offsets matrices for stereo rendering
        
     

#ifdef __cplusplus
   }
#endif

#endif /* RAYLIB_PB_HELPER_H_INCLUDED */
