; /*******************************************************************************************
; *
; *   raylib [shapes] example - easings ball anim
; *
; *   Example originally created With raylib 2.5, last time updated With raylib 2.5
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2014-2023 Ramon Santamaria (@raysan5)
; *
; ********************************************************************************************/
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

XIncludeFile "reasing.pbi"              ; Required For easing functions


; Initialization
;>--------------------------------------------------------------------------------------
#screenWidth = 800
#screenHeight = 450

InitWindow(#screenWidth, #screenHeight, "raylib [shapes] example - easings ball anim")

; Ball variable value To be animated With easings
Define.rl_int ballPositionX = -100
Define.rl_int ballRadius = 20
Define.rl_float ballAlpha = 0

Define.rl_int state = 0
Define.rl_int framesCounter = 0

SetTargetFPS(60)  ; Set our game to run at 60 frames-per-second
;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose() ; Detect window close button Or ESC key
  ; Update
  ;>----------------------------------------------------------------------------------
  If state = 0  ; Move ball position X With easing
    framesCounter + 1
    ballPositionX = EaseElasticOut(framesCounter, -100, #screenWidth / 2.0 + 100, 120)

    If framesCounter >= 120
      framesCounter = 0
      state = 1
    EndIf

  ElseIf state = 1 ; Increase ball radius With easing
    framesCounter + 1
    ballRadius = EaseElasticIn(framesCounter, 20, 500, 200)

    If framesCounter >= 200
      framesCounter = 0
      state = 2
     EndIf
  ElseIf state = 2 ; Change ball alpha With easing (background color blending)
    framesCounter + 1
    ballAlpha = EaseCubicOut(framesCounter, 0.0, 1.0, 200)

    If framesCounter >= 200
      framesCounter = 0
      state = 3
    EndIf
  ElseIf state = 3 ; Reset state To play again
    If IsKeyPressed(#KEY_ENTER)
      ; Reset required variables To play again
      ballPositionX = -100
      ballRadius = 20
      ballAlpha = 0
      state = 0
    EndIf
  EndIf

  If IsKeyPressed(#KEY_R)
    framesCounter = 0
  EndIf
  
  ;>----------------------------------------------------------------------------------

  ; Draw
  ;-----------------------------------------------------------------------------------
  BeginDrawing()

    ClearBackground(#COLOR_RAYWHITE)

    If state >= 2 
      DrawRectangle(0, 0, #screenWidth, #screenHeight, #COLOR_GREEN)
    EndIf
    
    DrawCircle(ballPositionX, 200, ballRadius, Fade(#COLOR_RED, 1.0 - ballAlpha))

    If state = 3 
      DrawTextRayLib("PRESS [ENTER] TO PLAY AGAIN!", 240, 200, 20, #COLOR_BLACK)
    EndIf

  EndDrawing()
  ;-----------------------------------------------------------------------------------
  
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/shapes_easings_ball_anim.png")
  EndIf
  
Wend

; De-Initialization
;>--------------------------------------------------------------------------------------
CloseWindowRayLib() ; Close window and OpenGL context
;---------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 105
; FirstLine = 81
; Optimizer
; EnableThread
; EnableXP
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)