; /*******************************************************************************************
; *
; *   raylib [models] example - Skybox loading And drawing
; *
; *   Example originally created With raylib 1.8, last time updated With raylib 4.0
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2017-2023 Ramon Santamaria (@raysan5)
; *
; ********************************************************************************************/
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

XIncludeFile "raymath.pbi"

; Generate cubemap (6 faces) from equirectangular (panorama) texture
Declare GenTextureCubemap(*result.TextureCubemap, *shader.Shader, *panorama.Texture2D , size.rl_int, format.rl_int)

#GLSL_VERSION = "330"

; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 450

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [models] example - skybox loading and drawing" )
If Not IsWindowReady()                  ; After creating the window, we check
  End                                   ; for errors at initialization.
EndIf 

; Define the camera To look into our 3d world
Define.Camera camera

Init_Vector3(@camera\position, 1.0, 1.0, 1.0)     ; Camera position
Init_Vector3(@camera\target, 4.0, 1.0, 4.0)       ; Camera looking at point
Init_Vector3(@camera\up, 0.0, 1.0, 0.0)           ; Camera up vector (rotation towards target)
camera\fovy = 45.0                                ; Camera field-of-view Y
camera\projection = #CAMERA_PERSPECTIVE       ; Camera projection type

; Load skybox model
Define.Mesh cube
GenMeshCube(@cube, 1.0, 1.0, 1.0)

Define.Model skybox 
LoadModelFromMesh(@skybox, @cube)

Debug skyBox\meshCount

Define.rl_bool useHDR = #True

Define.Shader skyboxShader

; Load skybox shader And set required locations
; NOTE: Some locations are automatically set at shader loading
LoadShader(@skyboxShader, "resources/shaders/glsl" + #GLSL_VERSION + "/skybox.vs",
                          "resources/shaders/glsl" + #GLSL_VERSION + "/skybox.fs")

Debug @skyboxShader

;SetShaderValue(@skyboxShader, GetShaderLocation(@skyboxShader, "environmentMap"), #MAP_CUBEMAP, #UNIFORM_INT)
;SetShaderValue(@skyboxShader, GetShaderLocation(@skyboxShader, "doGamma"), Bool(useHDR), #UNIFORM_INT)
;SetShaderValue(@skyboxShader, GetShaderLocation(@skyboxShader, "vflipped"), Bool(useHDR), #UNIFORM_INT)

; Load cubemap shader And setup required shader locations
Define.Shader shdrCubemap 
LoadShader(@shdrCubemap, "resources/shaders/glsl" + #GLSL_VERSION + "/cubemap.vs",
                         "resources/shaders/glsl" + #GLSL_VERSION + "/cubemap.fs")

SetShaderValue(@shdrCubemap, GetShaderLocation(@shdrCubemap, "equirectangularMap"), 0, #SHADER_UNIFORM_INT)

Define.s skyboxFileName
    
Define.Texture2D panorama

If useHDR = #True
  skyboxFileName = "resources/dresden_square_2k.hdr"

  ; Load HDR panorama (sphere) texture
  LoadTextureRayLib(@panorama, skyboxFileName)

  ; Generate cubemap (texture With 6 quads-cube-mapping) from panorama HDR texture
  ; NOTE 1: New texture is generated rendering To texture, shader calculates the sphere->cube coordinates mapping
  ; NOTE 2: It seems on some Android devices WebGL, fbo does Not properly support a FLOAT-based attachment,
  ; despite texture can be successfully created.. so using PIXELFORMAT_UNCOMPRESSED_R8G8B8A8 instead of PIXELFORMAT_UNCOMPRESSED_R32G32B32A32
  
  Define.TextureCubemap gen
  
  GenTextureCubemap(@gen, @shdrCubemap, @panorama, 1024, #PIXELFORMAT_UNCOMPRESSED_R8G8B8A8)
  ;CopyMemory(@gen, @skybox\materials\maps(#MAP_CUBEMAP)\texture, SizeOf(TextureCubemap))
  CopyStructure(@gen, @skybox\materials\maps\texture + #MATERIAL_MAP_CUBEMAP, TextureCubemap)
  
  ;skybox.materials[0].maps[MATERIAL_MAP_CUBEMAP].texture = GenTextureCubemap(shdrCubemap, panorama, 1024, PIXELFORMAT_UNCOMPRESSED_R8G8B8A8);

  ;UnloadTexture(@panorama)  ; Texture not required anymore, cubemap already generated
  
Else
  Define.Image img 
  LoadImageRayLib(@img, "resources/skybox.png")
  
  Define.TextureCubemap gen
  
  LoadTextureCubemap(@gen, @img, #CUBEMAP_LAYOUT_AUTO_DETECT)
  
  ; CUBEMAP_LAYOUT_PANORAMA
  CopyStructure(@gen, @skybox\materials\maps\texture + #MATERIAL_MAP_DIFFUSE, TextureCubemap)
  
  UnloadImage(@img)
EndIf

DisableCursor()   ; Limit cursor to relative movement inside the window

SetTargetFPS(60)  ; Set our game to run at 60 frames-per-second
;>--------------------------------------------------------------------------------------

Define._Vector3 drawPos_v3
Define.Vector2  drawPos_v2

; Main game loop
While Not WindowShouldClose() ; Detect window close button Or ESC key
  ; Update
  ;>----------------------------------------------------------------------------------
  UpdateCamera(@camera, #CAMERA_FREE)

  ;>----------------------------------------------------------------------------------
  ; Draw
  ;-----------------------------------------------------------------------------------
  BeginDrawing()

  ClearBackground(#COLOR_RAYWHITE)

  BeginMode3D(@camera)

  ; We are inside the cube, we need To disable backface culling!
  rlDisableBackfaceCulling()
  rlDisableDepthMask()
  
  Init_Vector3(@drawPos_v3, 0, 0, 0)
  DrawModel(@skybox, @drawPos_v3, 1.0, #COLOR_WHITE)
  
  rlEnableBackfaceCulling()
  rlEnableDepthMask()

  DrawGrid(10, 1.0)

  EndMode3D()
  
  InitVector2(@drawPos_v2, 0, 0)
            
  DrawTextureEx(@panorama, @drawPos_v2, 0.0, 0.5, #COLOR_WHITE)

  If useHDR = #True 
    DrawTextRayLib("Panorama image from hdrihaven.com: " + GetFileName(skyboxFileName), 10, GetScreenHeight() - 20, 10, #COLOR_BLACK)
  Else 
    DrawTextRayLib(": " + GetFileName(skyboxFileName), 10, GetScreenHeight() - 20, 10, #COLOR_BLACK)
  EndIf
  
  DrawFPS(10, 10)

  EndDrawing()
  ;-----------------------------------------------------------------------------------
  
  ; If we want to have a screenshot
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/models_skybox.png")
  EndIf
Wend

; De-Initialization
;>--------------------------------------------------------------------------------------
UnloadShader(@skybox\materials\shader)

UnloadTexture(@skybox\materials\maps\texture)

UnloadModel(@skybox)      ; Unload skybox model

CloseWindowRayLib()       ; Close window and OpenGL context
;---------------------------------------------------------------------------------------


; Generate cubemap texture from HDR texture
Procedure GenTextureCubemap(*result.TextureCubemap, *shader.Shader, *panorama.Texture2D, size.rl_int, format.rl_int)
  Protected.TextureCubemap cubemap
  Protected.rl_uint rbo, fbo
  Protected.Matrix matFboProjection
  Protected Dim fboViews.Matrix(6)
  Protected.rl_int i

  rlDisableBackfaceCulling()  ; Disable backface culling to render inside the cube

  ; Step 1: Setup framebuffer
  ;>------------------------------------------------------------------------------------------
  rbo = rlLoadTextureDepth(size, size, #True)
  cubemap\id = rlLoadTextureCubemap(0, size, format)

  fbo = rlLoadFramebuffer(size, size)
  rlFramebufferAttach(fbo, rbo, #RL_ATTACHMENT_DEPTH, #RL_ATTACHMENT_RENDERBUFFER, 0)
  rlFramebufferAttach(fbo, cubemap\id, #RL_ATTACHMENT_COLOR_CHANNEL0, #RL_ATTACHMENT_CUBEMAP_POSITIVE_X, 0)

  ; Check If framebuffer is complete With attachments (valid)
  If rlFramebufferComplete(fbo)
    ;TraceLog(LOG_INFO, "FBO: [ID %i] Framebuffer object created successfully", fbo)
    Debug "Framebuffer object created successfully"
  EndIf
  ;-------------------------------------------------------------------------------------------

  ; Step 2: Draw To framebuffer
  ;>------------------------------------------------------------------------------------------
  ; NOTE: Shader is used To convert HDR equirectangular environment Map To cubemap equivalent (6 faces)
  rlEnableShader(*shader\id)

  ; Define projection matrix And send it To shader
  MatrixPerspective(@matFboProjection, 90.0 * #DEG2RAD, 1.0, #RL_CULL_DISTANCE_NEAR, #RL_CULL_DISTANCE_FAR)
  rlSetUniformMatrix(*shader\locs + #RL_SHADER_LOC_MATRIX_PROJECTION, @matFboProjection)
  
  Define._Vector3 v1, v2, v3
  Init_Vector3(v1, 0.0, 0.0, 0.0) : Init_Vector3(v2, 1.0, 0.0, 0.0) : Init_Vector3(v3, 0.0, -1.0, 0.0)
  ; Define view matrix For every side of the cubemap
  MatrixLookAt(@fboViews(0), @v1, @v2, @v3)
  
  Init_Vector3(v1, 0.0, 0.0, 0.0) : Init_Vector3(v2, -1.0, 0.0, 0.0) : Init_Vector3(v3, 0.0, -1.0, 0.0)
  MatrixLookAt(@fboViews(1), @v1, @v2, @v3)
  
  Init_Vector3(v1, 0.0, 0.0, 0.0) : Init_Vector3(v2, 0.0, 1.0, 0.0) : Init_Vector3(v3, 0.0, 0.0, 1.0)
  MatrixLookAt(@fboViews(2), @v1, @v2, @v3)
  
  Init_Vector3(v1, 0.0, 0.0, 0.0) : Init_Vector3(v2, 0.0, -1.0, 0.0) : Init_Vector3(v3, 0.0, 0.0, -1.0)
  MatrixLookAt(@fboViews(3), @v1, @v2, @v3)
  
  Init_Vector3(v1, 0.0, 0.0, 0.0) : Init_Vector3(v2, 0.0, 0.0, 1.0) : Init_Vector3(v3, 0.0, -1.0, 0.0)
  MatrixLookAt(@fboViews(4), @v1, @v2, @v3)
  
  Init_Vector3(v1, 0.0, 0.0, 0.0) : Init_Vector3(v2, 0.0, 0.0, -1.0) : Init_Vector3(v3, 0.0, -1.0, 0.0)
  MatrixLookAt(@fboViews(5), @v1, @v2, @v3)

  rlViewport(0, 0, size, size)  ; Set viewport to current fbo dimensions
    
  ; Activate And enable texture For drawing To cubemap faces
  rlActiveTextureSlot(0)
  rlEnableTexture(*panorama\id)

  For i = 0 To 5
    ; Set the view matrix For the current cube face
    rlSetUniformMatrix(*shader\locs + #RL_SHADER_LOC_MATRIX_VIEW, @fboViews(i))
        
    ; Select the current cubemap face attachment For the fbo
    ; WARNING: This function by Default enables->attach->disables fbo!!!
    rlFramebufferAttach(fbo, cubemap\id, #RL_ATTACHMENT_COLOR_CHANNEL0, #RL_ATTACHMENT_CUBEMAP_POSITIVE_X + i, 0)
    rlEnableFramebuffer(fbo)

    ; Load And draw a cube, it uses the current enabled texture
    rlClearScreenBuffers()
    rlLoadDrawCube()

    ; ALTERNATIVE: Try To use internal batch system To draw the cube instead of rlLoadDrawCube
    ; For some reason this method does Not work, maybe due To cube triangles definition? normals pointing out?
    ; TODO: Investigate this issue...
    ;rlSetTexture(*panorama\id); // WARNING: It must be called after enabling current framebuffer if using internal batch system!
    ;rlClearScreenBuffers()
    
    ;Define._Vector3 dV1, dV2
    ;Vector3Zero(@dv1)
    ;Vector3One(@dV2)
    
    ;DrawCubeV(@dv1, @dV2, #COLOR_WHITE)
    ;rlDrawRenderBatchActive()
  Next
  ;>------------------------------------------------------------------------------------------

  ; Step 3: Unload framebuffer And reset state
  ;-------------------------------------------------------------------------------------------
  rlDisableShader()             ; Unbind shader
  rlDisableTexture()            ; Unbind texture
  rlDisableFramebuffer()        ; Unbind framebuffer
  rlUnloadFramebuffer(fbo)      ; Unload framebuffer (and automatically attached depth texture/renderbuffer)

  ; Reset viewport dimensions To Default
  rlViewport(0, 0, rlGetFramebufferWidth(), rlGetFramebufferHeight())
  rlEnableBackfaceCulling()
  ;>------------------------------------------------------------------------------------------

  cubemap\width = size
  cubemap\height = size
  cubemap\mipmaps = 1
  cubemap\format = format

  *result = @cubemap
  ;CopyMemory(@cubemap, *result, SizeOf(TextureCubemap))
  
EndProcedure
  
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 291
; Folding = -
; Optimizer
; EnableThread
; EnableXP
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)