; /*******************************************************************************************
; *
; *   raylib [text] example - Draw 3d
; *
; *   NOTE: Draw a 2D text in 3D space, each letter is drawn in a quad (Or 2 quads If backface is set)
; *   where the texture coodinates of each quad Map To the texture coordinates of the glyphs
; *   inside the font texture.
; *
; *   A more efficient approach, i believe, would be To render the text in a render texture And
; *   Map that texture To a plane And render that, Or maybe a shader but my method allows more
; *   flexibility...For example To change position of each letter individually To make somethink
; *   like a wavy text effect.
; *    
; *   Special thanks To:
; *        @Nighten For the DrawTextStyle() code https://github.com/NightenDushi/Raylib_DrawTextStyle
; *        Chris Camacho (codifies - http://bedroomcoders.co.uk/) For the alpha discard shader
; *
; *   Example originally created With raylib 3.5, last time updated With raylib 4.0
; *
; *   Example contributed by Vlad Adrian (@demizdor) And reviewed by Ramon Santamaria (@raysan5)
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2021-2023 Vlad Adrian (@demizdor)
; *
; ********************************************************************************************/
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

;//--------------------------------------------------------------------------------------
;// Globals
;//--------------------------------------------------------------------------------------
#LETTER_BOUNDRY_SIZE  = 0.25
#TEXT_MAX_LAYERS = 32
#LETTER_BOUNDRY_COLOR = #COLOR_VIOLET

Global.rl_bool SHOW_LETTER_BOUNDRY = #False
Global.rl_bool SHOW_TEXT_BOUNDRY = #False

; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 450

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [text] example - draw 2D text in 3D" )
If Not IsWindowReady()                ; After creating the window, we check
  End                                 ; for errors at initialization.
EndIf                                 ; In case of error at init we end the program.

Define.rl_bool spin = #True           ; Spin the camera?
Define.rl_bool multicolor = #False    ; Multicolor mode

; Define the camera To look into our 3d world
Define.Camera3D camera
Init_Vector3(@camera\position, -10.0, 15.0, -10.0)  ; Camera position
Init_Vector3(@camera\target, 0.0, 0.0, 0.0)         ; Camera looking at point
Init_Vector3(@camera\up, 0.0, 1.0, 0.0)             ; Camera up vector (rotation towards target)
camera\fovy = 45.0                                  ; Camera field-of-view Y
camera\projection = #CAMERA_PERSPECTIVE         ; Camera mode type

;SetCameraMode(@camera, #CAMERA_ORBITAL)

Define._Vector3 cubePosition
Init_Vector3(@cubePosition, 0.0, 1.0, 0.0)

Define._Vector3 cubeSize
Init_Vector3(@cubeSize, 2.0, 2.0, 2.0)

SetTargetFPS(60) ; Set our game to run at 60 frames-per-second

; Use the Default font
Define.Font font
GetFontDefault(@font)

Define.rl_float fontSize = 8.0
Define.rl_float fontSpacing = 0.5
Define.rl_float lineSpacing = -1.0

; Set the text (using markdown!)
Define text.s{64} = "Hello ~~World~~ in 3D!"
Define._Vector3 tbox
Define.rl_int layers = 1
Define.rl_int quads = 0
Define.rl_float layerDistance = 0.01

Define.WaveTextConfig wcfg
wcfg\waveSpeed\y = 3.0 
wcfg\waveSpeed\x = wcfg\waveSpeed\y
wcfg\waveSpeed\z = 0.5
wcfg\waveOffset\z = 0.35
wcfg\waveOffset\y = wcfg\waveOffset\z
wcfg\waveOffset\x = wcfg\waveOffset\y
wcfg\waveRange\z = 0.45
wcfg\waveRange\y = wcfg\waveRange\z
wcfg\waveRange\x = wcfg\waveRange\y

Define.rl_float time = 0.0

; Setup a light And dark color
Define.rl_ColorLong light = #COLOR_MAROON
Define.rl_ColorLong dark = #COLOR_RED

; Load the alpha discard shader
Define.Shader alphaDiscard  
LoadShader(@alphaDiscard, #Null$, "resources/shaders/glsl330/alpha_discard.fs")

; Array filled With multiple random colors (when multicolor mode is set)
Dim multi.rl_ColorLong(#TEXT_MAX_LAYERS)

;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose() ; Detect window close button Or ESC key
  ; Update
  ;>----------------------------------------------------------------------------------
  UpdateCamera(@camera, #CAMERA_ORBITAL)
  
  ; Handle Events
  If IsKeyPressed(#KEY_F1)
    SHOW_LETTER_BOUNDRY = Bool(Not SHOW_LETTER_BOUNDRY)
  EndIf
  If IsKeyPressed(#KEY_F2)
    SHOW_TEXT_BOUNDRY = Bool(Not SHOW_TEXT_BOUNDRY)
  EndIf
  If IsKeyPressed(#KEY_F3)
    ; Handle camera change
    If spin = #True
      spin = #False
    Else
      spin = #True
    EndIf
    ; we need To reset the camera when changing modes
    Init_Vector3(@camera\target, 0.0, 0.0, 0.0)           ; Camera looking at point
    Init_Vector3(@camera\up, 0.0, 1.0, 0.0)               ; Camera up vector (rotation towards target)
    camera\fovy = 45.0                                    ; Camera field-of-view Y
    camera\projection = #CAMERA_PERSPECTIVE           ; Camera mode type
    
    If spin = #True 
      Init_Vector3(@camera\position, -10.0, 15.0, -10.0)  ; Camera position
      UpdateCamera(@camera, #CAMERA_ORBITAL)
    Else
      Init_Vector3(@camera\position, 10.0, 10.0, -10.0)   ; Camera position
      UpdateCamera(@camera, #CAMERA_FREE)
    EndIf
  EndIf
  ; Handle clicking the cube
  If IsMouseButtonPressed(#MOUSE_LEFT_BUTTON)
    Define.Ray ray
    Define.Vector2 mousePos
    Define.BoundingBox collision_box
    
    GetMousePosition(@mousePos)
    
    GetMouseRay(@ray, @mousePos, @camera)
    
    ; Check collision between ray And box
    Define.RayCollision collision 
    
    With collision_box
      \min\x = cubePosition\x - cubeSize\x / 2
      \min\y = cubePosition\y - cubeSize\y / 2
      \min\z = cubePosition\z - cubeSize\z / 2
      
      \max\x = cubePosition\x + cubeSize\x / 2
      \max\y = cubePosition\y + cubeSize\y / 2
      \max\z = cubePosition\z + cubeSize\z / 2
    EndWith
    
    GetRayCollisionBox(@collision, @ray, @collision_box)
    If collision\hit
      ; Generate new random colors
       GenerateRandomColor(@light, 0.5, 0.78)
       GenerateRandomColor(@dark, 0.4, 0.58)
    EndIf
  EndIf
  ; Handle text layers changes
  If IsKeyPressed(#KEY_HOME)
    If layers > 1
      layers - 1
    EndIf
  ElseIf IsKeyPressed(#KEY_END)
    If layers < #TEXT_MAX_LAYERS
      layers + 1
    EndIf
  EndIf
  
  ; Handle text changes
  If IsKeyPressed(#KEY_LEFT)
    fontSize - 0.5
  ElseIf IsKeyPressed(#KEY_RIGHT)
    fontSize + 0.5
  ElseIf IsKeyPressed(#KEY_UP)
    fontSpacing - 0.1
  ElseIf IsKeyPressed(#KEY_DOWN)
    fontSpacing + 0.1
  ElseIf IsKeyPressed(#KEY_PAGE_UP)
    lineSpacing - 0.1
  ElseIf IsKeyPressed(#KEY_PAGE_DOWN)
    lineSpacing + 0.1
  ElseIf IsKeyDown(#KEY_INSERT)
    layerDistance - 0.001
  ElseIf IsKeyDown(#KEY_DELETE)
    layerDistance + 0.001
  ElseIf IsKeyPressed(#KEY_TAB)
    If multicolor = #True
      multicolor = #False ; Enable /disable multicolor mode
    Else
      multicolor = #True
    EndIf
  EndIf
  
  If multicolor = #True
    ; Fill color Array With random colors
    Define.rl_int i
    For i = 0 To #TEXT_MAX_LAYERS - 1
       GenerateRandomColor(@multi(i), 0.5, 0.8)
    Next
  EndIf
  
  ; Measure 3D text so we can center it
  MeasureTextWave3D(@tbox, @font, text, fontSize, fontSpacing, lineSpacing)
  
  quads = 0               ;// Reset quad counter
  time + GetFrameTime()   ;// Update timer needed by `DrawTextWave3D()`
  ;>----------------------------------------------------------------------------------
  
  ; Draw
  ;-----------------------------------------------------------------------------------
  BeginDrawing()
  
  ClearBackground(#COLOR_RAYWHITE)
  
  BeginMode3D(@camera)
  DrawCubeV(@cubePosition, @cubeSize, dark)
  DrawCubeWires(@cubePosition, 2.1, 2.1, 2.1, light)
  
  DrawGrid(10, 2.0)
  
  ; Use a shader To handle the depth buffer issue With transparent textures
  ; NOTE: more info at https://bedroomcoders.co.uk/raylib-billboards-advanced-use/
  ;BeginShaderMode(alphaDiscard)
  
  ; Draw the 3D text above the red cube
  rlPushMatrix()
  rlRotatef(90.0, 1.0, 0.0, 0.0)
  rlRotatef(90.0, 0.0, 0.0, -1.0)
  
  Define.rl_int i
  For i = 0 To layers - 1
    Define.rl_ColorLong clr = light
    If multicolor = #True
      clr = multi(i)
    EndIf
    Define._Vector3 tvec
    Init_Vector3(@tvec, -tbox\x / 2.0, layerDistance * i, -4.5)
    DrawTextWave3D(@font, text, @tvec, fontSize, fontSpacing, lineSpacing, #True, @wcfg, time, clr)
  Next
  
  ; Draw the text boundry If set
  If SHOW_TEXT_BOUNDRY = #True
    Define._Vector3 cube_vec
    Init_Vector3(@cube_vec, 0.0, 0.0, -4.5 + tbox\z / 2)
    
    DrawCubeWiresV(@cube_vec, @tbox, dark)
  EndIf
  
  rlPopMatrix()
  
  ; Don't draw the letter boundries for the 3D text below
  Define.rl_bool slb = SHOW_LETTER_BOUNDRY
  SHOW_LETTER_BOUNDRY = #False
  
  ; Draw 3D options (use Default font)
  ;>-------------------------------------------------------------------------
  rlPushMatrix()
  
  rlRotatef(180.0, 0.0, 1.0, 0.0)
  
  Define opt.s = "< SIZE: "+StrF(fontSize, 2)+" >"
  
  quads + Len(opt)
  
  Define._Vector3 m 
  GetFontDefault(@font)
  MeasureText3D(@m, @font, opt, 8.0, 1.0, 0.0)
  
  Define._Vector3 pos 
  Init_Vector3(@pos, -m\x / 2.0, 0.01, 2.0)
  
  DrawText3D(@font, opt, @pos, 8.0, 1.0, 0.0, #False, #COLOR_BLUE)
  
  pos\z + (0.5 + m\z)
  
  opt = "< SPACING: "+StrF(fontSpacing, 2)+" >"
  
  quads + Len(opt)
  
  MeasureText3D(@m, @font, opt, 8.0, 1.0, 0.0)
  
  pos\x = (-m\x / 2.0)
  
  DrawText3D(@font, opt, @pos, 8.0, 1.0, 0.0, #False, #COLOR_BLUE)
  
  pos\z + (0.5 + m\z)
  
  opt = "< LINE: "+StrF(lineSpacing, 2)+" >"
  
  quads + Len(opt)
  
  MeasureText3D(@m, @font, opt, 8.0, 1.0, 0.0)
  
  pos\x = (-m\x / 2.0)
  
  DrawText3D(@font, opt, @pos, 8.0, 1.0, 0.0, #False, #COLOR_BLUE)
  
  pos\z + (1.0 + m\z)
  
  If slb = #True
    opt = "< LBOX: ON >"
  Else
    opt = "< LBOX: OFF >"
  EndIf
  
  quads + Len(opt)
  
  MeasureText3D(@m, @font, opt, 8.0, 1.0, 0.0)
  
  pos\x = (-m\x / 2.0)
  
  DrawText3D(@font, opt, @pos, 8.0, 1.0, 0.0, #False, #COLOR_RED)
  
  pos\z + (0.5 + m\z)
  
  If SHOW_TEXT_BOUNDRY = #True
    opt = "< TBOX: ON >"
  Else
    opt = "< TBOX: OFF >"
  EndIf
  
  quads + Len(opt)
  
  MeasureText3D(@m, @font, opt, 8.0, 1.0, 0.0)
  
  pos\x = (-m\x / 2.0)
  
  DrawText3D(@font, opt, @pos, 8.0, 1.0, 0.0, #False, #COLOR_RED)
  
  pos\z + (0.5 + m\z)
  
  opt = "< LAYER DISTANCE: "+StrF(layerDistance, 2)+" >"
  
  quads + Len(opt)
  
  MeasureText3D(@m, @font, opt, 8.0, 1.0, 0.0)
  
  pos\x = (-m\x / 2.0)
  
  DrawText3D(@font, opt, @pos, 8.0, 1.0, 0.0, #False, #COLOR_DARKPURPLE)
  
  rlPopMatrix()
  
  ;>-------------------------------------------------------------------------
  
  ; Draw 3D info text (use Default font)
  ;--------------------------------------------------------------------------
  opt = "All the text displayed here is in 3D"
  quads + 36
  
  MeasureText3D(@m, @font, opt, 10.0, 0.5, 0.0)
  
  Init_Vector3(@pos, -m\x / 2.0, 0.01, 2.0)
  
  DrawText3D(@font, opt, @pos, 10.0, 0.5, 0.0, #False, #COLOR_DARKBLUE)
  
  pos\z + (1.5 + m\z)
  
  opt = "press [Left]/[Right] to change the font size"
  quads + 44
  
  MeasureText3D(@m, @font, opt, 6.0, 0.5, 0.0)
  
  pos\x = -m\x / 2.0
  
  DrawText3D(@font, opt, @pos, 6.0, 0.5, 0.0, #False, #COLOR_DARKBLUE)
  
  pos\z + (0.5 + m\z)
  
  opt = "press [Up]/[Down] to change the font spacing"
  quads + 44
  
  MeasureText3D(@m, @font, opt, 6.0, 0.5, 0.0)
  
  pos\x = (-m\x / 2.0)
  
  DrawText3D(@font, opt, @pos, 6.0, 0.5, 0.0, #False, #COLOR_DARKBLUE)
  
  pos\z + (0.5 + m\z)
  
  opt = "press [PgUp]/[PgDown] to change the line spacing"
  quads + 48
  
  MeasureText3D(@m, @font, opt, 6.0, 0.5, 0.0)
  
  pos\x = (-m\x / 2.0)
  
  DrawText3D(@font, opt, @pos, 6.0, 0.5, 0.0, #False, #COLOR_DARKBLUE)
  
  pos\z + (0.5 + m\z)
  
  opt = "press [F1] to toggle the letter boundry"
  quads + 39
  
  MeasureText3D(@m, @font, opt, 6.0, 0.5, 0.0)
  
  pos\x = (-m\x / 2.0)
  
  DrawText3D(@font, opt, @pos, 6.0, 0.5, 0.0, #False, #COLOR_DARKBLUE)
  
  pos\z + (0.5 + m\z)
  
  opt = "press [F2] to toggle the text boundry"
  quads + 37
  
  MeasureText3D(@m, @font, opt, 6.0, 0.5, 0.0)
  
  pos\x = (-m\x / 2.0)
  
  DrawText3D(@font, opt, @pos, 6.0, 0.5, 0.0, #False, #COLOR_DARKBLUE)
  
  ;>-------------------------------------------------------------------------
  
  SHOW_LETTER_BOUNDRY = slb
  
  ;EndShaderMode()
  
  EndMode3D()
  
  ; Draw 2D info text & stats
  ;--------------------------------------------------------------------------
  DrawTextRayLib("Press [F3] To toggle the camera", 10, 35, 10, #COLOR_BLACK)
  
  quads + (Len(text) * 2 * layers)
  
  Define tmp.s = Str(layers)+" layer(s) | "+Str(spin)+" camera | "+Str(quads)+" quads ("+StrF(quads * 4)+" verts)"
  
  Define.rl_int width = MeasureText(tmp, 10)
  
  DrawTextRayLib(tmp, #SCREEN_WIDTH - 20 - width, 10, 10, #COLOR_DARKGREEN)
  
  tmp = "[Home]/[End] to add/remove 3D text layers"
  
  width = MeasureText(tmp, 10)
  
  DrawTextRayLib(tmp, #SCREEN_WIDTH - 20 - width, 25, 10, #COLOR_DARKGRAY)
  
  tmp = "[Insert]/[Delete] to increase/decrease distance between layers"
  
  width = MeasureText(tmp, 10)
  
  DrawTextRayLib(tmp, #SCREEN_WIDTH - 20 - width, 40, 10, #COLOR_DARKGRAY)
  
  tmp = "click the [CUBE] for a random color"
  
  width = MeasureText(tmp, 10)
  
  DrawTextRayLib(tmp, #SCREEN_WIDTH - 20 - width, 55, 10, #COLOR_DARKGRAY)
  
  tmp = "[Tab] to toggle multicolor mode"
  
  width = MeasureText(tmp, 10)
  
  DrawTextRayLib(tmp, #SCREEN_WIDTH - 20 - width, 70, 10, #COLOR_DARKGRAY)
  ;--------------------------------------------------------------------------
  
  DrawFPS(10, 10)
  
  EndDrawing()
  ;>----------------------------------------------------------------------------------
  
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/text_3D_text.png")
  EndIf
Wend

; De-Initialization
;--------------------------------------------------------------------------------------
UnloadFont(@font)
CloseWindowRayLib()       ;// Close window and OpenGL context
;--------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 438
; FirstLine = 422
; Optimizer
; EnableThread
; EnableXP
; DPIAware
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)