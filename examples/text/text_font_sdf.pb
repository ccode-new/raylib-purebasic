; /*******************************************************************************************
; *
; *   raylib [text] example - Font SDF loading
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

; Desktop platforms
#GLSL_VERSION = "330"
; PLATFORM_RPI, PLATFORM_ANDROID, PLATFORM_WEB
;#GLSL_VERSION = "100"

; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 450

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [text] example - SDF fonts" )
If Not IsWindowReady()                  ; After creating the window, we check
    End                                 ; for errors at initialization.
EndIf                                   ; In case of error at init we end the program.

; NOTE: Textures/Fonts MUST be loaded after Window initialization (OpenGL context is required)

#msg = "Signed Distance Fields"

; Loading file To memory
Define.rl_uint fileSize = 0
Define *fileData = LoadFileData("resources/AnonymousPro-Bold.ttf", @fileSize)

; Default font generation from TTF font
Define.Font fontDefault
fontDefault\baseSize = 16
fontDefault\glyphCount = 95
  
; Loading font Data from memory Data
; Parameters > font size: 16, no glyphs Array provided (0), glyphs count: 95 (autogenerate chars Array)
fontDefault\glyphs = LoadFontData(*fileData, fileSize, 16, 0, 95, #FONT_DEFAULT)

; Parameters > glyphs count: 95, font size: 16, glyphs padding in image: 4 px, pack method: 0 (Default)
Define.Image atlas
GenImageFontAtlas(@atlas, fontDefault\glyphs, @fontDefault\recs, 95, 16, 4, 0)
LoadTextureFromImage(@fontDefault\texture, @atlas)
UnloadImage(@atlas)                                                                  
  
; SDF font generation from TTF font
Define.Font fontSDF
fontSDF\baseSize = 16
fontSDF\glyphCount = 95

; Parameters > font size: 16, no glyphs Array provided (0), glyphs count: 0 (defaults To 95)
fontSDF\glyphs = LoadFontData(*fileData, fileSize, 16, 0, 0, #FONT_SDF)

; Parameters > glyphs count: 95, font size: 16, glyphs padding in image: 0 px, pack method: 1 (Skyline algorythm)
GenImageFontAtlas(@atlas, fontSDF\glyphs, @fontSDF\recs, 95, 16, 0, 1)
LoadTextureFromImage(@fontSDF\texture, @atlas)                         
UnloadImage(@atlas)                                                    
  
UnloadFileData(*fileData)  ; Free memory from loaded file
  
; Load SDF required shader (we use Default vertex shader)
Define.Shader shader
LoadShader(@shader, "resources/shaders/glsl"+#GLSL_VERSION+"/sdf.fs", #GLSL_VERSION)

SetTextureFilter(@fontSDF\texture, #TEXTURE_FILTER_BILINEAR) ; Required for SDF font
  
Define.Vector2 fontPosition
InitVector2(@fontPosition, 40, #SCREEN_HEIGHT/2 - 50)

Define.Vector2 textSize
InitVector2(@textSize, 0, 0)

Define.rl_float fontSize = 16.0
Define.rl_int currentFont = 0 ; 0 - fontDefault, 1 - fontSDF
  
SetTargetFPS(60) ; Set our game to run at 60 frames-per-second

;>--------------------------------------------------------------------------------------
  
; Main game loop
While Not WindowShouldClose() ; Detect window close button Or ESC key
  
  ; Update
  ;>----------------------------------------------------------------------------------
  fontSize + GetMouseWheelMove() * 8.0
  
  If fontSize < 6 : fontSize = 6 : EndIf
  
  If IsKeyDown(#KEY_SPACE)
    currentFont = 1
  Else
    currentFont = 0 
  EndIf
  
  If (currentFont = 0) 
    MeasureTextEx(@textSize, @fontDefault, #msg, fontSize, 0)
  Else 
    MeasureTextEx(@textSize, @fontSDF, #msg, fontSize, 0)                     ;
  EndIf         
  
  ;Debug textSize\x
  fontPosition\x = (GetScreenWidth() / 2) - (textSize\x / 2)
  fontPosition\y = (GetScreenHeight() / 2) - (textSize\y / 2 + 80)
  
  ;>----------------------------------------------------------------------------------
  
  ; Draw
  ;>----------------------------------------------------------------------------------
  BeginDrawing()
  
  ClearBackground(#COLOR_RAYWHITE);
  
  If currentFont = 1
    ; NOTE: SDF fonts require a custom SDf shader To compute fragment color
    BeginShaderMode(@shader)  ; Activate SDF font shader
      DrawTextEx(@fontSDF, #msg, @fontPosition, fontSize, 0, #COLOR_BLACK)
    EndShaderMode() ; Activate our default shader for next drawings
    
    DrawTextEx(@fontSDF, #msg, @fontPosition, fontSize, 0, #COLOR_RED)
    
    DrawTexture(@fontSDF\texture, 10, 10, #COLOR_BLACK);
    
  Else
    DrawTextEx(@fontDefault, #msg, @fontPosition, fontSize, 0, #COLOR_RED)
    ;DrawTextRayLib(#msg, 200, 200, fontSize, #COLOR_RED)
    DrawTexture(@fontDefault\texture, 10, 10, #COLOR_BLACK)                
  EndIf
  
  If currentFont = 1 
    DrawTextRayLib("SDF!", 320, 20, 80, #COLOR_RED)
  Else 
    DrawTextRayLib("default font", 315, 40, 30, #COLOR_GRAY)
  EndIf           
  
  DrawTextRayLib("FONT SIZE: 16.0", GetScreenWidth() - 240, 20, 20, #COLOR_DARKGRAY)
  DrawTextRayLib("RENDER SIZE: "+StrF(fontSize, 2), GetScreenWidth() - 240, 50, 20, #COLOR_DARKGRAY)
  DrawTextRayLib("Use MOUSE WHEEL to SCALE TEXT!", GetScreenWidth() - 240, 90, 10, #COLOR_DARKGRAY)
  
  DrawTextRayLib("HOLD SPACE to USE SDF FONT VERSION!", 340, GetScreenHeight() - 30, 20, #COLOR_MAROON)
  
  EndDrawing()
  ;>----------------------------------------------------------------------------------
  
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/text_font_sdf.png")
  EndIf
  
Wend

; De-Initialization
;>--------------------------------------------------------------------------------------
UnloadFont(@fontDefault)  ; Default font unloading
UnloadFont(@fontSDF)      ; SDF font unloading
              
UnloadShader(@shader)     ; Unload SDF shader
              
CloseWindowRayLib()             ; Close window and OpenGL context
;>--------------------------------------------------------------------------------------
              
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 64
; FirstLine = 42
; Optimizer
; EnableThread
; EnableXP
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)