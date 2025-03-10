; /*******************************************************************************************
; *
; *   raylib [audio] example - Music playing (streaming)
; *
; *   Example originally created With raylib 1.3, last time updated With raylib 4.0
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

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [audio] example - music playing (streaming)" )
If Not IsWindowReady()                  ; After creating the window, we check
  End                                   ; for errors at initialization.
EndIf 

InitAudioDevice() ; Initialize audio device

Define.Music music 
LoadMusicStream(@music, "resources/country.mp3")

;SetMusicVolume(@music, 100)

PlayMusicStream(@music)

Define.rl_float timePlayed = 0.0  ; Time played normalized [0.0f..1.0f]
Define.rl_bool pause = #False     ; Music playing paused

SetTargetFPS(30)                  ; Set our game to run at 30 frames-per-second
;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose()     ; Detect window close button Or ESC key
  ; Update
  ;>----------------------------------------------------------------------------------
  UpdateMusicStream(@music)        ; Update music buffer with new stream data
        
  ; Restart music playing (stop And play)
  If IsKeyPressed(#KEY_SPACE)
    StopMusicStream(@music)
    PlayMusicStream(@music)
  EndIf

  ; Pause/Resume music playing
  If IsKeyPressed(#KEY_P)
    pause = Bool( Not pause )

    If pause = #True
      PauseMusicStream(@music)
    Else 
      ResumeMusicStream(@music)
    EndIf
  EndIf

  ; Get normalized time played For current music stream
  timePlayed = GetMusicTimePlayed(@music) / GetMusicTimeLength(@music)

  If timePlayed > 1.0
    timePlayed = 1.0 ; Make sure time played is no longer than music
  EndIf
  ;>----------------------------------------------------------------------------------

  ; Draw
  ;----------------------------------------------------------------------------------
  BeginDrawing()

  ClearBackground(#COLOR_RAYWHITE)

  DrawTextRayLib("MUSIC SHOULD BE PLAYING!", 255, 150, 20, #COLOR_LIGHTGRAY)

  DrawRectangle(200, 200, 400, 12, #COLOR_LIGHTGRAY)
  DrawRectangle(200, 200, timePlayed * 400.0, 12, #COLOR_MAROON)
  DrawRectangleLines(200, 200, 400, 12, #COLOR_GRAY)

  DrawTextRayLib("PRESS SPACE TO RESTART MUSIC", 215, 250, 20, #COLOR_LIGHTGRAY)
  DrawTextRayLib("PRESS P TO PAUSE/RESUME MUSIC", 208, 280, 20, #COLOR_LIGHTGRAY)

  EndDrawing()
  
  ; If we want to have a screenshot
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/audio_music_playing.png")
  EndIf
  
Wend
;>----------------------------------------------------------------------------------

; De-Initialization
;--------------------------------------------------------------------------------------
UnloadMusicStream(@music) ; Unload music stream buffers from RAM

CloseAudioDevice()        ; Close audio device (music streaming is automatically stopped)

CloseWindowRayLib()       ; Close window and OpenGL context

UnuseModule ray
;--------------------------------------------------------------------------------------

    
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 38
; FirstLine = 30
; Optimizer
; EnableThread
; EnableXP
; DPIAware
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)