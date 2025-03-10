; /*******************************************************************************************
; *
; *   raylib [textures] example - Texture drawing
; *
; *   NOTE: This example illustrates how To draw into a blank texture using a shader
; *
; *   Example originally created With raylib 2.0, last time updated With raylib 3.7
; *
; *   Example contributed by Michał Ciesielski And reviewed by Ramon Santamaria (@raysan5)
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2019-2023 Michał Ciesielski And Ramon Santamaria (@raysan5)
; *
; ********************************************************************************************/
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

#GLSL_VERSION = "330" ;No Raspi!

; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 450

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [shaders] example - texture drawing" )
If Not IsWindowReady()                  ; After creating the window, we check
  End                                   ; for errors at initialization.
EndIf    

Define.Image imBlank
GenImageColor(@imBlank, 1024, 1024, #Color_BLANK)

Define.Texture2D texture 
LoadTextureFromImage(@texture, @imBlank) ; Load blank texture to fill on shader

UnloadImage(@imBlank)

; NOTE: Using GLSL 330 shader version, on OpenGL ES 2.0 use GLSL 100 shader version
Define.Shader shader 
LoadShader(shader, #Null$, "resources/shaders/glsl"+#GLSL_VERSION+"/cubes_panning.fs");

Define.rl_float time = 0.0
Define.rl_int timeLoc = GetShaderLocation(shader, "uTime")

SetShaderValue(shader, timeLoc, @time, #SHADER_UNIFORM_FLOAT)

SetTargetFPS(60) ; Set our game to run at 60 frames-per-second
                 ;> -------------------------------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose() ; Detect window close button Or ESC key
  ; Update
  ;>----------------------------------------------------------------------------------
  time = GetTime()
  
  SetShaderValue(shader, timeLoc, @time, #SHADER_UNIFORM_FLOAT)
  
  ;>----------------------------------------------------------------------------------
  
  ; Draw
  ;-----------------------------------------------------------------------------------
  BeginDrawing()
  
  ClearBackground(#COLOR_RAYWHITE)
  
  BeginShaderMode(shader)                    ; Enable our custom shader for next shapes/textures drawings
  DrawTexture(@texture, 0, 0, #COLOR_WHITE)   ; Drawing BLANK texture, all magic happens on shader
  EndShaderMode()                             ; Disable our custom shader, return to default shader
  
  DrawTextRayLib("BACKGROUND is PAINTED and ANIMATED on SHADER!", 10, 10, 20, #COLOR_MAROON)
  
  EndDrawing()
  ;>----------------------------------------------------------------------------------
  
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/shaders_texture_drawing.png")
  EndIf
  
Wend

; De-Initialization
;>--------------------------------------------------------------------------------------
UnloadShader(shader)

CloseWindowRayLib() ; Close window and OpenGL context

UnuseModule ray
;---------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 88
; FirstLine = 68
; Optimizer
; EnableThread
; EnableXP
; DPIAware
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)