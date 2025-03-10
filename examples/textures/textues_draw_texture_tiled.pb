; /*******************************************************************************************
; *
; *   raylib [textures] example - Draw part of the texture tiled
; *
; *   Example originally created With raylib 3.0, last time updated With raylib 4.2
; *
; *   Example contributed by Vlad Adrian (@demizdor) And reviewed by Ramon Santamaria (@raysan5)
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2020-2023 Vlad Adrian (@demizdor) And Ramon Santamaria (@raysan5)
; *
; ********************************************************************************************/
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

#OPT_WIDTH = 220       ; Max width For the options container
#MARGIN_SIZE = 8       ; Size For the margins
#COLOR_SIZE = 16       ; Size of the color Select buttons

; // Draw part of a texture (defined by a rectangle) With rotation And scale tiled into dest.
; void DrawTextureTiled(Texture2D texture, Rectangle source, Rectangle dest, Vector2 origin, float rotation, float scale, Color tint);

; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 450

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [textures] example - Draw part of a texture tiled" )
If Not IsWindowReady()                  ; After creating the window, we check
    End                                 ; for errors at initialization.
EndIf                                   ; In case of error at init we end the program.

; NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
Define.Texture texPattern 
LoadTextureRayLib(@texPattern, "resources/patterns.png")

SetTextureFilter(@texPattern, #TEXTURE_FILTER_TRILINEAR)    ; Makes the texture smoother when upscaled

; Coordinates For all patterns inside the texture
Dim recPattern.Rectangle(5)
InitRectangle(@recPattern(0), 3, 3, 66, 66)
InitRectangle(@recPattern(1), 75, 3, 100, 100)
InitRectangle(@recPattern(2), 3, 75, 66, 66)
InitRectangle(@recPattern(3), 7, 156, 50, 50)
InitRectangle(@recPattern(4), 85, 106, 90, 45)
InitRectangle(@recPattern(5), 75, 154, 100, 60)

; Setup colors
Dim colors.rl_ColorLong(9)
colors(0) = #COLOR_BLACK : colors(1) = #COLOR_MAROON : colors(2) = #COLOR_ORANGE : colors(3) = #COLOR_BLUE
colors(4) = #COLOR_PURPLE : colors(5) = #COLOR_BEIGE : colors(6) = #COLOR_LIME : colors(7) = #COLOR_RED
colors(8) = #COLOR_DARKGRAY : colors(9) = #COLOR_SKYBLUE

Define.rl_int MAX_COLORS = ArraySize(colors())

Dim colorRec.Rectangle(MAX_COLORS)

Define.rl_int i = 0, x = 0, y = 0

; Calculate rectangle For each color
For i = 0 To MAX_COLORS - 1
  colorRec(i)\x = 2.0 + #MARGIN_SIZE + x
  colorRec(i)\y = 22.0 + 256.0 + #MARGIN_SIZE + y
  colorRec(i)\width = #COLOR_SIZE * 2.0
  colorRec(i)\height = #COLOR_SIZE
  
  If i = (MAX_COLORS / 2 - 1)
    x = 0
    y + (#COLOR_SIZE + #MARGIN_SIZE)
  Else 
    x + (#COLOR_SIZE * 2 + #MARGIN_SIZE)
  EndIf
Next
        

Define.rl_int activePattern = 0, activeCol = 0
Define.rl_float scale = 1.0, rotation = 0.0

SetTargetFPS(60);
;>---------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose()   ; Detect window close button Or ESC key
  ; Update
  ;>----------------------------------------------------------------------------------
  
  ; Handle mouse
  If IsMouseButtonPressed(#MOUSE_LEFT_BUTTON)
    Define.Vector2 mouse 
    GetMousePosition(@mouse)

    ; Check which pattern was clicked And set it As the active pattern
    For i = 0 To ArraySize(recPattern())
      Define.Rectangle cRec
      InitRectangle(@cRec, 2 + #MARGIN_SIZE + recPattern(i)\x, 40 + #MARGIN_SIZE + recPattern(i)\y, recPattern(i)\width, recPattern(i)\height)
      If CheckCollisionPointRec(@mouse, @cRec)
        activePattern = i
        Break
      EndIf
    Next

    ; Check To see which color was clicked And set it As the active color
    For i = 0 To MAX_COLORS - 1
      If CheckCollisionPointRec(@mouse, @colorRec(i))
        activeCol = i
        Break
      EndIf
    Next
  EndIf

  ; Handle keys

  ; Change scale
  If IsKeyPressed(#KEY_UP)
    scale + 0.25
  EndIf
  
  If IsKeyPressed(#KEY_DOWN)
    scale - 0.25
  EndIf
  
  If scale > 10.0
    scale = 10.0
  ElseIf scale <= 0.0
    scale = 0.25
  EndIf

  ; Change rotation
  If IsKeyPressed(#KEY_LEFT)
    rotation - 25.0
  EndIf
  
  If IsKeyPressed(#KEY_RIGHT)
    rotation + 25.0
  EndIf

  ; Reset
  If IsKeyPressed(#KEY_SPACE)
    rotation = 0.0
    scale = 1.0
  EndIf
  
  ;>----------------------------------------------------------------------------------

  ; Draw
  ;-----------------------------------------------------------------------------------
  BeginDrawing()
  
  ClearBackground(#COLOR_RAYWHITE)

  ; Draw the tiled area
  Define.Rectangle drawRec
  InitRectangle(@drawRec, #OPT_WIDTH + #MARGIN_SIZE, #MARGIN_SIZE, GetScreenWidth() - #OPT_WIDTH - 2.0 * #MARGIN_SIZE, 
                GetScreenHeight() - 2.0 * #MARGIN_SIZE)
  
  Define.Vector2 drawV
  InitVector2(@drawV, 0, 0)
  
  DrawTextureTiled(@texPattern, @recPattern(activePattern), drawRec,
                   drawV, rotation, scale, colors(activeCol))

  ; Draw options
  DrawRectangle(#MARGIN_SIZE, #MARGIN_SIZE, #OPT_WIDTH - #MARGIN_SIZE, GetScreenHeight() - 2 * #MARGIN_SIZE, ColorAlpha(#COLOR_LIGHTGRAY, 0.5))

  DrawTextRayLib("Select Pattern", 2 + #MARGIN_SIZE, 30 + #MARGIN_SIZE, 10, #COLOR_BLACK)
  
  DrawTexture(@texPattern, 2 + #MARGIN_SIZE, 40 + #MARGIN_SIZE, #COLOR_BLACK)
  
  DrawRectangle(2 + #MARGIN_SIZE + recPattern(activePattern)\x, 40 + #MARGIN_SIZE + recPattern(activePattern)\y, recPattern(activePattern)\width, recPattern(activePattern)\height, ColorAlpha(#COLOR_DARKBLUE, 0.3))

  DrawTextRayLib("Select Color", 2 + #MARGIN_SIZE, 10 + 256 + #MARGIN_SIZE, 10, #COLOR_BLACK)
  
  For i = 0 To MAX_COLORS - 1
    DrawRectangleRec(@colorRec(i), colors(i))
    If activeCol = i 
      DrawRectangleLinesEx(@colorRec(i), 3, ColorAlpha(#COLOR_WHITE, 0.5))
    EndIf
  Next

  DrawTextRayLib("Scale (UP/DOWN to change)", 2 + #MARGIN_SIZE, 80 + 256 + #MARGIN_SIZE, 10, #COLOR_BLACK)
  DrawTextRayLib(StrF(scale, 2), 2 + #MARGIN_SIZE, 92 + 256 + #MARGIN_SIZE, 20, #COLOR_BLACK)

  DrawTextRayLib("Rotation (LEFT/RIGHT to change)", 2 + #MARGIN_SIZE, 122 + 256 + #MARGIN_SIZE, 10, #COLOR_BLACK)
  DrawTextRayLib(StrF(rotation, 2) +" degrees", 2 + #MARGIN_SIZE, 134 + 256 + #MARGIN_SIZE, 20, #COLOR_BLACK)

  DrawTextRayLib("Press [SPACE] to reset", 2 + #MARGIN_SIZE, 164 + 256 + #MARGIN_SIZE, 10, #COLOR_DARKBLUE)

  ; Draw FPS
  DrawTextRayLib(Str(GetFPS()), 2 + #MARGIN_SIZE, 2 + #MARGIN_SIZE, 20, #COLOR_BLACK)
  EndDrawing()
  ;>----------------------------------------------------------------------------------
  
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/textues_draw_texture_tiled.png")
  EndIf
Wend

; De-Initialization
;>--------------------------------------------------------------------------------------
UnloadTexture(@texPattern)        ; Unload texture

CloseWindowRayLib()               ; Close window And OpenGL context
;---------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 42
; FirstLine = 33
; Optimizer
; EnableThread
; EnableXP
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)