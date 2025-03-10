; /*******************************************************************************************
; *
; *   raylib [audio] example - Multichannel sound playing
; *
; *   Example originally created With raylib 3.0, last time updated With raylib 3.5
; *
; *   Example contributed by Chris Camacho (@chriscamacho) And reviewed by Ramon Santamaria (@raysan5)
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2019-2023 Chris Camacho (@chriscamacho) And Ramon Santamaria (@raysan5)
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

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [audio] example - Multichannel sound playing" )
If Not IsWindowReady()                  ; After creating the window, we check
  End                                   ; for errors at initialization.
EndIf 

InitAudioDevice() ; Initialize audio device

Define.Sound fxWav
LoadSoundRayLib(@fxWav, "resources/sound.wav")   ; Load WAV audio file

Define.Sound fxOgg 
LoadSoundRayLib(@fxOgg, "resources/target.ogg")  ; Load OGG audio file

SetSoundVolume(@fxWav, 0.2)

SetTargetFPS(60) ; Set our game to run at 60 frames-per-second
                 ;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose() ; Detect window close button Or ESC key
                              ; Update
                              ;>----------------------------------------------------------------------------------
  If IsKeyPressed(#KEY_ENTER)
    PlaySoundMulti(@fxWav) ; Play a new wav sound instance
  EndIf
  
  If IsKeyPressed(#KEY_SPACE) 
    PlaySoundMulti(@fxOgg) ; Play a new ogg sound instance
  EndIf
  
  ;>----------------------------------------------------------------------------------
  
  ; Draw
  ;----------------------------------------------------------------------------------
  BeginDrawing()
  
  ClearBackground(#COLOR_RAYWHITE)
  
  DrawTextRayLib("MULTICHANNEL SOUND PLAYING", 20, 20, 20, #COLOR_GRAY)
  DrawTextRayLib("Press SPACE to play new ogg instance!", 200, 120, 20, #COLOR_LIGHTGRAY)
  DrawTextRayLib("Press ENTER to play new wav instance!", 200, 180, 20, #COLOR_LIGHTGRAY)
  
  DrawTextRayLib("CONCURRENT SOUNDS PLAYING: " + Str(GetSoundsPlaying()), 220, 280, 20, #COLOR_RED)
  
  EndDrawing()

  ; If we want to have a screenshot
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/audio_multichannel_playing.png")
  EndIf
  
Wend
;>----------------------------------------------------------------------------------

;De-Initialization
;--------------------------------------------------------------------------------------
StopSoundMulti()    ; We must stop the buffer pool before unloading

UnloadSound(@fxWav)  ; Unload sound data
UnloadSound(@fxOgg)  ; Unload sound data

CloseAudioDevice()  ; Close audio device

CloseWindowRayLib() ; Close window and OpenGL context

UnuseModule ray
;--------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 73
; FirstLine = 47
; Optimizer
; EnableThread
; EnableXP
; DPIAware
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)