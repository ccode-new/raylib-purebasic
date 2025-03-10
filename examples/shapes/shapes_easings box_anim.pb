; /*******************************************************************************************
; *
; *   raylib [shapes] example - easings box anim
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

InitWindow(#screenWidth, #screenHeight, "raylib [shapes] example - easings box anim");

; Box variables To be animated With easings
Define.Rectangle rec 
InitRectangle(@rec, GetScreenWidth() / 2.0, -100, 100, 100)

Define.rl_float rotation = 0
Define.rl_float alpha = 1.0

Define.rl_int state = 0
Define.rl_int framesCounter = 0

SetTargetFPS(60)  ; Set our game to run at 60 frames-per-second
;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose() ; Detect window close button Or ESC key
  ; Update
  ;>----------------------------------------------------------------------------------
  Select state
    Case 0  ; Move box down To center of screen
      framesCounter + 1

      ; NOTE: Remember that 3rd parameter of easing function refers To
      ; desired value variation, do Not confuse it With expected final value!
      rec\y = EaseElasticOut(framesCounter, -100, GetScreenHeight() / 2.0 + 100, 120)

      If framesCounter >= 120
        framesCounter = 0
        state = 1
      EndIf
    Case 1  ; Scale box To an horizontal bar
      framesCounter + 1
      rec\height = EaseBounceOut(framesCounter, 100, -90, 120)
      rec\width = EaseBounceOut(framesCounter, 100, GetScreenWidth(), 120)

      If framesCounter >= 120
        framesCounter = 0
        state = 2
      EndIf
    Case 2  ; Rotate horizontal bar rectangle
      framesCounter + 1
      rotation = EaseQuadOut(framesCounter, 0.0, 270.0, 240)

      If framesCounter >= 240
        framesCounter = 0
        state = 3
      EndIf
    Case 3  ; Increase bar size To fill all screen
      framesCounter + 1
      rec\height = EaseCircOut(framesCounter, 10, GetScreenWidth(), 120)

      If framesCounter >= 120
        framesCounter = 0
        state = 4
      EndIf
    Case 4  ; Fade out animation
      framesCounter + 1
      alpha = EaseSineOut(framesCounter, 1.0, -1.0, 160)

      If framesCounter >= 160
        framesCounter = 0
        state = 5
      EndIf
  EndSelect

  ; Reset animation at any moment
  If IsKeyPressed(#KEY_SPACE)
    InitRectangle(@rec, GetScreenWidth() / 2.0, -100, 100, 100)
    rotation = 0
    alpha = 1.0
    state = 0
    framesCounter = 0
  EndIf
  
  ;>----------------------------------------------------------------------------------

  ; Draw
  ;-----------------------------------------------------------------------------------
  BeginDrawing()

    ClearBackground(#COLOR_RAYWHITE)
  
    Define.Vector2 origin
    InitVector2(@origin, rec\width / 2, rec\height / 2)
    
    DrawRectanglePro(@rec, @origin, rotation, Fade(#COLOR_BLACK, alpha))

    DrawTextRayLib("PRESS [SPACE] TO RESET BOX ANIMATION!", 10, GetScreenHeight() - 25, 20, #COLOR_LIGHTGRAY)

  EndDrawing()
  ;-----------------------------------------------------------------------------------
  
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/shapes_easings_box_anim.png")
  EndIf
  
Wend

; De-Initialization
;>--------------------------------------------------------------------------------------
CloseWindowRayLib() ; Close window and OpenGL context
;---------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.00 LTS - C Backend (MacOS X - arm64)
; CursorPosition = 121
; Optimizer
; EnableThread
; EnableXP
; Compiler = PureBasic 6.00 LTS - C Backend (MacOS X - arm64)