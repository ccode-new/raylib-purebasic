; /*******************************************************************************************
; *
; *   raylib [shapes] example - Draw Textured Polygon
; *
; *   Example originally created With raylib 3.7, last time updated With raylib 3.7
; *
; *   Example contributed by Chris Camacho (@codifies) And reviewed by Ramon Santamaria (@raysan5)
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2021-2023 Chris Camacho (@codifies) And Ramon Santamaria (@raysan5)
; *
; ********************************************************************************************/
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

;// Rotate vector by angle
Procedure Vector2Rotate(*v_result.Vector2, *v.Vector2, angle.rl_float)  
  Protected.rl_float cosres = Cos(angle)
  Protected.rl_float sinres = Sin(angle)

  *v_result\x = *v\x * cosres - *v\y * sinres
  *v_result\y = *v\x * sinres + *v\y * cosres
EndProcedure

#MAX_POINTS = 11                        ; 10 points And back To the start

; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 450

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [textures] example - textured polygon" )
If Not IsWindowReady()                  ; After creating the window, we check
  End                                   ; for errors at initialization.
EndIf 

; // Draw textured polygon, defined by vertex And texture coordinates
; void DrawTexturePoly(Texture2D texture, Vector2 center, Vector2 *points, Vector2 *texcoords, int pointCount, Color tint);

; Define texture coordinates To Map our texture To poly
Dim texcoords.Vector2(#MAX_POINTS)
InitVector2(texcoords(0), 0.75, 0.0)
InitVector2(texcoords(1), 0.25, 0.0)
InitVector2(texcoords(2), 0.0, 0.5)
InitVector2(texcoords(3), 0.0, 0.75)
InitVector2(texcoords(4), 0.25, 1.0)
InitVector2(texcoords(5), 0.375, 0.875)
InitVector2(texcoords(6), 0.625, 0.875)
InitVector2(texcoords(7), 0.75, 1.0)
InitVector2(texcoords(8), 1.0, 0.75)
InitVector2(texcoords(9), 1.0, 0.5)
InitVector2(texcoords(10), 0.75, 0.0) ; Close the poly

; Define the base poly vertices from the UV's
; NOTE: They can be specified in any other way
Dim points.Vector2(#MAX_POINTS)

Define.rl_int i
For i = 0 To #MAX_POINTS - 1
  points(i)\x = (texcoords(i)\x - 0.5) * 256.0
  points(i)\y = (texcoords(i)\y - 0.5) * 256.0
Next
    
; Define the vertices drawing position
; NOTE: Initially same As points but updated every frame
Dim positions.Vector2(#MAX_POINTS)

For i = 0 To #MAX_POINTS -1
  positions(i) = points(i)
Next

; Load texture To be mapped To poly
Define.Texture texture 
LoadTextureRayLib(@texture, "resources/cat.png")

Define.rl_float angle = 0.0 ; Rotation angle (in degrees)

Define.Vector2 texV
InitRectangle(@texV, GetScreenWidth() / 2.0, GetScreenHeight() / 2.0)

Define *p_positions = @positions()
Define *p_texcoords = @texcoords()

SetTargetFPS(60) ; Set our game to run at 60 frames-per-second
;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose() ; Detect window close button Or ESC key
  ; Update
  ;>----------------------------------------------------------------------------------
  ; Update points rotation With an angle transform
  ; NOTE: Base points position are Not modified
  angle + 1
  
  For i = 0 To #MAX_POINTS -1
    Vector2Rotate(@positions(i), @points(i), angle * #DEG2RAD)
  Next
  
  ;>----------------------------------------------------------------------------------

  ; Draw
  ;-----------------------------------------------------------------------------------
  BeginDrawing()

  ClearBackground(#COLOR_RAYWHITE)

  DrawTextRayLib("textured polygon", 20, 20, 20, #COLOR_DARKGRAY)

  DrawTexturePoly(@texture, @texV, *p_positions, *p_texcoords, #MAX_POINTS, #COLOR_WHITE)

  EndDrawing()
  ;>-----------------------------------------------------------------------------------
  
  ; If we want to have a screenshot
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/texture_textured_polygon.png")
  EndIf
Wend

; De-Initialization
;>--------------------------------------------------------------------------------------
UnloadTexture(@texture) ; Unload texture

CloseWindowRayLib()     ; Close window and OpenGL context
;---------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 121
; FirstLine = 68
; Folding = -
; Optimizer
; EnableThread
; EnableXP
; DPIAware
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)