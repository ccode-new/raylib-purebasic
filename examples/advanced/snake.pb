; /*******************************************************************************************
; *
; *   raylib - classic game: snake
; *
; *   Sample game developed by Ian Eito, Albert Martos And Ramon Santamaria
; *
; *   This game has been created using raylib v1.3 (www.raylib.com)
; *   raylib is licensed under an unmodified zlib/libpng license (View raylib.h For details)
; *
; *   Copyright (c) 2015 Ramon Santamaria (@raysan5)
; *
; ********************************************************************************************/
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

; //----------------------------------------------------------------------------------
; // Some Defines
; //----------------------------------------------------------------------------------
#SNAKE_LENGTH = 256
#SQUARE_SIZE = 31

; //----------------------------------------------------------------------------------
; // Types And Structures Definition
; //----------------------------------------------------------------------------------
Structure Snake
  position.Vector2
  size.Vector2
  speed.Vector2
  color.rl_ColorLong
EndStructure

Structure Food
  position.Vector2
  size.Vector2
  active.b
  color.rl_ColorLong
EndStructure

; //------------------------------------------------------------------------------------
; // Global Variables Declaration
; //------------------------------------------------------------------------------------
#screenWidth = 800
#screenHeight = 450

#FPS = 60

Global.rl_int framesCounter = 0
Global.rl_bool gameOver = #False
Global.rl_bool pause = #False

Global.Food fruit
Global Dim snake.Snake(#SNAKE_LENGTH)
Global Dim snakePosition.Vector2(#SNAKE_LENGTH)
Global.rl_bool allowMove = #False
Global.Vector2 offset
Global.rl_int counterTail = 0
Global.rl_int speed = #SQUARE_SIZE

; //------------------------------------------------------------------------------------
; // Module Functions Declaration (local)
; //------------------------------------------------------------------------------------
Declare InitGame()                  ; Initialize game
Declare UpdateGame()                ; Update game (one frame)
Declare DrawGame()                  ; Draw game (one frame)
Declare UnloadGame()                ; Unload game
Declare UpdateDrawFrame()           ; Update and Draw (one frame)

; //------------------------------------------------------------------------------------
; // Program main entry point
; //------------------------------------------------------------------------------------

;-Main

; Initialization (Note windowTitle is unused on Android)
;>---------------------------------------------------------
InitWindow(#screenWidth, #screenHeight, "classic game: snake")

InitGame()

SetTargetFPS(#FPS)
;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose()     ; Detect window close button Or ESC key
  
  ;Update And Draw
  ;>----------------------------------------------------------------------------------
  BeginDrawing()

  ClearBackground(#COLOR_RAYWHITE)
  
  If gameOver = #True
    DrawTextRayLib("PRESS [SPACE] TO PLAY AGAIN", GetScreenWidth() / 2 - MeasureText("PRESS [SPACE] TO PLAY AGAIN", 20) / 2, GetScreenHeight() / 2 - 50, 20, #COLOR_GRAY)
  Else
    UpdateDrawFrame()
  EndIf
  
  If gameOver = #True And IsKeyPressed(#KEY_SPACE)
    InitGame()
  EndIf
  ;-----------------------------------------------------------------------------------
  EndDrawing()
Wend

; De-Initialization
;>--------------------------------------------------------------------------------------
UnloadGame()                      ; Unload loaded data (textures, sounds, models...)

CloseWindowRayLib()               ; Close window and OpenGL context
;---------------------------------------------------------------------------------------


; //------------------------------------------------------------------------------------
; // Module Functions Definitions (local)
; //------------------------------------------------------------------------------------

; Initialize game variables
Procedure InitGame()
  Protected.rl_int i
  
  framesCounter = 0

  counterTail = 1
  allowMove = #False
  
  speed = #SQUARE_SIZE

  offset\x = Mod(#screenWidth, #SQUARE_SIZE)
  offset\y = Mod(#screenHeight, #SQUARE_SIZE)

  For i = 0 To #SNAKE_LENGTH
    InitVector2(@snake(i)\position, offset\x / 2, offset\y / 2)
    InitVector2(@snake(i)\size, #SQUARE_SIZE, #SQUARE_SIZE)
    InitVector2(@snake(i)\speed, speed, 0)

    If i = 0 
      snake(i)\color = #COLOR_DARKBLUE
    Else 
      snake(i)\color = #COLOR_BLUE
    EndIf
  Next

  For i = 0 To #SNAKE_LENGTH
    InitVector2(@snakePosition(i), 0, 0)
  Next

  InitVector2(@fruit\size, #SQUARE_SIZE, #SQUARE_SIZE)
  fruit\color = #COLOR_SKYBLUE
  fruit\active = #False
  
  gameOver = #False
  pause = #False
EndProcedure

; Update game (one frame)
Procedure UpdateGame()
  Protected.rl_int i
  
  If gameOver = #False
    If IsKeyPressed(#KEY_P) 
      pause = Bool( Not pause)
    EndIf
    
    If pause = #False
      ; Player control
      If IsKeyPressed(#KEY_RIGHT) And (snake(0)\speed\x = 0) And allowMove = #True
        InitVector2(@snake(0)\speed, speed, 0)
        allowMove = #False
      EndIf
      
      If IsKeyPressed(#KEY_LEFT) And (snake(0)\speed\x = 0) And allowMove = #True
        InitVector2(@snake(0)\speed, -speed, 0)
        allowMove = #False
      EndIf
      
      If IsKeyPressed(#KEY_UP) And (snake(0)\speed\y = 0) And allowMove = #True
        InitVector2(@snake(0)\speed, 0, -speed)
        allowMove = #False
      EndIf
      
      If IsKeyPressed(#KEY_DOWN) And (snake(0)\speed\y = 0) And allowMove = #True
        InitVector2(@snake(0)\speed, 0, speed)
        allowMove = #False
      EndIf
      
      ; Snake movement
      For i = 0 To counterTail
        snakePosition(i) = snake(i)\position
      Next
      
      If Mod(framesCounter, 5) = 0
        For i = 0 To counterTail
          If i = 0
            snake(0)\position\x + snake(0)\speed\x
            snake(0)\position\y + snake(0)\speed\y
            allowMove = #True
          Else 
            snake(i)\position = snakePosition(i-1)
          EndIf
        Next
      EndIf
      
      ; Wall behaviour
      If (snake(0)\position\x > (#screenWidth - offset\x)) Or
         (snake(0)\position\y > (#screenHeight - offset\y)) Or
         (snake(0)\position\x < 0) Or (snake(0)\position\y < 0)
        gameOver = #True
      EndIf
      
      ; Collision With yourself
      For i = 1 To counterTail
        If (snake(0)\position\x = snake(i)\position\x) And (snake(0)\position\y = snake(i)\position\y) 
          gameOver = #True
          Break
        EndIf
      Next
      
      ; Fruit position calculation
      If Not fruit\active
        fruit\active = #True
        InitVector2(@fruit\position, GetRandomValue(0, (#screenWidth / #SQUARE_SIZE) - 1) * #SQUARE_SIZE + offset\x / 2, 
                    Random((#screenHeight / #SQUARE_SIZE) - 1) * #SQUARE_SIZE + offset\y / 2)
        
        For i = 0 To counterTail
          While (fruit\position\x = snake(i)\position\x) And (fruit\position\y = snake(i)\position\y)
            InitVector2(@fruit\position, GetRandomValue(0, (#screenWidth / #SQUARE_SIZE) - 1) * #SQUARE_SIZE + offset\x / 2, 
                        Random((#screenHeight / #SQUARE_SIZE) - 1) * #SQUARE_SIZE + offset\y / 2)
            i = 0
          Wend
        Next
      EndIf
      
      ; Collision
      If (snake(0)\position\x < (fruit\position\x + fruit\size\x)) And ((snake(0)\position\x + snake(0)\size\x) > fruit\position\x) And
         (snake(0)\position\y < (fruit\position\y + fruit\size\y)) And ((snake(0)\position\y + snake(0)\size\y) > fruit\position\y)
        
        snake(counterTail)\position = snakePosition(counterTail - 1)
        counterTail + 1
        fruit\active = #False
      EndIf
      
      If framesCounter <= #FPS
        framesCounter + 1
      Else
        framesCounter = 0
      EndIf
    EndIf
  EndIf
EndProcedure

; Draw game (one frame)
Procedure DrawGame()
  Protected.Vector2 startPos, endPos
  Protected.rl_int i

  If Not gameOver
;     ; Draw grid lines
;     For i = 0 To (#screenWidth / #SQUARE_SIZE + 1) - 1
;       
;       InitVector2(@startPos, #SQUARE_SIZE * i + offset\x / 2, offset\y / 2)
;       InitVector2(@endPos, #SQUARE_SIZE * i + offset\x / 2, #screenHeight - offset\y / 2)
;       
;       DrawLineV(@startPos, @endPos, #COLOR_LIGHTGRAY)
;     Next
; 
;     For i = 0 To #screenHeight / #SQUARE_SIZE + 1
;       InitVector2(@startPos, offset\x / 2, #SQUARE_SIZE * i + offset\y / 2)
;       InitVector2(@endPos, #screenWidth - offset\x / 2, #SQUARE_SIZE * i + offset\y / 2)
;       
;       DrawLineV(@startPos, @endPos, #COLOR_LIGHTGRAY)
;     Next

    ; Draw snake
    For i = 0 To counterTail - 1 
      DrawRectangleV(@snake(i)\position, @snake(i)\size, snake(i)\color)
    Next

    ; Draw fruit To pick
    DrawRectangleV(@fruit\position, @fruit\size, fruit\color)

    If pause = #True 
      DrawTextRayLib("GAME PAUSED", #screenWidth / 2 - MeasureText("GAME PAUSED", 40) / 2, #screenHeight / 2 - 40, 40, #COLOR_GRAY)
    EndIf
  EndIf

EndProcedure

; Unload game variables
Procedure UnloadGame()
  ; TODO: Unload all dynamic loaded Data (textures, sounds, models...)
EndProcedure

; Update And Draw (one frame)
Procedure UpdateDrawFrame()
  UpdateGame()
  DrawGame()
EndProcedure
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 230
; FirstLine = 227
; Folding = -
; Optimizer
; EnableThread
; EnableXP
; DPIAware
; Compiler = PureBasic 6.00 LTS - C Backend (MacOS X - arm64)