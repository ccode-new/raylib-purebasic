; /*******************************************************************************************
; *
; *   raylib [core] example - Window should close
; *
; *   Example originally created With raylib 4.2, last time updated With raylib 4.2
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2013-2023 Ramon Santamaria (@raysan5)
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

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [core] example - window should close" )
If Not IsWindowReady()                  ; After creating the window, we check
  End                                   ; for errors at initialization.
EndIf    

SetExitKey(#KEY_NULL) ; Disable KEY_ESCAPE to close window, X-button still works

Define.rl_bool exitWindowRequested = #False ; Flag to request window to exit
Define.rl_bool exitWindow = #False          ; Flag to set window to exit

SetTargetFPS(60) ; Set our game to run at 60 frames-per-second

;>--------------------------------------------------------------------------------------

While Not exitWindow
  ; Update
  ;>----------------------------------------------------------------------------------
  ; Detect If X-button Or KEY_ESCAPE have been pressed To close window
  If WindowShouldClose() Or IsKeyPressed(#KEY_ESCAPE)
    exitWindowRequested = #True
  EndIf
  
  If exitWindowRequested
    ; A request For close window has been issued, we can save Data before closing
    ; Or just show a message asking For confirmation
    
    If IsKeyPressed(#KEY_Y) ;IsKeyPressed(#KEY_Z)
      exitWindow = #True
    ElseIf IsKeyPressed(#KEY_N) 
      exitWindowRequested = #False
    EndIf
  EndIf
  ;>----------------------------------------------------------------------------------
  
  ; Draw
  ;----------------------------------------------------------------------------------
  BeginDrawing()
  
  ClearBackground(#COLOR_RAYWHITE)
  
  If exitWindowRequested
    DrawRectangle(0, 100, #SCREEN_WIDTH, 200, #COLOR_BLACK)
    DrawTextRayLib("Are you sure you want to exit program? [Y/N]", 40, 180, 30, #COLOR_WHITE)
  Else 
    DrawTextRayLib("Try to close the window to get confirmation message!", 120, 200, 20, #COLOR_LIGHTGRAY)
  EndIf          
  
  EndDrawing()
  
  ; If we want to have a screenshot
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/core_window_should_close.png")
  EndIf

Wend
;>----------------------------------------------------------------------------------

; De-Initialization
;--------------------------------------------------------------------------------------
CloseWindowRayLib() ; Close window and OpenGL context

UnuseModule ray
;>--------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.00 LTS - C Backend (MacOS X - arm64)
; CursorPosition = 74
; FirstLine = 43
; Optimizer
; EnableThread
; EnableXP
; DPIAware
; Compiler = PureBasic 6.00 LTS - C Backend (MacOS X - arm64)