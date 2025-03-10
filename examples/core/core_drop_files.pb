; /*******************************************************************************************
; *
; *   raylib [core] example - Windows drop files
; *
; *   NOTE: This example only works on platforms that support drag & drop (Windows, Linux, OSX, Html5?)
; *
; *   Example originally created With raylib 1.3, last time updated With raylib 4.2
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2015-2023 Ramon Santamaria (@raysan5)
; *
; ********************************************************************************************/

;- This example doesn't work.

IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 450

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [core] example - drop files" )
If Not IsWindowReady()                  ; After creating the window, we check
  End                                   ; for errors at initialization.
EndIf 

Define.FilePathList droppedFiles
droppedFiles\capacity = 10
Define.i i = 0
Define.b check = #False

SetTargetFPS(60) ; Set our game to run at 60 frames-per-second

;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose() ; Detect window close button Or ESC key
                              ; Update
                              ;>----------------------------------------------------------------------------------
  check = IsFileDropped()
  
  ;Debug check
  
  If check
    ; Is some files have been previously loaded, unload them
    ;Debug droppedFiles\count
    
    If droppedFiles\count < 0
      UnloadDroppedFiles(@droppedFiles)
    EndIf
    ; Load new dropped files
    LoadDroppedFiles(@droppedFiles)
  EndIf
  
  ;>----------------------------------------------------------------------------------
  ; Draw
  ;----------------------------------------------------------------------------------
  BeginDrawing()
  
  ClearBackground(#COLOR_RAYWHITE)
  
  If droppedFiles\count = 0
    DrawTextRayLib("Drop your files to this window!", 100, 40, 20, #COLOR_DARKGRAY)
  Else
    DrawTextRayLib("Dropped files:", 100, 40, 20, #COLOR_DARKGRAY);
    
    For i = 0 To droppedFiles\count
      If Mod(i, 2) = 0
        DrawRectangle(0, 85 + 40 * i, #SCREEN_WIDTH, 40, Fade(#COLOR_LIGHTGRAY, 0.5))
      Else 
        DrawRectangle(0, 85 + 40 * i, #SCREEN_WIDTH, 40, Fade(#COLOR_LIGHTGRAY, 0.3))
        DrawTextRayLib(PeekS(@droppedFiles\paths(0), -1, #PB_Ascii), 120, 100 + 40 * i, 10, #COLOR_GRAY)
      EndIf
      DrawTextRayLib("Drop new files...", 100, 110 + 40 * droppedFiles\count, 20, #COLOR_DARKGRAY)
    Next
  EndIf
  
  EndDrawing()
  
  ; If we want to have a screenshot
  If IsKeyPressed(ray::#KEY_F1)
    TakeScreenshot("screenshots/core_drop_files.png")
  EndIf
  
Wend
;>----------------------------------------------------------------------------------

; De-Initialization
;>--------------------------------------------------------------------------------------
UnloadDroppedFiles(@droppedFiles) ; Unload files memory

CloseWindowRayLib() ; Close window and OpenGL context

UnuseModule ray
;>--------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 79
; FirstLine = 74
; Optimizer
; EnableThread
; EnableXP
; DPIAware
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)
; Debugger = Standalone