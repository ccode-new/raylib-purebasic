; /*******************************************************************************************
; *
; *   raylib [core] example - window flags
; *
; *   Example originally created With raylib 3.5, last time updated With raylib 3.5
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2020-2023 Ramon Santamaria (@raysan5)
; *
; ********************************************************************************************/
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit

UseModule ray                           ; Import the module

; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 600

; Possible window flags
; /*
; FLAG_VSYNC_HINT
; FLAG_FULLSCREEN_MODE    -> Not working properly -> wrong scaling!
; FLAG_WINDOW_RESIZABLE
; FLAG_WINDOW_UNDECORATED
; FLAG_WINDOW_TRANSPARENT
; FLAG_WINDOW_HIDDEN
; FLAG_WINDOW_MINIMIZED   -> Not supported on window creation
; FLAG_WINDOW_MAXIMIZED   -> Not supported on window creation
; FLAG_WINDOW_UNFOCUSED
; FLAG_WINDOW_TOPMOST
; FLAG_WINDOW_HIGHDPI     -> errors after minimize-resize, fb size is recalculated
; FLAG_WINDOW_ALWAYS_RUN
; FLAG_MSAA_4X_HINT
; */

; Set configuration flags For window creation
;SetWindowStateRayLib(#FLAG_VSYNC_HINT | #FLAG_MSAA_4X_HINT | #FLAG_WINDOW_HIGHDPI)
;SetWindowStateRayLib(#FLAG_WINDOW_TRANSPARENT)

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [core] example - window flags" )
If Not IsWindowReady()    ; After creating the window, we check
  End                     ; for errors at initialization.
EndIf                     ; In case of error at init we end the program.

Define.Vector2 ballPosition
InitVector2(@ballPosition, GetScreenWidth() / 2.0, GetScreenHeight() / 2.0)

Define.Vector2 ballSpeed
InitVector2(@ballSpeed, 5.0, 4.0)

Define.rl_float ballRadius = 20

Define.rl_int framesCounter = 0

Define.Rectangle drawRec

Define.Vector2 mousePos
InitVector2(@mousePos, 0, 0)

SetTargetFPS(60) ; Set our game to run at 60 frames-per-second
;>----------------------------------------------------------

HideCursor()

; Main game loop
While Not WindowShouldClose() ; Detect window close button Or ESC key
                              ; Update
                              ;>-----------------------------------------------------
  If IsKeyPressed(#KEY_F) 
    ToggleFullscreen() ; modifies window size when scaling!
  EndIf
  
  If IsKeyPressed(#KEY_R)
    If IsWindowState(#FLAG_WINDOW_RESIZABLE)
      ClearWindowState(#FLAG_WINDOW_RESIZABLE)
    Else 
      SetWindowStateRayLib(#FLAG_WINDOW_RESIZABLE)
    EndIf
  EndIf
  
  If IsKeyPressed(#KEY_D)
    If IsWindowState(#FLAG_WINDOW_UNDECORATED) 
      ClearWindowState(#FLAG_WINDOW_UNDECORATED)
    Else 
      SetWindowStateRayLib(#FLAG_WINDOW_UNDECORATED)
    EndIf
  EndIf
  
  If IsKeyPressed(#KEY_H)
    If Not IsWindowState(#FLAG_WINDOW_HIDDEN) 
      SetWindowStateRayLib(#FLAG_WINDOW_HIDDEN)
    EndIf
    framesCounter = 0
  EndIf
  
  If IsWindowState(#FLAG_WINDOW_HIDDEN)
    framesCounter + 1
    If framesCounter >= 240
      ClearWindowState(#FLAG_WINDOW_HIDDEN) ; Show window after 3 seconds
    EndIf
  EndIf
  
  If IsKeyPressed(#KEY_N)
    If Not IsWindowState(#FLAG_WINDOW_MINIMIZED) 
      MinimizeWindow()
    EndIf
    framesCounter = 0
  EndIf
  
  If IsWindowState(#FLAG_WINDOW_MINIMIZED)
    framesCounter + 1
    If (framesCounter >= 240) 
      RestoreWindow() ; Restore window after 3 seconds
    EndIf
  EndIf
  
  If IsKeyPressed(#KEY_M)
    ; NOTE: Requires FLAG_WINDOW_RESIZABLE enabled!
    If IsWindowState(#FLAG_WINDOW_MAXIMIZED)
      RestoreWindow()
    Else 
      MaximizeWindow()
    EndIf
  EndIf
  
  If IsKeyPressed(#KEY_U)
    If IsWindowState(#FLAG_WINDOW_UNFOCUSED)
      ClearWindowState(#FLAG_WINDOW_UNFOCUSED)
    Else 
      SetWindowStateRayLib(#FLAG_WINDOW_UNFOCUSED)
    EndIf
  EndIf
  
  If IsKeyPressed(#KEY_T)
    If IsWindowState(#FLAG_WINDOW_TOPMOST)
      ClearWindowState(#FLAG_WINDOW_TOPMOST)
    Else 
      SetWindowStateRayLib(#FLAG_WINDOW_TOPMOST)
    EndIf
  EndIf
  
  If IsKeyPressed(#KEY_A)
    If IsWindowState(#FLAG_WINDOW_ALWAYS_RUN)
      ClearWindowState(#FLAG_WINDOW_ALWAYS_RUN)
    Else 
      SetWindowStateRayLib(#FLAG_WINDOW_ALWAYS_RUN)
    EndIf
  EndIf
  
  If IsKeyPressed(#KEY_V)
    If IsWindowState(#FLAG_VSYNC_HINT)
      ClearWindowState(#FLAG_VSYNC_HINT)
    Else 
      SetWindowStateRayLib(#FLAG_VSYNC_HINT)
    EndIf
  EndIf
  
  ; Bouncing ball logic
  ballPosition\x + ballSpeed\x
  ballPosition\y + ballSpeed\y
  
  If ballPosition\x >= (GetScreenWidth() - ballRadius) Or ballPosition\x <= ballRadius
    ballSpeed\x * -1.0
  EndIf
  
  If ballPosition\y >= (GetScreenHeight() - ballRadius) Or ballPosition\y <= ballRadius
    ballSpeed\y * -1.0
  EndIf
  ;>-----------------------------------------------------
  
  ; Draw
  ;-----------------------------------------------------
  BeginDrawing()
  
  If IsWindowState(#FLAG_WINDOW_TRANSPARENT)
    ClearBackground(#COLOR_BLANK)
  Else 
    ClearBackground(#COLOR_RAYWHITE)
  EndIf
  
  DrawCircleV(@ballPosition, ballRadius, #COLOR_MAROON)
  
  With drawRec
    \x = 0
    \y = 0
    \width = GetScreenWidth()
    \height = GetScreenHeight()
  EndWith

  
  DrawRectangleLinesEx(@drawRec, 4, #COLOR_RAYWHITE)
  
  GetMousePosition(@mousePos)
  
  DrawCircleV(mousePos, 10, #COLOR_DARKBLUE)
  
  DrawFPS(10, 10)
  
  DrawTextRayLib("Screen Size: " + StrF(GetScreenWidth())+ ", " + StrF(GetScreenHeight()), 10, 40, 10, #COLOR_GREEN)
  
  ; Draw window state info
  DrawTextRayLib("Following flags can be set after window creation:", 10, 60, 10, #COLOR_GRAY)
  If IsWindowState(#FLAG_FULLSCREEN_MODE)
    DrawTextRayLib("[F] FLAG_FULLSCREEN_MODE: on", 10, 80, 10, #COLOR_LIME)
  Else 
    DrawTextRayLib("[F] FLAG_FULLSCREEN_MODE: off", 10, 80, 10, #COLOR_MAROON)
  EndIf
  If IsWindowState(#FLAG_WINDOW_RESIZABLE) 
    DrawTextRayLib("[R] FLAG_WINDOW_RESIZABLE: on", 10, 100, 10, #COLOR_LIME)
  Else 
    DrawTextRayLib("[R] FLAG_WINDOW_RESIZABLE: off", 10, 100, 10, #COLOR_MAROON)
  EndIf
  If IsWindowState(#FLAG_WINDOW_UNDECORATED)
    DrawTextRayLib("[D] FLAG_WINDOW_UNDECORATED: on", 10, 120, 10, #COLOR_LIME)
  Else 
    DrawTextRayLib("[D] FLAG_WINDOW_UNDECORATED: off", 10, 120, 10, #COLOR_MAROON)
  EndIf
  If IsWindowState(#FLAG_WINDOW_HIDDEN)
    DrawTextRayLib("[H] FLAG_WINDOW_HIDDEN: on", 10, 140, 10, #COLOR_LIME)
  Else 
    DrawTextRayLib("[H] FLAG_WINDOW_HIDDEN: off", 10, 140, 10, #COLOR_MAROON)
  EndIf
  If IsWindowState(#FLAG_WINDOW_MINIMIZED)
    DrawTextRayLib("[N] FLAG_WINDOW_MINIMIZED: on", 10, 160, 10, #COLOR_LIME)
  Else 
    DrawTextRayLib("[N] FLAG_WINDOW_MINIMIZED: off", 10, 160, 10, #COLOR_MAROON)
  EndIf
  If IsWindowState(#FLAG_WINDOW_MAXIMIZED)
    DrawTextRayLib("[M] FLAG_WINDOW_MAXIMIZED: on", 10, 180, 10, #COLOR_LIME)
  Else 
    DrawTextRayLib("[M] FLAG_WINDOW_MAXIMIZED: off", 10, 180, 10, #COLOR_MAROON)
  EndIf
  If IsWindowState(#FLAG_WINDOW_UNFOCUSED)
    DrawTextRayLib("[G] FLAG_WINDOW_UNFOCUSED: on", 10, 200, 10, #COLOR_LIME)
  Else 
    DrawTextRayLib("[U] FLAG_WINDOW_UNFOCUSED: off", 10, 200, 10, #COLOR_MAROON)
  EndIf
  If IsWindowState(#FLAG_WINDOW_TOPMOST) 
    DrawTextRayLib("[T] FLAG_WINDOW_TOPMOST: on", 10, 220, 10, #COLOR_LIME)
  Else 
    DrawTextRayLib("[T] FLAG_WINDOW_TOPMOST: off", 10, 220, 10, #COLOR_MAROON)
  EndIf
  If IsWindowState(#FLAG_WINDOW_ALWAYS_RUN)
    DrawTextRayLib("[A] FLAG_WINDOW_ALWAYS_RUN: on", 10, 240, 10, #COLOR_LIME)
  Else 
    DrawTextRayLib("[A] FLAG_WINDOW_ALWAYS_RUN: off", 10, 240, 10, #COLOR_MAROON)
  EndIf
  If IsWindowState(#FLAG_VSYNC_HINT)
    DrawTextRayLib("[V] FLAG_VSYNC_HINT: on", 10, 260, 10, #COLOR_LIME)
  Else 
    DrawTextRayLib("[V] FLAG_VSYNC_HINT: off", 10, 260, 10, #COLOR_MAROON)
  EndIf
  DrawTextRayLib("Following flags can only be set before window creation:", 10, 300, 10, #COLOR_GRAY)
  If IsWindowState(#FLAG_WINDOW_HIGHDPI)
    DrawTextRayLib("FLAG_WINDOW_HIGHDPI: on", 10, 320, 10, #COLOR_LIME)
  Else 
    DrawTextRayLib("FLAG_WINDOW_HIGHDPI: off", 10, 320, 10, #COLOR_MAROON)
  EndIf
  If IsWindowState(#FLAG_WINDOW_TRANSPARENT)
    DrawTextRayLib("FLAG_WINDOW_TRANSPARENT: on", 10, 340, 10, #COLOR_LIME)
  Else 
    DrawTextRayLib("FLAG_WINDOW_TRANSPARENT: off", 10, 340, 10, #COLOR_MAROON)
  EndIf
  If IsWindowState(#FLAG_MSAA_4X_HINT) 
    DrawTextRayLib("FLAG_MSAA_4X_HINT: on", 10, 360, 10, #COLOR_LIME)
  Else 
    DrawTextRayLib("FLAG_MSAA_4X_HINT: off", 10, 360, 10, #COLOR_MAROON);
  EndIf
  
  EndDrawing()
  ;>------------------------------------------------------
  
  ; If we want to have a screenshot
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/core_window_flags.png")
  EndIf
  
Wend
; De-Initialization
;>---------------------------------------------------------
CloseWindowRayLib() ; Close window and OpenGL context
                    ;----------------------------------------------------------

UnuseModule ray
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 65
; FirstLine = 59
; Optimizer
; EnableThread
; EnableXP
; DPIAware
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)