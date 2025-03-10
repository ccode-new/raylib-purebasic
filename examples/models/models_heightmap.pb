; /*******************************************************************************************
; *
; *   raylib [models] example - Heightmap loading And drawing
; *
; *   Example originally created With raylib 1.8, last time updated With raylib 3.5
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2015-2023 Ramon Santamaria (@raysan5)
; *
; ********************************************************************************************/
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 450

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [models] example - heightmap loading and drawing" )
If Not IsWindowReady()                ; After creating the window, we check
  End                                 ; for errors at initialization.
EndIf                                 ; In case of error at init we end the program.

; Define our custom camera To look into our 3d world
Define.Camera camera
Init_Vector3(@camera\position, 18.0, 18.0, 18.0)      ; Camera position
Init_Vector3(@camera\target, 0.0, 0.0, 0.0)           ; Camera looking at point
Init_Vector3(@camera\up, 0.0, 1.0, 0.0)               ; Camera up vector (rotation towards target)
camera\fovy = 45.0                                    ; Camera field-of-view Y
camera\projection = #CAMERA_PERSPECTIVE           ; Camera mode type

Define.Image image 
LoadImageRayLib(@image, "resources/heightmap.png")          ; Load heightmap image (RAM)

Define.Texture2D texture
LoadTextureFromImage(@texture, @image);               ; Convert image to texture (VRAM)

Define.Mesh mesh 
Define._Vector3 meshSize
Init_Vector3(@meshSize, 16, 8, 16)
GenMeshHeightmap(@mesh, @image, @meshSize)            ; Generate heightmap mesh (RAM and VRAM)

Define.Model model 
LoadModelFromMesh(@model, @mesh)                      ; Load model from generated mesh

;model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture ; Set map diffuse texture
CopyMemory(@texture, @model\materials\maps\texture + #MATERIAL_MAP_DIFFUSE, SizeOf(texture))

Define._Vector3 mapPosition 
Init_Vector3(@mapPosition, -8.0, 0.0, -8.0)           ; Define model position

UnloadImage(@image)                                   ; Unload heightmap image from RAM, already uploaded to VRAM

;SetCameraMode(@camera, #CAMERA_ORBITAL)           ; Set an orbital camera mode

SetTargetFPS(60)                                      ; Set our game to run at 60 frames-per-second
;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose()                         ; Detect window close button Or ESC key
  ; Update
  ;>----------------------------------------------------------------------------------
  UpdateCamera(@camera, #CAMERA_ORBITAL)
  ;-----------------------------------------------------------------------------------

  ; Draw
  ;-----------------------------------------------------------------------------------
  BeginDrawing()

  ClearBackground(#COLOR_RAYWHITE)

  BeginMode3D(@camera)

    DrawModel(@model, @mapPosition, 1.0, #COLOR_RED)

    DrawGrid(20, 1.0)

  EndMode3D()

  DrawTexture(@texture, #SCREEN_WIDTH - texture\width - 20, 20, #COLOR_WHITE)
  DrawRectangleLines(#SCREEN_WIDTH - texture\width - 20, 20, texture\width, texture\height, #COLOR_GREEN)

  DrawFPS(10, 10)

  EndDrawing()
  ;>----------------------------------------------------------------------------------
  
  ; If we want to have a screenshot
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/models_heightmap.png")
  EndIf
Wend

; De-Initialization
;>--------------------------------------------------------------------------------------
UnloadTexture(@texture)      ; Unload texture
UnloadModel(@model)          ; Unload model

CloseWindowRayLib()         ; Close window And OpenGL context
;---------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 68
; FirstLine = 56
; Optimizer
; EnableThread
; EnableXP
; Compiler = PureBasic 6.00 LTS - C Backend (MacOS X - arm64)