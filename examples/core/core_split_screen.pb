; /*******************************************************************************************
; *
; *   raylib [core] example - split screen
; *
; *   Example originally created With raylib 3.7, last time updated With raylib 4.0
; *
; *   Example contributed by Jeffery Myers (@JeffM2501) And reviewed by Ramon Santamaria (@raysan5)
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2021-2023 Jeffery Myers (@JeffM2501)
; *
; ********************************************************************************************/
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

Global.Camera cameraPlayer1
Global.Camera cameraPlayer2

;// Scene drawing
Procedure DrawScene()
  Protected.rl_int count = 5
  Protected.rl_float spacing = 4
  Protected._Vector3 planePosV, cubePosV
  Protected.Vector2 planeSizeV
  Protected.rl_int x, z
  
  Init_Vector3(@planePosV, 0, 0, 0)
  InitVector2(@planeSizeV, 50, 50)
  
  ; Grid of cube trees on a plane To make a "world"
  DrawPlane(@planePosV, @planeSizeV, #COLOR_BEIGE) ;// Simple world plane
  
  For x = (-count * spacing) To (count * spacing) Step 4
    For z = -count * spacing To (count * spacing) Step 4
      Init_Vector3(@cubePosV, x, 1.5, z)
      DrawCube(@cubePosV, 1, 1, 1, #COLOR_LIME)
      
      Init_Vector3(@cubePosV, x, 0.5, z)
      DrawCube(@cubePosV, 0.25, 1, 0.25, #COLOR_BROWN)
    Next
  Next
  
  ; Draw a cube at each player's position
  DrawCube(cameraPlayer1\position, 1, 1, 1, #COLOR_RED)
  DrawCube(cameraPlayer2\position, 1, 1, 1, #COLOR_BLUE)
EndProcedure


; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 450

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [core] example - split screen" )
If Not IsWindowReady()                ; After creating the window, we check
  End                                 ; for errors at initialization.
EndIf                                 ; In case of error at init we end the program.

; Setup player 1 camera And screen
cameraPlayer1\fovy = 45.0
cameraPlayer1\up\y = 1.0
cameraPlayer1\target\y = 1.0
cameraPlayer1\position\z = -3.0
cameraPlayer1\position\y = 1.0

Define.RenderTexture screenPlayer1 
LoadRenderTexture(@screenPlayer1, #SCREEN_WIDTH / 2, #SCREEN_HEIGHT)

; Setup player two camera And screen
cameraPlayer2\fovy = 45.0
cameraPlayer2\up\y = 1.0
cameraPlayer2\target\y = 3.0
cameraPlayer2\position\x = -3.0
cameraPlayer2\position\y = 3.0

Define.RenderTexture screenPlayer2 
LoadRenderTexture(@screenPlayer2, #SCREEN_WIDTH / 2, #SCREEN_HEIGHT)

; Build a flipped rectangle the size of the split view To use For drawing later
Define.Rectangle splitScreenRect 
InitRectangle(@splitScreenRect, 0.0, 0.0, screenPlayer1\texture\width, -screenPlayer1\texture\height)

SetTargetFPS(60)  ; Set our game to run at 60 frames-per-second
;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose() ;// Detect window close button Or ESC key
  ; Update
  ;>----------------------------------------------------------------------------------
  ; If anyone moves this frame, how far will they move based on the time since the last frame
  ; this moves thigns at 10 world units per second, regardless of the actual FPS
  Define.rl_float offsetThisFrame = 10.0 * GetFrameTime()

  ; Move Player1 forward And backwards (no turning)
  If IsKeyDown(#KEY_W)
    cameraPlayer1\position\z + offsetThisFrame
    cameraPlayer1\target\z + offsetThisFrame
  ElseIf IsKeyDown(#KEY_S)
    cameraPlayer1\position\z - offsetThisFrame
    cameraPlayer1\target\z - offsetThisFrame
  EndIf

  ; Move Player2 forward And backwards (no turning)
  If IsKeyDown(#KEY_UP)
    cameraPlayer2\position\x + offsetThisFrame
    cameraPlayer2\target\x + offsetThisFrame
  ElseIf IsKeyDown(#KEY_DOWN)
    cameraPlayer2\position\x - offsetThisFrame
    cameraPlayer2\target\x - offsetThisFrame
  EndIf
  
  ;>----------------------------------------------------------------------------------

  ; Draw
  ;-----------------------------------------------------------------------------------
  
  ; Draw Player1 view To the render texture
  BeginTextureMode(@screenPlayer1)
    ClearBackground(#COLOR_SKYBLUE)
    
    BeginMode3D(@cameraPlayer1)
      DrawScene()
    EndMode3D()
    
    DrawTextRayLib("PLAYER1 W/S to move", 10, 10, 20, #COLOR_RED)
  EndTextureMode()

  ; Draw Player2 view To the render texture
  BeginTextureMode(@screenPlayer2)
    ClearBackground(#COLOR_SKYBLUE)
    
    BeginMode3D(@cameraPlayer2)
      DrawScene()
    EndMode3D()
    
    DrawTextRayLib("PLAYER2 UP/DOWN to move", 10, 10, 20, #COLOR_BLUE)
  EndTextureMode();

  ; Draw both views render textures To the screen side by side
  BeginDrawing()
    ClearBackground(#COLOR_BLACK)
    
    Define.Vector2 texV
    
    InitVector2(@texV, 0, 0)
    DrawTextureRec(@screenPlayer1\texture, splitScreenRect, @texV, #COLOR_WHITE)
    
    InitVector2(@texV, #SCREEN_WIDTH / 2.0, 0)
    DrawTextureRec(@screenPlayer2\texture, splitScreenRect, @texV, #COLOR_WHITE)
  EndDrawing()
  ;>---------------------------------------------------------------------------------
    
  ; If we want to have a screenshot
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/core_split_screen.png")
  EndIf   
Wend

; De-Initialization
;>--------------------------------------------------------------------------------------
UnloadRenderTexture(@screenPlayer1)   ;// Unload render texture
UnloadRenderTexture(@screenPlayer2)   ;// Unload render texture

CloseWindowRayLib()                   ;// Close window and OpenGL context
;---------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.00 LTS - C Backend (MacOS X - arm64)
; CursorPosition = 160
; FirstLine = 71
; Folding = -
; Optimizer
; EnableThread
; EnableXP
; Compiler = PureBasic 6.00 LTS - C Backend (MacOS X - arm64)