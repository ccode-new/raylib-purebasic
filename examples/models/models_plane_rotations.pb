; /*******************************************************************************************
; *
; *   raylib [models] example - Plane rotations (yaw, pitch, roll)
; *
; *   Example originally created With raylib 1.8, last time updated With raylib 4.0
; *
; *   Example contributed by Berni (@Berni8k) And reviewed by Ramon Santamaria (@raysan5)
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2017-2023 Berni (@Berni8k) And Ramon Santamaria (@raysan5)
; *
; ********************************************************************************************/
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

XIncludeFile "raymath.pbi"              ; Required For: MatrixRotateXYZ()

; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 450

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [models] example - plane rotations (yaw, pitch, roll)" )
If Not IsWindowReady()                  ; After creating the window, we check
  End                                   ; for errors at initialization.
EndIf 

Define.Camera camera

Init_Vector3(@camera\position, 0.0, 50.0, -120.0)       ; Camera position perspective
Init_Vector3(@camera\target, 0.0, 0.0, 0.0)             ; Camera looking at point
Init_Vector3(@camera\up, 0.0, 1.0, 0.0)                 ; Camera up vector (rotation towards target)
camera\fovy = 30.0                                      ; Camera field-of-view Y
camera\projection = #CAMERA_PERSPECTIVE             ; Camera type

Define.Model model 
LoadModel(@model, "resources/models/obj/plane.obj")     ; Load model

Define.Texture2D texture 
LoadTextureRayLib(@texture, "resources/models/obj/plane_diffuse.png")                           ; Load model texture

CopyStructure(@texture, @model\materials\maps\texture + #MATERIAL_MAP_DIFFUSE, Texture2D)         

Define.rl_float pitch = 0.0
Define.rl_float roll = 0.0
Define.rl_float yaw = 0.0

SetTargetFPS(60)  ; Set our game to run at 60 frames-per-second
;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose() ; Detect window close button Or ESC key
  ; Update
  ;>----------------------------------------------------------------------------------
  ; Plane Pitch (x-axis) controls
  If IsKeyDown(#KEY_DOWN) 
    pitch + 0.6
  ElseIf IsKeyDown(#KEY_UP) 
    pitch - 0.6
  Else
    If pitch > 0.3
      pitch - 0.3
    ElseIf pitch < -0.3 
      pitch + 0.3
    EndIf
  EndIf

  ; Plane Yaw (y-axis) controls
  If IsKeyDown(#KEY_S)
    yaw - 1.0
  ElseIf IsKeyDown(#KEY_A) 
    yaw + 1.0
  Else
    If yaw > 0.0 
      yaw - 0.5
    ElseIf yaw < 0.0 
      yaw + 0.5
    EndIf
  EndIf

  ; Plane Roll (z-axis) controls
  If IsKeyDown(#KEY_LEFT) 
    roll - 1.0
  ElseIf IsKeyDown(#KEY_RIGHT) 
    roll + 1.0
  Else
    If roll > 0.0 
      roll - 0.5
    ElseIf roll < 0.0 
      roll + 0.5
    EndIf
  EndIf

  ; Tranformation matrix For rotations
  Define._Vector3 mVec
  Init_Vector3(@mVec, #DEG2RAD * pitch, #DEG2RAD * yaw, #DEG2RAD * roll)
  
  MatrixRotateXYZ(@model\transform, @mVec)
  
  ;>----------------------------------------------------------------------------------

  ; Draw
  ;-----------------------------------------------------------------------------------
  BeginDrawing()

  ClearBackground(#COLOR_RAYWHITE)

  ; Draw 3D model (recomended To draw 3D always before 2D)
  BeginMode3D(@camera)
  
  Define.Vector2 drawVec
  Init_Vector3(@drawVec, 0.0, -8.0, 0.0)
  
    DrawModel(@model, @drawVec, 1.0, #COLOR_WHITE)  ; Draw 3d model with texture
    DrawGrid(10, 10.0)

  EndMode3D()

  ; Draw controls info
  DrawRectangle(30, 370, 260, 70, Fade(#COLOR_GREEN, 0.5))
  DrawRectangleLines(30, 370, 260, 70, Fade(#COLOR_DARKGREEN, 0.5))
  
  DrawTextRayLib("Pitch controlled with: KEY_UP / KEY_DOWN", 40, 380, 10, #COLOR_DARKGRAY)
  DrawTextRayLib("Roll controlled with: KEY_LEFT / KEY_RIGHT", 40, 400, 10, #COLOR_DARKGRAY)
  DrawTextRayLib("Yaw controlled with: KEY_A / KEY_S", 40, 420, 10, #COLOR_DARKGRAY)

  DrawTextRayLIb("(c) WWI Plane Model created by GiaHanLam", #SCREEN_WIDTH - 240, #SCREEN_HEIGHT - 20, 10, #COLOR_DARKGRAY)

  EndDrawing()
  ;-----------------------------------------------------------------------------------
Wend

; De-Initialization
;>--------------------------------------------------------------------------------------
UnloadModel(@model)         ; Unload model data

CloseWindowRayLib()         ; Close window And OpenGL context
;---------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 47
; FirstLine = 43
; EnableXP