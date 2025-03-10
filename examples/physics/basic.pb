; /*******************************************************************************************
; *
; *   Physac - Physics demo
; *
; *   NOTE 1: Physac requires multi-threading, when InitPhysics() a second thread 
; *           is created To manage physics calculations.
; *   NOTE 2: Physac requires Static C library linkage To avoid dependency 
; *           on MinGW DLL (-Static -lpthread)
; *
; *   Compile this program using:
; *       gcc -o $(NAME_PART).exe $(FILE_NAME) -s ..\icon\physac_icon -I. -I../src 
; *           -I../src/external/raylib/src -Static -lraylib -lopengl32 -lgdi32 -pthread -std=c99
; *   
; *   Copyright (c) 2016-2020 Victor Fisac (github: @victorfisac)
; *
; ********************************************************************************************/
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

XIncludeFile "raymath.pbi"

;#define PHYSAC_IMPLEMENTATION
XIncludeFile "physac.pbi"

; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 450

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "[physac] Basic demo" )
If Not IsWindowReady()                  ; After creating the window, we check
  End                                   ; for errors at initialization.
EndIf

; Physac logo drawing position
Define.rl_int logoX = #SCREEN_WIDTH - MeasureText("Physac", 30) - 10
Define.rl_int logoY = 15

; Initialize physics And Default physics bodies
InitPhysics()

; Create floor rectangle physics body
Define.PhysicsBody floor 

Define.Vector2 vec1
InitVector2(@vec1, #SCREEN_WIDTH / 2, #SCREEN_HEIGHT)

;CreatePhysicsBodyRectangle(@floor, @vec1, 200, 100, 10)

floor\enabled = #False  ; Disable body state to convert it to static (no dynamics, but collisions)

; Create obstacle circle physics body
Define.PhysicsBody circle

Define.Vector2 vec2
InitVector2(@vec2, #SCREEN_WIDTH / 2, #SCREEN_HEIGHT / 2)

;CreatePhysicsBodyCircle(@circle, @vec2, 45, 10)

circle\enabled = #True ; Disable body state to convert it to static (no dynamics, but collisions)
    
SetTargetFPS(60)

;>--------------------------------------------------------------------------------------

Define.PhysicsBody tmpBody
Define.Vector2 mv

; Main game loop
While Not WindowShouldClose() ; Detect window close button Or ESC key
  ; Update
  ;>----------------------------------------------------------------------------------
  
  GetMousePosition(@mv)
  
  Define.i mp = 10
  Define.f cw = Random(60, 20)
  Define.f ch = Random(60, 20)
  
  ; Physics body creation inputs
  If IsMouseButtonPressed(#MOUSE_LEFT_BUTTON)
    CreatePhysicsBodyRectangle(@tmpBody, @mv, 20, 20, 10)
    Debug(physicsThreadEnabled)
  ElseIf IsMouseButtonPressed(#MOUSE_RIGHT_BUTTON)
    CreatePhysicsBodyCircle(@tmpBody, @mv, Random(45, 10), 10)
  EndIf

  ; Destroy falling physics bodies
  Define.rl_int i, j, jj, bodiesCount = GetPhysicsBodiesCount()
  
  For i = bodiesCount - 1 To 0 Step - 1
    
    Define.PhysicsBody body2
    GetPhysicsBody(@body2, i)
            
    If ((body2 <> #Null) And (body2\position\y > #SCREEN_HEIGHT * 2))
      DestroyPhysicsBody(@body2)
    EndIf
  Next
  
  ;>----------------------------------------------------------------------------------

  ; Draw
  ;>----------------------------------------------------------------------------------
  BeginDrawing()

  ClearBackground(#COLOR_BLACK)

  DrawFPS(#SCREEN_WIDTH - 90, #SCREEN_HEIGHT - 30)

  ; Draw created physics bodies
  bodiesCount = GetPhysicsBodiesCount()
  
  Define.PhysicsBody body
  
  For i = 0 To bodiesCount - 1

    GetPhysicsBody(@body, i)

    If body <> #Null
      
      ;body\enabled = #False
      
      Define.rl_int vertexCount = GetPhysicsShapeVerticesCount(i)
      
      ;Debug "VertexCount: " + Str(vertexCount)
      
      For j = 0 To vertexCount - 1
        ; Get physics bodies shape vertices To draw lines
        ; Note: GetPhysicsShapeVertex() already calculates rotation transformations
        
        Define.Vector2 vertexA
        Define.Vector2 vertexB
        
        GetPhysicsShapeVertex(@vertexA, @body, j)

        If (j+1) < vertexCount  ; Get next vertex or first to close the shape
          jj = (j+1)
        Else
          jj = 0
        EndIf
        
        GetPhysicsShapeVertex(@vertexB, @body, jj)

        DrawLineV(@vertexA, @vertexB, #COLOR_GREEN) ; Draw a line between two vertex positions
      Next
    EndIf
  Next
  
  DrawTextRayLib("Physac", logoX, logoY, 30, #COLOR_WHITE)
  
  DrawTextRayLib("Left mouse button to create a polygon", 10, 40, 10, #COLOR_WHITE)
  DrawTextRayLib("Right mouse button to create a circle", 10, 55, 10, #COLOR_WHITE)
  
  
  EndDrawing()
        
  ;----------------------------------------------------------------------------------
  
  
Wend

; De-Initialization
;>--------------------------------------------------------------------------------------   
ClosePhysics()  ; Unitialize physics
    
CloseWindowRayLib()   ; Close window and OpenGL context

;---------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 125
; FirstLine = 99
; Optimizer
; EnableThread
; EnableXP
; DPIAware
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)
; Debugger = Standalone