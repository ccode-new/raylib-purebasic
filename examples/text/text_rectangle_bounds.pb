; /*******************************************************************************************
; *
; *   raylib [text] example - Rectangle bounds
; *
; *   Example originally created With raylib 2.5, last time updated With raylib 4.0
; *
; *   Example contributed by Vlad Adrian (@demizdor) And reviewed by Ramon Santamaria (@raysan5)
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2018-2023 Vlad Adrian (@demizdor) And Ramon Santamaria (@raysan5)
; *
; ********************************************************************************************/
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

Declare DrawTextBoxed(*font.Font, text.s, *rec.Rectangle, fontSize.rl_float, spacing.rl_float, wordWrap.rl_bool, tint.rl_ColorLong) ; Draw text using font inside rectangle limits

; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 450

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [text] example - draw text inside a rectangle" )
If Not IsWindowReady()                  ; After creating the window, we check
  End                                   ; for errors at initialization.
EndIf

Define.s text = ~"Text cannot escape\tthis container\t...word wrap also works when active so here's " +
                ~"a long text For testing.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod " +
                ~"tempor incididunt ut labore et dolore magna aliqua. Nec ullamcorper sit amet risus nullam eget felis eget."

Define.rl_bool resizing = #False
Define.rl_bool wordWrap = #True

Define.Rectangle container 
InitRectangle(@container, 25.0, 25.0, #SCREEN_WIDTH - 50.0, #SCREEN_HEIGHT - 250.0)

Define.Rectangle resizer 
InitRectangle(@resizer, container\x + container\width - 17, container\y + container\height - 17, 14, 14)

; Minimum width And heigh For the container rectangle
#MIN_WIDTH = 60
#MIN_HEIGHT = 60
#MAX_WIDTH = #SCREEN_WIDTH - 50.0
#MAX_HEIGHT = #SCREEN_HEIGHT - 160.0

Define.Vector2 lastMouse 
InitVector2( 0.0, 0.0 ) ; Stores last mouse coordinates

Define.rl_ColorLong borderColor = #COLOR_MAROON ; Container border color

Define.Font font 
GetFontDefault(@font) ; Get default system font

SetTargetFPS(60) ; Set our game to run at 60 frames-per-second
                 ;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose() ; Detect window close button Or ESC key
                              ; Update
                              ;----------------------------------------------------------------------------------
  If IsKeyPressed(#KEY_SPACE)
    wordWrap ! 1
  EndIf
  
  Define.Vector2 mouse 
  GetMousePosition(@mouse)
  
  ; Check If the mouse is inside the container And toggle border color
  If CheckCollisionPointRec(@mouse, @container)
    borderColor = Fade(#COLOR_MAROON, 0.4)
  ElseIf Not resizing
    borderColor = #COLOR_MAROON
  EndIf
  
  ; Container resizing logic
  If resizing
    If IsMouseButtonReleased(#MOUSE_LEFT_BUTTON)
      resizing = #False
    EndIf
    
    Define width = container\width + (mouse\x - lastMouse\x)
    If (width > #MIN_WIDTH)
      If width < #MAX_WIDTH
        container\width = width
      Else
        container\width = #MAX_WIDTH
      EndIf
    Else
      container\width = #MIN_WIDTH
    EndIf
    
    Define height = container\height + (mouse\y - lastMouse\y)
    If height > #MIN_HEIGHT
      If height < #MAX_HEIGHT
        container\height = height
      Else
        container\height = #MAX_HEIGHT
      EndIf
    Else
      container\height = #MIN_HEIGHT
    EndIf
    
  Else
    ; Check if we're resizing
    If IsMouseButtonDown(#MOUSE_LEFT_BUTTON) And CheckCollisionPointRec(@mouse, @resizer)
      resizing = #True
    EndIf
    
  EndIf
  
  ; Move resizer rectangle properly
  resizer\x = container\x + container\width - 17
  resizer\y = container\y + container\height - 17
  
  lastMouse = mouse   ; Update mouse
  ;>---------------------------------------------------------------------------------
  
  ; Draw
  ;----------------------------------------------------------------------------------
  BeginDrawing()
  
  ClearBackground(#COLOR_RAYWHITE)
  
  DrawRectangleLinesEx(@container, 3, borderColor) ; Draw container border
  
  ; Draw text in container (add some padding)
  Define rect.Rectangle
  InitRectangle(@rect, container\x+4, container\y+4, container\width-4, container\height-4)
  
  DrawTextBoxed(@font, text, @rect, 20.0, 2.0, wordWrap, #COLOR_GRAY)
  
  DrawRectangleRec(@resizer, borderColor) ; Draw the resize box
  
  ; Draw bottom info
  DrawRectangle(0, #SCREEN_HEIGHT - 54, #SCREEN_WIDTH, 54, #COLOR_GRAY)
  InitRectangle(@rect, 382, #SCREEN_HEIGHT - 34, 12, 12)
  DrawRectangleRec(@rect, #COLOR_MAROON)
  
  DrawTextRayLib("Word Wrap: ", 313, #SCREEN_HEIGHT - 115, 20, #COLOR_BLACK)
  If wordWrap 
    DrawTextRayLib("ON", 447, #SCREEN_HEIGHT - 115, 20, #COLOR_RED)
  Else 
    DrawTextRayLib("OFF", 447, #SCREEN_HEIGHT - 115, 20, #COLOR_BLACK)
  EndIf
  
  DrawTextRayLib("Press [SPACE] to toggle word wrap", 218, #SCREEN_HEIGHT - 86, 20, #COLOR_GRAY)
  
  DrawTextRaylib("Click hold & drag the    to resize the container", 155, #SCREEN_HEIGHT - 38, 20, #COLOR_RAYWHITE)
  
  EndDrawing()
  ;>----------------------------------------------------------------------------------
  
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/text_rectangle_bounds.png")
  EndIf
  
Wend

; De-Initialization
;>-------------------------------------------------------------------------------------
CloseWindowRaylib() ; Close window and OpenGL context
;--------------------------------------------------------------------------------------

;>--------------------------------------------------------------------------------------
; Module functions definition
;--------------------------------------------------------------------------------------

; Draw text using font inside rectangle limits
Procedure DrawTextBoxed(*font.Font, text.s, *rec.Rectangle, fontSize.rl_float, spacing.rl_float, wordWrap.rl_bool, tint.rl_ColorLong)
  DrawTextBoxedSelectable(*font, text, *rec, fontSize, spacing, wordWrap, tint, 0, 0, #COLOR_WHITE, #COLOR_WHITE)
EndProcedure

UnuseModule ray
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 173
; FirstLine = 148
; Folding = -
; Optimizer
; EnableThread
; EnableXP
; DPIAware
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)