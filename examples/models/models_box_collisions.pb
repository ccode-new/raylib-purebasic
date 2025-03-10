; /*******************************************************************************************
; *
; *   raylib [models] example - Detect basic 3d collisions (box vs sphere vs box)
; *
; *   Example originally created With raylib 1.3, last time updated With raylib 3.5
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

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [models] example - box collisions" )
If Not IsWindowReady()                  ; After creating the window, we check
  End                                   ; for errors at initialization.
EndIf 

; Define the camera To look into our 3d world
Define.Camera camera 
Init_Vector3(@camera\position, 0.0, 10.0, 10.0)
Init_Vector3(@camera\target, 0.0, 0.0, 0.0)
Init_Vector3(@camera\up, 0.0, 1.0, 0.0)
camera\fovy = 45.0
camera\projection = 0

Define._Vector3 playerPosition 
Init_Vector3(@playerPosition, 0.0, 1.0, 2.0)

Define._Vector3 playerSize 
Init_Vector3(@playerSize, 1.0, 2.0, 1.0)

Define.rl_ColorLong playerColor = #COLOR_GREEN

Define._Vector3 enemyBoxPos 
Init_Vector3(@enemyBoxPos, -4.0, 1.0, 0.0)

Define._Vector3 enemyBoxSize 
Init_Vector3(@enemyBoxSize, 2.0, 2.0, 2.0)

Define._Vector3 enemySpherePos 
Init_Vector3(@enemySpherePos, 4.0, 0.0, 0.0)

Define.rl_float enemySphereSize = 1.5

Define.rl_bool collision = #False

SetTargetFPS(60) ; Set our game to run at 60 frames-per-second
                 ;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose() ; Detect window close button Or ESC key
                              ; Update
                              ;>----------------------------------------------------------------------------------
  
  ; Move player
  If IsKeyDown(#KEY_RIGHT)
    playerPosition\x + 0.2
  ElseIf IsKeyDown(#KEY_LEFT)
    playerPosition\x - 0.2
  ElseIf IsKeyDown(#KEY_DOWN)
    playerPosition\z + 0.2
  ElseIf IsKeyDown(#KEY_UP)
    playerPosition\z - 0.2
  EndIf
  
  collision = #False
  
  Define.BoundingBox playerBox, enemyBox
  Init_Vector3(@playerBox\min, playerPosition\x - playerSize\x / 2, playerPosition\y - playerSize\y / 2, playerPosition\z - playerSize\z / 2)
  Init_Vector3(@playerBox\max, playerPosition\x + playerSize\x / 2, playerPosition\y + playerSize\y / 2, playerPosition\z + playerSize\z / 2)
  
  Init_Vector3(@enemyBox\min, enemyBoxPos\x - enemyBoxSize\x / 2, enemyBoxPos\y - enemyBoxSize\y / 2, enemyBoxPos\z - enemyBoxSize\z / 2)
  Init_Vector3(@enemyBox\max, enemyBoxPos\x + enemyBoxSize\x / 2, enemyBoxPos\y + enemyBoxSize\y / 2, enemyBoxPos\z + enemyBoxSize\z / 2)
  
  ; Check collisions player vs enemy-box
  If CheckCollisionBoxes(@playerBox, @enemyBox) 
    collision = #True
  EndIf
  
  ; Check collisions player vs enemy-sphere
  If CheckCollisionBoxSphere(@playerBox, @enemySpherePos, enemySphereSize)
    collision = #True
  EndIf
  
  If collision = #True
    playerColor = #COLOR_RED
  Else 
    playerColor = #COLOR_GREEN
  EndIf
  
  ;>----------------------------------------------------------------------------------
  
  ; Draw
  ;-----------------------------------------------------------------------------------
  BeginDrawing()
  
  ClearBackground(#COLOR_RAYWHITE)
  
  BeginMode3D(@camera)
  
  ; Draw enemy-box
  DrawCube(@enemyBoxPos, enemyBoxSize\x, enemyBoxSize\y, enemyBoxSize\z, #COLOR_GRAY)
  DrawCubeWires(@enemyBoxPos, enemyBoxSize\x, enemyBoxSize\y, enemyBoxSize\z, #COLOR_DARKGRAY)
  
  ; Draw enemy-sphere
  DrawSphere(@enemySpherePos, enemySphereSize, #COLOR_GRAY)
  DrawSphereWires(@enemySpherePos, enemySphereSize, 16, 16, #COLOR_DARKGRAY)
  
  ; Draw player
  DrawCubeV(@playerPosition, @playerSize, playerColor)
  
  DrawGrid(10, 1.0) ; Draw a grid
  
  EndMode3D()
  
  DrawTextRayLib("Move player with cursors to collide", 220, 40, 20, #COLOR_GRAY)
  
  DrawFPS(10, 10)
  
  EndDrawing()
  ;>----------------------------------------------------------------------------------
  
  ; If we want to have a screenshot
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/models_box_collisions.png")
  EndIf
Wend

; De-Initialization
;>--------------------------------------------------------------------------------------
CloseWindowRayLib() ; Close window and OpenGL context

;---------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 136
; FirstLine = 110
; Optimizer
; EnableThread
; EnableXP
; DPIAware
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)