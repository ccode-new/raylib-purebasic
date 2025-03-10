; /*******************************************************************************************
; *
; *   raylib [models] example - first person maze
; *
; *   Example originally created With raylib 2.5, last time updated With raylib 3.5
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2019-2023 Ramon Santamaria (@raysan5)
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

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [models] example - first person maze" )
If Not IsWindowReady()                  ; After creating the window, we check
  End                                   ; for errors at initialization.
EndIf       

; Define the camera To look into our 3d world
Define.Camera camera
Init_Vector3(@camera\position, 0.2, 0.4, 0.2)
Init_Vector3(@camera\target, 0.0, 0.0, 0.0)
Init_Vector3(@camera\up, 0.0, 1.0, 0.0)
camera\fovy = 45.0
camera\projection = 0

Define.Image imMap 
LoadImageRayLib(@imMap, "resources/cubicmap.png") ; Load cubicmap image (RAM)

Define.Texture2D cubicmap 
LoadTextureFromImage(@cubicmap, @imMap) ; Convert image to texture to display (VRAM)

Define.Mesh mesh
Define._Vector3 cubeSize
Init_Vector3(@cubeSize, 1.0, 1.0, 1.0)

GenMeshCubicmap(@mesh, @imMap, @cubeSize)

Define.Model model
LoadModelFromMesh(@model, @mesh)

; NOTE: By Default each cube is mapped To one part of texture atlas
Define.Texture2D texture 
LoadTextureRayLib(@texture, "resources/cubicmap_atlas.png") ; Load map texture

;model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture
CopyStructure(@texture, @model\materials\maps\texture + #MATERIAL_MAP_DIFFUSE, Texture2D)

Define._Vector3 mapPosition 
Init_Vector3(@mapPosition, -16.0, 0.0, -8.0) ; Set model position

;SetCameraMode(@camera, #CAMERAMODE_FIRST_PERSON) ; Set camera mode

SetTargetFPS(60) ; Set our game to run at 60 frames-per-second
;>--------------------------------------------------------------------------------------

DisableCursor()

Define.rl_int x, y

; Main game loop
While Not WindowShouldClose() ; Detect window close button Or ESC key
  
  ; Update
  ;>----------------------------------------------------------------------------------
  Define._Vector3 oldCamPos ; Store old camera position
  With oldCamPos  
    \x = camera\position\x
    \y = camera\position\y
    \z = camera\position\z
  EndWith
  
  UpdateCamera(@camera, #CAMERA_FIRST_PERSON)
  
  ; Check player collision (we simplify To 2D collision detection)
  Define.Vector2 playerPos
  InitVector2(@playerPos, camera\position\x, camera\position\z)
  
  Define.rl_float playerRadius = 0.1 ; Collision radius (player is modelled as a cilinder for collision)
  
  Define.rl_int playerCellX = Int(playerPos\x - mapPosition\x + 0.5)
  Define.rl_int playerCellY = Int(playerPos\y - mapPosition\z + 0.5)
  
  ; Out-of-limits security check
  If playerCellX < 0 
    playerCellX = 0
  ElseIf playerCellX >= cubicmap\width 
    playerCellX = cubicmap\width - 1
  EndIf
  
  If playerCellY < 0
    playerCellY = 0
  ElseIf playerCellY >= cubicmap\height
    playerCellY = cubicmap\height - 1
  EndIf
  
  Define.Rectangle in_rect
  InitRectangle(@in_rect, 0, 0, 0, 0)
  
  ; Check Map collisions using image Data And player position
  ; TODO: Improvement: Just check player surrounding cells For collision
  For y = 0 To cubicmap\height - 1
    For x = 0 To cubicmap\width - 1
      
      With in_rect
        \x = mapPosition\x - 0.5 + x * 1.0
        \y = mapPosition\z - 0.5 + y * 1.0
        \width = 1.0
        \height = 1.0
      EndWith
      
      If (PeekA(imMap\_data + (y * cubicmap\width + x) * 3) = 255) And        ; Collision: white pixel, only check R channel
         (CheckCollisionCircleRec(@playerPos, playerRadius, @in_rect))
        ; Collision detected, reset camera position
        camera\position\x = oldCamPos\x
        camera\position\y = oldCamPos\y
        camera\position\z = oldCamPos\z
      EndIf
    Next
  Next
  
  ;>----------------------------------------------------------------------------------
  
  ; Draw
  ;----------------------------------------------------------------------------------
  BeginDrawing()
  
  ClearBackground(#COLOR_RAYWHITE);
  
  BeginMode3D(@camera)
  DrawModel(@model, @mapPosition, 1.0, #COLOR_WHITE) ; Draw maze map
  EndMode3D()                               
  
  Define.Vector2 draw
  InitVector2(@draw, GetScreenWidth() - cubicmap\width * 4.0 - 20, 20.0)
  DrawTextureEx(cubicmap, @draw, 0.0, 4.0, #COLOR_WHITE);
  DrawRectangleLines(GetScreenWidth() - cubicmap\width * 4 - 20, 20, cubicmap\width * 4, cubicmap\height * 4, #COLOR_GREEN);
  
  ; Draw player position radar
  DrawRectangle(GetScreenWidth() - cubicmap\width * 4 - 20 + playerCellX * 4, 20 + playerCellY * 4, 4, 4, #COLOR_RED)
  
  DrawFPS(10, 10)
  
  EndDrawing()
  ;>----------------------------------------------------------------------------------
  
  ; If we want to have a screenshot
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/models_first_person_maze.png")
  EndIf
  
Wend

;> De-Initialization
;--------------------------------------------------------------------------------------   

UnloadImage(@imMap)           ; Unload image from RAM

UnloadTexture(@cubicmap)      ; Unload cubicmap texture
UnloadTexture(@texture)       ; Unload map texture
UnloadModel(@model)           ; Unload map model

CloseWindowRayLib()           ; Close window And OpenGL context

UnuseModule ray
;---------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 68
; FirstLine = 55
; Optimizer
; EnableThread
; EnableXP
; DPIAware
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)