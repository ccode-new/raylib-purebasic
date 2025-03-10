; /*******************************************************************************************
; *
; *   raylib [textures] example - Fog of war
; *
; *   Example originally created With raylib 4.2, last time updated With raylib 4.2
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2018-2023 Ramon Santamaria (@raysan5)
; *
; ********************************************************************************************/
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

#MAP_TILE_SIZE = 32         ; Tiles size 32x32 pixels
#PLAYER_SIZE = 16           ; Player size
#PLAYER_TILE_VISIBILITY = 2 ; Player can see 2 tiles around its position

; Map Data type
Structure MapData Align 4
  tilesX.rl_uint    ; Number of tiles in X axis
  tilesY.rl_uint    ; Number of tiles in Y axis
  *tileIds.ascii    ; Tile ids (tilesX*tilesY), defines type of tile to draw
  *tileFog.ascii    ; Tile fog state (tilesX*tilesY), defines if a tile has fog or half-fog
EndStructure

Define.rl_uint i
Define.rl_uint x, y

; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 450

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [textures] example - fog of war" )
If Not IsWindowReady()                  ; After creating the window, we check
  End                                   ; for errors at initialization.
EndIf                                   ; In case of error at init we end the program.

Global.MapData NMap
NMap\tilesX = 25
NMap\tilesY = 15

; NOTE: We can have up To 256 values For tile ids And For tile fog state,
; probably we don't need that many values for fog state, it can be optimized
; To use only 2 bits per fog state (reducing size by 4) but logic will be a bit more complex
CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  NMap\tileIds = AllocateMemory(NMap\tilesX * NMap\tilesY)
  NMap\tileFog = AllocateMemory(NMap\tilesX * NMap\tilesY)
CompilerElse
  NMap\tileIds = calloc_(NMap\tilesX * NMap\tilesY, 1)
  NMap\tileFog = calloc_(NMap\tilesX * NMap\tilesY, 1)
CompilerEndIf


; Load Map tiles (generating 2 random tile ids For testing)
; NOTE: Map tile ids should be probably loaded from an external Map file
For i = 0 To (NMap\tilesY * NMap\tilesX) - 1
  PokeA(NMap\tileIds + i, GetRandomValue(0, 1))
Next

; Player position on the screen (pixel coordinates, Not tile coordinates)
Define.Vector2 playerPosition 
InitVector2(@playerPosition, 180, 130)

Define.rl_int playerTileX = 0
Define.rl_int playerTileY = 0

; Render texture To render fog of war
; NOTE: To get an automatic smooth-fog effect we use a render texture To render fog
; at a smaller size (one pixel per tile) And scale it on drawing With bilinear filtering
Define.RenderTexture2D fogOfWar
LoadRenderTexture(@fogOfWar, NMap\tilesX, NMap\tilesY)

SetTextureFilter(@fogOfWar\texture, #TEXTURE_FILTER_BILINEAR)

SetTargetFPS(60) ; Set our game to run at 60 frames-per-second
;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose() ; Detect window close button Or ESC key
  ; Update
  ;>----------------------------------------------------------------------------------
  ; Move player around
  If IsKeyDown(#KEY_RIGHT)
    playerPosition\x + 5
  EndIf
  If IsKeyDown(#KEY_LEFT)
    playerPosition\x - 5
  EndIf
  If IsKeyDown(#KEY_DOWN)
    playerPosition\y + 5
  EndIf
  If IsKeyDown(#KEY_UP)
    playerPosition\y - 5
  EndIf
  
  ; Check player position To avoid moving outside tilemap limits
  If playerPosition\x < 0 
    playerPosition\x = 0
  ElseIf (playerPosition\x + #PLAYER_SIZE) > (NMap\tilesX * #MAP_TILE_SIZE) 
    playerPosition\x = NMap\tilesX * #MAP_TILE_SIZE - #PLAYER_SIZE
  EndIf
  
  If playerPosition\y < 0
    playerPosition\y = 0
  ElseIf (playerPosition\y + #PLAYER_SIZE) > (NMap\tilesY * #MAP_TILE_SIZE) 
    playerPosition\y = NMap\tilesY * #MAP_TILE_SIZE - #PLAYER_SIZE
  EndIf
  
  ; Previous visited tiles are set To partial fog
  For i = 0 To (NMap\tilesX * NMap\tilesY) - 1
    If PeekA(NMap\tileFog + i) = 1
      PokeA(NMap\tileFog + i, 2)
    EndIf
  Next
  
  ; Get current tile position from player pixel position
  playerTileX = Int((playerPosition\x + #MAP_TILE_SIZE / 2) / #MAP_TILE_SIZE)
  playerTileY = Int((playerPosition\y + #MAP_TILE_SIZE / 2) / #MAP_TILE_SIZE)
  
  ; Check visibility And update fog
  ; NOTE: We check tilemap limits To avoid processing tiles out-of-Array-bounds (it could crash program)
  For y = (playerTileY - #PLAYER_TILE_VISIBILITY) To (playerTileY + #PLAYER_TILE_VISIBILITY) - 1
    For x = (playerTileX - #PLAYER_TILE_VISIBILITY) To (playerTileX + #PLAYER_TILE_VISIBILITY) - 1 
      If ((x >= 0) And (x < NMap\tilesX) And (y >= 0) And (y < NMap\tilesY)) 
        PokeA(NMap\tileFog + (y * NMap\tilesX + x), 1)
      EndIf
    Next
  Next
  ;>----------------------------------------------------------------------------------
  
  ; Draw
  ; ----------------------------------------------------------------------------------
  ; Draw fog of war To a small render texture For automatic smoothing on scaling
  BeginTextureMode(@fogOfWar)
  ClearBackground(#COLOR_BLANK)
  
  For y = 0 To NMap\tilesY - 1
    For x = 0 To NMap\tilesX - 1
      If PeekA(NMap\tileFog + (y * NMap\tilesX + x)) = 0
        DrawRectangle(x, y, 1, 1, #COLOR_BLACK)
      ElseIf PeekA(NMap\tileFog + (y * NMap\tilesX + x)) = 2 
        DrawRectangle(x, y, 1, 1, Fade(#COLOR_BLACK, 0.8))
      EndIf
    Next
  Next
  
  EndTextureMode()
  
  BeginDrawing()
  
  ClearBackground(#COLOR_RAYWHITE)
  
  For y = 0 To NMap\tilesY - 1
    For x = 0 To NMap\tilesX - 1
      ; Draw tiles from id (And tile borders)
      If NMap\tileIds <> 0
        If PeekA(NMap\tileIds + y * NMap\tilesX + x) = 0
          DrawRectangle(x * #MAP_TILE_SIZE, y * #MAP_TILE_SIZE, #MAP_TILE_SIZE, #MAP_TILE_SIZE, #COLOR_BLUE)
        Else
          DrawRectangle(x * #MAP_TILE_SIZE, y * #MAP_TILE_SIZE, #MAP_TILE_SIZE, #MAP_TILE_SIZE, Fade(#COLOR_BLUE, 0.9))
        EndIf
      EndIf
      DrawRectangleLines(x * #MAP_TILE_SIZE, y * #MAP_TILE_SIZE, #MAP_TILE_SIZE, #MAP_TILE_SIZE, Fade(#COLOR_DARKBLUE, 0.5))
    Next
  Next
  
  ; Draw player
  Define.Vector2 playerV
  InitVector2(@playerV, #PLAYER_SIZE, #PLAYER_SIZE)
  DrawRectangleV(@playerPosition, @playerV, #COLOR_RED)
  
  
  ; Draw fog of war (scaled To full Map, bilinear filtering)
  Define.Rectangle drawRec, drawRec2
  drawRec\x = 0 : drawRec\y = 0 : drawRec\width = fogOfWar\texture\width : drawRec\height = -fogOfWar\texture\height
  drawRec2\x = 0 : drawRec2\y = 0 : drawRec2\width = NMap\tilesX * #MAP_TILE_SIZE : drawRec2\height = NMap\tilesY * #MAP_TILE_SIZE
  
  Define.Vector2 drawV
  InitVector2(@drawV, 0, 0)
  
  DrawTexturePro(@fogOfWar\texture, @drawRec, @drawRec2, @drawV, 0.0, #COLOR_WHITE)
  
  ; Draw player current tile
  DrawTextRayLib("Current tile: " + Str(playerTileX) + ", " + Str(playerTileY), 10, 10, 20, #COLOR_LIME)
  
  EndDrawing()
  ;>----------------------------------------------------------------------------------
  
  ; If we want to have a screenshot
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/textures_fog_of_war.png")
  EndIf
  
Wend

; De-Initialization
; --------------------------------------------------------------------------------------
CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  FreeMemory(NMap\tileFog)
  FreeMemory(NMap\tileIds)
CompilerElse
  free_(NMap\tileFog)
  free_(NMap\tileIds)
CompilerEndIf

UnloadRenderTexture(@fogOfWar) ; Unload render texture

CloseWindowRayLib() ; Close window and OpenGL context

UnuseModule ray
; --------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 79
; FirstLine = 75
; Folding = -
; Optimizer
; EnableThread
; EnableXP
; DPIAware