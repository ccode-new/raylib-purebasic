; /*******************************************************************************************
; *
; *   raylib [shaders] example - Raymarching shapes generation
; *
; *   NOTE: This example requires raylib OpenGL 3.3 For shaders support And only #version 330
; *         is currently supported. OpenGL ES 2.0 platforms are Not supported at the moment.
; *
; *   Example originally created With raylib 2.0, last time updated With raylib 4.2
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2018-2023 Ramon Santamaria (@raysan5)
; *
; ********************************************************************************************/
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

#GLSL_VERSION = 330

; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 450

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [shaders] example - raymarching shapes" )
If Not IsWindowReady()                ; After creating the window, we check
  End                                 ; for errors at initialization.
EndIf                                 ; In case of error at init we end the program.

Define.Camera camera
Init_Vector3(@camera\position, 2.5, 2.5, 3.0)           ; Camera position
Init_Vector3(@camera\target, 0.0, 0.0, 0.7)             ; Camera looking at point
Init_Vector3(@camera\up, 0.0, 1.0, 0.0)                 ; Camera up vector (rotation towards target)
camera\fovy = 65.0                                      ; Camera field-of-view Y
camera\projection = #CAMERA_PERSPECTIVE

;SetCameraMode(@camera, #CAMERAMODE_FREE)                ; Set camera mode

; Load raymarching shader
; NOTE: Defining 0 (NULL) For vertex shader forces usage of internal Default vertex shader
Define.Shader *shader
LoadShader(*shader, #Null$, "resources/shaders/glsl"+#GLSL_VERSION+"/raymarching.fs")

If IsShaderValid(*shader)
  Debug "ok"
EndIf

; Get shader locations For required uniforms
Define.rl_int viewEyeLoc = GetShaderLocation(*shader, "viewEye")
Define.rl_int viewCenterLoc = GetShaderLocation(*shader, "viewCenter")
Define.rl_int runTimeLoc = GetShaderLocation(*shader, "runTime")
Define.rl_int resolutionLoc = GetShaderLocation(*shader, "resolution")

Dim resolution.rl_float(1) 
resolution(0) = #SCREEN_WIDTH
resolution(1) = #SCREEN_HEIGHT

SetShaderValue(*shader, resolutionLoc, @resolution(), #SHADER_UNIFORM_VEC2)

Define.rl_float fRuntime = 0

SetTargetFPS(60)                    ; Set our game to run at 60 frames-per-second
;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose()       ; Detect window close button Or ESC key
  ; Update
  ;>----------------------------------------------------------------------------------
  UpdateCamera(@camera, #CAMERA_FIRST_PERSON)

  Dim cameraPos.rl_float(2)
  cameraPos(0) = camera\position\x 
  cameraPos(1) = camera\position\y 
  cameraPos(2) = camera\position\z
  
  Dim cameraTarget.rl_float(2)
  cameraTarget(0) = camera\target\x 
  cameraTarget(1) = camera\target\y 
  cameraTarget(2) = camera\target\z

  Define.rl_float deltaTime = GetFrameTime()
  
  fRuntime + deltaTime

  ; Set shader required uniform values
  SetShaderValue(*shader, viewEyeLoc, @cameraPos(), #SHADER_UNIFORM_VEC3)
  SetShaderValue(*shader, viewCenterLoc, @cameraTarget(), #SHADER_UNIFORM_VEC3)
  SetShaderValue(*shader, runTimeLoc, @fRuntime, #SHADER_UNIFORM_FLOAT)

  ; Check If screen is resized
  If IsWindowResized()
    Define.Vector2 resolution
    InitVector2(@resolution, GetScreenWidth(), GetScreenHeight())
    
    SetShaderValue(*shader, resolutionLoc, @resolution, #SHADER_UNIFORM_VEC2)
  EndIf
  ;>----------------------------------------------------------------------------------

  ; Draw
  ;-----------------------------------------------------------------------------------
  BeginDrawing()

  ClearBackground(#COLOR_RAYWHITE)

  ; We only draw a white full-screen rectangle,
  ; frame is generated in shader using raymarching
  BeginShaderMode(*shader)
    DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), #COLOR_WHITE)
  EndShaderMode()

  DrawTextRayLib("(c) Raymarching shader by Iñigo Quilez. MIT License.", GetScreenWidth() - 280, GetScreenHeight() - 20, 10, #COLOR_BLACK)

  EndDrawing()
  ;>----------------------------------------------------------------------------------
  
  ; If we want to have a screenshot
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/shaders_raymarching_shapes.png")
  EndIf
Wend

; De-Initialization
;>--------------------------------------------------------------------------------------
UnloadShader(*shader)       ; Unload shader

CloseWindowRayLib()         ; Close window and OpenGL context
;---------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 48
; FirstLine = 41
; Optimizer
; EnableThread
; EnableXP
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)