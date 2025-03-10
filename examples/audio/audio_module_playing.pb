; /*******************************************************************************************
; *
; *   raylib [audio] example - Module playing (streaming)
; *
; *   Example originally created With raylib 1.5, last time updated With raylib 3.5
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2016-2023 Ramon Santamaria (@raysan5)
; *
; ********************************************************************************************/
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

#MAX_CIRCLES = 64

Structure CircleWave
  position.Vector2
  radius.rl_float
  alpha.rl_float
  speed.rl_float
  color.rl_ColorLong
EndStructure

; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 450

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [audio] example - module playing (streaming)" )
If Not IsWindowReady()                  ; After creating the window, we check
  End                                   ; for errors at initialization.
EndIf 

InitAudioDevice() ; Initialize audio device

Dim colors.rl_ColorLong(13)
colors(0) = #COLOR_ORANGE : colors(1) = #COLOR_RED : colors(2) = #COLOR_GOLD : colors(3) = #COLOR_LIME : colors(4) = #COLOR_BLUE
colors(5) = #COLOR_VIOLET : colors(6) = #COLOR_BROWN : colors(7) = #COLOR_LIGHTGRAY : colors(8) = #COLOR_PINK : colors(9) = #COLOR_YELLOW
colors(10) = #COLOR_GREEN : colors(11) = #COLOR_SKYBLUE : colors(12) = #COLOR_PURPLE : colors(13) = #COLOR_BEIGE

; Creates some circles For visual effect
Dim circles.CircleWave(#MAX_CIRCLES)

Define.rl_int i

For i = #MAX_CIRCLES - 1 To 0 Step -1
  circles(i)\alpha = 0.0
  circles(i)\radius = GetRandomValue(10, 40)
  circles(i)\position\x = GetRandomValue(circles(i)\radius, #SCREEN_WIDTH - circles(i)\radius)
  circles(i)\position\y = GetRandomValue(circles(i)\radius, #SCREEN_HEIGHT - circles(i)\radius)
  circles(i)\speed = GetRandomValue(1, 100) / 2000.0
  circles(i)\color = colors(GetRandomValue(0, 13));
Next

Define.Music music 
LoadMusicStream(@music, "resources/mini1111.xm");

music\looping = #False

Define.rl_float pitch = 1.0

PlayMusicStream(@music)

Define.rl_float timePlayed = 0.0
Define.rl_bool pause = #False

SetTargetFPS(60) ; Set our game to run at 60 frames-per-second
;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose() ; Detect window close button Or ESC key
  ; Update
  ;>----------------------------------------------------------------------------------
  UpdateMusicStream(@music) ; Update music buffer with new stream data

  ; Restart music playing (stop And play)
  If IsKeyPressed(#KEY_SPACE)
    StopMusicStream(@music)
    PlayMusicStream(@music)
  EndIf

  ; Pause/Resume music playing
  If IsKeyPressed(#KEY_P)
    If pause = #True 
      pause = #False 
    Else 
      pause = #True 
    EndIf

    If pause = #True
      PauseMusicStream(@music)
    Else 
      ResumeMusicStream(@music)
    EndIf
  EndIf

  If IsKeyDown(#KEY_DOWN)
    pitch - 0.01
  ElseIf IsKeyDown(#KEY_UP)
    pitch + 0.01
  EndIf
  
  SetMusicPitch(@music, pitch)

  ; Get timePlayed scaled To bar dimensions
  timePlayed = GetMusicTimePlayed(@music) / GetMusicTimeLength(@music) * (#SCREEN_WIDTH - 40)

  ; Color circles animation
  If pause = #False
    For i = #MAX_CIRCLES - 1 To 0 Step -1
      circles(i)\alpha + circles(i)\speed
      circles(i)\radius + circles(i)\speed * 10.0

      If circles(i)\alpha > 1.0
        circles(i)\speed * -1
      EndIf

      If circles(i)\alpha <= 0.0
        circles(i)\alpha = 0.0
        circles(i)\radius = GetRandomValue(10, 40)
        circles(i)\position\x = GetRandomValue(circles(i)\radius, #SCREEN_WIDTH - circles(i)\radius)
        circles(i)\position\y = GetRandomValue(circles(i)\radius, #SCREEN_HEIGHT - circles(i)\radius)
        circles(i)\color = colors(GetRandomValue(0, 13))
        circles(i)\speed = GetRandomValue(1, 100) / 2000.0
      EndIf
    Next
  EndIf
  
  ;>----------------------------------------------------------------------------------

  ; Draw
  ;----------------------------------------------------------------------------------
  BeginDrawing()

  ClearBackground(#COLOR_RAYWHITE)

  For i = #MAX_CIRCLES - 1 To 0 Step -1
    DrawCircleV(@circles(i)\position, circles(i)\radius, Fade(circles(i)\color, circles(i)\alpha))
  Next

  ; Draw time bar
  DrawRectangle(20, #SCREEN_HEIGHT - 20 - 12, #SCREEN_WIDTH - 40, 12, #COLOR_LIGHTGRAY)
  DrawRectangle(20, #SCREEN_HEIGHT - 20 - 12, timePlayed, 12, #COLOR_MAROON)
  DrawRectangleLines(20, #SCREEN_HEIGHT - 20 - 12, #SCREEN_WIDTH - 40, 12, #COLOR_GRAY)

  EndDrawing()
  ;----------------------------------------------------------------------------------
  
  ; If we want to have a screenshot
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/audio_module playing.png")
  EndIf
  
Wend

; De-Initialization
;>--------------------------------------------------------------------------------------
UnloadMusicStream(@music) ; Unload music stream buffers from RAM

CloseAudioDevice() ; Close audio device (music streaming is automatically stopped)

CloseWindowRayLib() ; Close window and OpenGL context

UnuseModule ray
;--------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.00 LTS - C Backend (MacOS X - arm64)
; CursorPosition = 156
; FirstLine = 77
; Optimizer
; EnableThread
; EnableXP
; DPIAware
; Compiler = PureBasic 6.00 LTS - C Backend (MacOS X - arm64)