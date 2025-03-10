;**********************************************************************************************
;*
;*   raylib - A simple and easy-to-use library to enjoy videogames programming (www.raylib.com)
;*
;*   FEATURES:
;*       - NO external dependencies, all required libraries included with raylib
;*       - Multiplatform: Windows, Linux, FreeBSD, OpenBSD, NetBSD, DragonFly, MacOS, UWP, Android, Raspberry Pi, HTML5.
;*       - Written in plain C code (C99) in PascalCase/camelCase notation
;*       - Hardware accelerated with OpenGL (1.1, 2.1, 3.3 or ES2 - choose at compile)
;*       - Unique OpenGL abstraction layer (usable as standalone module): [rlgl]
;*       - Multiple Fonts formats supported (TTF, XNA fonts, AngelCode fonts)
;*       - Outstanding texture formats support, including compressed formats (DXT, ETC, ASTC)
;*       - Full 3d support for 3d Shapes, Models, Billboards, Heightmaps and more!
;*       - Flexible Materials system, supporting classic maps and PBR maps
;*       - Skeletal Animation support (CPU bones-based animation)
;*       - Shaders support, including Model shaders and Postprocessing shaders
;*       - Powerful math module for Vector, Matrix and Quaternion operations: [raymath]
;*       - Audio loading and playing with streaming support (WAV, OGG, MP3, FLAC, XM, MOD)
;*       - VR stereo rendering with configurable HMD device parameters
;*       - Bindings to multiple programming languages available!
;*
;*   NOTES:
;*       One custom font is loaded by default when InitWindow() [core]
;*       If using OpenGL 3.3 or ES2, one default shader is loaded automatically (internally defined) [rlgl]
;*       If using OpenGL 3.3 or ES2, several vertex buffers (VAO/VBO) are created to manage lines-triangles-quads
;*
;*   DEPENDENCIES (included):
;*       [core] rglfw (github.com/glfw/glfw) for window/context management and input (only PLATFORM_DESKTOP)
;*       [rlgl] glad (github.com/Dav1dde/glad) for OpenGL 3.3 extensions loading (only PLATFORM_DESKTOP)
;*       [raudio] miniaudio (github.com/dr-soft/miniaudio) for audio device/context management
;*
;*   OPTIONAL DEPENDENCIES (included):
;*       [core] rgif (Charlie Tangora, Ramon Santamaria) for GIF recording
;*       [textures] stb_image (Sean Barret) for images loading (BMP, TGA, PNG, JPEG, HDR...)
;*       [textures] stb_image_write (Sean Barret) for image writting (BMP, TGA, PNG, JPG)
;*       [textures] stb_image_resize (Sean Barret) for image resizing algorithms
;*       [textures] stb_perlin (Sean Barret) for Perlin noise image generation
;*       [text] stb_truetype (Sean Barret) for ttf fonts loading
;*       [text] stb_rect_pack (Sean Barret) for rectangles packing
;*       [models] par_shapes (Philip Rideout) for parametric 3d shapes generation
;*       [models] tinyobj_loader_c (Syoyo Fujita) for models loading (OBJ, MTL)
;*       [models] cgltf (Johannes Kuhlmann) for models loading (glTF)
;*       [raudio] stb_vorbis (Sean Barret) for OGG audio loading
;*       [raudio] dr_flac (David Reid) for FLAC audio file loading
;*       [raudio] dr_mp3 (David Reid) for MP3 audio file loading
;*       [raudio] jar_xm (Joshua Reisenauer) for XM audio module loading
;*       [raudio] jar_mod (Joshua Reisenauer) for MOD audio module loading
;*
;*
;*   LICENSE: zlib/libpng
;*
;*   raylib is licensed under an unmodified zlib/libpng license, which is an OSI-certified,
;*   BSD-like license that allows static linking with closed source software:
;*
;*   Copyright (c) 2013-2023 Ramon Santamaria (@raysan5)
;*
;*   This software is provided "as-is", without any express or implied warranty. In no event
;*   will the authors be held liable for any damages arising from the use of this software.
;*
;*   Permission is granted to anyone to use this software for any purpose, including commercial
;*   applications, and to alter it and redistribute it freely, subject to the following restrictions:
;*
;*     1. The origin of this software must not be misrepresented; you must not claim that you
;*     wrote the original software. If you use this software in a product, an acknowledgment
;*     in the product documentation would be appreciated but is not required.
;*
;*     2. Altered source versions must be plainly marked as such, and must not be misrepresented
;*     as being the original software.
;*
;*     3. This notice may not be removed or altered from any source distribution.
;*
;**********************************************************************************************
;*
;*   'raylib-purebasic': Copyright (c) 2020 Danilo Krahn
;*
;**********************************************************************************************

;-Update: 03.2023 (ccode_new - Free publication)

EnableExplicit

;CompilerIf #PB_Compiler_Backend = #PB_Backend_C
  
  ;- ---------- DeclareModule Start
  ;{ ---------- DeclareModule Start
  DeclareModule ray
    
    #RAYLIB_VERSION = "4.5"
    
    ;#RL_PI = 3.14159265358979323846 ; too many digits
    #RL_PI = 3.1415926535897932385  ; remove last digit and round up
    
    #MAX_TOUCH_POINTS = 10          ;// Maximum number of touch points supported
    
    #DEG2RAD = #RL_PI/180.0
    #RAD2DEG = 180.0/#RL_PI
    
    #MAX_MATERIAL_MAPS = 12
    
    ;// Temporal hack to avoid breaking old codebases using
    ;// deprecated raylib implementation of these functions
    ;
    ; Macro FormatText : TextFormat   : EndMacro ;
    ; Macro SubText    : TextSubtext  : EndMacro ; This is here for finding the names.
    ; Macro ShowWindow : UnhideWindow : EndMacro ; Just use the new functions in PureBasic.
    ; Macro LoadText   : LoadFileText : EndMacro ;                       - Danilo
    
    Macro rl_RGBA(r,g,b,a)
      ( a<<24 | b<<16 | g<<8 | r )
    EndMacro
    
    ;// Some Basic Colors
    ;// NOTE: Custom raylib color palette for amazing visuals on WHITE background
    #COLOR_LIGHTGRAY  = rl_RGBA( 200, 200, 200, 255 )   ;// Light Gray
    #COLOR_GRAY       = rl_RGBA( 130, 130, 130, 255 )   ;// Gray
    #COLOR_DARKGRAY   = rl_RGBA( 80, 80, 80, 255 )      ;// Dark Gray
    #COLOR_YELLOW     = rl_RGBA( 253, 249, 0, 255 )     ;// Yellow
    #COLOR_GOLD       = rl_RGBA( 255, 203, 0, 255 )     ;// Gold
    #COLOR_ORANGE     = rl_RGBA( 255, 161, 0, 255 )     ;// Orange
    #COLOR_PINK       = rl_RGBA( 255, 109, 194, 255 )   ;// Pink
    #COLOR_RED        = rl_RGBA( 230, 41, 55, 255 )     ;// Red
    #COLOR_MAROON     = rl_RGBA( 190, 33, 55, 255 )     ;// Maroon
    #COLOR_GREEN      = rl_RGBA( 0, 228, 48, 255 )      ;// Green
    #COLOR_LIME       = rl_RGBA( 0, 158, 47, 255 )      ;// Lime
    #COLOR_DARKGREEN  = rl_RGBA( 0, 117, 44, 255 )      ;// Dark Green
    #COLOR_SKYBLUE    = rl_RGBA( 102, 191, 255, 255 )   ;// Sky Blue
    #COLOR_BLUE       = rl_RGBA( 0, 121, 241, 255 )     ;// Blue
    #COLOR_DARKBLUE   = rl_RGBA( 0, 82, 172, 255 )      ;// Dark Blue
    #COLOR_PURPLE     = rl_RGBA( 200, 122, 255, 255 )   ;// Purple
    #COLOR_VIOLET     = rl_RGBA( 135, 60, 190, 255 )    ;// Violet
    #COLOR_DARKPURPLE = rl_RGBA( 112, 31, 126, 255 )    ;// Dark Purple
    #COLOR_BEIGE      = rl_RGBA( 211, 176, 131, 255 )   ;// Beige
    #COLOR_BROWN      = rl_RGBA( 127, 106, 79, 255 )    ;// Brown
    #COLOR_DARKBROWN  = rl_RGBA( 76, 63, 47, 255 )      ;// Dark Brown
    #COLOR_WHITE      = rl_RGBA( 255, 255, 255, 255 )   ;// White
    #COLOR_BLACK      = rl_RGBA( 0, 0, 0, 255 )         ;// Black
    #COLOR_BLANK      = rl_RGBA( 0, 0, 0, 0 )           ;// Blank (Transparent)
    #COLOR_MAGENTA    = rl_RGBA( 255, 0, 255, 255 )     ;// Magenta
    #COLOR_RAYWHITE   = rl_RGBA( 245, 245, 245, 255 )   ;// My own White (raylib logo)
    
    ;- ---------- Enumerations Start
    ;{ ---------- Enumerations Start
    
    ;//----------------------------------------------------------------------------------
    ;// Enumerators Definition
    ;//----------------------------------------------------------------------------------
    
    ;// System/Window config flags
    ;// NOTE: Every bit registers one state (use it With bit masks)
    ;// By Default all flags are set To 0
    Enumeration ConfigFlags
      #FLAG_VSYNC_HINT         = $00000040        ;// Set To try enabling V-Sync on GPU
      #FLAG_FULLSCREEN_MODE    = $00000002        ;// Set To run program in fullscreen
      #FLAG_WINDOW_RESIZABLE   = $00000004        ;// Set To allow resizable window
      #FLAG_WINDOW_UNDECORATED = $00000008        ;// Set To disable window decoration (frame And buttons)
      #FLAG_WINDOW_HIDDEN      = $00000080        ;// Set To hide window
      #FLAG_WINDOW_MINIMIZED   = $00000200        ;// Set To minimize window (iconify)
      #FLAG_WINDOW_MAXIMIZED   = $00000400        ;// Set To maximize window (expanded To monitor)
      #FLAG_WINDOW_UNFOCUSED   = $00000800        ;// Set To window non focused
      #FLAG_WINDOW_TOPMOST     = $00001000        ;// Set To window always on top
      #FLAG_WINDOW_ALWAYS_RUN  = $00000100        ;// Set To allow windows running While minimized
      #FLAG_WINDOW_TRANSPARENT = $00000010        ;// Set To allow transparent framebuffer
      #FLAG_WINDOW_HIGHDPI     = $00002000        ;// Set To support HighDPI
      #FLAG_WINDOW_MOUSE_PASSTHROUGH = $00004000  ;// Set To support mouse passthrough, only supported when FLAG_WINDOW_UNDECORATED
      #FLAG_MSAA_4X_HINT       = $00000020        ;// Set To try enabling MSAA 4X
      #FLAG_INTERLACED_HINT  
    EndEnumeration
    
    ;// Trace log level
    ;// NOTE: Organized by priority level
    Enumeration TraceLogLevel
      #LOG_ALL = 0        ;// Display all logs
      #LOG_TRACE          ;// Trace logging, intended For internal use only
      #LOG_DEBUG          ;// Debug logging, used For internal debugging, it should be disabled on release builds
      #LOG_INFO           ;// Info logging, used For program execution info
      #LOG_WARNING        ;// Warning logging, used on recoverable failures
      #LOG_ERROR          ;// Error logging, used on unrecoverable failures
      #LOG_FATAL          ;// Fatal logging, used To abort program: exit(EXIT_FAILURE)
      #LOG_NONE           ;// Disable logging
    EndEnumeration
    
    ;// Keyboard keys (US keyboard layout)
    ;// NOTE: Use GetKeyPressed() To allow redefining
    ;// required keys For alternative layouts
    Enumeration KeyboardKey
      #KEY_NULL            = 0        ;// Key: NULL, used For no key pressed
                                      ;// Alphanumeric keys
      #KEY_APOSTROPHE      = 39
      #KEY_COMMA           = 44
      #KEY_MINUS           = 45
      #KEY_PERIOD          = 46
      #KEY_SLASH           = 47
      #KEY_ZERO            = 48
      #KEY_ONE             = 49
      #KEY_TWO             = 50
      #KEY_THREE           = 51
      #KEY_FOUR            = 52
      #KEY_FIVE            = 53
      #KEY_SIX             = 54
      #KEY_SEVEN           = 55
      #KEY_EIGHT           = 56
      #KEY_NINE            = 57
      #KEY_SEMICOLON       = 59
      #KEY_EQUAL           = 61
      #KEY_A               = 65
      #KEY_B               = 66
      #KEY_C               = 67
      #KEY_D               = 68
      #KEY_E               = 69
      #KEY_F               = 70
      #KEY_G               = 71
      #KEY_H               = 72
      #KEY_I               = 73
      #KEY_J               = 74
      #KEY_K               = 75
      #KEY_L               = 76
      #KEY_M               = 77
      #KEY_N               = 78
      #KEY_O               = 79
      #KEY_P               = 80
      #KEY_Q               = 81
      #KEY_R               = 82
      #KEY_S               = 83
      #KEY_T               = 84
      #KEY_U               = 85
      #KEY_V               = 86
      #KEY_W               = 87
      #KEY_X               = 88
      #KEY_Y               = 89
      #KEY_Z               = 90
      
      ;// Function keys
      #KEY_SPACE           = 32
      #KEY_ESCAPE          = 256
      #KEY_ENTER           = 257
      #KEY_TAB             = 258
      #KEY_BACKSPACE       = 259
      #KEY_INSERT          = 260
      #KEY_DELETE          = 261
      #KEY_RIGHT           = 262
      #KEY_LEFT            = 263
      #KEY_DOWN            = 264
      #KEY_UP              = 265
      #KEY_PAGE_UP         = 266
      #KEY_PAGE_DOWN       = 267
      #KEY_HOME            = 268
      #KEY_END             = 269
      #KEY_CAPS_LOCK       = 280
      #KEY_SCROLL_LOCK     = 281
      #KEY_NUM_LOCK        = 282
      #KEY_PRINT_SCREEN    = 283
      #KEY_PAUSE           = 284
      #KEY_F1              = 290
      #KEY_F2              = 291
      #KEY_F3              = 292
      #KEY_F4              = 293
      #KEY_F5              = 294
      #KEY_F6              = 295
      #KEY_F7              = 296
      #KEY_F8              = 297
      #KEY_F9              = 298
      #KEY_F10             = 299
      #KEY_F11             = 300
      #KEY_F12             = 301
      #KEY_LEFT_SHIFT      = 340
      #KEY_LEFT_CONTROL    = 341
      #KEY_LEFT_ALT        = 342
      #KEY_LEFT_SUPER      = 343
      #KEY_RIGHT_SHIFT     = 344
      #KEY_RIGHT_CONTROL   = 345
      #KEY_RIGHT_ALT       = 346
      #KEY_RIGHT_SUPER     = 347
      #KEY_KB_MENU         = 348
      #KEY_LEFT_BRACKET    = 91
      #KEY_BACKSLASH       = 92
      #KEY_RIGHT_BRACKET   = 93
      #KEY_GRAVE           = 96
      
      ;// Keypad keys
      #KEY_KP_0            = 320
      #KEY_KP_1            = 321
      #KEY_KP_2            = 322
      #KEY_KP_3            = 323
      #KEY_KP_4            = 324
      #KEY_KP_5            = 325
      #KEY_KP_6            = 326
      #KEY_KP_7            = 327
      #KEY_KP_8            = 328
      #KEY_KP_9            = 329
      #KEY_KP_DECIMAL      = 330
      #KEY_KP_DIVIDE       = 331
      #KEY_KP_MULTIPLY     = 332
      #KEY_KP_SUBTRACT     = 333
      #KEY_KP_ADD          = 334
      #KEY_KP_ENTER        = 335
      #KEY_KP_EQUAL        = 336
    EndEnumeration
    
    ;// Android buttons
    Enumeration AndroidButton
      #KEY_BACK            = 4
      #KEY_MENU            = 82
      #KEY_VOLUME_UP       = 24
      #KEY_VOLUME_DOWN     = 25
    EndEnumeration
    
    ;// Mouse buttons
    Enumeration MouseButton      
      #MOUSE_BUTTON_LEFT    = 0       ;// Mouse button left
      #MOUSE_BUTTON_RIGHT   = 1       ;// Mouse button right
      #MOUSE_BUTTON_MIDDLE  = 2       ;// Mouse button middle (pressed wheel)
      #MOUSE_BUTTON_SIDE    = 3       ;// Mouse button side (advanced mouse device)
      #MOUSE_BUTTON_EXTRA   = 4       ;// Mouse button extra (advanced mouse device)
      #MOUSE_BUTTON_FORWARD = 5       ;// Mouse button forward (advanced mouse device)
      #MOUSE_BUTTON_BACK    = 6       ;// Mouse button back (advanced mouse device)
      #MOUSE_BUTTON_SIDE    = 3       ;// Mouse button side (advanced mouse device)
      #MOUSE_BUTTON_EXTRA   = 4       ;// Mouse button extra (advanced mouse device)
      #MOUSE_BUTTON_FORWARD = 5       ;// Mouse button forward (advanced mouse device)
      #MOUSE_BUTTON_BACK    = 6       ;// Mouse button back (advanced mouse device)
    EndEnumeration
    
    ;// Add backwards compatibility support For deprecated names
    #MOUSE_LEFT_BUTTON = #MOUSE_BUTTON_LEFT
    #MOUSE_RIGHT_BUTTON = #MOUSE_BUTTON_RIGHT
    #MOUSE_MIDDLE_BUTTON = #MOUSE_BUTTON_MIDDLE
    
    ;// Mouse cursor
    Enumeration MouseCursor
      #MOUSE_CURSOR_DEFAULT       = 0     ;// Default pointer shape
      #MOUSE_CURSOR_ARROW         = 1     ;// Arrow shape
      #MOUSE_CURSOR_IBEAM         = 2     ;// Text writing cursor shape
      #MOUSE_CURSOR_CROSSHAIR     = 3     ;// Cross shape
      #MOUSE_CURSOR_POINTING_HAND = 4     ;// Pointing hand cursor
      #MOUSE_CURSOR_RESIZE_EW     = 5     ;// Horizontal resize/move arrow shape
      #MOUSE_CURSOR_RESIZE_NS     = 6     ;// Vertical resize/move arrow shape
      #MOUSE_CURSOR_RESIZE_NWSE   = 7     ;// Top-left To bottom-right diagonal resize/move arrow shape
      #MOUSE_CURSOR_RESIZE_NESW   = 8     ;// The top-right To bottom-left diagonal resize/move arrow shape
      #MOUSE_CURSOR_RESIZE_ALL    = 9     ;// The omni-directional resize/move cursor shape
      #MOUSE_CURSOR_NOT_ALLOWED   = 10    ;// The operation-Not-allowed shape
    EndEnumeration
    
    ;// Gamepad number
    Enumeration GamepadNumber
      #GAMEPAD_PLAYER1     = 0
      #GAMEPAD_PLAYER2     = 1
      #GAMEPAD_PLAYER3     = 2
      #GAMEPAD_PLAYER4     = 3
    EndEnumeration
    
    ;// Gamepad Buttons
    Enumeration GamepadButton
      ;// This is here just for error checking
      #GAMEPAD_BUTTON_UNKNOWN = 0
      
      ;// This is normally a DPAD
      #GAMEPAD_BUTTON_LEFT_FACE_UP
      #GAMEPAD_BUTTON_LEFT_FACE_RIGHT
      #GAMEPAD_BUTTON_LEFT_FACE_DOWN
      #GAMEPAD_BUTTON_LEFT_FACE_LEFT
      
      ;// This normally corresponds with PlayStation and Xbox controllers
      ;// XBOX: [Y,X,A,B]
      ;// PS3: [Triangle,Square,Cross,Circle]
      ;// No support for 6 button controllers though..
      #GAMEPAD_BUTTON_RIGHT_FACE_UP
      #GAMEPAD_BUTTON_RIGHT_FACE_RIGHT
      #GAMEPAD_BUTTON_RIGHT_FACE_DOWN
      #GAMEPAD_BUTTON_RIGHT_FACE_LEFT
      
      ;// Triggers
      #GAMEPAD_BUTTON_LEFT_TRIGGER_1
      #GAMEPAD_BUTTON_LEFT_TRIGGER_2
      #GAMEPAD_BUTTON_RIGHT_TRIGGER_1
      #GAMEPAD_BUTTON_RIGHT_TRIGGER_2
      
      ;// These are buttons in the center of the gamepad
      #GAMEPAD_BUTTON_MIDDLE_LEFT     ;//PS3 Select
      #GAMEPAD_BUTTON_MIDDLE          ;//PS Button/XBOX Button
      #GAMEPAD_BUTTON_MIDDLE_RIGHT    ;//PS3 Start
      
      ;// These are the joystick press in buttons
      #GAMEPAD_BUTTON_LEFT_THUMB
      #GAMEPAD_BUTTON_RIGHT_THUMB
    EndEnumeration
    
    Enumeration GamepadAxis
      ;// Left stick
      #GAMEPAD_AXIS_LEFT_X = 0
      #GAMEPAD_AXIS_LEFT_Y
      
      ;// Right stick
      #GAMEPAD_AXIS_RIGHT_X
      #GAMEPAD_AXIS_RIGHT_Y
      
      ;// Pressure levels for the back triggers
      #GAMEPAD_AXIS_LEFT_TRIGGER       ;// [1..-1] (pressure-level)
      #GAMEPAD_AXIS_RIGHT_TRIGGER      ;// [1..-1] (pressure-level)
    EndEnumeration
    
    ;// Material map type
    Enumeration MaterialMapType
      #MAP_ALBEDO    = 0       ;// MAP_DIFFUSE
      #MAP_METALNESS = 1       ;// MAP_SPECULAR
      #MAP_NORMAL    = 2
      #MAP_ROUGHNESS = 3
      #MAP_OCCLUSION
      #MAP_EMISSION
      #MAP_HEIGHT
      #MAP_CUBEMAP             ;// NOTE: Uses GL_TEXTURE_CUBE_MAP
      #MAP_IRRADIANCE          ;// NOTE: Uses GL_TEXTURE_CUBE_MAP
      #MAP_PREFILTER           ;// NOTE: Uses GL_TEXTURE_CUBE_MAP
      #MAP_BRDF
    EndEnumeration
    
    #MAP_DIFFUSE  = #MAP_ALBEDO
    #MAP_SPECULAR = #MAP_METALNESS
    
    ;// Shader location index
    Enumeration ShaderLocationIndex
      #LOC_VERTEX_POSITION = 0
      #LOC_VERTEX_TEXCOORD01
      #LOC_VERTEX_TEXCOORD02
      #LOC_VERTEX_NORMAL
      #LOC_VERTEX_TANGENT
      #LOC_VERTEX_COLOR
      #LOC_MATRIX_MVP
      #LOC_MATRIX_MODEL
      #LOC_MATRIX_VIEW
      #LOC_MATRIX_PROJECTION
      #LOC_VECTOR_VIEW
      #LOC_COLOR_DIFFUSE
      #LOC_COLOR_SPECULAR
      #LOC_COLOR_AMBIENT
      #LOC_MAP_ALBEDO          ;// LOC_MAP_DIFFUSE
      #LOC_MAP_METALNESS       ;// LOC_MAP_SPECULAR
      #LOC_MAP_NORMAL
      #LOC_MAP_ROUGHNESS
      #LOC_MAP_OCCLUSION
      #LOC_MAP_EMISSION
      #LOC_MAP_HEIGHT
      #LOC_MAP_CUBEMAP
      #LOC_MAP_IRRADIANCE
      #LOC_MAP_PREFILTER
      #LOC_MAP_BRDF
    EndEnumeration
    
    #LOC_MAP_DIFFUSE  = #LOC_MAP_ALBEDO
    #LOC_MAP_SPECULAR = #LOC_MAP_METALNESS
    
    ;// Shader uniform data types
    Enumeration ShaderUniformDataType
      #UNIFORM_FLOAT = 0
      #UNIFORM_VEC2
      #UNIFORM_VEC3
      #UNIFORM_VEC4
      #UNIFORM_INT
      #UNIFORM_IVEC2
      #UNIFORM_IVEC3
      #UNIFORM_IVEC4
      #UNIFORM_SAMPLER2D
    EndEnumeration
    
    ;// Shader attribute Data types
    Enumeration ShaderAttributeDataType
      #SHADER_ATTRIB_FLOAT = 0        ;// Shader attribute type: float
      #SHADER_ATTRIB_VEC2             ;// Shader attribute type: vec2 (2 float)
      #SHADER_ATTRIB_VEC3             ;// Shader attribute type: vec3 (3 float)
      #SHADER_ATTRIB_VEC4             ;// Shader attribute type: vec4 (4 float)
    EndEnumeration
    
    ;// Pixel formats
    ;// NOTE: Support depends on OpenGL version and platform
    Enumeration PixelFormat
      #UNCOMPRESSED_GRAYSCALE = 1     ;// 8 bit per pixel (no alpha)
      #UNCOMPRESSED_GRAY_ALPHA        ;// 8*2 bpp (2 channels)
      #UNCOMPRESSED_R5G6B5            ;// 16 bpp
      #UNCOMPRESSED_R8G8B8            ;// 24 bpp
      #UNCOMPRESSED_R5G5B5A1          ;// 16 bpp (1 bit alpha)
      #UNCOMPRESSED_R4G4B4A4          ;// 16 bpp (4 bit alpha)
      #UNCOMPRESSED_R8G8B8A8          ;// 32 bpp
      #UNCOMPRESSED_R32               ;// 32 bpp (1 channel - float)
      #UNCOMPRESSED_R32G32B32         ;// 32*3 bpp (3 channels - float)
      #UNCOMPRESSED_R32G32B32A32      ;// 32*4 bpp (4 channels - float)
      #COMPRESSED_DXT1_RGB            ;// 4 bpp (no alpha)
      #COMPRESSED_DXT1_RGBA           ;// 4 bpp (1 bit alpha)
      #COMPRESSED_DXT3_RGBA           ;// 8 bpp
      #COMPRESSED_DXT5_RGBA           ;// 8 bpp
      #COMPRESSED_ETC1_RGB            ;// 4 bpp
      #COMPRESSED_ETC2_RGB            ;// 4 bpp
      #COMPRESSED_ETC2_EAC_RGBA       ;// 8 bpp
      #COMPRESSED_PVRT_RGB            ;// 4 bpp
      #COMPRESSED_PVRT_RGBA           ;// 4 bpp
      #COMPRESSED_ASTC_4x4_RGBA       ;// 8 bpp
      #COMPRESSED_ASTC_8x8_RGBA       ;// 2 bpp
    EndEnumeration
    
    ;// Texture parameters: filter mode
    ;// NOTE 1: Filtering considers mipmaps if available in the texture
    ;// NOTE 2: Filter is accordingly set for minification and magnification
    Enumeration TextureFilter
      #FILTER_POINT = 0               ;// No filter, just pixel aproximation
      #FILTER_BILINEAR                ;// Linear filtering
      #FILTER_TRILINEAR               ;// Trilinear filtering (linear with mipmaps)
      #FILTER_ANISOTROPIC_4X          ;// Anisotropic filtering 4x
      #FILTER_ANISOTROPIC_8X          ;// Anisotropic filtering 8x
      #FILTER_ANISOTROPIC_16X         ;// Anisotropic filtering 16x
    EndEnumeration
    
    ;// Texture parameters: wrap mode
    Enumeration TextureWrap
      #WRAP_REPEAT = 0                ;// Repeats texture in tiled mode
      #WRAP_CLAMP                     ;// Clamps texture to edge pixel in tiled mode
      #WRAP_MIRROR_REPEAT             ;// Mirrors and repeats the texture in tiled mode
      #WRAP_MIRROR_CLAMP              ;// Mirrors and clamps to border the texture in tiled mode
    EndEnumeration
    
    ;// Cubemap layout type
    Enumeration CubemapLayout
      #CUBEMAP_AUTO_DETECT = 0        ;// Automatically detect layout type
      #CUBEMAP_LINE_VERTICAL          ;// Layout is defined by a vertical line with faces
      #CUBEMAP_LINE_HORIZONTAL        ;// Layout is defined by an horizontal line with faces
      #CUBEMAP_CROSS_THREE_BY_FOUR    ;// Layout is defined by a 3x4 cross with cubemap faces
      #CUBEMAP_CROSS_FOUR_BY_THREE    ;// Layout is defined by a 4x3 cross with cubemap faces
      #CUBEMAP_PANORAMA               ;// Layout is defined by a panorama image (equirectangular map)
    EndEnumeration
    
    ;// Font type, defines generation method
    Enumeration FontType
      #FONT_DEFAULT = 0               ;// Default font generation, anti-aliased
      #FONT_BITMAP                    ;// Bitmap font generation, no anti-aliasing
      #FONT_SDF                       ;// SDF font generation, requires external shader
    EndEnumeration
    
    ;// Color blending modes (pre-defined)
    Enumeration BlendMode
      #BLEND_ALPHA = 0                ;// Blend textures considering alpha (default)
      #BLEND_ADDITIVE                 ;// Blend textures adding colors
      #BLEND_MULTIPLIED               ;// Blend textures multiplying colors
      #BLEND_ADD_COLORS               ;// Blend textures adding colors (alternative)
      #BLEND_SUBTRACT_COLORS          ;// Blend textures subtracting colors (alternative)
      #BLEND_ALPHA_PREMULTIPLY        ;// Blend premultiplied textures considering alpha
      #BLEND_CUSTOM                   ;// Blend textures using custom src/dst factors (use rlSetBlendFactors())
      #BLEND_CUSTOM_SEPARATE          ;// Blend textures using custom rgb/alpha separate src/dst factors (use rlSetBlendFactorsSeparate())  
    EndEnumeration
    
    ;// Gesture
    ;// NOTE: Provided As bit-wise flags To enable only desired gestures
    Enumeration Gesture
      #GESTURE_NONE        = 0
      #GESTURE_TAP         = 1
      #GESTURE_DOUBLETAP   = 2
      #GESTURE_HOLD        = 4
      #GESTURE_DRAG        = 8
      #GESTURE_SWIPE_RIGHT = 16
      #GESTURE_SWIPE_LEFT  = 32
      #GESTURE_SWIPE_UP    = 64
      #GESTURE_SWIPE_DOWN  = 128
      #GESTURE_PINCH_IN    = 256
      #GESTURE_PINCH_OUT   = 512
    EndEnumeration
    
    ;// Camera system modes
    Enumeration CameraMode
      #CAMERAMODE_CUSTOM = 0
      #CAMERAMODE_FREE
      #CAMERAMODE_ORBITAL
      #CAMERAMODE_FIRST_PERSON
      #CAMERAMODE_THIRD_PERSON
    EndEnumeration
    
    ;// Camera projection modes
    Enumeration CameraProjection
      #CAMERATYPE_PERSPECTIVE = 0
      #CAMERATYPE_ORTHOGRAPHIC
    EndEnumeration
    
    ;// N-patch layout
    Enumeration NPatchLayout
      #NPATCH_NINE_PATCH = 0          ;// Npatch layout: 3x3 tiles
      #NPATCH_THREE_PATCH_VERTICAL    ;// Npatch layout: 1x3 tiles
      #NPATCH_THREE_PATCH_HORIZONTAL  ;// Npatch layout: 3x1 tiles
    EndEnumeration
    
    ;- ---------- Enumerations End
    ;} ---------- Enumerations End
    
    ;- ---------- Macros Start
    ;{ ---------- Macros Start
    
    ;**************** TEMP
    Macro rl_ColorLong: l : EndMacro
    ;****************
    
    Macro rl_bool  : b : EndMacro
    Macro rl_int   : l : EndMacro
    Macro rl_uint  : l : EndMacro
    Macro rl_long  : i : EndMacro
    Macro rl_float : f : EndMacro
    Macro rl_double: d : EndMacro
    Macro rl_quad : q : EndMacro ;(unsigned) long long/int
    ;Macro rl_void :   : EndMacro
    
    Macro RLDQ
      "
    EndMacro
    
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
        Macro RLAS(__procname)
          As RLDQ#_#__procname#RLDQ
        EndMacro
        Macro __PBAS(__procname)
          As RLDQ#_pbhelper_#__procname#RLDQ
        EndMacro
      CompilerElseIf #PB_Compiler_Processor = #PB_Processor_x64
        Macro RLAS(__procname)
          As RLDQ#__procname#RLDQ
        EndMacro
        Macro __PBAS(__procname)
          As RLDQ#pbhelper_#__procname#RLDQ
        EndMacro
      CompilerEndIf
    CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
      Macro RLAS(__procname)
        As RLDQ#__procname#RLDQ
      EndMacro
      Macro __PBAS(__procname)
        As RLDQ#pbhelper_#__procname#RLDQ
      EndMacro
    CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
      Macro RLAS(__procname)
        As RLDQ#_#__procname#RLDQ
      EndMacro
      Macro __PBAS(__procname)
        As RLDQ#_pbhelper_#__procname#RLDQ
      EndMacro
    CompilerEndIf
    ;- ---------- Macros End
    ;} ---------- Macros End
    
    
    ;- ---------- Structures Start
    ;{ ---------- Structures Start
    
    ;//----------------------------------------------------------------------------------
    ;// Structures Definition
    ;//----------------------------------------------------------------------------------
    
    ;// Vector2 type
    Structure Vector2 Align #PB_Structure_AlignC
      x.rl_float
      y.rl_float
    EndStructure
    
    ;// _Vector3 type
    Structure _Vector3 Align #PB_Structure_AlignC
      x.rl_float
      y.rl_float
      z.rl_float
    EndStructure
    
    ;// _Vector4 type
    Structure _Vector4 Align #PB_Structure_AlignC
      x.rl_float
      y.rl_float
      z.rl_float
      w.rl_float
    EndStructure
    
    ;// Quaternion type, same As _Vector4
    Structure Quaternion Extends _Vector4 Align #PB_Structure_AlignC
    EndStructure
    
    ;// Matrix type (OpenGL style 4x4 - right handed, column major)
    Structure Matrix Align #PB_Structure_AlignC
      m0.rl_float
      m4.rl_float
      m8.rl_float
      m12.rl_float
      m1.rl_float
      m5.rl_float
      m9.rl_float
      m13.rl_float
      m2.rl_float
      m6.rl_float
      m10.rl_float
      m14.rl_float
      m3.rl_float
      m7.rl_float
      m11.rl_float
      m15.rl_float
    EndStructure
    
    ;// Color type, 4 components, R8G8B8A8 (32bit)
    Structure Color Align #PB_Structure_AlignC
      r.a
      g.a
      b.a
      a.a
    EndStructure
    
    ;// Rectangle type, 4 components
    Structure Rectangle Align #PB_Structure_AlignC
      x.rl_float
      y.rl_float
      width.rl_float
      height.rl_float
    EndStructure
    
    ;// Image type, bpp always RGBA (32bit)
    ;// NOTE: Data stored in CPU memory (RAM)
    Structure Image Align #PB_Structure_AlignC
      *_data          ;// Image raw data
      width.rl_int    ;// Image base width
      height.rl_int   ;// Image base height
      mipmaps.rl_int  ;// Mipmap levels, 1 by default
      format.rl_int   ;// Data format (PixelFormat type)
    EndStructure
    
    ;// Texture2D type
    ;// NOTE: Data stored in GPU memory
    Structure Texture2D Align #PB_Structure_AlignC
      id.rl_uint      ;// OpenGL texture id
      width.rl_int    ;// Texture base width
      height.rl_int   ;// Texture base height
      mipmaps.rl_int  ;// Mipmap levels, 1 by default
      format.rl_int   ;// Data format (PixelFormat type)
    EndStructure
    
    ;// Texture type, same As Texture2D
    Structure Texture Extends Texture2D Align #PB_Structure_AlignC
    EndStructure
    
    ;// TextureCubemap type, actually, same As Texture2D
    Structure TextureCubemap Extends Texture2D  Align #PB_Structure_AlignC
    EndStructure
    
    ;// RenderTexture2D type, For texture rendering
    Structure RenderTexture2D Align #PB_Structure_AlignC
      id.rl_uint              ;// OpenGL Framebuffer Object (FBO) id
      texture.Texture2D       ;// Color buffer attachment texture
      depth.Texture2D         ;// Depth buffer attachment texture
      depthTexture.rl_bool    ;// Track if depth attachment is a texture or renderbuffer
    EndStructure
    
    ;// RenderTexture type, same As RenderTexture2D
    Structure RenderTexture Extends RenderTexture2D Align #PB_Structure_AlignC
    EndStructure
    
    ;// N-Patch layout info
    Structure NPatchInfo Align #PB_Structure_AlignC
      sourceRec.Rectangle     ;// Region in the texture
      left.rl_int             ;// left border offset
      top.rl_int              ;// top border offset
      right.rl_int            ;// right border offset
      bottom.rl_int           ;// bottom border offset
      layout.rl_int           ;// layout of the n-patch: 3x3, 1x3 or 3x1
    EndStructure
    
    ;// GlyphInfo, font characters glyphs info
    Structure GlyphInfo Align #PB_Structure_AlignC
      value.rl_int            ;// Character value (Unicode)
      offsetX.rl_int          ;// Character offset X when drawing
      offsetY.rl_int          ;// Character offset Y when drawing
      advanceX.rl_int         ;// Character advance position X
      image.Image             ;// Character image data
    EndStructure
    
    ;// Font type, includes texture And charSet Array Data
    Structure Font Align #PB_Structure_AlignC
      baseSize.rl_int         ;// Base size (default chars height)
      glyphCount.rl_int       ;// Number of glyph characters
      glyphPadding.rl_int     ;// Padding around the glyph characters
      texture.Texture2D       ;// Texture atlas containing the glyphs
      *recs.Rectangle         ;// Rectangles in texture for the glyphs
      *glyphs.GlyphInfo       ;// Glyphs info data
    EndStructure
    
    ;// SpriteFont type fallback, defaults To Font
    Structure SpriteFont Extends Font Align #PB_Structure_AlignC
    EndStructure
    
    ;// Camera type, defines a camera position/orientation in 3d space
    Structure Camera3D Align #PB_Structure_AlignC
      position._Vector3    ;// Camera position
      target._Vector3      ;// Camera target it looks-at
      up._Vector3          ;// Camera up vector (rotation over its axis)
      fovy.rl_float        ;// Camera field-of-view apperture in Y (degrees) in perspective, used as near plane width in orthographic
      projection.rl_int    ;// Camera type, defines projection type: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC
    EndStructure
    
    ;// Camera type fallback, defaults to Camera3D
    Structure Camera Extends Camera3D Align #PB_Structure_AlignC
    EndStructure
    
    ;// Camera2D type, defines a 2d camera
    Structure Camera2D Align #PB_Structure_AlignC
      offset.Vector2      ;// Camera offset (displacement from target)
      target.Vector2      ;// Camera target (rotation and zoom origin)
      rotation.rl_float   ;// Camera rotation in degrees
      zoom.rl_float       ;// Camera zoom (scaling), should be 1.0f by default
    EndStructure
    
    ;// Vertex Data definning a mesh
    ;// NOTE: Data stored in CPU memory (And GPU)
    Structure Mesh Align #PB_Structure_AlignC
      vertexCount.rl_int  ;// Number of vertices stored in arrays
      triangleCount.rl_int;// Number of triangles stored (indexed or not)
      
      ;// Default vertex Data
      *vertices.Float     ;// Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
      *texcoords.Float    ;// Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
      *texcoords2.Float   ;// Vertex second texture coordinates (useful for lightmaps) (shader-location = 5)
      *normals.Float      ;// Vertex normals (XYZ - 3 components per vertex) (shader-location = 2)
      *tangents.Float     ;// Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)
      *colors.Ascii       ;// Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
      *indices.Unicode    ;// Vertex indices (in case vertex data comes indexed)
      
      ;// Animation vertex Data
      *animVertices.Float ;// Animated vertex positions (after bones transformations)
      *animNormals.Float  ;// Animated normals (after bones transformations)
      *boneIds.Long       ;// Vertex bone ids, up to 4 bones influence by vertex (skinning)
      *boneWeights.Float  ;// Vertex bone weight, up to 4 bones influence by vertex (skinning)
      
      ;// OpenGL identifiers
      vaoId.rl_uint       ;// OpenGL Vertex Array Object id
      *vboId.Long         ;// OpenGL Vertex Buffer Objects id (default vertex data)
    EndStructure
    
    ;// Shader type (generic)
    Structure Shader Align #PB_Structure_AlignC
      id.rl_uint          ;// Shader program id
      *locs.Long          ;// Shader locations array (MAX_SHADER_LOCATIONS)
    EndStructure
    
    ;// Material texture Map
    Structure MaterialMap Align #PB_Structure_AlignC
      texture.Texture2D   ;// Material map texture
      color.rl_ColorLong  ;// Material Map color
      value.rl_float      ;// Material Map value
    EndStructure
    
    ;// Material type (generic)
    Structure Material Align #PB_Structure_AlignC
      shader.Shader       ;// Material shader
      *maps.MaterialMap[#MAX_MATERIAL_MAPS]   ;// Material maps array (MAX_MATERIAL_MAPS)
      params.rl_float[4]  ;// Material generic parameters (if required)
    EndStructure
    
    ;// Transformation properties
    Structure Transform Align #PB_Structure_AlignC
      translation._Vector3   ;// Translation
      rotation.Quaternion    ;// Rotation
      scale._Vector3         ;// Scale
    EndStructure
    
    ;// Bone information
    Structure BoneInfo Align #PB_Structure_AlignC
      name.a[32]          ;// Bone name
      parent.rl_int       ;// Bone parent
    EndStructure
    
    ;// Model type
    Structure Model Align #PB_Structure_AlignC
      transform.Matrix      ;// Local transform matrix
      
      meshCount.rl_int      ;// Number of meshes
      materialCount.rl_int  ;// Number of materials
      *meshes.Mesh          ;// Meshes array
      *materials.Material   ;// Materials array
      *meshMaterial.Long    ;// Mesh material number
      
      ;// Animation Data
      boneCount.rl_int      ;// Number of bones
      *bones.BoneInfo       ;// Bones information (skeleton)
      *bindPose.Transform   ;// Bones base transformation (pose)
    EndStructure
    
    ;// Model animation
    Structure ModelAnimation Align #PB_Structure_AlignC
      boneCount.rl_int             ;// Number of bones
      frameCount.rl_int            ;// Number of animation frames
      *bones.BoneInfo              ;// Bones information (skeleton)
      *framePoses.rl_Transform[0]  ;// Poses array by frame
    EndStructure
    
    ;// Ray type (useful For raycast)
    Structure Ray Align #PB_Structure_AlignC
      position._Vector3        ;// Ray position (origin)
      direction._Vector3       ;// Ray direction
    EndStructure
    
    ;// RayCollision, ray hit information
    Structure RayCollision Align #PB_Structure_AlignC
      hit.rl_bool             ;// Did the ray hit something?
      distance.rl_float       ;// Distance to nearest hit
      point._Vector3          ;// Position of nearest hit
      normal._Vector3         ;// Surface normal of hit
    EndStructure
    
    ;// Bounding box type
    Structure BoundingBox Align #PB_Structure_AlignC
      min._Vector3             ;// Minimum vertex box-corner
      max._Vector3             ;// Maximum vertex box-corner
    EndStructure
    
    ;// Wave type, defines audio wave Data
    Structure Wave Align #PB_Structure_AlignC
      frameCount.rl_uint      ;// Total number of frames (considering channels)
      sampleRate.rl_uint      ;// Frequency (samples per second)
      sampleSize.rl_uint      ;// Bit depth (bits per sample): 8, 16, 32 (24 not supported)
      channels.rl_uint        ;// Number of channels (1-mono, 2-stereo)
      *_data                  ;// Buffer data pointer
    EndStructure
    
    ;// Opaque structs declaration
    ;// NOTE: Actual structs are defined internally in raudio Module
    Structure rAudioBuffer Align #PB_Structure_AlignC
    EndStructure
    
    Structure rAudioProcessor Align #PB_Structure_AlignC
    EndStructure
    
    ;// Audio stream type
    ;// NOTE: Useful To create custom audio streams Not bound To a specific file
    Structure AudioStream Align #PB_Structure_AlignC
      *buffer.rAudioBuffer        ;// Pointer to internal data used by the audio system
      *processor.rAudioProcessor  ;// Pointer to internal data processor, useful for audio effects
      
      
      sampleRate.rl_uint          ;// Frequency (samples per second)
      sampleSize.rl_uint          ;// Bit depth (bits per sample): 8, 16, 32 (24 not supported)
      channels.rl_uint            ;// Number of channels (1-mono, 2-stereo)
    EndStructure
    
    ;// Sound source type
    Structure Sound Align #PB_Structure_AlignC
      stream.AudioStream      ;// Audio stream
      frameCount.rl_uint      ;// Total number of frames (considering channels)
    EndStructure
    
    ;// Music stream type (audio file streaming from memory)
    ;// NOTE: Anything longer than ~10 seconds should be streamed
    Structure Music Align #PB_Structure_AlignC
      stream.AudioStream      ;// Audio stream
      frameCount.rl_uint      ;// Total number of frames (considering channels)
      looping.rl_bool         ;// Music looping enable
      
      ctxType.rl_int          ;// Type of music context (audio filetype)
      *ctxData                ;// Audio context data, depends on type
    EndStructure
    
    ;// Head-Mounted-Display device parameters
    Structure VrDeviceInfo Align #PB_Structure_AlignC
      hResolution.rl_int              ;// HMD horizontal resolution in pixels
      vResolution.rl_int              ;// HMD vertical resolution in pixels
      hScreenSize.rl_float            ;// HMD horizontal size in meters
      vScreenSize.rl_float            ;// HMD vertical size in meters
      vScreenCenter.rl_float          ;// HMD screen center in meters
      eyeToScreenDistance.rl_float    ;// HMD distance between eye and display in meters
      lensSeparationDistance.rl_float ;// HMD lens separation distance in meters
      interpupillaryDistance.rl_float ;// HMD IPD (distance between pupils) in meters
      lensDistortionValues.rl_float[4];// HMD lens distortion constant parameters
      chromaAbCorrection.rl_float[4]  ;// HMD chromatic aberration correction parameters
    EndStructure
    
    ;// VrStereoConfig, VR stereo rendering configuration For simulator
    Structure VrStereoConfig Align #PB_Structure_AlignC
      projection.Matrix[2]            ;// VR projection matrices (per eye)
      viewOffset.Matrix[2]            ;// VR view offset matrices (per eye)
      leftLensCenter.rl_float[2]      ;// VR left lens center
      rightLensCenter.rl_float[2]     ;// VR right lens center
      leftScreenCenter.rl_float[2]    ;// VR left screen center
      rightScreenCenter.rl_float[2]   ;// VR right screen center
      scale.rl_float[2]               ;// VR distortion scale
      scaleIn.rl_float[2]             ;// VR distortion scale in
    EndStructure
    
    Structure FileName Align #PB_Structure_AlignC
      *name.Character
    EndStructure
    
    ;// File path List
    Structure FilePathList Align #PB_Structure_AlignC
      capacity.rl_uint                ;// Filepaths max entries
      count.rl_uint                   ;// Filepaths entries count
      *paths.FileName                ;// Filepaths entries
    EndStructure
    
    ;// Configuration Structure for waving the text
    Structure WaveTextConfig
      waveRange._Vector3
      waveSpeed._Vector3
      waveOffset._Vector3
    EndStructure

    ;- ---------- Structures End
    ;} ---------- Structures End
    
    ;//------------------------------------------------------------------------------------
    ;// Global Variables Definition
    ;//------------------------------------------------------------------------------------
    ;// "It's lonely here..." :)
    
    
    ;- Import "rlgl.h"
    ; /**********************************************************************************************
    ; *
    ; *   rlgl v4.0 - A multi-OpenGL abstraction layer With an immediate-mode style API
    ; *
    ; *   An abstraction layer For multiple OpenGL versions (1.1, 2.1, 3.3 Core, 4.3 Core, ES 2.0)
    ; *   that provides a pseudo-OpenGL 1.1 immediate-mode style API (rlVertex, rlTranslate, rlRotate...)
    ; *
    ; *   When chosing an OpenGL backend different than OpenGL 1.1, some internal buffer are
    ; *   initialized on rlglInit() To accumulate vertex Data.
    ; *
    ; *   When an internal state change is required all the stored vertex Data is renderer in batch,
    ; *   additioanlly, rlDrawRenderBatchActive() could be called To force flushing of the batch.
    ; *
    ; *   Some additional resources are also loaded For convenience, here the complete List:
    ; *      - Default batch (RLGL.defaultBatch): RenderBatch system To accumulate vertex Data
    ; *      - Default texture (RLGL.defaultTextureId): 1x1 white pixel R8G8B8A8
    ; *      - Default shader (RLGL.State.defaultShaderId, RLGL.State.defaultShaderLocs)
    ; *
    ; *   Internal buffer (And additional resources) must be manually unloaded calling rlglClose().
    ; *
    ; *
    ; *   CONFIGURATION:
    ; *
    ; *   #define GRAPHICS_API_OPENGL_11
    ; *   #define GRAPHICS_API_OPENGL_21
    ; *   #define GRAPHICS_API_OPENGL_33
    ; *   #define GRAPHICS_API_OPENGL_43
    ; *   #define GRAPHICS_API_OPENGL_ES2
    ; *       Use selected OpenGL graphics backend, should be supported by platform
    ; *       Those preprocessor defines are only used on rlgl Module, If OpenGL version is
    ; *       required by any other Module, use rlGetVersion() To check it
    ; *
    ; *   #define RLGL_IMPLEMENTATION
    ; *       Generates the implementation of the library into the included file.
    ; *       If Not defined, the library is in header only mode And can be included in other headers
    ; *       Or source files without problems. But only ONE file should hold the implementation.
    ; *
    ; *   #define RLGL_RENDER_TEXTURES_HINT
    ; *       Enable framebuffer objects (fbo) support (enabled by Default)
    ; *       Some GPUs could Not support them despite the OpenGL version
    ; *
    ; *   #define RLGL_SHOW_GL_DETAILS_INFO
    ; *       Show OpenGL extensions And capabilities detailed logs on init
    ; *
    ; *   #define RLGL_ENABLE_OPENGL_DEBUG_CONTEXT
    ; *       Enable Debug context (only available on OpenGL 4.3)
    ; *
    ; *   rlgl capabilities could be customized just defining some internal
    ; *   values before library inclusion (Default values listed):
    ; *
    ; *   #define RL_DEFAULT_BATCH_BUFFER_ELEMENTS   8192    // Default internal render batch elements limits
    ; *   #define RL_DEFAULT_BATCH_BUFFERS              1    // Default number of batch buffers (multi-buffering)
    ; *   #define RL_DEFAULT_BATCH_DRAWCALLS          256    // Default number of batch draw calls (by state changes: mode, texture)
    ; *   #define RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS    4    // Maximum number of textures units that can be activated on batch drawing (SetShaderValueTexture())
    ; *
    ; *   #define RL_MAX_MATRIX_STACK_SIZE             32    // Maximum size of internal Matrix stack
    ; *   #define RL_MAX_SHADER_LOCATIONS              32    // Maximum number of shader locations supported
    ; *   #define RL_CULL_DISTANCE_NEAR              0.01    // Default projection matrix near cull distance
    ; *   #define RL_CULL_DISTANCE_FAR             1000.0    // Default projection matrix far cull distance
    ; *
    ; *   When loading a shader, the following vertex attribute And uniform
    ; *   location names are tried To be set automatically:
    ; *
    ; *   #define RL_DEFAULT_SHADER_ATTRIB_NAME_POSITION     "vertexPosition"    // Binded by Default To shader location: 0
    ; *   #define RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD     "vertexTexCoord"    // Binded by Default To shader location: 1
    ; *   #define RL_DEFAULT_SHADER_ATTRIB_NAME_NORMAL       "vertexNormal"      // Binded by Default To shader location: 2
    ; *   #define RL_DEFAULT_SHADER_ATTRIB_NAME_COLOR        "vertexColor"       // Binded by Default To shader location: 3
    ; *   #define RL_DEFAULT_SHADER_ATTRIB_NAME_TANGENT      "vertexTangent"     // Binded by Default To shader location: 4
    ; *   #define RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD2    "vertexTexCoord2"   // Binded by Default To shader location: 5
    ; *   #define RL_DEFAULT_SHADER_UNIFORM_NAME_MVP         "mvp"               // model-view-projection matrix
    ; *   #define RL_DEFAULT_SHADER_UNIFORM_NAME_VIEW        "matView"           // view matrix
    ; *   #define RL_DEFAULT_SHADER_UNIFORM_NAME_PROJECTION  "matProjection"     // projection matrix
    ; *   #define RL_DEFAULT_SHADER_UNIFORM_NAME_MODEL       "matModel"          // model matrix
    ; *   #define RL_DEFAULT_SHADER_UNIFORM_NAME_NORMAL      "matNormal"         // normal matrix (transpose(inverse(matModelView))
    ; *   #define RL_DEFAULT_SHADER_UNIFORM_NAME_COLOR       "colDiffuse"        // color diffuse (base tint color, multiplied by texture color)
    ; *   #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE0  "texture0"          // texture0 (texture slot active 0)
    ; *   #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE1  "texture1"          // texture1 (texture slot active 1)
    ; *   #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE2  "texture2"          // texture2 (texture slot active 2)
    ; *
    ; *   DEPENDENCIES:
    ; *
    ; *      - OpenGL libraries (depending on platform And OpenGL version selected)
    ; *      - GLAD OpenGL extensions loading library (only For OpenGL 3.3 Core, 4.3 Core)
    ; *
    ; *
    ; *   LICENSE: zlib/libpng
    ; *
    ; *   Copyright (c) 2014-2022 Ramon Santamaria (@raysan5)
    ; *
    ; *   This software is provided "as-is", without any express Or implied warranty. In no event
    ; *   will the authors be held liable For any damages arising from the use of this software.
    ; *
    ; *   Permission is granted To anyone To use this software For any purpose, including commercial
    ; *   applications, And To alter it And redistribute it freely, subject To the following restrictions:
    ; *
    ; *     1. The origin of this software must Not be misrepresented; you must not claim that you
    ; *     wrote the original software. If you use this software in a product, an acknowledgment
    ; *     in the product documentation would be appreciated but is Not required.
    ; *
    ; *     2. Altered source versions must be plainly marked As such, And must Not be misrepresented
    ; *     As being the original software.
    ; *
    ; *     3. This notice may Not be removed Or altered from any source distribution.
    ; *
    ; **********************************************************************************************/
    
    #RLGL_VERSION = "4.0"
    
    ; //----------------------------------------------------------------------------------
    ; // Defines And Macros
    ; //----------------------------------------------------------------------------------
    
    ;// Default internal render batch elements limits
    CompilerIf Not Defined(RL_DEFAULT_BATCH_BUFFER_ELEMENTS, #PB_Constant)
      CompilerIf Defined(GRAPHICS_API_OPENGL_11, #PB_Constant) Or Defined(GRAPHICS_API_OPENGL_33, #PB_Constant)
        ;// This is the maximum amount of elements (quads) per batch
        ;// NOTE: Be careful With text, every letter maps To a quad
        #RL_DEFAULT_BATCH_BUFFER_ELEMENTS = 8192
      CompilerEndIf
      CompilerIf Defined(GRAPHICS_API_OPENGL_ES2, #PB_Constant)
        ;// We reduce memory sizes For embedded systems (RPI And HTML5)
        ;// NOTE: On HTML5 (emscripten) this is allocated on heap,
        ;// by Default it's only 16MB!...just take care...
        #RL_DEFAULT_BATCH_BUFFER_ELEMENTS = 2048
      CompilerEndIf
    CompilerEndIf
    
    CompilerIf Not Defined(RL_DEFAULT_BATCH_BUFFERS, #PB_Constant)
      #RL_DEFAULT_BATCH_BUFFERS = 1 ;// Default number of batch buffers (multi-buffering)
    CompilerEndIf
    
    CompilerIf Not Defined(RL_DEFAULT_BATCH_DRAWCALLS, #PB_Constant)
      #RL_DEFAULT_BATCH_DRAWCALLS = 256 ;// Default number of batch draw calls (by state changes: mode, texture)
    CompilerEndIf
    
    CompilerIf Not Defined(RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS, #PB_Constant)
      #RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS = 4 ;// Maximum number of textures units that can be activated on batch drawing (SetShaderValueTexture())
    CompilerEndIf
    
    ;// Internal Matrix stack
    CompilerIf Not Defined(RL_MAX_MATRIX_STACK_SIZE, #PB_Constant)
      #RL_MAX_MATRIX_STACK_SIZE = 32 ;// Maximum size of Matrix stack
    CompilerEndIf
    
    ;// Shader limits
    CompilerIf Not Defined(RL_MAX_SHADER_LOCATIONS, #PB_Constant)
      #RL_MAX_SHADER_LOCATIONS = 32 ;// Maximum number of shader locations supported
    CompilerEndIf
    
    ;// Projection matrix culling
    CompilerIf Not Defined(RL_CULL_DISTANCE_NEAR, #PB_Constant)
      #RL_CULL_DISTANCE_NEAR = 0.01 ;// Default near cull distance
    CompilerEndIf
    
    CompilerIf Not Defined(RL_CULL_DISTANCE_FAR, #PB_Constant)
      #RL_CULL_DISTANCE_FAR = 1000.0 ;// Default far cull distance
    CompilerEndIf
    
    ;// Texture parameters (equivalent To OpenGL defines)
    #RL_TEXTURE_WRAP_S = $2802      ;// GL_TEXTURE_WRAP_S
    #RL_TEXTURE_WRAP_T = $2803      ;// GL_TEXTURE_WRAP_T
    #RL_TEXTURE_MAG_FILTER = $2800  ;// GL_TEXTURE_MAG_FILTER
    #RL_TEXTURE_MIN_FILTER = $2801  ;// GL_TEXTURE_MIN_FILTER
    
    #RL_TEXTURE_FILTER_NEAREST = $2600              ;// GL_NEAREST
    #RL_TEXTURE_FILTER_LINEAR = $2601               ;// GL_LINEAR
    #RL_TEXTURE_FILTER_MIP_NEAREST = $2700          ;// GL_NEAREST_MIPMAP_NEAREST
    #RL_TEXTURE_FILTER_NEAREST_MIP_LINEAR = $2702   ;// GL_NEAREST_MIPMAP_LINEAR
    #RL_TEXTURE_FILTER_LINEAR_MIP_NEAREST = $2701   ;// GL_LINEAR_MIPMAP_NEAREST
    #RL_TEXTURE_FILTER_MIP_LINEAR = $2703           ;// GL_LINEAR_MIPMAP_LINEAR
    #RL_TEXTURE_FILTER_ANISOTROPIC = $3000          ;// Anisotropic filter (custom identifier)
    
    #RL_TEXTURE_WRAP_REPEAT = $2901                 ;// GL_REPEAT
    #RL_TEXTURE_WRAP_CLAMP = $812F                  ;// GL_CLAMP_TO_EDGE
    #RL_TEXTURE_WRAP_MIRROR_REPEAT = $8370          ;// GL_MIRRORED_REPEAT
    #RL_TEXTURE_WRAP_MIRROR_CLAMP = $8742           ;// GL_MIRROR_CLAMP_EXT
    
    ;// Matrix modes (equivalent To OpenGL)
    #RL_MODELVIEW = $1700                           ;// GL_MODELVIEW
    #RL_PROJECTION = $1701                          ;// GL_PROJECTION
    #RL_TEXTURE = $1702                             ;// GL_TEXTURE
    
    ;// Primitive assembly draw modes
    #RL_LINES = $0001                               ;// GL_LINES
    #RL_TRIANGLES = $0004                           ;// GL_TRIANGLES
    #RL_QUADS = $0007                               ;// GL_QUADS
    
    ;// GL equivalent Data types
    #RL_UNSIGNED_BYTE = $1401                       ;// GL_UNSIGNED_BYTE
    #RL_FLOAT = $1406                               ;// GL_FLOAT
    
    ;// Buffer usage hint
    #RL_STREAM_DRAW = $88E0                         ;// GL_STREAM_DRAW
    #RL_STREAM_READ = $88E1                         ;// GL_STREAM_READ
    #RL_STREAM_COPY = $88E2                         ;// GL_STREAM_COPY
    #RL_STATIC_DRAW = $88E4                         ;// GL_STATIC_DRAW
    #RL_STATIC_READ = $88E5                         ;// GL_STATIC_READ
    #RL_STATIC_COPY = $88E6                         ;// GL_STATIC_COPY
    #RL_DYNAMIC_DRAW = $88E8                        ;// GL_DYNAMIC_DRAW
    #RL_DYNAMIC_READ = $88E9                        ;// GL_DYNAMIC_READ
    #RL_DYNAMIC_COPY = $88EA                        ;// GL_DYNAMIC_COPY
    
    ;// GL Shader type
    #RL_FRAGMENT_SHADER = $8B30                     ;// GL_FRAGMENT_SHADER
    #RL_VERTEX_SHADER = $8B31                       ;// GL_VERTEX_SHADER
    #RL_COMPUTE_SHADER = $91B9                      ;// GL_COMPUTE_SHADER
    
    ; //----------------------------------------------------------------------------------
    ; // Types And Structures Definition
    ; //----------------------------------------------------------------------------------
    Enumeration rlGlVersion
      #OPENGL_11 = 1
      #OPENGL_21
      #OPENGL_33
      #OPENGL_43
      #OPENGL_ES_20
    EndEnumeration
    
    Enumeration rlFramebufferAttachType
      #RL_ATTACHMENT_COLOR_CHANNEL0 = 0
      #RL_ATTACHMENT_COLOR_CHANNEL1
      #RL_ATTACHMENT_COLOR_CHANNEL2
      #RL_ATTACHMENT_COLOR_CHANNEL3
      #RL_ATTACHMENT_COLOR_CHANNEL4
      #RL_ATTACHMENT_COLOR_CHANNEL5
      #RL_ATTACHMENT_COLOR_CHANNEL6
      #RL_ATTACHMENT_COLOR_CHANNEL7
      #RL_ATTACHMENT_DEPTH = 100
      #RL_ATTACHMENT_STENCIL = 200
    EndEnumeration
    
    Enumeration rlFramebufferAttachTextureType
      #RL_ATTACHMENT_CUBEMAP_POSITIVE_X = 0
      #RL_ATTACHMENT_CUBEMAP_NEGATIVE_X
      #RL_ATTACHMENT_CUBEMAP_POSITIVE_Y
      #RL_ATTACHMENT_CUBEMAP_NEGATIVE_Y
      #RL_ATTACHMENT_CUBEMAP_POSITIVE_Z
      #RL_ATTACHMENT_CUBEMAP_NEGATIVE_Z
      #RL_ATTACHMENT_TEXTURE2D = 100
      #RL_ATTACHMENT_RENDERBUFFER = 200
    EndEnumeration
    
    ;// Dynamic vertex buffers (position + texcoords + colors + indices arrays)
    Structure rlVertexBuffer Align #PB_Structure_AlignC
      elementCount.rl_int     ;// Number of elements in the buffer (QUADS)
      *vertices.float         ;// Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
      *texcoords.float        ;// Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
      *colors.ascii           ;// Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
      CompilerIf Defined(GRAPHICS_API_OPENGL_11, #PB_Constant) Or Defined(GRAPHICS_API_OPENGL_33, #PB_Constant)
        *indices.long         ;// Vertex indices (in case vertex data comes indexed) (6 indices per quad)
      CompilerEndIf
      CompilerIf Defined(GRAPHICS_API_OPENGL_ES2, #PB_Constant)
        *indices.character    ;// Vertex indices (in case vertex data comes indexed) (6 indices per quad)
      CompilerEndIf
      vaoId.rl_uint         ;// OpenGL Vertex Array Object id
      vboId.rl_uint[4]      ;// OpenGL Vertex Buffer Objects id (4 types of vertex data)
    EndStructure
    
    ; // Draw call type
    ; // NOTE: Only texture changes register a new draw, other state-change-related elements are Not
    ; // used at this moment (vaoId, shaderId, matrices), raylib just forces a batch draw call If any
    ; // of those state-change happens (this is done in core Module)
    Structure rlDrawCall Align #PB_Structure_AlignC
      mode.rl_int             ;// Drawing mode: LINES, TRIANGLES, QUADS
      vertexCount.rl_int      ;// Number of vertex of the draw
      vertexAlignment.rl_int  ;// Number of vertex required for index alignment (LINES, TRIANGLES)
      ;//unsigned int vaoId;       // Vertex array id to be used on the draw -> Using RLGL.currentBatch->vertexBuffer.vaoId
      ;//unsigned int shaderId;    // Shader id to be used on the draw -> Using RLGL.currentShaderId
      textureId.rl_uint       ;// Texture id to be used on the draw -> Use to create new draw call if changes
      
      ;//Matrix projection;      // Projection matrix for this draw -> Using RLGL.projection by default
      ;//Matrix modelview;       // Modelview matrix for this draw -> Using RLGL.modelview by default
    EndStructure
    
    ; rlRenderBatch type
    Structure rlRenderBatch Align #PB_Structure_AlignC
      bufferCount.rl_int            ;// Number of vertex buffers (multi-buffering support)
      currentBuffer.rl_int          ;// Current buffer tracking in case of multi-buffering
      *vertexBuffer.rlVertexBuffer  ;// Dynamic buffer(s) for vertex data
      
      *draws.rlDrawCall             ;// Draw calls array, depends on textureId
      drawCounter.rl_int            ;// Draw calls counter
      currentDepth.rl_float         ;// Current depth value for next draw
    EndStructure
    
    CompilerIf Not Defined(RL_MATRIX_TYPE, #PB_Constant)
      ;// Matrix, 4x4 components, column major, OpenGL style, right handed
      CompilerIf Not Defined(Matrix, #PB_Structure)
        Structure Matrix
          m0.f : m4.f : m8.f : m12.f  ;// Matrix first row (4 components)
          m1.f : m5.f : m9.f : m13.f  ;// Matrix second row (4 components)
          m2.f : m6.f : m10.f : m14.f ;// Matrix third row (4 components)
          m3.f : m7.f : m11.f : m15.f ;// Matrix fourth row (4 components)
        EndStructure
      CompilerEndIf
      #RL_MATRIX_TYPE = 0
    CompilerEndIf
    
    ;// Trace log level
    ;// NOTE: Organized by priority level
    Enumeration rlTraceLogLevel
      #RL_LOG_ALL = 0   ;// Display all logs
      #RL_LOG_TRACE     ;// Trace logging, intended For internal use only
      #RL_LOG_DEBUG     ;// Debug logging, used For internal debugging, it should be disabled on release builds
      #RL_LOG_INFO      ;// Info logging, used For program execution info
      #RL_LOG_WARNING   ;// Warning logging, used on recoverable failures
      #RL_LOG_ERROR     ;// Error logging, used on unrecoverable failures
      #RL_LOG_FATAL     ;// Fatal logging, used To abort program: exit(EXIT_FAILURE)
      #RL_LOG_NONE      ;// Disable logging
    EndEnumeration
    
    ;// Texture formats (support depends on OpenGL version)
    Enumeration rlPixelFormat
      #RL_PIXELFORMAT_UNCOMPRESSED_GRAYSCALE = 1  ;// 8 bit per pixel (no alpha)
      #RL_PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA     ;// 8*2 bpp (2 channels)
      #RL_PIXELFORMAT_UNCOMPRESSED_R5G6B5         ;// 16 bpp
      #RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8         ;// 24 bpp
      #RL_PIXELFORMAT_UNCOMPRESSED_R5G5B5A1       ;// 16 bpp (1 bit alpha)
      #RL_PIXELFORMAT_UNCOMPRESSED_R4G4B4A4       ;// 16 bpp (4 bit alpha)
      #RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8A8       ;// 32 bpp
      #RL_PIXELFORMAT_UNCOMPRESSED_R32            ;// 32 bpp (1 channel - float)
      #RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32      ;// 32*3 bpp (3 channels - float)
      #RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32A32   ;// 32*4 bpp (4 channels - float)
      #RL_PIXELFORMAT_COMPRESSED_DXT1_RGB         ;// 4 bpp (no alpha)
      #RL_PIXELFORMAT_COMPRESSED_DXT1_RGBA        ;// 4 bpp (1 bit alpha)
      #RL_PIXELFORMAT_COMPRESSED_DXT3_RGBA        ;// 8 bpp
      #RL_PIXELFORMAT_COMPRESSED_DXT5_RGBA        ;// 8 bpp
      #RL_PIXELFORMAT_COMPRESSED_ETC1_RGB         ;// 4 bpp
      #RL_PIXELFORMAT_COMPRESSED_ETC2_RGB         ;// 4 bpp
      #RL_PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA    ;// 8 bpp
      #RL_PIXELFORMAT_COMPRESSED_PVRT_RGB         ;// 4 bpp
      #RL_PIXELFORMAT_COMPRESSED_PVRT_RGBA        ;// 4 bpp
      #RL_PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA    ;// 8 bpp
      #RL_PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA    ;// 2 bpp
    EndEnumeration
    
    ; // Texture parameters: filter mode
    ; // NOTE 1: Filtering considers mipmaps If available in the texture
    ; // NOTE 2: Filter is accordingly set For minification And magnification
    Enumeration rlTextureFilter
      #RL_TEXTURE_FILTER_POINT = 0        ;// No filter, just pixel approximation
      #RL_TEXTURE_FILTER_BILINEAR         ;// Linear filtering
      #RL_TEXTURE_FILTER_TRILINEAR        ;// Trilinear filtering (linear With mipmaps)
      #RL_TEXTURE_FILTER_ANISOTROPIC_4X   ;// Anisotropic filtering 4x
      #RL_TEXTURE_FILTER_ANISOTROPIC_8X   ;// Anisotropic filtering 8x
      #RL_TEXTURE_FILTER_ANISOTROPIC_16X  ;// Anisotropic filtering 16x
    EndEnumeration
    
    ;// Color blending modes (pre-defined)
    Enumeration rlBlendMode
      #RL_BLEND_ALPHA = 0                 ;// Blend textures considering Alpha (Default)
      #RL_BLEND_ADDITIVE                  ;// Blend textures adding colors
      #RL_BLEND_MULTIPLIED                ;// Blend textures multiplying colors
      #RL_BLEND_ADD_COLORS                ;// Blend textures adding colors (alternative)
      #RL_BLEND_SUBTRACT_COLORS           ;// Blend textures subtracting colors (alternative)
      #RL_BLEND_ALPHA_PREMULTIPLY         ;// Blend premultiplied textures considering alpha
      #RL_BLEND_CUSTOM                    ;// Blend textures using custom src/dst factors (use rlSetBlendFactors())
    EndEnumeration
    
    ;// Shader location point type
    Enumeration rlShaderLocationIndex
      #RL_SHADER_LOC_VERTEX_POSITION = 0  ;// Shader location: vertex attribute: position
      #RL_SHADER_LOC_VERTEX_TEXCOORD01    ;// Shader location: vertex attribute: texcoord01
      #RL_SHADER_LOC_VERTEX_TEXCOORD02    ;// Shader location: vertex attribute: texcoord02
      #RL_SHADER_LOC_VERTEX_NORMAL        ;// Shader location: vertex attribute: normal
      #RL_SHADER_LOC_VERTEX_TANGENT       ;// Shader location: vertex attribute: tangent
      #RL_SHADER_LOC_VERTEX_COLOR         ;// Shader location: vertex attribute: color
      #RL_SHADER_LOC_MATRIX_MVP           ;// Shader location: matrix uniform: model-view-projection
      #RL_SHADER_LOC_MATRIX_VIEW          ;// Shader location: matrix uniform: view (camera transform)
      #RL_SHADER_LOC_MATRIX_PROJECTION    ;// Shader location: matrix uniform: projection
      #RL_SHADER_LOC_MATRIX_MODEL         ;// Shader location: matrix uniform: model (transform)
      #RL_SHADER_LOC_MATRIX_NORMAL        ;// Shader location: matrix uniform: normal
      #RL_SHADER_LOC_VECTOR_VIEW          ;// Shader location: vector uniform: view
      #RL_SHADER_LOC_COLOR_DIFFUSE        ;// Shader location: vector uniform: diffuse color
      #RL_SHADER_LOC_COLOR_SPECULAR       ;// Shader location: vector uniform: specular color
      #RL_SHADER_LOC_COLOR_AMBIENT        ;// Shader location: vector uniform: ambient color
      #RL_SHADER_LOC_MAP_ALBEDO           ;// Shader location: sampler2d texture: albedo (same As: RL_SHADER_LOC_MAP_DIFFUSE)
      #RL_SHADER_LOC_MAP_METALNESS        ;// Shader location: sampler2d texture: metalness (same As: RL_SHADER_LOC_MAP_SPECULAR)
      #RL_SHADER_LOC_MAP_NORMAL           ;// Shader location: sampler2d texture: normal
      #RL_SHADER_LOC_MAP_ROUGHNESS        ;// Shader location: sampler2d texture: roughness
      #RL_SHADER_LOC_MAP_OCCLUSION        ;// Shader location: sampler2d texture: occlusion
      #RL_SHADER_LOC_MAP_EMISSION         ;// Shader location: sampler2d texture: emission
      #RL_SHADER_LOC_MAP_HEIGHT           ;// Shader location: sampler2d texture: height
      #RL_SHADER_LOC_MAP_CUBEMAP          ;// Shader location: samplerCube texture: cubemap
      #RL_SHADER_LOC_MAP_IRRADIANCE       ;// Shader location: samplerCube texture: irradiance
      #RL_SHADER_LOC_MAP_PREFILTER        ;// Shader location: samplerCube texture: prefilter
      #RL_SHADER_LOC_MAP_BRDF             ;// Shader location: sampler2d texture: brdf
    EndEnumeration
    
    #RL_SHADER_LOC_MAP_DIFFUSE = #RL_SHADER_LOC_MAP_ALBEDO
    #RL_SHADER_LOC_MAP_SPECULAR = #RL_SHADER_LOC_MAP_METALNESS
    
    ;// Shader uniform Data type
    Enumeration rlShaderUniformDataType
      #RL_SHADER_UNIFORM_FLOAT = 0        ;// Shader uniform type: float
      #RL_SHADER_UNIFORM_VEC2             ;// Shader uniform type: vec2 (2 float)
      #RL_SHADER_UNIFORM_VEC3             ;// Shader uniform type: vec3 (3 float)
      #RL_SHADER_UNIFORM_VEC4             ;// Shader uniform type: vec4 (4 float)
      #RL_SHADER_UNIFORM_INT              ;// Shader uniform type: int
      #RL_SHADER_UNIFORM_IVEC2            ;// Shader uniform type: ivec2 (2 int)
      #RL_SHADER_UNIFORM_IVEC3            ;// Shader uniform type: ivec3 (3 int)
      #RL_SHADER_UNIFORM_IVEC4            ;// Shader uniform type: ivec4 (4 int)
      #RL_SHADER_UNIFORM_SAMPLER2D        ;// Shader uniform type: sampler2d
    EndEnumeration
    
    ;// Shader attribute Data types
    Enumeration rlShaderAttributeDataType
      #RL_SHADER_ATTRIB_FLOAT = 0         ;// Shader attribute type: float
      #RL_SHADER_ATTRIB_VEC2              ;// Shader attribute type: vec2 (2 float)
      #RL_SHADER_ATTRIB_VEC3              ;// Shader attribute type: vec3 (3 float)
      #RL_SHADER_ATTRIB_VEC4              ;// Shader attribute type: vec4 (4 float)
    EndEnumeration
    
    ;- Import "rlights.h"
    
    #MAX_LIGHTS = 4
    
    ;//----------------------------------------------------------------------------------
    ;// Types And Structures Definition
    ;//----------------------------------------------------------------------------------

    ;// Light Data
    Structure Light Align #PB_Structure_AlignC
      type.rl_int
      enabled.rl_bool
      position._Vector3
      target._Vector3
      color.rl_ColorLong
      attenuation.rl_float
    
      ;Shader locations
      enabledLoc.rl_int
      typeLoc.rl_int
      positionLoc.rl_int
      targetLoc.rl_int
      colorLoc.rl_int
      attenuationLoc.rl_int
    EndStructure

    ;// Light type
    Enumeration LightType
      #LIGHT_DIRECTIONAL = 0
      #LIGHT_POINT
    EndEnumeration
    
    ;//----------------------------------------------------------------------------------
    ;// Global Variables Definition
    ;//----------------------------------------------------------------------------------
    CompilerIf Not Defined(RL_LIGHTS_COUNT, #PB_Variable)
      Global.rl_int RL_LIGHTS_COUNT = 0      ; Current amount of created lights
    CompilerEndIf
    
;     ;- Import "libpartikel.h"
;     
;     Prototype.rl_bool protoDeactivator(*p)
;     
;     ;-Structure-Types
;     
;     ; Min/Max pair structs For various types.
;     Structure FloatRange Align #PB_Structure_AlignC
;       min.rl_float
;       max.rl_float
;     EndStructure
;     
;     Structure IntRange Align #PB_Structure_AlignC
;       min.rl_int
;       max.rl_int
;     EndStructure
;     
;     ; EmitterConfig type
;     Structure EmitterConfig Align #PB_Structure_AlignC
;       direction.Vector2                       ; Direction vector will be normalized.
;       velocity.FloatRange                     ; The possible range of the particle velocities.
;                                               ; Velocity is a scalar defining the length of the direction vector.
;       directionAngle.FloatRange               ; The angle range modiying the direction vector.
;       velocityAngle.FloatRange                ; The angle range to rotate the velocity vector.
;       offset.FloatRange                       ; The min and max offset multiplier for the particle origin.
;       originAcceleration.FloatRange           ; An acceleration towards or from (centrifugal) the origin.
;       burst.IntRange                          ; The range of sudden particle bursts.
;       capacity.rl_quad                        ; Maximum amounts of particles in the system.
;       emissionRate.rl_quad                    ; Rate of emitted particles per second.
;       origin.Vector2                          ; Origin is the source of the emitter.
;       externalAcceleration.Vector2            ; External constant acceleration. e.g. gravity.
;       startColor.rl_ColorLong                 ; The color the particle starts with when it spawns.
;       endColor.rl_ColorLong                   ; The color the particle ends with when it disappears.
;       age.FloatRange                          ; Age range of particles in seconds.
;       blendMode.rl_uint                       ; Color blending mode for all particles of this Emitter.
;       texture.Texture2D                       ; The texture used as particle texture.    
;       
;       *particle_Deactivator.protoDeactivator  ; Pointer to a function that determines when
;                                               ; a particle is deactivated.
;     EndStructure
;     
;     
;     ; Particle type
;     
;     ; Particle describes one particle in a particle system.
;     Structure Particle Align #PB_Structure_AlignC
;       origin.Vector2                          ; The origin of the particle (never changes).
;       position.Vector2                        ; Position of the particle in 2d space.
;       velocity.Vector2                        ; Velocity vector in 2d space.
;       externalAcceleration.Vector2            ; Acceleration vector in 2d space.
;       originAcceleration.rl_float             ; Accelerates velocity vector
;       age.rl_float                            ; Age is measured in seconds.
;       ttl.rl_float                            ; Ttl is the time to live in seconds.
;       active.rl_bool                          ; Inactive particles are neither updated nor drawn.
;       
;       *particle_Deactivator.protoDeactivator  ; Pointer To a function that determines when
;                                               ; a particle is deactivated.
;     EndStructure
;     
;     ; Emitter type.
;     
;     ; Emitter is a single (point) source emitting many particles.
;     Structure Emitter Align #PB_Structure_AlignC
;       config.EmitterConfig
;       mustEmit.rl_float             ; Amount of particles To be emitted within Next update call.
;       offset.Vector2                ; Offset holds half the width and height of the texture.
;       isEmitting.rl_bool
;       *particles.Particle   ; Array of all particles (by pointer).
;     EndStructure
;     
;     ; ParticleSystem type.
;     ;>----------------------------------------------------------------------------------
;     Structure ParticleSystem Align #PB_Structure_AlignC
;       active.rl_bool
;       length.rl_quad
;       capacity.rl_quad
;       origin.Vector2
;       *emitters.Emitter
;     EndStructure
    
    ;- ---------- Import Functions Start
    ;{ ---------- Import Functions Start
    
    ;-Callbacks
    ;// Callbacks To hook some internal functions
    ;// WARNING: This callbacks are intended For advance users
    ;typedef void (*TraceLogCallback)(int logLevel, const char *text, va_list args);  // Logging: Redirect trace log messages
    ;typedef unsigned char *(*LoadFileDataCallback)(const char *fileName, unsigned int *bytesRead);      // FileIO: Load binary data
    ;typedef Bool (*SaveFileDataCallback)(const char *fileName, void *Data, unsigned int bytesToWrite);  // FileIO: Save binary data
    ;typedef char *(*LoadFileTextCallback)(const char *fileName);            // FileIO: Load text data
    ;typedef Bool (*SaveFileTextCallback)(const char *fileName, char *text); // FileIO: Save text data
    
    ;// Callbacks To be implemented by users:
    PrototypeC TraceLogCallback(logType.rl_int, *text.Ascii)
    PrototypeC.i LoadFileDataCallback(*fileName.Ascii, *bytesRead.Long)
    PrototypeC.b SaveFileDataCallback(*fileName.Ascii, *in_data, bytesToWrite.rl_uint)
    PrototypeC.i LoadFileTextCallback(*fileName.Ascii)
    PrototypeC.b SaveFileTextCallback(*fileName.Ascii, *text.Ascii)
    
    ;// PureBasic example for using rlTraceLogCallback():
    CompilerIf 0
      
      ProcedureC MyCustomLogger( logType.rl_int, *text.Ascii )
        Protected msg.s
        If *text
          msg.s = PeekS(*text,-1,#PB_UTF8)
        EndIf
        Debug Str(logType)+": "+msg
      EndProcedure
      
      ray::SetTraceLogLevel(#LOG_ALL)
      ray::SetTraceLogCallback( @MyCustomLogger() )
      
    CompilerEndIf
    
    ; CHANGED FUNCTION NAMES:
    ;
    ;   GetClipboardText()          =>  GetClipboardTextRaylib()
    ;   SetClipboardText()          =>  SetClipboardTextRaylib()
    ;
    ;   CloseWindow()               =>  CloseWindowRaylib()
    ;   SetWindowTitle()            =>  SetWindowTitleRaylib()
    ;
    ;   SetWindowState              =>  SetWindowStateRayLib()
    ;
    ;   LoadImage()                 =>  LoadImageRaylib()
    ;   ImageFormat()               =>  ImageFormatRaylib()
    ;   LoadTexture()               =>  LoadTextureRaylib()
    ;   LoadFont()                  =>  LoadFontRaylib()
    ;   DrawText()                  =>  DrawTextRaylib()
    ;
    ;   LoadSound()                 =>  LoadSoundRaylib()
    ;   PlaySound()                 =>  PlaySoundRaylib()
    ;   StopSound()                 =>  StopSoundRaylib()
    ;   PauseSound()                =>  PauseSoundRaylib()
    ;   ResumeSound()               =>  ResumeSoundRaylib()
    ;
    
    ;-Config RayLib-Path
    ;No 32 bit, only 64bit Versions !!!
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
        #pbhelper_path = "bin/libraylib_win_pbhelper_x64.a"
        #raylib_path = "bin/libraylib_win_x64.lib"
        #ext_import = ""
      CompilerElse
        CompilerError "raylib for Windows: processor error"
      CompilerEndIf
      
    CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
        #pbhelper_path = "bin/libraylib_linux_pbhelper_amd64.a"
        #raylib_path = "bin/libraylib_linux_amd64.a"
        #ext_import = "-lc -lm -lpthread -ldl -lrt -lX11 -lXrandr -lXinerama -lXi -lXxf86vm -lXcursor -lGLESv2 -lglfw"
      CompilerElseIf #PB_Compiler_Processor = #PB_Processor_Arm64
        #pbhelper_path = "bin/libraylib_linux_pbhelper_arm64.a"
        #raylib_path = "bin/libraylib_linux_arm64.a"
        #ext_import = "-lc -lm -lpthread -ldl -lrt -lgbm -lEGL -lX11 -lXrandr -lXinerama -lXi -lXxf86vm -lXcursor -lGLESv2 -lGL -ldrm -lglut"
      CompilerElse
        CompilerError "raylib for Linux: processor error"
      CompilerEndIf
      
    CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
        #pbhelper_path = "bin/libraylib_macos_pbhelper_x64.a"
        #raylib_path = "bin/libraylib_macos_x64.a"
        #ext_import = "-framework AppKit -framework IOKit -framework OpenGL"
      CompilerElseIf #PB_Compiler_Processor = #PB_Processor_Arm64
        #pbhelper_path = "bin/libraylib_macos_pbhelper_arm64.a"
        #raylib_path = "bin/libraylib_macos_arm64.a"
        #ext_import = "-framework AppKit -framework IOKit -framework OpenGL"
      CompilerElse
        CompilerError "raylib for macOS: processor error"
      CompilerEndIf 
      
    CompilerEndIf
    
    ImportC #pbhelper_path
      ImportC #raylib_path
        ;//------------------------------------------------------------------------------------
        ;// Window and Graphics Device Functions (Module: core)
        ;//------------------------------------------------------------------------------------
        ;
        ;// Window-related functions
        InitWindow(width.rl_int, height.rl_int, title.p-utf8)                 RLAS(InitWindow)                  ;// Initialize window and OpenGL context
        WindowShouldClose.rl_bool()                                           RLAS(WindowShouldClose)           ;// Check if KEY_ESCAPE pressed or Close icon pressed
        CloseWindowRaylib()                                                   RLAS(CloseWindow)                 ;// Close window and unload OpenGL context
        IsWindowReady.rl_bool()                                               RLAS(IsWindowReady)               ;// Check if window has been initialized successfully
        IsWindowFullscreen.rl_bool()                                          RLAS(IsWindowFullscreen)          ;// Check if window is currently fullscreen
        IsWindowHidden.rl_bool()                                              RLAS(IsWindowHidden)              ;// Check if window is currently hidden
        IsWindowMinimized.rl_bool()                                           RLAS(IsWindowMinimized)           ;// Check if window has been minimized (or lost focus)
        IsWindowMaximized.rl_bool()                                           RLAS(IsWindowMaximized)           ;// Check if window is currently maximized (only PLATFORM_DESKTOP)
        IsWindowFocused.rl_bool()                                             RLAS(IsWindowFocused)             ;// Check if window is currently focused (only PLATFORM_DESKTOP)
        IsWindowResized.rl_bool()                                             RLAS(IsWindowResized)             ;// Check if window has been resized
        IsWindowState.rl_bool(flag.rl_uint)                                   RLAS(IsWindowState)               ;// Check if one specific window flag is enabled
        SetWindowStateRayLib(flags.rl_uint)                                   RLAS(SetWindowState)              ;// Set window configuration state using flags (only PLATFORM_DESKTOP)
        ClearWindowState(flags.rl_uint)                                       RLAS(ClearWindowState)            ;// Clear window configuration state flags
        ToggleFullscreen()                                                    RLAS(ToggleFullscreen)            ;// Toggle fullscreen mode (only PLATFORM_DESKTOP)
        MaximizeWindow()                                                      RLAS(MaximizeWindow)              ;// Set window state: maximized, if resizable (only PLATFORM_DESKTOP)
        MinimizeWindow()                                                      RLAS(MinimizeWindow)              ;// Set window state: minimized, if resizable (only PLATFORM_DESKTOP)
        RestoreWindow()                                                       RLAS(RestoreWindow)               ;// Set window state: not minimized/maximized (only PLATFORM_DESKTOP)
        SetWindowIcon(*in_image.ray::Image)                                 __PBAS(SetWindowIcon)               ;// Set icon for window (only PLATFORM_DESKTOP)
        SetWindowTitleRaylib(title.p-utf8)                                    RLAS(SetWindowTitle)              ;// Set title for window (only PLATFORM_DESKTOP)
        SetWindowPosition(x.rl_int, y.rl_int)                                 RLAS(SetWindowPosition)           ;// Set window position on screen (only PLATFORM_DESKTOP)
        SetWindowMonitor(monitor.rl_int)                                      RLAS(SetWindowMonitor)            ;// Set monitor for the current window (fullscreen mode)
        SetWindowMinSize(width.rl_int, height.rl_int)                         RLAS(SetWindowMinSize)            ;// Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE)
        SetWindowSize(width.rl_int, height.rl_int)                            RLAS(SetWindowSize)               ;// Set window dimensions
        SetWindowOpacity(opacity.rl_float)                                    RLAS(SetWindowOpacity)            ;// Set window opacity [0.0f..1.0f] (only PLATFORM_DESKTOP)
        GetWindowHandle.i()                                                   RLAS(GetWindowHandle)             ;// Get native window handle
        GetScreenWidth.rl_int()                                               RLAS(GetScreenWidth)              ;// Get current screen width
        GetScreenHeight.rl_int()                                              RLAS(GetScreenHeight)             ;// Get current screen height
        GetRenderWidth.rl_int()                                               RLAS(GetRenderWidth)              ;// Get current render width (it considers HiDPI)
        GetRenderHeight.rl_int()                                              RLAS(GetRenderHeight)             ;// Get current render height (it considers HiDPI)
        GetMonitorCount.rl_int()                                              RLAS(GetMonitorCount)             ;// Get number of connected monitors
        GetCurrentMonitor.rl_int()                                            RLAS(GetCurrentMonitor)           ;// Get current connected monitor
        GetMonitorPosition(*out_monitor_pos.ray::Vector2, 
                           monitor.rl_int)                                  __PBAS(GetMonitorPosition)          ;// Get specified monitor position
        GetMonitorWidth.rl_int(monitor.rl_int)                                RLAS(GetMonitorWidth)             ;// Get primary monitor width
        GetMonitorHeight.rl_int(monitor.rl_int)                               RLAS(GetMonitorHeight)            ;// Get primary monitor height
        GetMonitorPhysicalWidth.rl_int(monitor.rl_int)                        RLAS(GetMonitorPhysicalWidth)     ;// Get primary monitor physical width in millimetres
        GetMonitorPhysicalHeight.rl_int(monitor.rl_int)                       RLAS(GetMonitorPhysicalHeight)    ;// Get primary monitor physical height in millimetres
        GetMonitorRefreshRate.rl_int(monitor.rl_int)                          RLAS(GetMonitorRefreshRate)       ;// Get specified monitor refresh rate
        GetWindowPosition(*out_result.ray::Vector2)                         __PBAS(GetWindowPosition)           ;// Get window position XY on monitor
        GetWindowScaleDPI(*out_result.ray::Vector2)                         __PBAS(GetWindowScaleDPI)           ;// Get window scale DPI factor
        __GetMonitorName.i(monitor.rl_int)                                    RLAS(GetMonitorName)              ;// Get the human-readable, UTF-8 encoded name of the primary monitor
        SetClipboardTextRaylib(text.p-utf8)                                   RLAS(SetClipboardText)            ;// Set clipboard text content
        __GetClipboardTextRaylib.i()                                          RLAS(GetClipboardText)            ;// Get clipboard text content
        EnableEventWaiting()                                                  RLAS(EnableEventWaiting)          ;// Enable waiting for events on EndDrawing(), no automatic event polling
        DisableEventWaiting()                                                 RLAS(DisableEventWaiting)         ;// Disable waiting for events on EndDrawing(), automatic events polling
        
        ;// Custom frame control functions
        ;// NOTE: Those functions are intended For advance users that want full control over the frame processing
        ;// By Default EndDrawing() does this job: draws everything + SwapScreenBuffer() + manage frame timming + PollInputEvents()
        ;// To avoid that behaviour And control frame processes manually, enable in config.h: SUPPORT_CUSTOM_FRAME_CONTROL
        SwapScreenBuffer()                                                    RLAS(SwapScreenBuffer)            ;// Swap back buffer With front buffer (screen drawing)
        PollInputEvents()                                                     RLAS(PollInputEvents)             ;// Register all input events
        WaitTime(seconds.rl_double)                                           RLAS(WaitTime)                    ;// Wait For some time (halt program execution)
        
        ;// Cursor-related functions
        ShowCursor()                                                          RLAS(ShowCursor)                  ;// Shows cursor
        HideCursor()                                                          RLAS(HideCursor)                  ;// Hides cursor
        IsCursorHidden.rl_bool()                                              RLAS(IsCursorHidden)              ;// Check if cursor is not visible
        EnableCursor()                                                        RLAS(EnableCursor)                ;// Enables cursor (unlock cursor)
        DisableCursor()                                                       RLAS(DisableCursor)               ;// Disables cursor (lock cursor)
        IsCursorOnScreen.rl_bool()                                            RLAS(IsCursorOnScreen)            ;// Check if cursor is on the screen
        
        ;// Drawing-related functions
        ClearBackground(color.rl_ColorLong)                                   RLAS(ClearBackground)             ;// Set background color (framebuffer clear color)
        BeginDrawing()                                                        RLAS(BeginDrawing)                ;// Setup canvas (framebuffer) to start drawing
        EndDrawing()                                                          RLAS(EndDrawing)                  ;// End canvas drawing and swap buffers (double buffering)
        BeginMode2D(*in_camera2d.ray::Camera2D)                             __PBAS(BeginMode2D)                 ;// Initialize 2D mode with custom camera (2D)
        EndMode2D()                                                           RLAS(EndMode2D)                   ;// Ends 2D mode with custom camera
        BeginMode3D(*in_camera3d.ray::Camera3D)                             __PBAS(BeginMode3D)                 ;// Initializes 3D mode with custom camera (3D)
        EndMode3D()                                                           RLAS(EndMode3D)                   ;// Ends 3D mode and returns to default 2D orthographic mode
        BeginTextureMode(*in_target.ray::RenderTexture2D)                   __PBAS(BeginTextureMode)            ;// Initializes render texture for drawing
        EndTextureMode()                                                      RLAS(EndTextureMode)              ;// Ends drawing to render texture
        BeginShaderMode(*shader.ray::Shader)                                __PBAS(BeginShaderMode)             ;// Begin custom shader drawing
        EndShaderMode()                                                       RLAS(EndShaderMode)               ;// End custom shader drawing (use Default shader)
        BeginBlendMode(mode.rl_int)                                           RLAS(BeginBlendMode)              ;// Begin blending mode (alpha, additive, multiplied, subtract, custom)
        EndBlendMode()                                                        RLAS(EndBlendMode)                ;// End blending mode (reset To Default: alpha blending)
        BeginScissorMode(x.rl_int, y.rl_int,
                         width.rl_int, height.rl_int)                         RLAS(BeginScissorMode)            ;// Begin scissor mode (define screen area for following drawing)
        EndScissorMode()                                                      RLAS(EndScissorMode)              ;// End scissor mode
        BeginVrStereoMode(*config.ray::VrStereoConfig)                      __PBAS(BeginVrStereoMode)           ;// Begin stereo rendering (requires VR simulator)
        EndVrStereoMode()                                                     RLAS(EndVrStereoMode)             ;// End stereo rendering (requires VR simulator)
        
        ;// VR stereo config functions for VR simulator
        LoadVrStereoConfig(*out_result.ray::VrStereoConfig, 
                           *device.ray::VrDeviceInfo)                       __PBAS(LoadVrStereoConfig)          ;// Load VR stereo config For VR simulator device parameters
        UnloadVrStereoConfig(*config.ray::VrStereoConfig)                   __PBAS(UnloadVrStereoConfig)        ;// Unload VR stereo config
        
        ;// Shader management functions
        ;// NOTE: Shader functionality is Not available on OpenGL 1.1
        LoadShader(*out_result.ray::Shader, vsFileName.p-utf8, 
                   fsFileName.p-utf8)                                       __PBAS(LoadShader)                  ;// Load shader from files And bind Default locations
        LoadShaderFromMemory(*out_result.ray::Shader, vsCode.p-utf8, 
                             fsCode.p-utf8)                                 __PBAS(LoadShaderFromMemory)        ;// Load shader from code strings And bind Default locations
        GetShaderLocation.rl_int(*in_shader.ray::Shader, 
                                 uniformName.p-utf8)                        __PBAS(GetShaderLocation)           ;// Get shader uniform location
        GetShaderLocationAttrib.rl_int(*in_shader.ray::Shader, 
                                       attribName.p-utf8)                   __PBAS(GetShaderLocationAttrib)     ;// Get shader attribute location
        SetShaderValue(*in_shader.ray::Shader, locIndex.rl_int, *value, 
                       uniformType.rl_int)                                  __PBAS(SetShaderValue)              ;// Set shader uniform value
        SetShaderValueV(*in_shader.ray::Shader, locIndex.rl_int, *value, 
                        uniformType.rl_int, count.rl_int)                   __PBAS(SetShaderValueV)             ;// Set shader uniform value vector
        SetShaderValueMatrix(*in_shader.ray::Shader, locIndex.rl_int, 
                             *mat.ray::Matrix)                              __PBAS(SetShaderValueMatrix)        ;// Set shader uniform value (matrix 4x4)
        SetShaderValueTexture(*in_shader.ray::Shader, locIndex.rl_int, 
                              *in_texture.ray::Texture2D)                   __PBAS(SetShaderValueTexture)       ;// Set shader uniform value For texture (sampler2d)
        UnloadShader(*in_shader.ray::Shader)                                __PBAS(UnloadShader)                ;// Unload shader from GPU memory (VRAM)
        
        ;// Screen-space-related functions
        GetMouseRay(*out_result.ray::Ray, *in_mousePosition.ray::Vector2,
                    *in_camera.ray::Camera)                                 __PBAS(GetMouseRay)                 ;// Returns a ray trace from mouse position
        GetCameraMatrix(*out_result.ray::Matrix, *in_camera.ray::Camera)    __PBAS(GetCameraMatrix)             ;// Returns camera transform matrix (view matrix)
        GetCameraMatrix2D(*out_result.ray::Matrix,*in_camera.ray::Camera2D) __PBAS(GetCameraMatrix2D)           ;// Returns camera 2d transform matrix
        GetWorldToScreen(*out_result.ray::Vector2, *in_position.ray::_Vector3,
                         *in_camera.ray::Camera)                            __PBAS(GetWorldToScreen)            ;// Returns the screen space position for a 3d world space position
        GetScreenToWorld2D(*out_result.ray::Vector2, *in_position.ray::Vector2,
                           *in_camera.ray::Camera2D)                        __PBAS(GetScreenToWorld2D)          ;// Returns the world space position for a 2d camera screen space position
        GetWorldToScreenEx(*out_result.ray::Vector2, *in_position.ray::_Vector3,
                           *in_camera.ray::Camera,
                           width.rl_int, height.rl_int)                     __PBAS(GetWorldToScreenEx)          ;// Returns size position for a 3d world space position
        GetWorldToScreen2D(*out_result.ray::Vector2, *in_position.ray::Vector2,
                           *in_camera.ray::Camera2D)                        __PBAS(GetWorldToScreen2D)          ;// Returns the screen space position for a 2d camera world space position
        
        ;// Timing-related functions
        SetTargetFPS(fps.rl_int)                                              RLAS(SetTargetFPS)                ;// Set target FPS (maximum)
        GetFPS.rl_int()                                                       RLAS(GetFPS)                      ;// Returns current FPS
        GetFrameTime.rl_float()                                               RLAS(GetFrameTime)                ;// Returns time in seconds for last frame drawn
        GetTime.rl_double()                                                   RLAS(GetTime)                     ;// Returns elapsed time in seconds since InitWindow()
        
        ;// Misc. functions
        GetRandomValue.rl_int(min.rl_int, max.rl_int)                         RLAS(GetRandomValue)              ;// Returns a random value between min and max (both included)
        SetRandomSeed(seed.rl_uint)                                           RLAS(SetRandomSeed)               ;// Set the seed for the random number generator               
        TakeScreenshot(fileName.p-utf8)                                       RLAS(TakeScreenshot)              ;// Takes a screenshot of current screen (filename extension defines format)
        SetConfigFlags(flags.rl_uint)                                         RLAS(SetConfigFlags)              ;// Setup init configuration flags (view FLAGS)
        
        TraceLog(logType.rl_int, text.p-utf8)                                 RLAS(TraceLog)                    ;// Show trace log messages (LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR)
        SetTraceLogLevel(logType.rl_int)                                      RLAS(SetTraceLogLevel)            ;// Set the current threshold (minimum) log level
        
        OpenURL(url.p-utf8)                                                   RLAS(OpenURL)                     ;// Open URL with default system browser (if available)
        
        ;// Set custom callbacks
        ;// WARNING: Callbacks setup is intended For advance users
        SetTraceLogCallback(*callback.ray::TraceLogCallback)                __PBAS(SetTraceLogCallback)         ;// Set a trace log callback to enable custom logging                                             
        SetLoadFileDataCallback(*callback.ray::LoadFileDataCallback)          RLAS(SetLoadFileDataCallback)     ;// Set custom file binary data loader
        SetSaveFileDataCallback(*callback.ray::SaveFileDataCallback)          RLAS(SetSaveFileDataCallback)     ;// Set custom file binary data saver
        SetLoadFileTextCallback(*callback.ray::LoadFileTextCallback)          RLAS(SetLoadFileTextCallback)     ;// Set custom file text data loader
        SetSaveFileTextCallback(*callback.ray::SaveFileTextCallback)          RLAS(SetSaveFileTextCallback)     ;// Set custom file text data saver
        
        ;// Files management functions
        LoadFileData.i(fileName.p-utf8, *bytesRead.Long)                      RLAS(LoadFileData)                ;// Load file data as byte array (read)
        UnloadFileData(*p_data)                                               RLAS(UnloadFileData)              ;// Unload file Data allocated by LoadFileData()
        SaveFileData.rl_bool(fileName.p-utf8, *p_data, bytesToWrite.rl_uint)  RLAS(SaveFileData)                ;// Save data to file from byte array (write)
        ExportDataAsCode.rl_bool(*p_data, size.rl_uint, fileName.p-utf8)      RLAS(ExportDataAsCode)            ;// Export data to code (.h), returns true on success
        __LoadFileText.i(fileName.p-utf8)                                     RLAS(LoadFileText)                ;// Load text data from file (read), returns a '\0' terminated string
        UnloadFileText(*p_text.ascii)                                         RLAS(UnloadFileText)              ;// Unload file text data allocated by LoadFileText()
        SaveFileText(fileName.p-utf8, text.p-utf8)                            RLAS(SaveFileText)                ;// Save text data to file (write), string must be '\0' terminated
        FileExists.rl_bool(fileName.p-utf8)                                   RLAS(FileExists)                  ;// Check if file exists
        DirectoryExists.rl_bool(dirPath.p-utf8)                               RLAS(DirectoryExists)             ;// Check if a directory path exists
        IsFileExtension.rl_bool(fileName.p-utf8, ext.p-utf8)                  RLAS(IsFileExtension)             ;// Check file extension
        GetFileLength.rl_int(fileName.p-utf8)                                 RLAS(GetFileLength)               ;// Get file length in bytes (NOTE: GetFileSize() conflicts with windows.h)
        
        __GetFileExtension.i(fileName.p-utf8)                                 RLAS(GetFileExtension)            ;// Get pointer to extension for a filename string
        __GetFileName.i(filePath.p-utf8)                                      RLAS(GetFileName)                 ;// Get pointer to filename for a path string
        __GetFileNameWithoutExt.i(filePath.p-utf8)                            RLAS(GetFileNameWithoutExt)       ;// Get filename string without extension (uses static string)
        __GetDirectoryPath.i(filePath.p-utf8)                                 RLAS(GetDirectoryPath)            ;// Get full path for a given fileName with path (uses static string)
        __GetPrevDirectoryPath.i(dirPath.p-utf8)                              RLAS(GetPrevDirectoryPath)        ;// Get previous directory path for a given path (uses static string)
        __GetWorkingDirectory.i()                                             RLAS(GetWorkingDirectory)         ;// Get current working directory (uses static string)
        __GetApplicationDirectory.i()
        
        ChangeDirectory.rl_bool(dir.p-utf8)                                   RLAS(ChangeDirectory)             ;// Change working directory, returns true if success
        IsPathFile.rl_bool(path.p-utf8)                                       RLAS(IsPathFile)                  ;// Check if a given path is a file or a directory
        
        LoadDirectoryFiles(*out_result.ray::FilePathList, dirPath.p-utf8)   __PBAS(LoadDirectoryFiles)          ;// Load directory filepaths
        LoadDirectoryFilesEx(*out_result.ray::FilePathList, basePath.p-utf8, 
                             filter.p-utf8, scanSubdirs.rl_bool)            __PBAS(LoadDirectoryFilesEx)        ;// Load directory filepaths with extension filtering and recursive directory scan
        
        UnloadDirectoryFiles(*in_files.ray::FilePathList)                   __PBAS(UnloadDirectoryFiles)        ;// Unload filepaths
        
        IsFileDropped.rl_bool()                                               RLAS(IsFileDropped)               ;// Check if a file has been dropped into window
        LoadDroppedFiles(*out_result.ray::FilePathList)                     __PBAS(LoadDroppedFiles)            ;// Load dropped filepaths
        UnloadDroppedFiles(*in_files.ray::FilePathList)                       RLAS(UnloadDroppedFiles)          ;// Unload dropped filepaths
        
        GetFileModTime.rl_long(fileName.p-utf8)                               RLAS(GetFileModTime)              ;// Get file modification time (last write time)
        
        ;// Compression/Encoding functionality
        CompressData.i(*in_data, dataLength.rl_int, *compDataLength.Long)     RLAS(CompressData)                ;// Compress data (DEFLATE algorythm)
        DecompressData.i(*in_compData,compDataLength.rl_int,*dataLength.Long) RLAS(DecompressData)              ;// Decompress data (DEFLATE algorythm)
        EncodeDataBase64.i(*in_data, dataSize.rl_int, *outputSize.Long)       RLAS(EncodeDataBase64)            ;// Encode data to Base64 string, memory must be MemFree()
        DecodeDataBase64.i(*in_data, *outputSize.Long)                        RLAS(DecodeDataBase64)            ;// Decode Base64 string data, memory must be MemFree()
        
        ;//------------------------------------------------------------------------------------
        ;// Input Handling Functions (Module: core)
        ;//------------------------------------------------------------------------------------
        
        ;// Input-related functions: keyboard
        IsKeyPressed.rl_bool(key.rl_int)                                      RLAS(IsKeyPressed)                ;// Detect if a key has been pressed once
        IsKeyDown.rl_bool(key.rl_int)                                       __PBAS(IsKeyDown)                   ;// Detect if a key is being pressed
        IsKeyReleased.rl_bool(key.rl_int)                                     RLAS(IsKeyReleased)               ;// Detect if a key has been released once
        IsKeyUp.rl_bool(key.rl_int)                                         __PBAS(IsKeyUp)                     ;// Detect if a key is NOT being pressed
        SetExitKey(key.rl_int)                                                RLAS(SetExitKey)                  ;// Set a custom key to exit program (default is ESC)
        GetKeyPressed.rl_int()                                                RLAS(GetKeyPressed)               ;// Get key pressed, call it multiple times for chars queued
        GetCharPressed.rl_int()                                               RLAS(GetCharPressed)              ;// Get char pressed (unicode), call it multiple times for chars queued, returns 0 when the queue is empty
        
        ;// Input-related functions: gamepads
        IsGamepadAvailable.rl_bool(gamepad.rl_int)                            RLAS(IsGamepadAvailable)          ;// Detect if a gamepad is available
        __GetGamepadName(gamepad.rl_int)                                      RLAS(GetGamepadName)              ;// Return gamepad internal name id
        IsGamepadButtonPressed.rl_bool(gamepad.rl_int, button.rl_int)         RLAS(IsGamepadButtonPressed)      ;// Detect if a gamepad button has been pressed once
        IsGamepadButtonDown.rl_bool(gamepad.rl_int, button.rl_int)            RLAS(IsGamepadButtonDown)         ;// Detect if a gamepad button is being pressed
        IsGamepadButtonReleased.rl_bool(gamepad.rl_int, button.rl_int)        RLAS(IsGamepadButtonReleased)     ;// Detect if a gamepad button has been released once
        IsGamepadButtonUp.rl_bool(gamepad.rl_int, button.rl_int)              RLAS(IsGamepadButtonUp)           ;// Detect if a gamepad button is NOT being pressed
        GetGamepadButtonPressed.rl_int()                                      RLAS(GetGamepadButtonPressed)     ;// Get the last gamepad button pressed
        GetGamepadAxisCount.rl_int(gamepad.rl_int)                            RLAS(GetGamepadAxisCount)         ;// Return gamepad axis count for a gamepad
        GetGamepadAxisMovement.rl_float(gamepad.rl_int, axis.rl_int)          RLAS(GetGamepadAxisMovement)      ;// Return axis movement value for a gamepad axis
        SetGamepadMappings.rl_int(mappings.p-utf8)                            RLAS(SetGamepadMappings)          ;// Set internal gamepad mappings (SDL_GameControllerDB)
        
        ;// Input-related functions: mouse
        IsMouseButtonPressed.rl_bool(button.rl_int)                           RLAS(IsMouseButtonPressed)        ;// Detect if a mouse button has been pressed once
        IsMouseButtonDown.rl_bool(button.rl_int)                            __PBAS(IsMouseButtonDown)           ;// Detect if a mouse button is being pressed
        IsMouseButtonReleased.rl_bool(button.rl_int)                          RLAS(IsMouseButtonReleased)       ;// Detect if a mouse button has been released once
        IsMouseButtonUp.rl_bool(button.rl_int)                              __PBAS(IsMouseButtonUp)             ;// Detect if a mouse button is NOT being pressed
        GetMouseX.rl_int()                                                    RLAS(GetMouseX)                   ;// Returns mouse position X
        GetMouseY.rl_int()                                                    RLAS(GetMouseY)                   ;// Returns mouse position Y
        GetMousePosition(*out_result.ray::Vector2)                          __PBAS(GetMousePosition)            ;// Returns mouse position XY
        GetMouseDelta(*out_result.ray::Vector2)                             __PBAS(GetMouseDelta)               ;// Get mouse delta between frames
        SetMousePosition(x.rl_int, y.rl_int)                                  RLAS(SetMousePosition)            ;// Set mouse position XY
        SetMouseOffset(offsetX.rl_int, offsetY.rl_int)                        RLAS(SetMouseOffset)              ;// Set mouse offset
        SetMouseScale(scaleX.rl_float, scaleY.rl_float)                       RLAS(SetMouseScale)               ;// Set mouse scaling
        GetMouseWheelMove.rl_float()                                          RLAS(GetMouseWheelMove)           ;// Get mouse wheel movement for X or Y, whichever is larger
        GetMouseWheelMoveV(*out_result.ray::Vector2)                        __PBAS(GetMouseWheelMoveV)          ;// Get mouse wheel movement for both X and Y
        SetMouseCursor(cursor.rl_int)                                         RLAS(SetMouseCursor)              ;// Set mouse cursor
        
        ;// Input-related functions: touch
        GetTouchX.rl_int()                                                    RLAS(GetTouchX)                   ;// Returns touch position X for touch point 0 (relative to screen size)
        GetTouchY.rl_int()                                                    RLAS(GetTouchY)                   ;// Returns touch position Y for touch point 0 (relative to screen size)
        GetTouchPosition(*out_result.ray::Vector2, index.rl_int)            __PBAS(GetTouchPosition)            ;// Returns touch position XY for a touch point index (relative to screen size)
        GetTouchPointId.rl_int(index.rl_int)                                  RLAS(GetTouchPointId)             ;// Get touch point identifier for given index
        GetTouchPointCount.rl_int()                                           RLAS(GetTouchPointCount)          ;// Get number of touch points
        
        ;//------------------------------------------------------------------------------------
        ;// Gestures and Touch Handling Functions (Module: gestures)
        ;//------------------------------------------------------------------------------------
        SetGesturesEnabled(gestureFlags.rl_uint)                              RLAS(SetGesturesEnabled)          ;// Enable a set of gestures using flags
        IsGestureDetected.rl_bool(gesture.rl_int)                             RLAS(IsGestureDetected)           ;// Check if a gesture have been detected
        GetGestureDetected.rl_int()                                           RLAS(GetGestureDetected)          ;// Get latest detected gesture
        GetGestureHoldDuration.rl_float()                                     RLAS(GetGestureHoldDuration)      ;// Get gesture hold time in milliseconds
        GetGestureDragVector(*out_result.ray::Vector2)                      __PBAS(GetGestureDragVector)        ;// Get gesture drag vector
        GetGestureDragAngle.rl_float()                                        RLAS(GetGestureDragAngle)         ;// Get gesture drag angle
        GetGesturePinchVector(*out_result.ray::Vector2)                     __PBAS(GetGesturePinchVector)       ;// Get gesture pinch delta
        GetGesturePinchAngle.rl_float()                                       RLAS(GetGesturePinchAngle)        ;// Get gesture pinch angle
        
        ;//------------------------------------------------------------------------------------
        ;// Camera System Functions (Module: camera)
        ;//------------------------------------------------------------------------------------
        SetCameraMode(*in_camera.ray::Camera, cameraMode.rl_int)            __PBAS(SetCameraMode)               ;// Set camera mode (multiple camera modes available)
        UpdateCamera(*inout_camera.ray::Camera)                               RLAS(UpdateCamera)                ;// Update camera position for selected mode
        
        SetCameraPanControl(panKey.rl_int)                                    RLAS(SetCameraPanControl)         ;// Set camera pan key to combine with mouse movement (free camera)
        SetCameraAltControl(altKey.rl_int)                                    RLAS(SetCameraAltControl)         ;// Set camera alt key to combine with mouse movement (free camera)
        SetCameraSmoothZoomControl(szKey.rl_int)                              RLAS(SetCameraSmoothZoomControl)  ;// Set camera smooth zoom key to combine with mouse (free camera)
        SetCameraMoveControls( frontKey.rl_int, backKey.rl_int,
                               rightKey.rl_int, leftKey.rl_int,
                               upKey.rl_int   , downKey.rl_int )              RLAS(SetCameraMoveControls)       ;// Set camera move controls (1st person and 3rd person cameras)
        
        ;//------------------------------------------------------------------------------------
        ;// Basic Shapes Drawing Functions (Module: shapes)
        ;//------------------------------------------------------------------------------------
        SetShapesTexture(*in_texture.ray::Texture2D, 
                         *source.ray::Rectangle)                            __PBAS(SetShapesTexture)            ;// Set texture and rectangle to be used on shapes drawing  
        
        ;// Basic shapes drawing functions
        DrawPixel(posX.rl_int, posY.rl_int, color.rl_ColorLong)               RLAS(DrawPixel)                   ;// Draw a pixel
        DrawPixelV(*in_position.ray::Vector2, color.rl_ColorLong)           __PBAS(DrawPixelV)                  ;// Draw a pixel (Vector version)
        DrawLine(startPosX.rl_int, startPosY.rl_int,
                 endPosX.rl_int  , endPosY.rl_int  , color.rl_ColorLong)      RLAS(DrawLine)                    ;// Draw a line
        DrawLineV(*in_startPos.ray::Vector2, *in_endPos.ray::Vector2,
                  color.rl_ColorLong)                                       __PBAS(DrawLineV)                   ;// Draw a line (Vector version)
        DrawLineEx(*in_startPos.ray::Vector2, *in_endPos.ray::Vector2,
                   thick.rl_float, color.rl_ColorLong)                      __PBAS(DrawLineEx)                  ;// Draw a line defining thickness
        DrawLineBezier(*in_startPos.ray::Vector2, *in_endPos.ray::Vector2,
                       thick.rl_float, color.rl_ColorLong)                  __PBAS(DrawLineBezier)              ;// Draw a line using cubic-bezier curves in-out
        DrawLineBezierQuad(*in_startPos.ray::Vector2, *in_endPos.ray::Vector2, 
                           *controlPos.ray::Vector2, thick.rl_float, 
                           color.rl_ColorLong)                              __PBAS(DrawLineBezierQuad)          ;// Draw line using quadratic bezier curves with a control point
        DrawLineBezierCubic(*in_startPos.ray::Vector2, *in_endPos.ray::Vector2, 
                            *startControlPos.ray::Vector2, *endControlPos.ray::Vector2, 
                            thick.rl_float, color.rl_ColorLong)             __PBAS(DrawLineBezierCubic)         ;// Draw line using cubic bezier curves with 2 control points
        DrawLineStrip(*in_pointsArray.ray::Vector2, numPoints.rl_int,
                      color.rl_ColorLong)                                     RLAS(DrawLineStrip)               ;// Draw lines sequence
        DrawCircle(centerX.rl_int , centerY.rl_int,
                   radius.rl_float, color.rl_ColorLong)                       RLAS(DrawCircle)                  ;// Draw a color-filled circle
        DrawCircleSector(*in_center.ray::Vector2, radius.rl_float,
                         startAngle.rl_int, endAngle.rl_int,
                         segments.rl_int, color.rl_ColorLong)               __PBAS(DrawCircleSector)            ;// Draw a piece of a circle
        DrawCircleSectorLines(*in_center.ray::Vector2, radius.rl_float,
                              startAngle.rl_int, endAngle.rl_int,
                              segments.rl_int, color.rl_ColorLong)          __PBAS(DrawCircleSectorLines)       ;// Draw circle sector outline
        DrawCircleGradient(centerX.rl_int, centerY.rl_int, radius.rl_float,
                           color1.rl_ColorLong, color2.rl_ColorLong)          RLAS(DrawCircleGradient)          ;// Draw a gradient-filled circle
        DrawCircleV(*in_center.ray::Vector2, radius.rl_float,
                    color.rl_ColorLong)                                     __PBAS(DrawCircleV)                 ;// Draw a color-filled circle (Vector version)
        DrawCircleLines(centerX.rl_int , centerY.rl_int,
                        radius.rl_float, color.rl_ColorLong)                  RLAS(DrawCircleLines)             ;// Draw circle outline
        DrawEllipse(centerX.rl_int  , centerY.rl_int  ,
                    radiusH.rl_float, radiusV.rl_float, color.rl_ColorLong)   RLAS(DrawEllipse)                 ;// Draw ellipse
        DrawEllipseLines(centerX.rl_int  , centerY.rl_int  ,
                         radiusH.rl_float, radiusV.rl_float,
                         color.rl_ColorLong)                                  RLAS(DrawEllipseLines)            ;// Draw ellipse outline
        DrawRing(*in_center.ray::Vector2,
                 innerRadius.rl_float, outerRadius.rl_float,
                 startAngle.rl_int, endAngle.rl_int,
                 segments.rl_int, color.rl_ColorLong)                       __PBAS(DrawRing)                    ;// Draw ring
        DrawRingLines(*in_center.ray::Vector2,
                      innerRadius.rl_float, outerRadius.rl_float,
                      startAngle.rl_int, endAngle.rl_int,
                      segments.rl_int, color.rl_ColorLong)                  __PBAS(DrawRingLines)               ;// Draw ring outline
        DrawRectangle(posX.rl_int, posY.rl_int, width.rl_int, height.rl_int,
                      color.rl_ColorLong)                                     RLAS(DrawRectangle)               ;// Draw a color-filled rectangle
        DrawRectangleV(*in_position.ray::Vector2, *in_size.ray::Vector2,
                       color.rl_ColorLong)                                  __PBAS(DrawRectangleV)              ;// Draw a color-filled rectangle (Vector version)
        DrawRectangleRec(*in_rect.ray::Rectangle, color.rl_ColorLong)       __PBAS(DrawRectangleRec)            ;// Draw a color-filled rectangle
        DrawRectanglePro(*in_rect.ray::Rectangle, *in_origin.ray::Vector2,
                         rotation.rl_float, color.rl_ColorLong)             __PBAS(DrawRectanglePro)            ;// Draw a color-filled rectangle with pro parameters
        DrawRectangleGradientV(posX.rl_int , posY.rl_int  ,
                               width.rl_int, height.rl_int,
                               color1.rl_ColorLong, color2.rl_ColorLong)      RLAS(DrawRectangleGradientV)      ;// Draw a vertical-gradient-filled rectangle
        DrawRectangleGradientH(posX.rl_int , posY.rl_int  ,
                               width.rl_int, height.rl_int,
                               color1.rl_ColorLong, color2.rl_ColorLong)      RLAS(DrawRectangleGradientH)      ;// Draw a horizontal-gradient-filled rectangle
        DrawRectangleGradientEx(*in_rect.ray::Rectangle,
                                col1.rl_ColorLong, col2.rl_ColorLong,
                                col3.rl_ColorLong, col4.rl_ColorLong)       __PBAS(DrawRectangleGradientEx)     ;// Draw a gradient-filled rectangle with custom vertex colors
        DrawRectangleLines(posX.rl_int , posY.rl_int  ,
                           width.rl_int, height.rl_int, color.rl_ColorLong)   RLAS(DrawRectangleLines)          ;// Draw rectangle outline
        DrawRectangleLinesEx(*in_rect.ray::Rectangle, lineThick.rl_int,
                             color.rl_ColorLong)                            __PBAS(DrawRectangleLinesEx)        ;// Draw rectangle outline with extended parameters
        DrawRectangleRounded(*in_rect.ray::Rectangle, roundness.rl_float,
                             segments.rl_int, color.rl_ColorLong)           __PBAS(DrawRectangleRounded)        ;// Draw rectangle with rounded edges
        DrawRectangleRoundedLines(*in_rect.ray::Rectangle,
                                  roundness.rl_float, segments.rl_int,
                                  lineThick.rl_int, color.rl_ColorLong)     __PBAS(DrawRectangleRoundedLines)   ;// Draw rectangle with rounded edges outline
        DrawTriangle(*in_v1.ray::Vector2, *in_v2.ray::Vector2,
                     *in_v3.ray::Vector2, color.rl_ColorLong)               __PBAS(DrawTriangle)                ;// Draw a color-filled triangle (vertex in counter-clockwise order!)
        DrawTriangleLines(*in_v1.ray::Vector2, *in_v2.ray::Vector2,
                          *in_v3.ray::Vector2, color.rl_ColorLong)          __PBAS(DrawTriangleLines)           ;// Draw triangle outline (vertex in counter-clockwise order!)
        DrawTriangleFan(*in_pointsArray.ray::Vector2, numPoints.rl_int,
                        color.rl_ColorLong)                                   RLAS(DrawTriangleFan)             ;// Draw a triangle fan defined by points (first vertex is the center)
        DrawTriangleStrip(*in_pointsArray.ray::Vector2, pointsCount.rl_int,
                          color.rl_ColorLong)                                 RLAS(DrawTriangleStrip)           ;// Draw a triangle strip defined by points
        DrawPoly(*in_center.ray::Vector2, sides.rl_int, radius.rl_float,
                 rotation.rl_float, color.rl_ColorLong)                     __PBAS(DrawPoly)                    ;// Draw a regular polygon (Vector version)
        DrawPolyLines(*in_center.ray::Vector2, sides.rl_int, radius.rl_float,
                      rotation.rl_float, color.rl_ColorLong)                __PBAS(DrawPolyLines)               ;// Draw a polygon outline of n sides
        DrawPolyLinesEx(*in_center, sides.rl_int, radius.rl_float, 
                        rotation.rl_float, lineThick.rl_float, 
                        color.rl_ColorLong)                                 __PBAS(DrawPolyLinesEx)             ;// Draw a polygon outline of n sides with extended parameters
        
        ;// Basic shapes collision detection functions
        CheckCollisionRecs.rl_bool(*in_rect1.ray::Rectangle,
                                   *in_rect2.ray::Rectangle)                __PBAS(CheckCollisionRecs)          ;// Check collision between two rectangles
        CheckCollisionCircles.rl_bool(*in_center1.ray::Vector2,
                                      radius1.rl_float,
                                      *in_center2.ray::Vector2,
                                      radius2.rl_float)                     __PBAS(CheckCollisionCircles)       ;// Check collision between two circles
        CheckCollisionCircleRec.rl_bool(*in_center.ray::Vector2,
                                        radius.rl_float,
                                        *in_rect.ray::Rectangle)            __PBAS(CheckCollisionCircleRec)     ;// Check collision between circle and rectangle
        CheckCollisionPointRec.rl_bool(*in_point.ray::Vector2,
                                       *in_rect.ray::Rectangle)             __PBAS(CheckCollisionPointRec)      ;// Check if point is inside rectangle
        CheckCollisionPointCircle.rl_bool(*in_point.ray::Vector2,
                                          *in_center.ray::Vector2,
                                          radius.rl_float)                  __PBAS(CheckCollisionPointCircle)   ;// Check if point is inside circle
        CheckCollisionPointTriangle.rl_bool(*in_point.ray::Vector2,
                                            *in_p1.ray::Vector2,
                                            *in_p2.ray::Vector2,
                                            *in_p3.ray::Vector2)            __PBAS(CheckCollisionPointTriangle) ;// Check if point is inside a triangle
        CheckCollisionLines.rl_bool(*startPos1.ray::Vector2, *endPos1.ray::Vector2, 
                                    *startPos2.ray::Vector2, *endPos2.ray::Vector2, 
                                    *collisionPoint.ray::Vector2)           __PBAS(CheckCollisionLines)         ;// Check the collision between two lines defined by two points each, returns collision point by reference   
        CheckCollisionPointLine.rl_bool(*point.ray::Vector2, *p1.ray::Vector2, 
                                        *p2.ray::Vector2, threshold.rl_int) __PBAS(CheckCollisionPointLine)     ;// Check if point belongs to line created between two points [p1] and [p2] with defined margin in pixels [threshold]
        GetCollisionRec(*out_result.ray::Rectangle,
                        *in_rect1.ray::Rectangle,
                        *in_rect2.ray::Rectangle)                           __PBAS(GetCollisionRec)             ;// Get collision rectangle for two rectangles collision
        
        ;//------------------------------------------------------------------------------------
        ;// Texture Loading and Drawing Functions (Module: textures)
        ;//------------------------------------------------------------------------------------
        
        ;// Image loading functions
        ;// NOTE: This functions do not require GPU access
        LoadImageRaylib.i(*out_result.ray::Image, fileName.p-utf8)          __PBAS(LoadImage)                   ;// Load image from file into CPU memory (RAM)
        LoadImageRaw(*out_result.ray::Image, fileName.p-utf8,
                     width.rl_int, height.rl_int, format.rl_int,
                     headerSize.rl_int)                                     __PBAS(LoadImageRaw)                ;// Load image from RAW file data
        LoadImageAnim(*out_result.ray::Image, fileName.p-utf8, 
                      *frames.Long)                                         __PBAS(LoadImageAnim)               ;// Load image sequence from file (frames appended to image.data)
        LoadImageFromMemory(*out_result.ray::Image, fileType.p-utf8, 
                            *fileData, dataSize.rl_int)                     __PBAS(LoadImageFromMemory)         ;// Load image from memory buffer, fileType refers to extension: i.e. '.png'
        LoadImageFromTexture(*out_result.ray::Image, 
                             *texture.ray::Texture2D)                       __PBAS(LoadImageFromTexture)        ;// Load image from GPU texture data
        LoadImageFromScreen(*out_result.ray::Image)                         __PBAS(LoadImageFromScreen)         ;// Load image from screen buffer and (screenshot)
        UnloadImage(*in_image.ray::Image)                                   __PBAS(UnloadImage)                 ;// Unload image from CPU memory (RAM)
        ExportImage.rl_bool(*in_image.ray::Image, fileName.p-utf8)          __PBAS(ExportImage)                 ;// Export image data to file
        ExportImageAsCode.rl_bool(*in_image.ray::Image, fileName.p-utf8)    __PBAS(ExportImageAsCode)           ;// Export image as code file defining an array of bytes
        
        ;// Image generation functions
        GenImageColor(*out_image.ray::Image, width.rl_int, height.rl_int,
                      color.rl_ColorLong)                                   __PBAS(GenImageColor)               ;// Generate image: plain color
        GenImageGradientV(*out_image.ray::Image, width.rl_int, height.rl_int,
                          top.rl_ColorLong, bottom.rl_ColorLong)            __PBAS(GenImageGradientV)           ;// Generate image: vertical gradient
        GenImageGradientH(*out_image.ray::Image, width.rl_int, height.rl_int,
                          left.rl_ColorLong, right.rl_ColorLong)            __PBAS(GenImageGradientH)           ;// Generate image: horizontal gradient
        GenImageGradientRadial(*out_image.ray::Image, width.rl_int, height.rl_int,
                               density.rl_float,
                               inner.rl_ColorLong, outer.rl_ColorLong)      __PBAS(GenImageGradientRadial)      ;// Generate image: radial gradient
        GenImageChecked(*out_image.ray::Image, width.rl_int, height.rl_int,
                        checksX.rl_int, checksY.rl_int,
                        col1.rl_ColorLong, col2.rl_ColorLong)               __PBAS(GenImageChecked)             ;// Generate image: checked
        GenImageWhiteNoise(*out_image.ray::Image, width.rl_int, height.rl_int,
                           factor.rl_float)                                 __PBAS(GenImageWhiteNoise)          ;// Generate image: white noise
        GenImageCellular(*out_image.ray::Image, width.rl_int, height.rl_int,
                         tileSize.rl_int)                                   __PBAS(GenImageCellular)            ;// Generate image: cellular algorithm. Bigger tileSize means bigger cells
        
        ;// Image manipulation functions
        ImageCopy(*out_copy.ray::Image, *in_sourceImage.ray::Image)         __PBAS(ImageCopy)                   ;// Create an image duplicate (useful for transformations)
        ImageFromImage(*out_image.ray::Image, *in_sourceImage.ray::Image,
                       *in_rect.ray::Rectangle)                             __PBAS(ImageFromImage)              ;// Create an image from another image piece
        ImageText(*out_image.ray::Image, text.p-utf8, fontSize.rl_int,
                  color.rl_ColorLong)                                       __PBAS(ImageText)                   ;// Create an image from text (default font)
        ImageTextEx(*out_image.ray::Image, *in_font.ray::Font,
                    text.p-utf8, fontSize.rl_float, spacing.rl_float,
                    tint.rl_ColorLong)                                      __PBAS(ImageTextEx)                 ;// Create an image from text (custom sprite font)
        ImageToPOT(*inout_image.ray::Image, fillColor.rl_ColorLong)           RLAS(ImageToPOT)                  ;// Convert image to POT (power-of-two)
        ImageFormatRaylib(*inout_image.ray::Image, newFormat.rl_int)          RLAS(ImageFormat)                 ;// Convert image data to desired format
        ImageAlphaMask(*inout_image.ray::Image, *in_alphaMask.ray::Image)   __PBAS(ImageAlphaMask)              ;// Apply alpha mask to image
        ImageAlphaClear(*inout_image.ray::Image, color.rl_ColorLong,
                        threshold.rl_float)                                   RLAS(ImageAlphaClear)             ;// Clear alpha channel to desired color
        ImageAlphaCrop(*inout_image.ray::Image, threshold.rl_float)           RLAS(ImageAlphaCrop)              ;// Crop image depending on alpha value
        ImageAlphaPremultiply(*inout_image.ray::Image)                        RLAS(ImageAlphaPremultiply)       ;// Premultiply alpha channel
        ImageCrop(*inout_image.ray::Image, *in_crop.ray::Rectangle)         __PBAS(ImageCrop)                   ;// Crop an image to a defined rectangle
        ImageResize(*inout_image.ray::Image,
                    newWidth.rl_int, newHeight.rl_int)                        RLAS(ImageResize)                 ;// Resize image (Bicubic scaling algorithm)
        ImageResizeNN(*inout_image.ray::Image,
                      newWidth.rl_int, newHeight.rl_int)                      RLAS(ImageResizeNN)               ;// Resize image (Nearest-Neighbor scaling algorithm)
        ImageResizeCanvas(*inout_image.ray::Image,
                          newWidth.rl_int, newHeight.rl_int,
                          offsetX.rl_int, offsetY.rl_int,
                          color.rl_ColorLong)                                 RLAS(ImageResizeCanvas)           ;// Resize canvas and fill with color
        ImageMipmaps(*inout_image.ray::Image)                                 RLAS(ImageMipmaps)                ;// Generate all mipmap levels for a provided image
        ImageDither(*inout_image.ray::Image, rBpp.rl_int, gBpp.rl_int,
                    bBpp.rl_int, aBpp.rl_int)                                 RLAS(ImageDither)                 ;// Dither image data to 16bpp or lower (Floyd-Steinberg dithering)
        ImageFlipVertical(*inout_image.ray::Image)                            RLAS(ImageFlipVertical)           ;// Flip image vertically
        ImageFlipHorizontal(*inout_image.ray::Image)                          RLAS(ImageFlipHorizontal)         ;// Flip image horizontally
        ImageRotateCW(*inout_image.ray::Image)                                RLAS(ImageRotateCW)               ;// Rotate image clockwise 90deg
        ImageRotateCCW(*inout_image.ray::Image)                               RLAS(ImageRotateCCW)              ;// Rotate image counter-clockwise 90deg
        ImageColorTint(*inout_image.ray::Image, color.rl_ColorLong)           RLAS(ImageColorTint)              ;// Modify image color: tint
        ImageColorInvert(*inout_image.ray::Image)                             RLAS(ImageColorInvert)            ;// Modify image color: invert
        ImageColorGrayscale(*inout_image.ray::Image)                          RLAS(ImageColorGrayscale)         ;// Modify image color: grayscale
        ImageColorContrast(*inout_image.ray::Image, contrast.rl_float)        RLAS(ImageColorContrast)          ;// Modify image color: contrast (-100 to 100)
        ImageColorBrightness(*inout_image.ray::Image, brightness.rl_int)      RLAS(ImageColorBrightness)        ;// Modify image color: brightness (-255 to 255)
        ImageColorReplace(*inout_image.ray::Image,
                          color.rl_ColorLong, replace.rl_ColorLong)           RLAS(ImageColorReplace)           ;// Modify image color: replace color
        LoadImageColors.i(*in_image.ray::Image)                               RLAS(LoadImageColors)             ;// Load color data from image as a Color array (RGBA - 32bit)
        LoadImagePalette.i(*in_image.ray::Image, maxPaletteSize.rl_int, 
                           *colorCount.Long)                                  RLAS(LoadImagePalette)            ;// Load colors palette from image as a Color array (RGBA - 32bit)
        UnloadImageColors(*colors.ray::Color)                                 RLAS(UnloadImageColors)           ;// Unload color data loaded with LoadImageColors()
        UnloadImagePalette(*colors.ray::Color)                                RLAS(UnloadImagePalette)          ;// Unload colors palette loaded with LoadImagePalette()
        GetImageAlphaBorder(*out_resultRect.ray::Rectangle,
                            *in_image.ray::Image, threshold.rl_float)       __PBAS(GetImageAlphaBorder)         ;// Get image alpha border rectangle
        GetImageColor.rl_ColorLong(*in_image.ray::Image, 
                                   x.rl_int, y.rl_int)                        RLAS(GetImageColor)               ;// Get image pixel color at (x, y) position
        
        ;// Image drawing functions
        ;// NOTE: Image software-rendering functions (CPU)
        ImageClearBackground(*inout_image.ray::Image, color.rl_ColorLong)     RLAS(ImageClearBackground)        ;// Clear image background with given color
        ImageDrawPixel(*inout_image.ray::Image, posX.rl_int, posY.rl_int,
                       color.rl_ColorLong)                                    RLAS(ImageDrawPixel)              ;// Draw pixel within an image
        ImageDrawPixelV(*inout_image.ray::Image, *in_position.ray::Vector2,
                        color.rl_ColorLong)                                 __PBAS(ImageDrawPixelV)             ;// Draw pixel within an image (Vector version)
        ImageDrawLine(*inout_image.ray::Image,
                      startPosX.rl_int, startPosY.rl_int,
                      endPosX.rl_int, endPosY.rl_int,
                      color.rl_ColorLong)                                     RLAS(ImageDrawLine)               ;// Draw line within an image
        ImageDrawLineV(*inout_image.ray::Image, *in_start.ray::Vector2,
                       *in_end.ray::Vector2, color.rl_ColorLong)            __PBAS(ImageDrawLineV)              ;// Draw line within an image (Vector version)
        ImageDrawCircle(*inout_image.ray::Image,
                        centerX.rl_int, centerY.rl_int, radius.rl_int,
                        color.rl_ColorLong)                                   RLAS(ImageDrawCircle)             ;// Draw circle within an image
        ImageDrawCircleV(*inout_image.ray::Image, *in_center.ray::Vector2,
                         radius.rl_int, color.rl_ColorLong)                 __PBAS(ImageDrawCircleV)            ;// Draw circle within an image (Vector version)
        ImageDrawRectangle(*inout_image.ray::Image, posX.rl_int, posY.rl_int,
                           width.rl_int, height.rl_int, color.rl_ColorLong)   RLAS(ImageDrawRectangle)          ;// Draw rectangle within an image
        ImageDrawRectangleV(*inout_image.ray::Image, *in_position.ray::Vector2,
                            *in_size.ray::Vector2, color.rl_ColorLong)      __PBAS(ImageDrawRectangleV)         ;// Draw rectangle within an image (Vector version)
        ImageDrawRectangleRec(*inout_image.ray::Image, *in_rec.ray::Rectangle,
                              color.rl_ColorLong)                           __PBAS(ImageDrawRectangleRec)       ;// Draw rectangle within an image
        ImageDrawRectangleLines(*inout_image.ray::Image, *in_rec.ray::Rectangle,
                                thick.rl_int, color.rl_ColorLong)           __PBAS(ImageDrawRectangleLines)     ;// Draw rectangle lines within an image
        ImageDraw(*inout_image.ray::Image, *in_src.ray::Image,
                  *in_srcRec.ray::Rectangle, *in_dstRec.ray::Rectangle,
                  tint.rl_ColorLong)                                        __PBAS(ImageDraw)                   ;// Draw a source image within a destination image (tint applied to source)
        ImageDrawText(*inout_image.ray::Image, text.p-utf8,
                      posX.rl_int, posY.rl_int, fontSize.rl_int, 
                      color.rl_ColorLong)                                     RLAS(ImageDrawText)               ;// Draw text (default font) within an image (destination)
        ImageDrawTextEx(*inout_image.ray::Image, *in_font.ray::Font, 
                        text.p-utf8, *in_position.ray::Vector2, fontSize.rl_float,
                        spacing.rl_float, color.rl_ColorLong)               __PBAS(ImageDrawTextEx)             ;// Draw text (custom sprite font) within an image (destination)
        
        ;// Texture loading functions
        ;// NOTE: These functions require GPU access
        LoadTextureRaylib(*out_texture.ray::Texture2D, fileName.p-utf8)     __PBAS(LoadTexture)                 ;// Load texture from file into GPU memory (VRAM)
        LoadTextureFromImage(*out_texture.ray::Texture2D,
                             *in_image.ray::Image )                         __PBAS(LoadTextureFromImage)        ;// Load texture from image data
        LoadTextureCubemap(*out_cubemap.ray::TextureCubemap,
                           *in_image.ray::Image, layoutType.rl_int)         __PBAS(LoadTextureCubemap)          ;// Load cubemap from image, multiple image cubemap layouts supported
        LoadRenderTexture(*out_renderTexture.ray::RenderTexture2D,
                          width.rl_int, height.rl_int)                      __PBAS(LoadRenderTexture)           ;// Load texture for rendering (framebuffer)
        UnloadTexture(*inout_texture.ray::Texture2D)                        __PBAS(UnloadTexture)               ;// Unload texture from GPU memory (VRAM)
        UnloadRenderTexture(*inout_target.ray::RenderTexture2D)             __PBAS(UnloadRenderTexture)         ;// Unload render texture from GPU memory (VRAM)
        UpdateTexture(*inout_texture.ray::Texture2D, *pixels)               __PBAS(UpdateTexture)               ;// Update GPU texture with new data, format of *pixels is texture\format (Enumeration PixelFormat)
        UpdateTextureRec(*inout_texture.ray::Texture2D, 
                         *rec.ray::Rectangle, *pixels)                      __PBAS(UpdateTextureRec)            ;// Update GPU texture rectangle with new data
        
        ;// Texture configuration functions
        GenTextureMipmaps(*inout_texture.ray::Texture2D)                      RLAS(GenTextureMipmaps)           ;// Generate GPU mipmaps for a texture
        SetTextureFilter(*in_texture.ray::Texture2D, filterMode.rl_int)     __PBAS(SetTextureFilter)            ;// Set texture scaling filter mode
        SetTextureWrap(*in_texture.ray::Texture2D, wrapMode.rl_int)         __PBAS(SetTextureWrap)              ;// Set texture wrapping mode
        
        ;// Texture drawing functions
        DrawTexture(*in_texture.ray::Texture2D, posX.rl_int,
                    posY.rl_int, tint.rl_ColorLong)                         __PBAS(DrawTexture)                 ;// Draw a Texture2D
        DrawTextureV(*in_texture.ray::Texture2D,
                     *in_position.ray::Vector2, tint.rl_ColorLong)          __PBAS(DrawTextureV)                ;// Draw a Texture2D with position defined as Vector2
        DrawTextureEx(*in_texture.ray::Texture2D,
                      *in_position.ray::Vector2, rotation.rl_float,
                      scale.rl_float, tint.rl_ColorLong)                    __PBAS(DrawTextureEx)               ;// Draw a Texture2D with extended parameters
        DrawTextureRec(*in_texture.ray::Texture2D, *in_sourceRec.ray::Rectangle,
                       *in_position.ray::Vector2, tint.rl_ColorLong)        __PBAS(DrawTextureRec)              ;// Draw a part of a texture defined by a rectangle
        DrawTextureQuad(*in_texture.ray::Texture2D, *in_tiling.ray::Vector2,
                        *in_offset.ray::Vector2, *in_quad.ray::Rectangle,
                        tint.rl_ColorLong)                                  __PBAS(DrawTextureQuad)             ;// Draw texture quad with tiling and offset parameters
        DrawTextureTiled(*in_texture.ray::Texture2D, *source.ray::Rectangle, 
                         *dest.ray::Rectangle, *origin.ray::Vector2, 
                         rotation.rl_float, scale.rl_float, 
                         tint.rl_ColorLong)                                 __PBAS(DrawTextureTiled)            ;// Draw part of a texture (defined by a rectangle) with rotation and scale tiled into dest.
        DrawTexturePro(*in_texture.ray::Texture2D,
                       *in_sourceRec.ray::Rectangle, *in_destRec.ray::Rectangle,
                       *in_origin.ray::Vector2, rotation.rl_float,
                       tint.rl_ColorLong)                                   __PBAS(DrawTexturePro)              ;// Draw a part of a texture defined by a rectangle with 'pro' parameters
        DrawTextureNPatch(*in_texture.ray::Texture2D,
                          *in_nPatchInfo.ray::NPatchInfo,
                          *in_destRec.ray::Rectangle, *in_origin.ray::Vector2,
                          rotation.rl_float, tint.rl_ColorLong)             __PBAS(DrawTextureNPatch)           ;// Draws a texture (or part of it) that stretches or shrinks nicely
        DrawTexturePoly(*in_texture.ray::Texture2D, *center.ray::Vector2, 
                        *points.ray::Vector2, *texcoords.ray::Vector2, 
                        pointCount.rl_int, tint.rl_ColorLong)               __PBAS(DrawTexturePoly)             ;// Draw a textured polygon
        
        ;// Color/pixel related functions
        Fade.rl_ColorLong(color.rl_ColorLong, alpha.rl_float)                 RLAS(Fade)                        ;// Color fade-in or fade-out, alpha goes from 0.0f to 1.0f
        ColorToInt.rl_int(color.rl_ColorLong)                                 RLAS(ColorToInt)                  ;// Returns hexadecimal value for a Color
        ColorNormalize(*out_result.ray::_Vector4, color.rl_ColorLong)       __PBAS(ColorNormalize)              ;// Returns color normalized as float [0..1]
        ColorFromNormalized.i(*in_normalized.ray::_Vector4)                 __PBAS(ColorFromNormalized)         ;// Returns color from normalized values [0..1]
        ColorToHSV(*out_result.ray::_Vector3, color.rl_ColorLong)           __PBAS(ColorToHSV)                  ;// Returns HSV values for a Color
        ColorFromHSV.rl_ColorLong(hue.rl_float, saturation.rl_float, 
                                  value.rl_float)                             RLAS(ColorFromHSV)                ;// Returns a Color from HSV values
        ColorAlpha.rl_ColorLong(color.rl_ColorLong, alpha.rl_float)           RLAS(ColorAlpha)                  ;// Get color with alpha applied, alpha goes from 0.0f to 1.0f
        ColorAlphaBlend.rl_ColorLong(dst.rl_ColorLong, src.rl_ColorLong, 
                                     tint.rl_ColorLong)                       RLAS(ColorAlphaBlend)             ;// Get src alpha-blended into dst color with tint
        GetColor.rl_ColorLong(hexValue.rl_int)                                RLAS(GetColor)                    ;// Returns a Color struct from hexadecimal value
        GetPixelColor.rl_ColorLong(*srcPtr, format.rl_int)                    RLAS(GetPixelColor)               ;// Get Color from a source pixel pointer of certain format
        SetPixelColor(*dstPtr, color.rl_ColorLong, format.rl_int)             RLAS(SetPixelColor)               ;// Set color formatted into destination pixel pointer
        GetPixelDataSize.rl_int(width.rl_int, height.rl_int, format.rl_int)   RLAS(GetPixelDataSize)            ;// Get pixel data size in bytes (image or texture)
        
        ;//------------------------------------------------------------------------------------
        ;// Font Loading and Text Drawing Functions (Module: text)
        ;//------------------------------------------------------------------------------------
        
        ;// Font loading/unloading functions
        GetFontDefault(*out_font.ray::Font)                                 __PBAS(GetFontDefault)              ;// Get the default Font
        LoadFontRaylib(*out_font.ray::Font, fileName.p-utf8)                __PBAS(LoadFont)                    ;// Load font from file into GPU memory (VRAM)
        LoadFontEx(*out_font.ray::Font, fileName.p-utf8,
                   fontSize.rl_int, *fontChars.Long, charsCount.rl_int)     __PBAS(LoadFontEx)                  ;// Load font from file with extended parameters
        LoadFontFromImage(*out_font.ray::Font, *in_image.ray::Image,
                          key.rl_ColorLong, firstChar.rl_int)               __PBAS(LoadFontFromImage)           ;// Load font from Image (XNA style)
        LoadFontFromMemory(*out_font.ray::Font, fileType.p-utf8, 
                           *fileData, dataSize.rl_int, fontSize.rl_int, 
                           *fontChars.Long, glyphCount.rl_int)              __PBAS(LoadFontFromMemory)          ;// Load font from memory buffer, fileType refers to extension: i.e. '.ttf'
        LoadFontData.i(*fileData, dataSize.rl_int, 
                     fontSize.rl_int, *fontChars.Long, glyphCount.rl_int, 
                     type.rl_int)                                             RLAS(LoadFontData)                ;// Load font data for further use
        GenImageFontAtlas(*out_font.ray::Image, *in_chars.ray::GlyphInfo,
                          *recs, charsCount.rl_int, fontSize.rl_int,
                          padding.rl_int, packMethod.rl_int)                __PBAS(GenImageFontAtlas)           ;// Generate image font atlas using chars info
        UnloadFontData(*chars.ray::GlyphInfo, glyphCount.rl_int)
        UnloadFont(*in_font.ray::Font)                                      __PBAS(UnloadFont)                  ;// Unload Font from GPU memory (VRAM)
        ExportFontAsCode.rl_bool(*in_font.ray::Font, fileName.p-utf8)       __PBAS(ExportFontAsCode)            ;// Export font as code file, returns true on success
        
        ;// Text drawing functions
        DrawFPS(posX.rl_int, posY.rl_int)                                     RLAS(DrawFPS)                     ;// Shows current FPS
        DrawTextRaylib(text.p-utf8, posX.rl_int, posY.rl_int,
                       fontSize.rl_int, color.rl_ColorLong)                   RLAS(DrawText)                    ;// Draw text (using default font)
        DrawTextEx(*in_font.ray::Font, text.p-utf8,
                   *in_position.ray::Vector2, fontSize.rl_float,
                   spacing.rl_float, tint.rl_ColorLong)                     __PBAS(DrawTextEx)                  ;// Draw text using font and additional parameters
        DrawTextPro(*in_font.ray::Font, text.p-utf8, 
                    *in_position.ray::Vector2, *origin.ray::Vector2, 
                    rotation.rl_float, fontSize.rl_float, 
                    spacing.rl_float, tint.rl_ColorLong)                    __PBAS(DrawTextPro)                 ;// Draw text using Font and pro parameters (rotation)
        DrawTextCodepoint(*in_font.ray::Font, codepoint.rl_int,
                          *in_position.ray::Vector2, scale.rl_float,
                          tint.rl_ColorLong)                                __PBAS(DrawTextCodepoint)           ;// Draw one character (codepoint)
        DrawTextCodepoints(*in_font.ray::Font, *codepoints.Long, 
                           count.rl_int, *position.ray::Vector2, 
                           fontSize.rl_float, spacing.rl_float, 
                           tint.rl_ColorLong)                               __PBAS(DrawTextCodepoints)          ;// Draw multiple character (codepoint)
        
        ;- Special
        DrawTextBoxedSelectable(*font.ray::Font, text.p-utf8, *rec.ray::Rectangle, 
                                fontSize.rl_float, spacing.rl_float, 
                                wordWrap.rl_bool, tint.rl_ColorLong, 
                                selectStart.rl_int, selectLength.rl_int, 
                                selectTint.rl_ColorLong, 
                                selectBackTint.rl_ColorLong)                __PBAS(DrawTextBoxedSelectable)     ;// Draw text using font inside rectangle limits With support For text selection
        
        ;// Draw a codepoint in 3D space
        DrawTextCodepoint3D(*font.ray::Font, codepoint.rl_int, *position.ray::_Vector3, 
                            fontSize.rl_float, backface.rl_bool, 
                            tint.rl_ColorLong)                              __PBAS(DrawTextCodepoint3D)
        ;// Draw a 2D text in 3D space
        DrawText3D(*font.ray::Font, text.p-utf8, *position.ray::_Vector3, fontSize.rl_float, 
                   fontSpacing.rl_float, lineSpacing.rl_float, backface.rl_bool, 
                   tint.rl_ColorLong)                                       __PBAS(DrawText3D)
        ;// Measure a text in 3D. For some reason `MeasureTextEx()` just doesn't seem to work so i had to use this instead.
        MeasureText3D(*result.ray::_Vector3, *font.ray::Font, text.p-utf8, fontSize.rl_float, 
                      fontSpacing.rl_float, lineSpacing.rl_float)           __PBAS(MeasureText3D)
        
        ;// Draw a 2D text in 3D space And wave the parts that start With `~~` And End With `~~`.
        ;// This is a modified version of the original code by @Nighten found here https://github.com/NightenDushi/Raylib_DrawTextStyle
        DrawTextWave3D(*font.ray::Font, text.p-utf8, *position.ray::_Vector3, fontSize.rl_float, 
                       fontSpacing.rl_float, lineSpacing.rl_float, backface.rl_bool, 
                       *config.WaveTextConfig, time.rl_float, 
                       tint.rl_ColorLong)                                   __PBAS(DrawTextWave3D)
        ;// Measure a text in 3D ignoring the `~~` chars.
        MeasureTextWave3D(*result.ray::_Vector3, *font.ray::Font, text.p-utf8, fontSize.rl_float, 
                          fontSpacing.rl_float, lineSpacing.rl_float)       __PBAS(MeasureTextWave3D)
        
        ;// Generates a nice color With a random hue
        GenerateRandomColor(*result.ray::Color, s.rl_float, v.rl_float)     __PBAS(GenerateRandomColor)
        
        
        ;// Text font info functions
        MeasureText.rl_int(text.p-utf8, fontSize.rl_int)                    __PBAS(MeasureText)                 ;// Measure string width for default font
        MeasureTextEx(*out_result.ray::Vector2, *in_font.ray::Font,
                      text.p-utf8, fontSize.rl_float, spacing.rl_float)     __PBAS(MeasureTextEx)               ;// Measure string size for Font
        GetGlyphIndex.rl_int(*in_font.ray::Font, codepoint.rl_int)          __PBAS(GetGlyphIndex)               ;// Get index position for a unicode character on font
        GetGlyphInfo(*glyph_info.ray::GlyphInfo, *in_font.ray::Font,
                     codepoint.rl_int)                                      __PBAS(GetGlyphInfo)                ;// Get glyph font info data for a codepoint (unicode character), fallback to '?' if not found
        GetGlyphAtlasRec(*out_rect.ray::Rectangle, *in_font.ray::Font, 
                         codepoint.rl_int)                                  __PBAS(GetGlyphAtlasRec)            ;// Get glyph rectangle in font atlas for a codepoint (unicode character), fallback to '?' if not found
        
        ;// Text codepoints management functions (unicode characters)
        LoadCodepoints.i(text.p-utf8, *out_count.Long)                        RLAS(LoadCodepoints)              ;// Load all codepoints from a UTF-8 text string, codepoints count returned by parameter
        UnloadCodepoints(*codepoints.Long)                                    RLAS(UnloadCodepoints)            ;// Unload codepoints data from memory
        GetCodepointCount.rl_int(text.p-utf8)                                 RLAS(GetCodepointCount)           ;// Get total number of characters (codepoints) in a UTF8 encoded string
        GetCodepoint.rl_int(text.p-utf8, *out_bytesProcessed.Long)                  RLAS(GetCodepoint)                ;// Returns next codepoint in a UTF8 encoded string; 0x3f('?') is returned on failure
                                                                                                                ;__CodepointToUtf8.i(codepoint.rl_int, *out_byteLength.Long)           RLAS(CodepointToUtf8)             ;// Encode codepoint into utf8 text (char array length returned as parameter)
        TextCodepointsToUTF8.i(*codepoints.Long, length.rl_int)               RLAS(TextCodepointsToUTF8)        ;// Encode text as codepoints array into UTF-8 text string (WARNING: memory must be freed!)
        
        
        ;// Text strings management functions (no utf8 strings, only byte chars)
        ;// NOTE: Some strings allocate memory internally for returned strings, just be careful!
        ;RLAPI int TextCopy(char *dst, const char *src);                                             // Copy one string to another, returns bytes copied
        ;RLAPI bool TextIsEqual(const char *text1, const char *text2);                               // Check if two text string are equal
        ;RLAPI unsigned int TextLength(const char *text);                                            // Get text length, checks for '\0' ending
        ;RLAPI const char *TextFormat(const char *text, ...);                                        // Text formatting with variables (sprintf style)
        ;RLAPI const char *TextSubtext(const char *text, int position, int length);                  // Get a piece of a text string
        ;RLAPI char *TextReplace(char *text, const char *replace, const char *by);                   // Replace text string (memory must be freed!)
        ;RLAPI char *TextInsert(const char *text, const char *insert, int position);                 // Insert text in a position (memory must be freed!)
        ;RLAPI const char *TextJoin(const char **textList, int count, const char *delimiter);        // Join text strings with delimiter
        ;RLAPI const char **TextSplit(const char *text, char delimiter, int *count);                 // Split text into multiple strings
        ;RLAPI void TextAppend(char *text, const char *append, int *position);                       // Append text at specific position and move cursor!
        ;RLAPI int TextFindIndex(const char *text, const char *find);                                // Find first text occurrence within a string
        ;RLAPI const char *TextToUpper(const char *text);                      // Get upper case version of provided string
        ;RLAPI const char *TextToLower(const char *text);                      // Get lower case version of provided string
        ;RLAPI const char *TextToPascal(const char *text);                     // Get Pascal case notation version of provided string
        ;RLAPI int TextToInteger(const char *text);                            // Get integer value from text (negative values not supported)
        ;RLAPI char *TextToUtf8(int *codepoints, int length);                  // Encode text codepoint into utf8 text (memory must be freed!)
        
        ;//------------------------------------------------------------------------------------
        ;// Basic 3d Shapes Drawing Functions (Module: models)
        ;//------------------------------------------------------------------------------------
        
        ;// Basic geometric 3D shapes drawing functions
        DrawLine3D(*in_startPos.ray::_Vector3, *in_endPos.ray::_Vector3,
                   color.rl_ColorLong)                                      __PBAS(DrawLine3D)                  ;// Draw a line in 3D world space
        DrawPoint3D(*in_position.ray::_Vector3, color.rl_ColorLong)         __PBAS(DrawPoint3D)                 ;// Draw a point in 3D space, actually a small line
        DrawCircle3D(*in_center.ray::_Vector3, radius.rl_float,
                     *in_rotationAxis.ray::_Vector3, rotationAngle.rl_float,
                     color.rl_ColorLong)                                    __PBAS(DrawCircle3D)                ;// Draw a circle in 3D world space
        DrawTriangle3D(*v1.ray::_Vector3, *v2.ray::_Vector3, 
                       *v3.ray::_Vector3, color.rl_ColorLong)               __PBAS(DrawTriangle3D)              ;// Draw a color-filled triangle (vertex in counter-clockwise order!)
        DrawTriangleStrip3D(*points.ray::_Vector3, pointCount.rl_int, 
                            color.rl_ColorLong)                             __PBAS(DrawTriangleStrip3D)         ;// Draw a triangle strip defined by points
        DrawCube(*in_position.ray::_Vector3, width.rl_float,
                 height.rl_float, length.rl_float, color.rl_ColorLong)      __PBAS(DrawCube)                    ;// Draw cube
        DrawCubeV(*in_position.ray::_Vector3, *in_size.ray::_Vector3,
                  color.rl_ColorLong)                                       __PBAS(DrawCubeV)                   ;// Draw cube (Vector version)
        DrawCubeWires(*in_position.ray::_Vector3, width.rl_float,
                      height.rl_float, length.rl_float, color.rl_ColorLong) __PBAS(DrawCubeWires)               ;// Draw cube wires
        DrawCubeWiresV(*in_position.ray::_Vector3, *in_size.ray::_Vector3,
                       color.rl_ColorLong)                                  __PBAS(DrawCubeWiresV)              ;// Draw cube wires (Vector version)
        DrawCubeTexture(*in_texture.ray::Texture2D, *in_position.ray::_Vector3,
                        width.rl_float, height.rl_float, length.rl_float,
                        color.rl_ColorLong)                                 __PBAS(DrawCubeTexture)             ;// Draw cube textured
        DrawCubeTextureRec(*in_texture.ray::Texture2D, *source.ray::Rectangle,
                           *in_position.ray::_Vector3, width.rl_float, 
                           height.rl_float, length.rl_float, 
                           color.rl_ColorLong)                              __PBAS(DrawCubeTextureRec)          ;// Draw cube with a region of a texture
        DrawSphere(*in_centerPos.ray::_Vector3, radius.rl_float,
                   color.rl_ColorLong)                                      __PBAS(DrawSphere)                  ;// Draw sphere
        DrawSphereEx(*in_centerPos.ray::_Vector3, radius.rl_float,
                     rings.rl_int, slices.rl_int, color.rl_ColorLong)       __PBAS(DrawSphereEx)                ;// Draw sphere with extended parameters
        DrawSphereWires(*in_centerPos.ray::_Vector3, radius.rl_float,
                        rings.rl_int, slices.rl_int, color.rl_ColorLong)    __PBAS(DrawSphereWires)             ;// Draw sphere wires
        DrawCylinder(*in_position.ray::_Vector3, radiusTop.rl_float,
                     radiusBottom.rl_float, height.rl_float,
                     slices.rl_int, color.rl_ColorLong)                     __PBAS(DrawCylinder)                ;// Draw a cylinder/cone
        DrawCylinderEx(*in_startPos.ray::_Vector3, *in_endPos.ray::_Vector3,
                       startRadius.rl_float, endRadius.rl_float, 
                       sides.rl_int, color.rl_ColorLong)                    __PBAS(DrawCylinderEx)              ;// Draw a cylinder with base at startPos and top at endPos
        DrawCylinderWires(*in_position.ray::_Vector3, radiusTop.rl_float,
                          radiusBottom.rl_float, height.rl_float,
                          slices.rl_int, color.rl_ColorLong)                __PBAS(DrawCylinderWires)           ;//Draw a cylinder/cone wires
        DrawCylinderWiresEx(*in_startPos.ray::_Vector3, *in_endPos.ray::_Vector3,
                            startRadius.rl_float, endRadius.rl_float, 
                            sides.rl_int, color.rl_ColorLong)               __PBAS(DrawCylinderWiresEx)         ;// Draw a cylinder wires with base at startPos and top at endPos
        DrawPlane(*in_centerPos.ray::_Vector3, *in_size.ray::Vector2,
                  color.rl_ColorLong)                                       __PBAS(DrawPlane)                   ;// Draw a plane XZ
        DrawRay(*in_ray.ray::Ray, color.rl_ColorLong)                       __PBAS(DrawRay)                     ;// Draw a ray line
        DrawGrid(slices.rl_int, spacing.rl_float)                             RLAS(DrawGrid)                    ;// Draw a grid (centered at (0, 0, 0))
        
        ;//DrawTorus(), DrawTeapot() could be useful?
        
        ;//------------------------------------------------------------------------------------
        ;// Model 3d Loading and Drawing Functions (Module: models)
        ;//------------------------------------------------------------------------------------
        
        ;// Model management functions
        LoadModel(*out_result.ray::Model, fileName.p-utf8)                  __PBAS(LoadModel)                   ;// Load model from files (meshes and materials)
        LoadModelFromMesh(*out_result.ray::Model, *in_mesh.ray::Mesh)       __PBAS(LoadModelFromMesh)           ;// Load model from generated mesh (default material)
        UnloadModel(*in_model.ray::Model)                                   __PBAS(UnloadModel)                 ;// Unload model from memory (RAM and/or VRAM)
        UnloadModelKeepMeshes(*in_model.ray::Model)                         __PBAS(UnloadModelKeepMeshes)       ;// Unload model (but not meshes) from memory (RAM and/or VRAM)
        GetModelBoundingBox(*out_box.ray::BoundingBox, 
                            *in_model.ray::Model)                           __PBAS(GetModelBoundingBox)         ;// Compute model bounding box limits (considers all meshes)
        
        ;// Model drawing functions
        DrawModel(*in_model.ray::Model, *in_position.ray::_Vector3,
                  scale.rl_float, tint.rl_ColorLong)                        __PBAS(DrawModel)                   ;// Draw a model (with texture if set)
        DrawModelEx(*in_model.ray::Model, *in_position.ray::_Vector3,
                    *in_rotationAxis.ray::_Vector3, rotationAngle.rl_float,
                    *in_scale.ray::_Vector3, tint.rl_ColorLong)             __PBAS(DrawModelEx)                 ;// Draw a model with extended parameters
        DrawModelWires(*in_model.ray::Model, *in_position.ray::_Vector3,
                       scale.rl_float, tint.rl_ColorLong)                   __PBAS(DrawModelWires)              ;// Draw a model wires (with texture if set)
        DrawModelWiresEx(*in_model.ray::Model, *in_position.ray::_Vector3,
                         *in_rotationAxis.ray::_Vector3, rotationAngle.rl_float,
                         *in_scale.ray::_Vector3, tint.rl_ColorLong)        __PBAS(DrawModelWiresEx)            ;// Draw a model wires (with texture if set) with extended parameters
        DrawBoundingBox(*in_box.ray::BoundingBox, color.rl_ColorLong)       __PBAS(DrawBoundingBox)             ;// Draw bounding box (wires)
        DrawBillboard(*in_camera.ray::Camera, *in_texture.ray::Texture2D,
                      *in_center.ray::_Vector3, size.rl_float,
                      tint.rl_ColorLong)                                    __PBAS(DrawBillboard)               ;// Draw a billboard texture
        DrawBillboardRec(*in_camera.ray::Camera, *in_texture.ray::Texture2D,
                         *in_sourceRec.ray::Rectangle, *in_center.ray::_Vector3,
                         size.rl_float, tint.rl_ColorLong)                  __PBAS(DrawBillboardRec)            ;// Draw a billboard texture defined by sourceRec
        DrawBillboardPro(*in_camera.ray::Camera, *in_texture.ray::Texture2D, 
                         *in_sourceRec.ray::Rectangle, *in_position.ray::_Vector3, 
                         *up.ray::_Vector3, *size.ray::Vector2, *origin.ray::Vector2, 
                         rotation.rl_float, tint.rl_ColorLong)              __PBAS(DrawBillboardPro)            ;// Draw a billboard texture defined by source and rotation
        
        ;// Mesh management functions
        UploadMesh(*in_mesh.ray::Mesh, dynamic.rl_bool)                     __PBAS(UploadMesh)                  ;// Upload mesh vertex Data in GPU And provide VAO/VBO ids
        UpdateMeshBuffer(*in_mesh.ray::Mesh, index.rl_int, 
                         *in_data, dataSize.rl_int, 
                         offset.rl_int)                                     __PBAS(UpdateMeshBuffer)            ;// Update mesh vertex data in GPU for a specific buffer index
        UnloadMesh(*in_mesh.ray::Mesh)                                      __PBAS(UnloadMesh)                  ;// Unload mesh Data from CPU And GPU
        DrawMesh(*in_mesh.ray::Mesh, *in_material.ray::Material, 
                 *transform.ray::Matrix)                                    __PBAS(DrawMesh)                    ;// Draw a 3d mesh With material And transform
        DrawMeshInstanced(*in_mesh.ray::Mesh, *in_material.ray::Material, 
                          *transforms.ray::Matrix, instances.rl_int)        __PBAS(DrawMeshInstanced)           ;// Draw multiple mesh instances with material and different transforms
        ExportMesh(*in_mesh.ray::Mesh, fileName.p-utf8)                     __PBAS(ExportMesh)                  ;// Export mesh Data To file, returns true on success
        GetMeshBoundingBox(*out_box.ray::BoundingBox, *in_mesh.ray::Mesh)   __PBAS(GetMeshBoundingBox)          ;// Compute mesh bounding box limits
        GenMeshTangents(*in_mesh.ray::Mesh)                                 __PBAS(GenMeshTangents)             ;// Compute mesh tangents
        
        ;// Mesh generation functions
        GenMeshPoly(*out_mesh.ray::Mesh, sides.rl_int, radius.rl_float)     __PBAS(GenMeshPoly)                 ;// Generate polygonal mesh
        GenMeshPlane(*out_mesh.ray::Mesh, width.rl_float, length.rl_float,
                     resX.rl_int, resZ.rl_int)                              __PBAS(GenMeshPlane)                ;// Generate plane mesh (with subdivisions)
        GenMeshCube(*out_mesh.ray::Mesh, width.rl_float,
                    height.rl_float, length.rl_float)                       __PBAS(GenMeshCube)                 ;// Generate cuboid mesh
        GenMeshSphere(*out_mesh.ray::Mesh, radius.rl_float,
                      rings.rl_int, slices.rl_int)                          __PBAS(GenMeshSphere)               ;// Generate sphere mesh (standard sphere)
        GenMeshHemiSphere(*out_mesh.ray::Mesh, radius.rl_float,
                          rings.rl_int, slices.rl_int)                      __PBAS(GenMeshHemiSphere)           ;// Generate half-sphere mesh (no bottom cap)
        GenMeshCylinder(*out_mesh.ray::Mesh, radius.rl_float,
                        height.rl_float, slices.rl_int)                     __PBAS(GenMeshCylinder)             ;// Generate cylinder mesh
        GenMeshCone(*out_mesh.ray::Mesh, radius.rl_float, 
                    height.rl_float, slices.rl_int)                         __PBAS(GenMeshCone)                 ;// Generate cone/pyramid mesh
        GenMeshTorus(*out_mesh.ray::Mesh, radius.rl_float, size.rl_float,
                     radSeg.rl_int, sides.rl_int)                           __PBAS(GenMeshTorus)                ;// Generate torus mesh
        GenMeshKnot(*out_mesh.ray::Mesh, radius.rl_float, size.rl_float,
                    radSeg.rl_int, sides.rl_int)                            __PBAS(GenMeshKnot)                 ;// Generate trefoil knot mesh
        GenMeshHeightmap(*out_mesh.ray::Mesh, *in_heightmap.ray::Image,
                         *in_size.ray::_Vector3)                            __PBAS(GenMeshHeightmap)            ;// Generate heightmap mesh from image data
        GenMeshCubicmap(*out_mesh.ray::Mesh, *in_cubicmap.ray::Image,
                        *in_cubeSize.ray::_Vector3)                         __PBAS(GenMeshCubicmap)             ;// Generate cubes-based map mesh from image data
        
        ;// Material loading/unloading functions
        LoadMaterials.i(fileName.p-utf8, *out_materialCount.Long)             RLAS(LoadMaterials)               ;// Load materials from model file, returns *pointer_to.ray::Material
        LoadMaterialDefault(*out_material.ray::Material)                    __PBAS(LoadMaterialDefault)         ;// Load default material (Supports: DIFFUSE, SPECULAR, NORMAL maps)
        UnloadMaterial(*in_material.ray::Material)                          __PBAS(UnloadMaterial)              ;// Unload material from GPU memory (VRAM)
        SetMaterialTexture(*in_material.ray::Material, mapType.rl_int,
                           *in_texture.ray::Texture2D)                      __PBAS(SetMaterialTexture)          ;// Set texture for a material map type (MAP_DIFFUSE, MAP_SPECULAR...)
        SetModelMeshMaterial(*in_model.ray::Model, meshId.rl_int,
                             materialId.rl_int)                               RLAS(SetModelMeshMaterial)        ;// Set material for a mesh
        
        ;// Model animations loading/unloading functions
        LoadModelAnimations.i(fileName.p-utf8, *out_animsCount.Long)          RLAS(LoadModelAnimations)         ;// Load model animations from file, returns *pointer_to.ray::ModelAnimation
        UpdateModelAnimation(*in_model.ray::Model,
                             *in_anim.ray::ModelAnimation, frame.rl_int)    __PBAS(UpdateModelAnimation)        ;// Update model animation pose
        UnloadModelAnimation(*in_anim.ray::ModelAnimation)                  __PBAS(UnloadModelAnimation)        ;// Unload animation data
        UnloadModelAnimations(*in_anim.ray::ModelAnimation, count.rl_int)   __PBAS(UnloadModelAnimations)       ;// Unload animation array data
        IsModelAnimationValid.rl_bool(*in_model.ray::Model,
                                      *in_anim.ray::ModelAnimation)         __PBAS(IsModelAnimationValid)       ;// Check model animation skeleton match
        
        ;// Collision detection functions
        CheckCollisionSpheres.rl_bool(*in_centerA.ray::_Vector3,
                                      radiusA.rl_float,
                                      *in_centerB.ray::_Vector3,
                                      radiusB.rl_float)                     __PBAS(CheckCollisionSpheres)       ;// Detect collision between two spheres
        CheckCollisionBoxes.rl_bool(*in_box1.ray::BoundingBox,
                                    *in_box2.ray::BoundingBox)              __PBAS(CheckCollisionBoxes)         ;// Detect collision between two bounding boxes
        CheckCollisionBoxSphere.rl_bool(*in_box.ray::BoundingBox,
                                        *in_center.ray::_Vector3,
                                        radius.rl_float)                    __PBAS(CheckCollisionBoxSphere)     ;// Detect collision between box and sphere
        
        GetRayCollisionSphere(*out_Collision.ray::RayCollision,
                              *in_ray.ray::Ray, *center.ray::_Vector3, 
                              radius.rl_float)                              __PBAS(GetRayCollisionSphere)       ;// Get collision info between ray And sphere
        GetRayCollisionBox(*out_Collision.ray::RayCollision, 
                           *in_ray.ray::Ray, *in_box.ray::BoundingBox)      __PBAS(GetRayCollisionBox)          ;// Get collision info between ray and box
        GetRayCollisionMesh(*out_Collision.ray::RayCollision, 
                            *in_ray.ray::Ray, *in_mesh.ray::Mesh, 
                            *transform.ray::Matrix)                         __PBAS(GetRayCollisionMesh)         ;// Get collision info between ray and mesh
        GetRayCollisionTriangle(*out_Collision.ray::RayCollision, 
                                *in_ray.ray::Ray, *in_p1.ray::_Vector3, 
                                *in_p2.ray::_Vector3, 
                                *in_p3.ray::_Vector3)                       __PBAS(GetRayCollisionTriangle)     ;// Get collision info between ray and triangle
        GetRayCollisionQuad(*out_Collision.ray::RayCollision, 
                            *in_ray.ray::Ray, *in_p1.ray::_Vector3, 
                            *in_p2.ray::_Vector3, 
                            *in_p3.ray::_Vector3, *in_p4.ray::_Vector3)     __PBAS(GetRayCollisionQuad)         ;// Get collision info between ray and quad
        
        ;//------------------------------------------------------------------------------------
        ;// Audio Loading and Playing Functions (Module: audio)
        ;//------------------------------------------------------------------------------------
        
        ;// Audio device management functions
        InitAudioDevice()                                                     RLAS(InitAudioDevice)             ;// Initialize audio device and context
        CloseAudioDevice()                                                    RLAS(CloseAudioDevice)            ;// Close the audio device and context
        IsAudioDeviceReady.rl_bool()                                          RLAS(IsAudioDeviceReady)          ;// Check if audio device has been initialized successfully
        SetMasterVolume(volume.rl_float)                                      RLAS(SetMasterVolume)             ;// Set master volume (listener)
        
        ;// Wave/Sound loading/unloading functions
        LoadWave(*out_result.ray::Wave, fileName.p-utf8)                    __PBAS(LoadWave)                    ;// Load wave data from file
        LoadWaveFromMemory(*out_result.ray::Wave, fileType.p-utf8, 
                           *fileData, dataSize.rl_int)                      __PBAS(LoadWaveFromMemory)          ;// Load wave from memory buffer, fileType refers to extension: i.e. '.wav'
        LoadSoundRaylib(*out_result.ray::Sound, fileName.p-utf8)            __PBAS(LoadSound)                   ;// Load sound from file
        LoadSoundFromWave(*out_result.ray::Sound, *in_wave.ray::Wave)       __PBAS(LoadSoundFromWave)           ;// Load sound from wave data
        UpdateSound(*inout_sound.ray::Sound, *in_data, samplesCount.rl_int) __PBAS(UpdateSound)                 ;// Update sound buffer with new data
        UnloadWave(*in_wave.ray::Wave)                                      __PBAS(UnloadWave)                  ;// Unload wave data
        UnloadSound(*in_sound.ray::Sound)                                   __PBAS(UnloadSound)                 ;// Unload sound
        ExportWave.rl_bool(*in_wave.ray::Wave, fileName.p-utf8)             __PBAS(ExportWave)                  ;// Export wave data to file
        ExportWaveAsCode.rl_bool(*in_wave.ray::Wave, fileName.p-utf8)       __PBAS(ExportWaveAsCode)            ;// Export wave sample data to code (.h)
        
        ;// Wave/Sound management functions
        PlaySoundRaylib(*in_sound.ray::Sound)                               __PBAS(PlaySound)                   ;// Play a sound
        StopSoundRaylib(*in_sound.ray::Sound)                               __PBAS(StopSound)                   ;// Stop playing a sound
        PauseSoundRaylib(*in_sound.ray::Sound)                              __PBAS(PauseSound)                  ;// Pause a sound
        ResumeSoundRaylib(*in_sound.ray::Sound)                             __PBAS(ResumeSound)                 ;// Resume a paused sound
        PlaySoundMulti(*in_sound.ray::Sound)                                __PBAS(PlaySoundMulti)              ;// Play a sound (using multichannel buffer pool)
        StopSoundMulti()                                                      RLAS(StopSoundMulti)              ;// Stop any sound playing (using multichannel buffer pool)
        GetSoundsPlaying.rl_int()                                             RLAS(GetSoundsPlaying)            ;// Get number of sounds playing in the multichannel
        IsSoundPlaying.rl_bool(*in_sound.ray::Sound)                        __PBAS(IsSoundPlaying)              ;// Check if a sound is currently playing
        SetSoundVolume(*in_sound.ray::Sound, volume.rl_float)               __PBAS(SetSoundVolume)              ;// Set volume for a sound (1.0 is max level)
        SetSoundPitch(*in_sound.ray::Sound, pitch.rl_float)                 __PBAS(SetSoundPitch)               ;// Set pitch for a sound (1.0 is base level)
        SetSoundPan(*in_sound.ray::Sound, pan.rl_float)                     __PBAS(SetSoundPan)                 ;// Set pan for a sound (0.5 is center)
        WaveCopy(*out_result.ray::Wave, *in_sourceWave.ray::Wave)           __PBAS(WaveCopy)                    ;// Copy a wave to a new wave
        WaveCrop(*inout_wave.ray::Wave, initSample.rl_int,
                 finalSample.rl_int)                                          RLAS(WaveCrop)                    ;// Crop a wave to defined samples range
        WaveFormat(*inout_wave.ray::Wave, sampleRate.rl_int,
                   sampleSize.rl_int, channels.rl_int)                        RLAS(WaveFormat)                  ;// Convert wave data to desired format
        LoadWaveSamples.i(*in_wave.ray::Wave)                                 RLAS(LoadWaveSamples)             ;// Load samples data from wave as a 32bit float data array
        UnloadWaveSamples(*samples.float)                                     RLAS(UnloadWaveSamples)           ;// Unload samples data loaded with LoadWaveSamples()
        
        ;// Music management functions
        LoadMusicStream(*out_result.ray::Music, fileName.p-utf8)            __PBAS(LoadMusicStream)             ;// Load music stream from file
        LoadMusicStreamFromMemory(*out_result.ray::Music, 
                                  fileType.p-utf8, *in_data, 
                                  dataSize.rl_int)                          __PBAS(LoadMusicStreamFromMemory)   ;// Load music stream from data
        UnloadMusicStream(*in_music.ray::Music)                             __PBAS(UnloadMusicStream)           ;// Unload music stream
        PlayMusicStream(*in_music.ray::Music)                               __PBAS(PlayMusicStream)             ;// Start music playing
        IsMusicStreamPlaying.rl_bool(*in_music.ray::Music)                  __PBAS(IsMusicStreamPlaying)        ;// Check if music is playing
        UpdateMusicStream(*in_music.ray::Music)                             __PBAS(UpdateMusicStream)           ;// Updates buffers for music streaming
        StopMusicStream(*in_music.ray::Music)                               __PBAS(StopMusicStream)             ;// Stop music playing
        PauseMusicStream(*in_music.ray::Music)                              __PBAS(PauseMusicStream)            ;// Pause music playing
        ResumeMusicStream(*in_music.ray::Music)                             __PBAS(ResumeMusicStream)           ;// Resume playing paused music
        SeekMusicStream(*in_music.ray::Music, position.rl_float)            __PBAS(SeekMusicStream)             ;// Seek music to a position (in seconds)
        SetMusicVolume(*in_music.ray::Music, volume.rl_float)               __PBAS(SetMusicVolume)              ;// Set volume for music (1.0 is max level)
        SetMusicPitch(*in_music.ray::Music, pitch.rl_float)                 __PBAS(SetMusicPitch)               ;// Set pitch for a music (1.0 is base level)
        SetMusicPan(*in_music.ray::Music, pan.rl_float)                     __PBAS(SetMusicPan)                 ;// Set pan for a music (0.5 is center)
        GetMusicTimeLength.rl_float(*in_music.ray::Music)                   __PBAS(GetMusicTimeLength)          ;// Get music time length (in seconds)
        GetMusicTimePlayed.rl_float(*in_music.ray::Music)                   __PBAS(GetMusicTimePlayed)          ;// Get current music time played (in seconds)
        
        ;// AudioStream management functions
        LoadAudioStream(*out_result.ray::AudioStream, sampleRate.rl_uint,
                        sampleSize.rl_uint, channels.rl_uint)               __PBAS(LoadAudioStream)             ;// Init audio stream (to stream raw audio pcm data)
        UnloadAudioStream(*in_stream.ray::AudioStream)                      __PBAS(UnloadAudioStream)           ;// Unload audio stream and free memory
        UpdateAudioStream(*in_stream.ray::AudioStream, *in_data,
                          samplesCount.rl_int)                              __PBAS(UpdateAudioStream)           ;// Update audio stream buffers with data
        IsAudioStreamProcessed.rl_bool(*in_stream.ray::AudioStream)         __PBAS(IsAudioStreamProcessed)      ;// Check if any audio stream buffers requires refill
        PlayAudioStream(*in_stream.ray::AudioStream)                        __PBAS(PlayAudioStream)             ;// Play audio stream
        PauseAudioStream(*in_stream.ray::AudioStream)                       __PBAS(PauseAudioStream)            ;// Pause audio stream
        ResumeAudioStream(*in_stream.ray::AudioStream)                      __PBAS(ResumeAudioStream)           ;// Resume audio stream
        IsAudioStreamPlaying.rl_bool(*in_stream.ray::AudioStream)           __PBAS(IsAudioStreamPlaying)        ;// Check if audio stream is playing
        StopAudioStream(*in_stream.ray::AudioStream)                        __PBAS(StopAudioStream)             ;// Stop audio stream
        SetAudioStreamVolume(*in_stream.ray::AudioStream, volume.rl_float)  __PBAS(SetAudioStreamVolume)        ;// Set volume for audio stream (1.0 is max level)
        SetAudioStreamPitch(*in_stream.ray::AudioStream, pitch.rl_float)    __PBAS(SetAudioStreamPitch)         ;// Set pitch for audio stream (1.0 is base level)
        SetAudioStreamPan(*in_stream.ray::AudioStream, pan.rl_float)        __PBAS(SetAudioStreamPan)           ;// Set pan for audio stream (0.5 is centered)
        SetAudioStreamBufferSizeDefault(size.rl_int)                          RLAS(SetAudioStreamBufferSizeDefault) ;// Default size for new audio streams
        SetAudioStreamCallback(*in_stream.ray::AudioStream, *callback)      __PBAS(SetAudioStreamCallback)          ;// Audio thread callback to request new data
        AttachAudioStreamProcessor(*in_stream.ray::AudioStream, *processor) __PBAS(AttachAudioStreamProcessor)      ;// Attach audio stream processor to stream
        DetachAudioStreamProcessor(*in_stream.ray::AudioStream, *processor) __PBAS(DetachAudioStreamProcessor)      ;// Detach audio stream processor from stream
        
        ;-Import "rlgl.h"
        ;//------------------------------------------------------------------------------------
        ;// Functions Declaration - Matrix operations
        ;//------------------------------------------------------------------------------------

        rlMatrixMode(mode.rl_int)                                             RLAS(rlMatrixMode)                    ;// Choose the current matrix to be transformed
        rlPushMatrix()                                                        RLAS(rlPushMatrix)                    ;// Push the current matrix to stack
        rlPopMatrix()                                                         RLAS(rlPopMatrix)                     ;// Pop lattest inserted matrix from stack
        rlLoadIdentity()                                                      RLAS(rlLoadIdentity)                  ;// Reset current matrix to identity matrix
        rlTranslatef(x.rl_float, y.rl_float, z.rl_float)                      RLAS(rlTranslatef)                    ;// Multiply the current matrix by a translation matrix
        rlRotatef(angle.rl_float, x.rl_float, y.rl_float, z.rl_float)         RLAS(rlRotatef)                       ;// Multiply the current matrix by a rotation matrix
        rlScalef(x.rl_float, y.rl_float, z.rl_float)                          RLAS(rlScalef)                        ;// Multiply the current matrix by a scaling matrix
        rlMultMatrixf(*matf.float)                                            RLAS(rlMultMatrixf)                   ;// Multiply the current matrix by another matrix
        rlFrustum(left.rl_double, right.rl_double, bottom.rl_double, 
                  top.rl_double, znear.rl_double, zfar.rl_double)             RLAS(rlFrustum)
        rlOrtho(left.rl_double, right.rl_double, bottom.rl_double, 
                top.rl_double, znear.rl_double, zfar.rl_double)               RLAS(rlOrtho)
        rlViewport(x.rl_int, y.rl_int, width.rl_int, height.rl_int)           RLAS(rlViewport)                      ;// Set the viewport area

        ;//------------------------------------------------------------------------------------
        ;// Functions Declaration - Vertex level operations
        ;//------------------------------------------------------------------------------------
        rlBegin(mode.rl_int)                                                  RLAS(rlBegin)                         ;// Initialize drawing mode (how to organize vertex)
        rlEnd()                                                               RLAS(rlEnd)                           ;// Finish vertex providing
        rlVertex2i(x.rl_int, y.rl_int)                                        RLAS(rlVertex2i)                      ;// Define one vertex (position) - 2 int
        rlVertex2f(x.rl_float, y.rl_float)                                    RLAS(rlVertex2f)                      ;// Define one vertex (position) - 2 float
        rlVertex3f(x.rl_float, y.rl_float, z.rl_float)                        RLAS(rlVertex3f)                      ;// Define one vertex (position) - 3 float
        rlTexCoord2f(x.rl_float, y.rl_float)                                  RLAS(rlTexCoord2f)                    ;// Define one vertex (texture coordinate) - 2 float
        rlNormal3f(x.rl_float, y.rl_float, z.rl_float)                        RLAS(rlNormal3f)                      ;// Define one vertex (normal) - 3 float
        rlColor4ub(r.a, g.a, b.a, a.a)                                        RLAS(rlColor4ub)                      ;// Define one vertex (color) - 4 byte
        rlColor3f(x.rl_float, y.rl_float, z.rl_float)                         RLAS(rlColor3f)                       ;// Define one vertex (color) - 3 float
        rlColor4f(x.rl_float, y.rl_float, z.rl_float, w.rl_float)             RLAS(rlColor4f)                       ;// Define one vertex (color) - 4 float

        ;//------------------------------------------------------------------------------------
        ;// Functions Declaration - OpenGL style functions (common To 1.1, 3.3+, ES2)
        ;// NOTE: This functions are used To completely abstract raylib code from OpenGL layer,
        ;// some of them are direct wrappers over OpenGL calls, some others are custom
        ;//------------------------------------------------------------------------------------

        ;// Vertex buffers state
        rlEnableVertexArray(vaoId.rl_uint)                                    RLAS(rlEnableVertexArray)             ;// Enable vertex array (VAO, if supported)
        rlDisableVertexArray()                                                RLAS(rlDisableVertexArray)            ;// Disable vertex array (VAO, if supported)
        rlEnableVertexBuffer(id.rl_uint)                                      RLAS(rlEnableVertexBuffer)            ;// Enable vertex buffer (VBO)
        rlDisableVertexBuffer()                                               RLAS(rlDisableVertexBuffer)           ;// Disable vertex buffer (VBO)
        rlEnableVertexBufferElement(id.rl_uint)                               RLAS(rlEnableVertexBufferElement)     ;// Enable vertex buffer element (VBO element)
        rlDisableVertexBufferElement()                                        RLAS(rlDisableVertexBufferElement)    ;// Disable vertex buffer element (VBO element)
        rlEnableVertexAttribute(index.rl_uint)                                RLAS(rlEnableVertexAttribute)         ;// Enable vertex attribute index
        rlDisableVertexAttribute(index.rl_uint)                               RLAS(rlDisableVertexAttribute)        ;// Disable vertex attribute index
        CompilerIf Defined(GRAPHICS_API_OPENGL_11, #PB_Constant)
          rlEnableStatePointer(vertexAttribType.rl_int, *buffer)              RLAS(rlEnableStatePointer)            ;// Enable attribute state pointer
          rlDisableStatePointer(vertexAttribType.rl_int)                      RLAS(rlDisableStatePointer)           ;// Disable attribute state pointer
        CompilerEndIf

        ;// Textures state
        rlActiveTextureSlot(slot.rl_int)                                      RLAS(rlActiveTextureSlot)             ;// Select and active a texture slot
        rlEnableTexture(id.rl_uint)                                           RLAS(rlEnableTexture)                 ;// Enable texture
        rlDisableTexture()                                                    RLAS(rlDisableTexture)                ;// Disable texture
        rlEnableTextureCubemap(id.rl_uint)                                    RLAS(rlEnableTextureCubemap)          ;// Enable texture cubemap
        rlDisableTextureCubemap()                                             RLAS(rlDisableTextureCubemap)         ;// Disable texture cubemap
        rlTextureParameters(id.rl_uint, param.rl_int, value.rl_int)           RLAS(rlTextureParameters)             ;// Set texture parameters (filter, wrap)

        ;// Shader state
        rlEnableShader(id.rl_uint)                                            RLAS(rlEnableShader)                  ;// Enable shader program
        rlDisableShader()                                                     RLAS(rlDisableShader)                 ;// Disable shader program

        ;// Framebuffer state
        rlEnableFramebuffer(id.rl_uint)                                       RLAS(rlEnableFramebuffer)             ;// Enable render texture (fbo)
        rlDisableFramebuffer()                                                RLAS(rlDisableFramebuffer)            ;// Disable render texture (fbo), return to default framebuffer
        rlActiveDrawBuffers(count.rl_int)                                     RLAS(rlActiveDrawBuffers)             ;// Activate multiple draw color buffers

        ;// General render state
        rlEnableColorBlend()                                                  RLAS(rlEnableColorBlend)              ;// Enable color blending
        rlDisableColorBlend()                                                 RLAS(rlDisableColorBlend)             ;// Disable color blending
        rlEnableDepthTest()                                                   RLAS(rlEnableDepthTest)               ;// Enable depth test
        rlDisableDepthTest()                                                  RLAS(rlDisableDepthTest)              ;// Disable depth test
        rlEnableDepthMask()                                                   RLAS(rlEnableDepthMask)               ;// Enable depth write
        rlDisableDepthMask()                                                  RLAS(rlDisableDepthMask)              ;// Disable depth write
        rlEnableBackfaceCulling()                                             RLAS(rlEnableBackfaceCulling)         ;// Enable backface culling
        rlDisableBackfaceCulling()                                            RLAS(rlDisableBackfaceCulling)        ;// Disable backface culling
        rlEnableScissorTest()                                                 RLAS(rlEnableScissorTest)             ;// Enable scissor test
        rlDisableScissorTest()                                                RLAS(rlDisableScissorTest)            ;// Disable scissor test
        rlScissor(x.rl_int, y.rl_int, width.rl_int, height.rl_int)            RLAS(rlScissor)                       ;// Scissor test
        rlEnableWireMode()                                                    RLAS(rlEnableWireMode)                ;// Enable wire mode
        rlDisableWireMode()                                                   RLAS(rlDisableWireMode)               ;// Disable wire mode
        rlSetLineWidth(width.rl_float)                                        RLAS(rlSetLineWidth)                  ;// Set the line drawing width
        rlGetLineWidth.rl_float()                                             RLAS(rlGetLineWidth)                  ;// Get the line drawing width
        rlEnableSmoothLines()                                                 RLAS(rlEnableSmoothLines)             ;// Enable line aliasing
        rlDisableSmoothLines()                                                RLAS(rlDisableSmoothLines)            ;// Disable line aliasing
        rlEnableStereoRender()                                                RLAS(rlEnableStereoRender)            ;// Enable stereo rendering
        rlDisableStereoRender()                                               RLAS(rlDisableStereoRender)           ;// Disable stereo rendering
        rlIsStereoRenderEnabled.rl_bool()                                     RLAS(rlIsStereoRenderEnabled)         ;// Check if stereo render is enabled

        rlClearColor(r.a, g.a, b.a, a.a)                                      RLAS(rlClearColor)                    ;// Clear color buffer with color
        rlClearScreenBuffers()                                                RLAS(rlClearScreenBuffers)            ;// Clear used screen buffers (color and depth)
        rlCheckErrors()                                                       RLAS(rlCheckErrors)                   ;// Check and log OpenGL error codes
        rlSetBlendMode(mode.rl_int)                                           RLAS(rlSetBlendMode)                  ;// Set blending mode
        rlSetBlendFactors(glSrcFactor.rl_int, glDstFactor.rl_int, 
                          glEquation.rl_int)                                  RLAS(rlSetBlendFactors)               ;// Set blending mode factor and equation (using OpenGL factors)

        ;//------------------------------------------------------------------------------------
        ;// Functions Declaration - rlgl functionality
        ;//------------------------------------------------------------------------------------
        ;// rlgl initialization functions
        rlglInit(width.rl_int, height.rl_int)                                 RLAS(rlglInit)                        ;// Initialize rlgl (buffers, shaders, textures, states)
        rlglClose()                                                           RLAS(rlglClose)                       ;// De-inititialize rlgl (buffers, shaders, textures)
        rlLoadExtensions(*loader)                                             RLAS(rlLoadExtensions)                ;// Load OpenGL extensions (loader function required)
        rlGetVersion.rl_int()                                                 RLAS(rlGetVersion)                    ;// Get current OpenGL version
        rlSetFramebufferWidth(width.rl_int)                                   RLAS(rlSetFramebufferWidth)           ;// Set current framebuffer width
        rlGetFramebufferWidth.rl_int()                                        RLAS(rlGetFramebufferWidth)           ;// Get default framebuffer width
        rlSetFramebufferHeight(height.rl_int)                                 RLAS(rlSetFramebufferHeight)          ;// Set current framebuffer height
        rlGetFramebufferHeight.rl_int()                                       RLAS(rlGetFramebufferHeight)          ;// Get default framebuffer height

        rlGetTextureIdDefault.rl_uint()                                       RLAS(rlGetTextureIdDefault)           ;// Get default texture id
        rlGetShaderIdDefault.rl_uint()                                        RLAS(rlGetShaderIdDefault)            ;// Get default shader id
        rlGetShaderLocsDefault.i()                                            RLAS(rlGetShaderLocsDefault)          ;// Get default shader locations

        ;// Render batch management
        ;// NOTE: rlgl provides a Default render batch To behave like OpenGL 1.1 immediate mode
        ;// but this render batch API is exposed in Case of custom batches are required
        rlLoadRenderBatch(*result.ray::rlRenderBatch, numBuffers.rl_int, 
                          bufferElements.rl_int)                            __PBAS(rlLoadRenderBatch)               ;// Load a render batch system
        rlUnloadRenderBatch(*batch.ray::rlRenderBatch)                      __PBAS(rlUnloadRenderBatch)             ;// Unload render batch system
        rlDrawRenderBatch(*batch.ray::rlRenderBatch)                        __PBAS(rlDrawRenderBatch)               ;// Draw render batch data (Update->Draw->Reset)
        rlSetRenderBatchActive(*batch.ray::rlRenderBatch)                   __PBAS(rlSetRenderBatchActive)          ;// Set the active render batch for rlgl (NULL for default internal)
        rlDrawRenderBatchActive()                                             RLAS(rlDrawRenderBatchActive)         ;// Update and draw internal render batch
        rlCheckRenderBatchLimit.rl_bool(vCount.rl_int)                        RLAS(rlCheckRenderBatchLimit)         ;// Check internal buffer overflow for a given number of vertex
        rlSetTexture(id.rl_uint)                                              RLAS(rlSetTexture)                    ;// Set current texture for render batch and check buffers limits

        ;//------------------------------------------------------------------------------------------------------------------------

        ;// Vertex buffers management
        rlLoadVertexArray.rl_uint()                                           RLAS(rlLoadVertexArray)               ;// Load vertex Array (vao) If supported
        rlLoadVertexBuffer.rl_uint(*buffer, size.rl_int, dynamic.rl_bool)     RLAS(rlLoadVertexBuffer)              ;// Load a vertex buffer attribute
        rlLoadVertexBufferElement.rl_uint(*buffer, size.rl_int, 
                                          dynamic.rl_bool)                    RLAS(rlLoadVertexBufferElement)       ;// Load a new attributes element buffer
        rlUpdateVertexBuffer(bufferId.rl_uint, *p_data, dataSize.rl_int, 
                             offset.rl_int)                                   RLAS(rlUpdateVertexBuffer)            ;// Update GPU buffer with new data
        rlUpdateVertexBufferElements(id.rl_uint, *p_data, dataSize.rl_int, 
                                     offset.rl_int)                           RLAS(rlUpdateVertexBufferElements)    ;// Update vertex buffer elements with new data
        rlUnloadVertexArray(vaoId.rl_uint)                                    RLAS(rlUnloadVertexArray)
        rlUnloadVertexBuffer(vboId.rl_uint)                                   RLAS(rlUnloadVertexBuffer)
        rlSetVertexAttribute(index.rl_uint, compSize.rl_int, type.rl_int, 
                             normalized.rl_bool, stride.rl_int, *pointer)     RLAS(rlSetVertexAttribute)
        rlSetVertexAttributeDivisor(index.rl_uint, divisor.rl_int)            RLAS(rlSetVertexAttributeDivisor)
        rlSetVertexAttributeDefault(locIndex.rl_int, *value, 
                                    attribType.rl_int, count.rl_int)          RLAS(rlSetVertexAttributeDefault)     ;// Set vertex attribute default value
        rlDrawVertexArray(offset.rl_int, count.rl_int)                        RLAS(rlDrawVertexArray)
        rlDrawVertexArrayElements(offset.rl_int, count.rl_int, *buffer)       RLAS(rlDrawVertexArrayElements)
        rlDrawVertexArrayInstanced(offset.rl_int, count.rl_int, 
                                   instances.rl_int)                          RLAS(rlDrawVertexArrayInstanced)
        rlDrawVertexArrayElementsInstanced(offset.rl_int, count.rl_int, 
                                           *buffer, instances.rl_int)         RLAS(rlDrawVertexArrayElementsInstanced)

        ;// Textures management
        rlLoadTexture.rl_uint(*p_data, width.rl_int, height.rl_int, 
                              format.rl_int, mipmapCount.rl_int)              RLAS(rlLoadTexture)                   ;// Load texture in GPU
        rlLoadTextureDepth.rl_uint(width.rl_int, height.rl_int, 
                                   useRenderBuffer.rl_bool)                   RLAS(rlLoadTextureDepth)              ;// Load depth texture/renderbuffer (to be attached to fbo)
        rlLoadTextureCubemap.rl_uint(*p_data, size.rl_int, format.rl_int)     RLAS(rlLoadTextureCubemap)            ;// Load texture cubemap
        rlUpdateTexture(id.rl_uint, offsetX.rl_int, offsetY.rl_int, 
                        width.rl_int, height.rl_int, format.rl_int, *p_data)  RLAS(rlUpdateTexture)                 ;// Update GPU texture with new data
        rlGetGlTextureFormats(format.rl_int, *glInternalFormat.long, 
                              *glFormat.long, *glType.long)                   RLAS(rlGetGlTextureFormats)           ;// Get OpenGL internal formats
        rlGetPixelFormatName.i(format.rl_uint)                                RLAS(rlGetPixelFormatName)            ;// Get name string for pixel format
        rlUnloadTexture(id.rl_uint)                                           RLAS(rlUnloadTexture)                 ;// Unload texture from GPU memory
        rlGenTextureMipmaps(id.rl_uint, width.rl_int, height.rl_int, 
                            format.rl_int, *mipmaps.long)                     RLAS(rlGenTextureMipmaps)             ;// Generate mipmap data for selected texture
        rlReadTexturePixels.i(id.rl_uint, width.rl_int, height.rl_int, 
                              format.rl_int)                                  RLAS(rlReadTexturePixels)             ;// Read texture pixel data
        rlReadScreenPixels.i(width.rl_int, height.rl_int)                     RLAS(rlReadScreenPixels)              ;// Read screen pixel data (color buffer)

        ;// Framebuffer management (fbo)
        rlLoadFramebuffer.rl_uint(width.rl_int, height.rl_int)                RLAS(rlLoadFramebuffer)               ;// Load an empty framebuffer
        rlFramebufferAttach(fboId.rl_uint, texId.rl_uint, attachType.rl_int, 
                            texType.rl_int, mipLevel.rl_int)                  RLAS(rlFramebufferAttach)             ;// Attach texture/renderbuffer to a framebuffer
        rlFramebufferComplete.rl_bool(id.rl_uint)                             RLAS(rlFramebufferComplete)           ;// Verify framebuffer is complete
        rlUnloadFramebuffer(id.rl_uint)                                       RLAS(rlUnloadFramebuffer)             ;// Delete framebuffer from GPU

        ;// Shaders management
        rlLoadShaderCode.rl_uint(vsCode.p-utf8, fsCode.p-utf8)                RLAS(rlLoadShaderCode)                ;// Load shader from code strings
        rlCompileShader.rl_uint(shaderCode.p-utf8, type.rl_int)               RLAS(rlCompileShader)                 ;// Compile custom shader and return shader id (type: RL_VERTEX_SHADER, RL_FRAGMENT_SHADER, RL_COMPUTE_SHADER)
        rlLoadShaderProgram.rl_uint(vShaderId.rl_uint, fShaderId.rl_uint)     RLAS(rlLoadShaderProgram)             ;// Load custom shader program
        rlUnloadShaderProgram(id.rl_uint)                                     RLAS(rlUnloadShaderProgram)           ;// Unload shader program
        rlGetLocationUniform.rl_int(shaderId.rl_uint, uniformName.p-utf8)     RLAS(rlGetLocationUniform)            ;// Get shader location uniform
        rlGetLocationAttrib.rl_int(shaderId.rl_uint, attribName.p-utf8)       RLAS(rlGetLocationAttrib)             ;// Get shader location attribute
        rlSetUniform(locIndex.rl_int, *value, 
                     uniformType.rl_int, count.rl_int)                        RLAS(rlSetUniform)                    ;// Set shader value uniform
        rlSetUniformMatrix(locIndex.rl_int, *mat.ray::Matrix)               __PBAS(rlSetUniformMatrix)              ;// Set shader value matrix
        rlSetUniformSampler(locIndex.rl_int, textureId.rl_uint)               RLAS(rlSetUniformSampler)             ;// Set shader value sampler
        rlSetShader(id.rl_uint, *locs.long)                                   RLAS(rlSetShader)                     ;// Set shader currently active (id And locations)

        ;// Compute shader management
        rlLoadComputeShaderProgram.rl_uint(shaderId.rl_uint)                  RLAS(rlLoadComputeShaderProgram)      ;// Load compute shader program
        rlComputeShaderDispatch(groupX.rl_uint, groupY.rl_uint, 
                                groupZ.rl_uint)                               RLAS(rlComputeShaderDispatch)         ;// Dispatch compute shader (equivalent to *draw* for graphics pilepine)

        ;// Shader buffer storage object management (ssbo)
        rlLoadShaderBuffer.rl_uint(size.rl_quad, *p_data, usageHint.rl_int)   RLAS(rlLoadShaderBuffer)              ;// Load shader storage buffer object (SSBO)
        rlUnloadShaderBuffer(ssboId.rl_uint)                                  RLAS(rlUnloadShaderBuffer)            ;// Unload shader storage buffer object (SSBO)
        rlUpdateShaderBufferElements(id.rl_uint, *p_data, dataSize.rl_quad, 
                                     offset.rl_quad)                          RLAS(rlUpdateShaderBufferElements)    ;// Update SSBO buffer data
        rlGetShaderBufferSize.rl_quad(id.rl_uint)                             RLAS(rlGetShaderBufferSize)           ;// Get SSBO buffer size
        rlReadShaderBufferElements(id.rl_uint, *dest, count.rl_quad, 
                                   offset.rl_quad)                            RLAS(rlReadShaderBufferElements)      ;// Bind SSBO buffer
        rlBindShaderBuffer(id.rl_uint, index.rl_uint)                         RLAS(rlBindShaderBuffer)              ;// Copy SSBO buffer data

        ;// Buffer management
        rlCopyBuffersElements(destId.rl_uint, srcId.rl_uint, 
                              destOffset.rl_quad, srcOffset.rl_quad, 
                              count.rl_quad)                                  RLAS(rlCopyBuffersElements)           ;// Copy SSBO buffer data
        rlBindImageTexture(id.rl_uint, index.rl_uint, format.rl_uint, 
                           readonly.rl_int)                                   RLAS(rlBindImageTexture)              ;// Bind image texture

        ;// Matrix state management
        rlGetMatrixModelview(*result.ray::Matrix)                           __PBAS(rlGetMatrixModelview)            ;// Get internal modelview matrix
        rlGetMatrixProjection(*result.ray::Matrix)                          __PBAS(rlGetMatrixProjection)           ;// Get internal projection matrix
        rlGetMatrixTransform(*result.ray::Matrix)                           __PBAS(rlGetMatrixTransform)            ;// Get internal accumulated transform matrix
        rlGetMatrixProjectionStereo(*result.ray::Matrix, eye.rl_int)        __PBAS(rlGetMatrixProjectionStereo)     ;// Get internal projection matrix for stereo render (selected eye)
        rlGetMatrixViewOffsetStereo(*result.ray::Matrix, eye.rl_int)        __PBAS(rlGetMatrixViewOffsetStereo)     ;// Get internal view offset matrix for stereo render (selected eye)
        rlSetMatrixProjection(*proj.ray::Matrix)                            __PBAS(rlSetMatrixProjection)           ;// Set a custom projection matrix (replaces internal projection matrix)
        rlSetMatrixModelview(*view.ray::Matrix)                             __PBAS(rlSetMatrixModelview)            ;// Set a custom modelview matrix (replaces internal modelview matrix)
        rlSetMatrixProjectionStereo(*right.ray::Matrix, *left.ray::Matrix)  __PBAS(rlSetMatrixProjectionStereo)     ;// Set eyes projection matrices for stereo rendering
        rlSetMatrixViewOffsetStereo(*right.ray::Matrix, *left.ray::Matrix)  __PBAS(rlSetMatrixViewOffsetStereo)     ;// Set eyes view offsets matrices for stereo rendering
        
        ;// Quick And dirty cube/quad buffers load->draw->unload
        rlLoadDrawCube()                                                      RLAS(rlLoadDrawCube)                  ;// Load and draw a cube
        rlLoadDrawQuad()                                                      RLAS(rlLoadDrawQuad)                  ;// Load and draw a quad
        
;         ;- Import "libpartikel.h" - Functions
;         rlParticle_DeactivatorAge.rl_bool(*p.ray::Particle)                   __PBAS(Particle_DeactivatorAge)
;         rlParticle_New(*result.ray::Particle, *deactivatorFunc)               __PBAS(Particle_New)
;         rlParticle_Free(*p.ray::Particle)                                     __PBAS(Particle_Free)
;         rlParticle_Init(*p.ray::Particle, *cfg.ray::EmitterConfig)            __PBAS(Particle_Init)
;         rlParticle_Update(*p.ray::Particle, dt.rl_float)                      __PBAS(Particle_Update)
; 
;         rlEmitter_New(*result.ray::Emitter, *cfg.ray::EmitterConfig)          __PBAS(Emitter_New)
;         rlEmitter_Reinit.rl_bool(*e.ray::Emitter, *cfg.ray::EmitterConfig)    __PBAS(Emitter_Reinit)
;         rlEmitter_Start(*e.ray::Emitter)                                      __PBAS(Emitter_Start)
;         rlEmitter_Stop(*e.ray::Emitter)                                       __PBAS(Emitter_Stop)
;         rlEmitter_Free(*e.ray::Emitter)                                       __PBAS(Emitter_Free)
;         rlEmitter_Burst(*e.ray::Emitter)                                      __PBAS(Emitter_Burst)
;         rlEmitter_Update.rl_uint(*e.ray::Emitter, dt.rl_float)                __PBAS(Emitter_Update)
;         rlEmitter_Draw(*e.ray::Emitter)                                       __PBAS(Emitter_Draw)
; 
;         rlParticleSystem_New(*result.ray::ParticleSystem)                     __PBAS(ParticleSystem_New)
;         rlParticleSystem_Register.rl_bool(*ps.ray::ParticleSystem, 
;                                         *emitter.ray::Emitter)              __PBAS(ParticleSystem_Register)
;         rlParticleSystem_Deregister.rl_bool(*ps.ray::ParticleSystem, 
;                                           *emitter.ray::Emitter)            __PBAS(ParticleSystem_Deregister)
;         rlParticleSystem_SetOrigin(*ps.ray::ParticleSystem, 
;                                  *origin.ray::Vector2)                      __PBAS(ParticleSystem_SetOrigin)
;         rlParticleSystem_Start(*ps.ray::ParticleSystem)                       __PBAS(ParticleSystem_Start)
;         rlParticleSystem_Stop(*ps.ray::ParticleSystem)                        __PBAS(ParticleSystem_Stop)
;         rlParticleSystem_Burst(*ps.ray::ParticleSystem)                       __PBAS(ParticleSystem_Burst)
;         rlParticleSystem_Draw(*ps.ray::ParticleSystem)                        __PBAS(ParticleSystem_Draw)
;         rlParticleSystem_Update.rl_uint(*ps.ray::ParticleSystem, 
;                                         dt.rl_float)                        __PBAS(ParticleSystem_Update)
;         rlParticleSystem_Free(*ps.ray::ParticleSystem)                        __PBAS(ParticleSystem_Free)
      EndImport
      
      ImportC #ext_import : EndImport
      
      ;- ---------- Import Functions End
      ;} ---------- Import Functions End
      
      ;
      ; raylib helper procedures
      ;
      Declare.s GetMonitorName(monitor.rl_int)
      Declare.s GetClipboardTextRaylib()
      Declare.s LoadFileText(fileName.s)
      Declare.s GetFileName(filePath.s)
      Declare.s GetFileNameWithoutExt(filePath.s)
      Declare.s GetDirectoryPath(filePath.s)
      Declare.s GetPrevDirectoryPath(dirPath.s)
      Declare.s GetWorkingDirectory()
      Declare.s GetGamepadName(gamepad.rl_int)
      
      ;
      ; New procedures
      ;
      Declare InitVector2(*out.ray::Vector2, x.f = 0.0, y.f = 0.0)
      Declare Init_Vector3(*out.ray::_Vector3, x.f = 0.0, y.f = 0.0, z.f = 0.0)
      Declare Init_Vector4(*out.ray::_Vector4, x.f = 0.0, y.f = 0.0, z.f = 0.0, w.f = 0.0)
      Declare InitRectangle(*out.ray::Rectangle, x.f = 0.0, y.f = 0.0, width.f = 0.0, height.f = 0.0)
      
      ;
      ; Import-Function: "rlights.h"
      ;
      Declare UpdateLightValues(*shader.Shader, *light.Light)
      Declare CreateLightRayLib(*result.Light, type.rl_int, *position._Vector3, *target._Vector3, color.rl_ColorLong, *shader.Shader)
    
    EndDeclareModule
    ;- ---------- DeclareModule End
    ;} ---------- DeclareModule End
    
    
    
    ;- ---------- Module Start
    ;{ ---------- Module Start
    
    Module ray
      
      ;
      ; Raylib helper procedures
      ;
      Procedure.s GetMonitorName(monitor.rl_int)
        Protected *p_char = ray::__GetMonitorName(monitor)
        If *p_char
          ProcedureReturn PeekS(*p_char,-1,#PB_UTF8)
        EndIf
        ProcedureReturn ""
      EndProcedure
      
      Procedure.s GetClipboardTextRaylib()
        Protected *p_char = ray::__GetClipboardTextRaylib()
        If *p_char
          ProcedureReturn PeekS(*p_char,-1,#PB_UTF8)
        EndIf
        ProcedureReturn ""
      EndProcedure
      
      Procedure.s LoadFileText(fileName.s)
        Protected *p_char = ray::__LoadFileText(fileName)
        If *p_char
          ProcedureReturn PeekS(*p_char,-1,#PB_UTF8)
        EndIf
        ProcedureReturn ""
      EndProcedure
      
      Procedure.s GetFileName(filePath.s)
        Protected *p_char = ray::__GetFileName(filePath)
        If *p_char
          ProcedureReturn PeekS(*p_char,-1,#PB_UTF8)
        EndIf
        ProcedureReturn ""
      EndProcedure
      
      Procedure.s GetFileNameWithoutExt(filePath.s)
        Protected *p_char = ray::__GetFileNameWithoutExt(filePath)
        If *p_char
          ProcedureReturn PeekS(*p_char,-1,#PB_UTF8)
        EndIf
        ProcedureReturn ""
      EndProcedure
      
      Procedure.s GetDirectoryPath(filePath.s)
        Protected *p_char = ray::__GetDirectoryPath(filePath)
        If *p_char
          ProcedureReturn PeekS(*p_char,-1,#PB_UTF8)
        EndIf
        ProcedureReturn ""
      EndProcedure
      
      Procedure.s GetPrevDirectoryPath(dirPath.s)
        Protected *p_char = ray::__GetPrevDirectoryPath(dirPath)
        If *p_char
          ProcedureReturn PeekS(*p_char,-1,#PB_UTF8)
        EndIf
        ProcedureReturn ""
      EndProcedure
      
      Procedure.s GetWorkingDirectory()
        Protected *p_char = ray::__GetWorkingDirectory()
        If *p_char
          ProcedureReturn PeekS(*p_char,-1,#PB_UTF8)
        EndIf
        ProcedureReturn ""
      EndProcedure
      
      Procedure.s GetGamepadName(gamepad.rl_int)
        Protected *p_char = ray::__GetGamepadName(gamepad)
        If *p_char
          ProcedureReturn PeekS(*p_char,-1,#PB_UTF8)
        EndIf
        ProcedureReturn ""
      EndProcedure
      
      ;
      ; Additional procedures
      ;
      Procedure InitVector2(*out.ray::Vector2, x.f = 0.0, y.f = 0.0)
        If *out : *out\x = x : *out\y = y : EndIf
      EndProcedure
      
      Procedure Init_Vector3(*out.ray::_Vector3, x.f = 0.0, y.f = 0.0, z.f = 0.0)
        If *out : *out\x = x : *out\y = y : *out\z = z : EndIf
      EndProcedure
      
      Procedure Init_Vector4(*out.ray::_Vector4, x.f = 0.0, y.f = 0.0, z.f = 0.0, w.f = 0.0)
        If *out : *out\x = x : *out\y = y : *out\z = z : *out\w = w : EndIf
      EndProcedure
      
      Procedure InitRectangle(*out.ray::Rectangle, x.f = 0.0, y.f = 0.0, width.f = 0.0, height.f = 0.0)
        If *out : *out\x = x : *out\y = y : *out\width = width : *out\height = height : EndIf
      EndProcedure
      
      
      ;- Import "rlights.h" - Functions
      
      ;>TODO : Not working!!!
      
      ;// Send light properties To shader
      ;// NOTE: Light shader locations should be available 
      Procedure UpdateLightValues(*shader.ray::Shader, *light.ray::Light)
        ;// Send To shader light enabled state And type
        SetShaderValue(*shader, *light\enabledLoc, @*light\enabled, #UNIFORM_INT)
        SetShaderValue(*shader, *light\typeLoc, @*light\type, #UNIFORM_INT)
        
        ;// Send To shader light position values
        Dim position.rl_float(2)
        position(0) = *light\position\x
        position(1) = *light\position\y
        position(2) = *light\position\z
        
        SetShaderValue(*shader, *light\positionLoc, @position(), #UNIFORM_VEC3)
        
        ;// Send To shader light target position values
        Dim target.rl_float(2)
        target(0) = *light\target\x
        target(1) = *light\target\y
        target(2) = *light\target\z
        
        SetShaderValue(*shader, *light\targetLoc, @target(), #UNIFORM_VEC3)
        
        ;// Send To shader light color values
        Dim fcolor.rl_float(3) 
        ;fcolor(0) = Red(*light\color) / 255 ;PeekA(@*light\color + 0) / 255
        ;fcolor(1) = Green(*light\color) / 255 ;PeekA(@*light\color + 1) / 255
        ;fcolor(2) = Blue(*light\color) / 255 ;PeekA(@*light\color + 2) / 255
        ;fcolor(3) = Alpha(*light\color) / 255 ;PeekA(@*light\color + 3) / 255
        
        PokeF(@fcolor(0), Red(*light\color) / 255)
        PokeF(@fcolor(1), Green(*light\color) / 255)
        PokeF(@fcolor(2), Blue(*light\color) / 255)
        PokeF(@fcolor(3), Alpha(*light\color) / 255)
        
        SetShaderValue(*shader, *light\colorLoc, @fcolor(), #UNIFORM_VEC4)
      EndProcedure
      
      ;// Create a light And get shader locations
      Procedure CreateLightRayLib(*result.ray::Light, type.rl_int, *position.ray::_Vector3, *target.ray::_Vector3, color.rl_ColorLong, *shader.ray::Shader)
        Protected.ray::Light light
        
        If RL_LIGHTS_COUNT < #MAX_LIGHTS
          light\enabled = #True
          light\type = type
          Init_Vector3(@light\position, *position\x, *position\y, *position\z)
          Init_Vector3(@light\target, *target\x, *target\y, *target\z)
          PokeA(@light\color + 0, PeekA(@color + 0))
          PokeA(@light\color + 1, PeekA(@color + 1))
          PokeA(@light\color + 2, PeekA(@color + 2))
          PokeA(@light\color + 3, PeekA(@color + 3))
          
          ; NOTE: Lighting shader naming must be the provided ones
          light\enabledLoc = GetShaderLocation(*shader, "lights"+Str(RL_LIGHTS_COUNT)+".enabled")
          light\typeLoc = GetShaderLocation(*shader, "lights"+Str(RL_LIGHTS_COUNT)+".type")
          light\positionLoc = GetShaderLocation(*shader, "lights"+Str(RL_LIGHTS_COUNT)+".position")
          light\targetLoc = GetShaderLocation(*shader, "lights"+Str(RL_LIGHTS_COUNT)+".target")
          light\colorLoc = GetShaderLocation(*shader, "lights"+Str(RL_LIGHTS_COUNT)+".color")
          
          UpdateLightValues(*shader, @light)
          
          CopyMemory(@light, *result, SizeOf(Light))
          
          RL_LIGHTS_COUNT + 1
        EndIf
      EndProcedure
      
    EndModule
    ;- ---------- Module End
    ;} ---------- Module End
    
;  CompilerElse
;   CompilerError("The Ray library has mysterious bugs when used without a C backend with the normal ASM compiler.")
;  CompilerEndIf
 
 DisableExplicit
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 845
; FirstLine = 826
; Folding = -----------
; Optimizer
; EnableThread
; EnableXP
; Compiler = PureBasic 6.00 LTS (Windows - x64)