; /*******************************************************************************************
; *
; *   raylib [audio] example - Music stream processing effects
; *
; *   Example originally created With raylib 4.2, last time updated With raylib 4.2
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2022-2023 Ramon Santamaria (@raysan5)
; *
; ********************************************************************************************/

;-Currently not working!

IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

; Required delay effect variables
Global.float *delayBuffer = #Null
Global.rl_uint delayBufferSize = 0
Global.rl_uint delayReadIndex = 2
Global.rl_uint delayWriteIndex = 0

;>------------------------------------------------------------------------------------
; Module Functions Declaration
;------------------------------------------------------------------------------------
Declare AudioProcessEffectLPF(*buffer, frames.rl_uint)          ; Audio effect: lowpass filter
Declare AudioProcessEffectDelay(*buffer, frames.rl_uint)        ; Audio effect: delay

; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 450

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [audio] example - stream effects" )
If Not IsWindowReady()                  ; After creating the window, we check
  End                                   ; for errors at initialization.
EndIf 

InitAudioDevice() ; Initialize audio device

Define.Music music 
LoadMusicStream(@music, "resources/country.mp3")

; Allocate buffer For the delay effect
delayBufferSize = 48000 * 2             ; 1 second delay (device sampleRate*channels)
*delayBuffer = AllocateMemory(delayBufferSize)

PlayMusicStream(@music)

Define.rl_float timePlayed = 0.0            ; Time played normalized [0.0f..1.0f]
Define.rl_bool pause = #False               ; Music playing paused
    
Define.rl_bool enableEffectLPF = #False     ; Enable effect low-pass-filter
Define.rl_bool enableEffectDelay = #False   ; Enable effect delay (1 second)

SetTargetFPS(60)                            ; Set our game To run at 60 frames-per-second
;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose()               ; Detect window close button Or ESC key
  ; Update
  ;>----------------------------------------------------------------------------------
  UpdateMusicStream(@music)                 ; Update music buffer with new stream data

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

  ; Add/Remove effect: lowpass filter
  If IsKeyPressed(#KEY_F)
    enableEffectLPF = Bool( Not enableEffectLPF )
    If enableEffectLPF
      AttachAudioStreamProcessor(@music\stream, @AudioProcessEffectLPF())
    Else 
      DetachAudioStreamProcessor(music\stream, @AudioProcessEffectLPF())
    EndIf
  EndIf

  ; Add/Remove effect: delay
  If IsKeyPressed(#KEY_D)
    enableEffectDelay = Bool( Not enableEffectDelay )
    If enableEffectDelay
      AttachAudioStreamProcessor(@music\stream, @AudioProcessEffectDelay())
    Else 
      DetachAudioStreamProcessor(music\stream, @AudioProcessEffectDelay())
    EndIf
  EndIf
        
  ; Get normalized time played For current music stream
  timePlayed = GetMusicTimePlayed(@music) / GetMusicTimeLength(@music)

  If (timePlayed > 1.0) 
    timePlayed = 1.0            ; Make sure time played is no longer than music
  EndIf
  ;>----------------------------------------------------------------------------------

  ; Draw
  ;-----------------------------------------------------------------------------------
  BeginDrawing()

  ClearBackground(#COLOR_RAYWHITE)

  DrawTextRayLib("MUSIC SHOULD BE PLAYING!", 245, 150, 20, #COLOR_LIGHTGRAY)

  DrawRectangle(200, 180, 400, 12, #COLOR_LIGHTGRAY)
  DrawRectangle(200, 180, (timePlayed * 400.0), 12, #COLOR_MAROON)
  DrawRectangleLines(200, 180, 400, 12, #COLOR_GRAY)

  DrawTextRayLib("PRESS SPACE TO RESTART MUSIC", 215, 230, 20, #COLOR_LIGHTGRAY)
  DrawTextRayLib("PRESS P TO PAUSE/RESUME MUSIC", 208, 260, 20, #COLOR_LIGHTGRAY)
  
  If enableEffectLPF = #True
    DrawTextRayLib("PRESS F TO TOGGLE LPF EFFECT: ON", 200, 320, 20, #COLOR_GRAY)
  Else
    DrawTextRayLib("PRESS F TO TOGGLE LPF EFFECT: OFF", 200, 320, 20, #COLOR_GRAY)
  EndIf
  
  If enableEffectDelay = #True
    DrawTextRayLib("PRESS D TO TOGGLE DELAY EFFECT: ON", 180, 350, 20, #COLOR_GRAY)
  Else
    DrawTextRayLib("PRESS D TO TOGGLE DELAY EFFECT: OFF", 180, 350, 20, #COLOR_GRAY)
  EndIf

  EndDrawing()
  ;>----------------------------------------------------------------------------------
  
  ; If we want to have a screenshot
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/audio_stream_effects.png")
  EndIf
Wend

; De-Initialization
;>--------------------------------------------------------------------------------------
UnloadMusicStream(@music)       ; Unload music stream buffers from RAM

CloseAudioDevice()              ; Close audio device (music streaming is automatically stopped)

FreeMemory(*delayBuffer)        ; Free delay buffer

CloseWindowRayLib()             ; Close window and OpenGL context
;---------------------------------------------------------------------------------------


;>------------------------------------------------------------------------------------
; Module Functions Definition
;-------------------------------------------------------------------------------------

; Audio effect: lowpass filter
Procedure AudioProcessEffectLPF(*buffer, frames.rl_uint)
  Static Dim low.rl_float(1)
  low(0) = 0.0 : low(1) = 0.0
  
  Static.rl_float cutoff = 70.0 / 44100.0                   ; 70 Hz lowpass filter
  Protected.rl_float k = cutoff / (cutoff + 0.1591549431)   ; RC filter formula
  
  Protected.rl_uint i
  
  For i = 0 To (frames * 2) - 1 Step 2
    Define.rl_float l = PeekF(*buffer + i)
    Define.rl_float r = PeekF(*buffer + (i + 1))
    
    low(0) + k * (l - low(0))
    low(1) + k * (r - low(1))
    
    PokeF(*buffer + i, low(0))
    PokeF(*buffer + (i + 1), low(1))
  Next
EndProcedure

; Audio effect: delay
Procedure AudioProcessEffectDelay(*buffer, frames.rl_uint)
  Protected.rl_uint i
  
  For i = 0 To (frames * 2) -1 Step 2
    delayReadIndex + 1
    Define.rl_float leftDelay = PeekF(*delayBuffer + delayReadIndex)    ; ERROR: Reading buffer -> WHY??? Maybe thread related???
    Define.rl_float rightDelay = PeekF(*delayBuffer + delayReadIndex)

    If delayReadIndex = delayBufferSize 
      delayReadIndex = 0
    EndIf
    
    PokeF(*buffer + i, 0.5 * PeekF(*buffer + i) + 0.5 * leftDelay)
    PokeF(*buffer + (i + 1), 0.5 * PeekF(*buffer + (i + 1)) + 0.5 * rightDelay)
    
    PokeF(*delayBuffer + delayWriteIndex, PeekF(*buffer + i))
    PokeF(*delayBuffer + delayWriteIndex, PeekF(*buffer + (i + 1)))
    
    If delayWriteIndex = delayBufferSize
      delayWriteIndex = 0
    EndIf
  Next
EndProcedure
  
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 169
; FirstLine = 160
; Folding = -
; Optimizer
; EnableThread
; EnableXP
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)