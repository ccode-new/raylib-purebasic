; /*******************************************************************************************
; *
; *   raylib [core] example - Storage save/load values
; *
; *   Example originally created With raylib 1.4, last time updated With raylib 4.2
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

#STORAGE_DATA_FILE = "storage.data" ; Storage file

; NOTE: Storage positions must start With 0, directly related To file memory layout
Enumeration StorageData
  #STORAGE_POSITION_SCORE = 0
  #STORAGE_POSITION_HISCORE = 1
EndEnumeration

; Persistent storage functions
Declare.rl_bool SaveStorageValue(position.rl_uint, value.rl_int)
Declare.rl_int LoadStorageValue(position.rl_uint)

; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 450

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [core] example - storage save/load values" )
If Not IsWindowReady()                  ; After creating the window, we check
  End                                   ; for errors at initialization.
EndIf                                   ; In case of error at init we end the program.

Define.rl_uint score = 0
Define.rl_uint hiscore = 0
Define.rl_int framesCounter = 0

SetTargetFPS(60)  ; Set our game to run at 60 frames-per-second
                  ;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose() ; Detect window close button Or ESC key
  ; Update
  ;>----------------------------------------------------------------------------------
  If IsKeyPressed(#KEY_R)
    score = GetRandomValue(1000, 2000)
    hiscore = GetRandomValue(2000, 4000)
  EndIf
  
  If IsKeyPressed(#KEY_ENTER)
    SaveStorageValue(#STORAGE_POSITION_SCORE, score)
    SaveStorageValue(#STORAGE_POSITION_HISCORE, hiscore)
  ElseIf IsKeyPressed(#KEY_SPACE)
    ; NOTE: If requested position could Not be found, value 0 is returned
    score = LoadStorageValue(#STORAGE_POSITION_SCORE)
    hiscore = LoadStorageValue(#STORAGE_POSITION_HISCORE)
  EndIf
  
  framesCounter + 1
  ;>----------------------------------------------------------------------------------
  
  ;Draw
  ;----------------------------------------------------------------------------------
  BeginDrawing()
  
  ClearBackground(#COLOR_RAYWHITE)
  
  DrawTextRayLib("SCORE: " + Str(score), 280, 130, 40, #COLOR_MAROON)
  DrawTextRayLib("HI-SCORE: " + Str(hiscore), 210, 200, 50, #COLOR_BLACK)
  
  DrawTextRayLib("frames: " + Str(framesCounter), 10, 10, 20, #COLOR_LIME)
  
  DrawTextRayLib("Press R to generate random numbers", 220, 40, 20, #COLOR_LIGHTGRAY)
  DrawTextRayLib("Press ENTER to SAVE values", 250, 310, 20, #COLOR_LIGHTGRAY)
  DrawTextRayLib("Press SPACE to LOAD values", 252, 350, 20, #COLOR_LIGHTGRAY)
  
  EndDrawing()
  ;>---------------------------------------------------------------------------------
  
  ; If we want to have a screenshot
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/core_storage_data.png")
  EndIf 
Wend
;>----------------------------------------------------------------------------------

; De-Initialization
;>--------------------------------------------------------------------------------------
CloseWindowRayLib() ; Close window and OpenGL context
;---------------------------------------------------------------------------------------

; // Save integer value To storage file (To defined position)
; // NOTE: Storage positions is directly related To file memory layout (4 bytes each integer)
Procedure.rl_bool SaveStorageValue(position.rl_uint, value.rl_int)
  Protected.rl_bool success = #False
  Protected.rl_uint dataSize = 0
  Protected.rl_uint newDataSize
  Protected *fileData = 0
  If FileSize(#STORAGE_DATA_FILE) <> -1
    *fileData = LoadFileData(#STORAGE_DATA_FILE, @dataSize)
  EndIf
  Protected *newFileData
  
  If *fileData <> 0 
    If dataSize <= (position * 4)
      ;// Increase Data size up To position And store value
      newDataSize = (position + 1) * 4
      ;*newFileData = ReAllocateMemory(*fileData, newDataSize) ;-> Error!
      *newFileData = AllocateMemory(newDataSize)
      CopyMemory(*fileData, *newFileData, newDataSize)
      If *newFileData <> 0
        ;// RL_REALLOC succeded
        Define *dataPtr = *newFileData
        PokeL(*dataPtr + (position * 4), value)
      Else
        ;// RL_REALLOC failed
        ;TraceLog(LOG_WARNING, "FILEIO: [%s] Failed to realloc data (%u), position in bytes (%u) bigger than actual file size", STORAGE_DATA_FILE, dataSize, position*SizeOf(int));
        
        ;// We store the old size of the file
        *newFileData = *fileData
        newDataSize = dataSize
      EndIf
    Else
      ;// Store the old size of the file
      *newFileData = *fileData
      newDataSize = dataSize
      
      ;// Replace value on selected position
      Define *dataPtr = *newFileData
      PokeL(*dataPtr + (position * 4), value)
    EndIf
    
    success = SaveFileData(#STORAGE_DATA_FILE, *newFileData, newDataSize)
    ;TraceLog(LOG_INFO, "FILEIO: [%s] Saved storage value: %i", STORAGE_DATA_FILE, value);
  Else
    ;TraceLog(LOG_INFO, "FILEIO: [%s] File created successfully", STORAGE_DATA_FILE);
    
    dataSize = (position + 1) * 4
    *fileData = AllocateMemory(dataSize)
    
    Define *dataPtr = *fileData
    PokeL(*dataPtr + (position * 4), value)
    
    success = SaveFileData(#STORAGE_DATA_FILE, *fileData, dataSize)
    If *newFileData
      UnloadFileData(*fileData)
    EndIf
    ;TraceLog(LOG_INFO, "FILEIO: [%s] Saved storage value: %i", STORAGE_DATA_FILE, value);
  EndIf
  
  ProcedureReturn success
EndProcedure

; // Load integer value from storage file (from defined position)
; // NOTE: If requested position could Not be found, value 0 is returned
Procedure.rl_int LoadStorageValue(position.rl_uint)
  Protected.rl_int value = 0
  Protected.rl_uint dataSize = 0
  Protected *fileData 
  *fileData = LoadFileData(#STORAGE_DATA_FILE, @dataSize)
  
  If *fileData <> #Null
    If dataSize < (position * 4)
      ;TraceLog(LOG_WARNING, "FILEIO: [%s] Failed to find storage position: %i", STORAGE_DATA_FILE, position);
    Else
      Define *dataPtr = *fileData
      value = PeekL(*dataPtr + (position * 4))      
    EndIf
    
    UnloadFileData(*fileData)
    
    ;TraceLog(LOG_INFO, "FILEIO: [%s] Loaded storage value: %i", STORAGE_DATA_FILE, value);
  EndIf
  
  ProcedureReturn value
EndProcedure
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 89
; FirstLine = 64
; Folding = -
; Optimizer
; EnableThread
; EnableXP
; DPIAware
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)