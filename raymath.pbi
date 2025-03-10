; /**********************************************************************************************
; *
; *   raymath v1.5 - Math functions To work With Vector2, Vector3, Matrix And Quaternions
; *
; *   CONFIGURATION:
; *
; *   #define RAYMATH_IMPLEMENTATION
; *       Generates the implementation of the library into the included file.
; *       If Not defined, the library is in header only mode And can be included in other headers
; *       Or source files without problems. But only ONE file should hold the implementation.
; *
; *   #define RAYMATH_STATIC_INLINE
; *       Define Static inline functions code, so #include header suffices For use.
; *       This may use up lots of memory.
; *
; *   CONVENTIONS:
; *
; *     - Functions are always self-contained, no function use another raymath function inside,
; *       required code is directly re-implemented inside
; *     - Functions input parameters are always received by value (2 unavoidable exceptions)
; *     - Functions use always a "result" variable For Return
; *     - Functions are always defined inline
; *     - Angles are always in radians (DEG2RAD/RAD2DEG macros provided For convenience)
; *
; *
; *   LICENSE: zlib/libpng
; *
; *   Copyright (c) 2015-2022 Ramon Santamaria (@raysan5)
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


;>----------------------------------------------------------------------------------
; Defines And Macros
;-----------------------------------------------------------------------------------
CompilerIf Not Defined(PI, #PB_Constant)
  #PI = 3.14159265358979323846f
CompilerEndIf

CompilerIf Not Defined(EPSILON, #PB_Constant)
  #EPSILON = 0.000001
CompilerEndIf

CompilerIf Not Defined(DEG2RAD, #PB_Constant)
  #DEG2RAD = #PI / 180.0
CompilerEndIf
  
CompilerIf Not Defined(RAD2DEG, #PB_Constant)
  #RAD2DEG = 180.0 / #PI
CompilerEndIf

Procedure.rl_int iMax(a.rl_int, b.rl_int)
 If a > b
  ProcedureReturn a
 EndIf
 ProcedureReturn b
EndProcedure

Procedure.rl_int iMin(a.rl_int, b.rl_int)
 If a < b
  ProcedureReturn a
 EndIf
 ProcedureReturn b
EndProcedure

Procedure.rl_float fMax(a.rl_float, b.rl_float)
 If a > b
  ProcedureReturn a
 EndIf
 ProcedureReturn b
EndProcedure

Procedure.rl_float fMin(a.rl_float, b.rl_float)
 If a < b
  ProcedureReturn a
 EndIf
 ProcedureReturn b
EndProcedure

Macro floor(x)
  Round(x, #PB_Round_Down)
EndMacro

Macro ceiling(x)
  Round(x, #PB_Round_Up)
EndMacro

; Get float vector For Matrix
Macro MatrixToFloat(mat)
  MatrixToFloatV(mat)
EndMacro

; Get float vector For Vector3
Macro Vector3ToFloat(vec)
  Vector3ToFloatV(vec)
EndMacro


;>----------------------------------------------------------------------------------
; Types And Structures Definition
;-----------------------------------------------------------------------------------

; NOTE: Helper types To be used instead of Array Return types For *ToFloat functions
Structure float3
  v.rl_float[3]
EndStructure

Structure float16
  v.rl_float[16]
EndStructure


;>----------------------------------------------------------------------------------
; Module Functions Definition - Utils math
;-----------------------------------------------------------------------------------

; Clamp float value
Procedure.rl_float Clamp(value.rl_float, min.rl_float, max.rl_float)
  Protected.rl_float result 
  
  If (value < min)
    result = min 
  Else
    result = value
  EndIf

  If (result > max) 
    result = max
  EndIf

  ProcedureReturn result
EndProcedure

; Calculate linear interpolation between two floats
Procedure.rl_float Lerp(start.rl_float, endValue.rl_float, amount.rl_float)
  Protected.rl_float result = start + amount * (endValue - start)

  ProcedureReturn result
EndProcedure

; Normalize input value within input range
Procedure.rl_float Normalize(value.rl_float, start.rl_float, endValue.rl_float)
  Protected.rl_float result = (value - start) / (endValue - start)

  ProcedureReturn result
EndProcedure

; Remap input value within input range To output range
Procedure.rl_float Remap(value.rl_float, inputStart.rl_float, inputEnd.rl_float, outputStart.rl_float, outputEnd.rl_float)
  Protected.rl_float result = (value - inputStart) / (inputEnd - inputStart) * (outputEnd - outputStart) + outputStart

  ProcedureReturn result
EndProcedure

; Wrap input value from min To max
Procedure.rl_float Wrap(value.rl_float, min.rl_float, max.rl_float)
  Protected.rl_float result = value - (max - min) * floor((value - min) / (max - min))

  ProcedureReturn result
EndProcedure

; Check whether two given floats are almost equal
Procedure.rl_bool FloatEquals(x.rl_float, y.rl_float)
  Protected.rl_bool result 
  
  result = Bool ( Abs(x - y) <= (#EPSILON * fMax(1.0, fMax(Abs(x), Abs(y)))) )
    
  ProcedureReturn result
EndProcedure

;>----------------------------------------------------------------------------------
; Module Functions Definition - Vector2 math
;-----------------------------------------------------------------------------------

; Vector With components value 0.0f
Procedure Vector2Zero(*result.Vector2)
  *result\x = 0.0
  *result\y = 0.0
EndProcedure

; Vector With components value 1.0f
Procedure Vector2One(*result.Vector2)
  *result\x = 1.0 
  *result\y = 1.0
EndProcedure

; Add two vectors (v1 + v2)
Procedure Vector2Add(*result.Vector2, *v1.Vector2, *v2.Vector2)
  *result\x = *v1\x + *v2\x
  *result\y = *v1\y + *v2\y
EndProcedure

; Add vector And float value
Procedure Vector2AddValue(*result.Vector2, *v.Vector2, add.rl_float)
  *result\x = *v\x + add 
  *result\y = *v\y + add
EndProcedure

; Subtract two vectors (v1 - v2)
Procedure Vector2Subtract(*result.Vector2, *v1.Vector2, *v2.Vector2)
  *result\x = *v1\x - *v2\x 
  *result\y = *v1\y - *v2\y
EndProcedure

; Subtract vector by float value
Procedure Vector2SubtractValue(*result.Vector2, *v.Vector2, sub.rl_float)
  *result\x = *v\x - sub 
  *result\y = *v\y - sub
EndProcedure

; Calculate vector length
Procedure.rl_float Vector2Length(*v.Vector2)
  Protected.rl_float result = Sqr((*v\x * *v\x) + (*v\y * *v\y))

  ProcedureReturn result
EndProcedure

; Calculate vector square length
Procedure.rl_float Vector2LengthSqr(*v.Vector2)
  Protected.rl_float result = (*v\x * *v\x) + (*v\y * *v\y)

  ProcedureReturn result
EndProcedure

; Calculate two vectors dot product
Procedure.rl_float Vector2DotProduct(*v1.Vector2, *v2.Vector2)
  Protected.rl_float result = (*v1\x * *v2\x + *v1\y * *v2\y)

  ProcedureReturn result
EndProcedure

; Calculate distance between two vectors
Procedure.rl_float Vector2Distance(*v1.Vector2, *v2.Vector2)
  Protected.rl_float result = Sqr((*v1\x - *v2\x) * (*v1\x - *v2\x) + (*v1\y - *v2\y) * (*v1\y - *v2\y))

  ProcedureReturn result
EndProcedure

; Calculate square distance between two vectors
Procedure.rl_float Vector2DistanceSqr(*v1.Vector2, *v2.Vector2)
  Protected.rl_float result = ((*v1\x - *v2\x) * (*v1\x - *v2\x) + (*v1\y - *v2\y) * (*v1\y - *v2\y))
    
  ProcedureReturn result
EndProcedure

; Calculate angle from two vectors
Procedure.rl_float Vector2Angle(*v1.Vector2, *v2.Vector2)
  Protected.rl_float result = ATan2(*v2\y, *v2\x) - ATan2(*v1\y, *v1\x)

  ProcedureReturn result
EndProcedure

; Scale vector (multiply by value)
Procedure Vector2Scale(*result.Vector2, *v.Vector2, scale.rl_float)
  *result\x = *v\x * scale 
  *result\y = *v\y * scale
EndProcedure

; Multiply vector by vector
Procedure Vector2Multiply(*result.Vector2, *v1.Vector2, *v2.Vector2)
  *result\x = *v1\x * *v2\x 
  *result\y = *v1\y * *v2\y
EndProcedure

; Negate vector
Procedure Vector2Negate(*result.Vector2, *v.Vector2)
  *result\x = -*v\x
  *result\y = -*v\y
EndProcedure

; Divide vector by vector
Procedure Vector2Divide(*result.Vector2, *v1.Vector2, *v2.Vector2)
  *result\x = *v1\x / *v2\x 
  *result\y = *v1\y / *v2\y
EndProcedure

; Normalize provided vector
Procedure Vector2Normalize(*result.Vector2, *v.Vector2)
  Protected.rl_float length = Sqr((*v\x * *v\x) + (*v\y * *v\y))
  Protected.rl_float ilength
  
  If length > 0
    ilength = 1.0 / length
    *result\x = *v\x * ilength
    *result\y = *v\y * ilength
  EndIf
EndProcedure

; Transforms a Vector2 by a given Matrix
Procedure Vector2Transform(*result.Vector2, *v.Vector2, *mat.Matrix)
  Protected.rl_float x = *v\x
  Protected.rl_float y = *v\y
  Protected.rl_float z = 0

  *result\x = *mat\m0 * x + *mat\m4 * y + *mat\m8 * z + *mat\m12
  *result\y = *mat\m1 * x + *mat\m5 * y + *mat\m9 * z + *mat\m13
EndProcedure

; Calculate linear interpolation between two vectors
Procedure Vector2Lerp(*result.Vector2, *v1.Vector2, *v2.Vector2, amount.rl_float)
  *result\x = *v1\x + amount * (*v2\x - *v1\x)
  *result\y = *v1\y + amount * (*v2\y - *v1\y)
EndProcedure

; Calculate reflected vector To normal
Procedure Vector2Reflect(*result.Vector2, *v.Vector2, *normal.Vector2)
  Protected.rl_float dotProduct = (*v\x * *normal\x + *v\y * *normal\y) ; Dot product

  *result\x = *v\x - (2.0 * *normal\x) * dotProduct
  *result\y = *v\y - (2.0 * *normal\y) * dotProduct

EndProcedure

; Rotate vector by angle
Procedure Vector2Rotate(*result.Vector2, *v.Vector2, angle.rl_float)
  Protected.rl_float cosres, sinres
  
  cosres = Cos(angle)
  sinres = Sin(angle)

  *result\x = *v\x * cosres - *v\y * sinres
  *result\y = *v\x * sinres + *v\y * cosres
EndProcedure

; Move Vector towards target
Procedure Vector2MoveTowards(*result.Vector2, *v.Vector2, *target.Vector2, maxDistance.rl_float)
  Protected.rl_float dx = *target\x - *v\x
  Protected.rl_float dy = *target\y - *v\y
  Protected.rl_float value = (dx * dx) + (dy * dy)
  Protected.rl_float dist

  If ((value = 0) Or ((maxDistance >= 0) And (value <= maxDistance * maxDistance))) 
    *result = *target
  EndIf
  
  dist = Sqr(value)

  *result\x = *v\x + dx / dist * maxDistance
  *result\y = *v\y + dy / dist * maxDistance
EndProcedure

; Invert the given vector
Procedure Vector2Invert(*result.Vector2, *v.Vector2)
  *result\x = 1.0 / *v\x 
  *result\y = 1.0 / *v\y
EndProcedure

; Clamp the components of the vector between
; min And max values specified by the given vectors
Procedure Vector2Clamp(*result.Vector2, *v.Vector2, *min.Vector2, *max.Vector2)
  *result\x = fMin(*max\x, fMax(*min\x, *v\x))
  *result\y = fMin(*max\y, fMax(*min\y, *v\y))
EndProcedure

; Clamp the magnitude of the vector between two min And max values
Procedure Vector2ClampValue(*result.Vector2, *v.Vector2, min.rl_float, max.rl_float)
  *result = *v

  Protected.rl_float length = (*v\x * *v\x) + (*v\y * *v\y)
  Protected.rl_float scale
  
  If length > 0.0
    length = Sqr(length)

    If length < min
      scale = min / length
      *result\x = *v\x * scale
      *result\y = *v\y * scale
    ElseIf length > max
      scale = max / length
      *result\x = *v\x * scale
      *result\y = *v\y * scale
    EndIf
  EndIf
EndProcedure

; Check whether two given vectors are almost equal
Procedure.rl_bool Vector2Equals(*p.Vector2, *q.Vector2)
  Protected.rl_bool result = Bool(((Abs(*p\x - *q\x)) <= (#EPSILON * fMax(1.0, fMax(Abs(*p\x), Abs(*q\x))))) And
                            ((Abs(*p\y - *q\y)) <= (#EPSILON * fMax(1.0, fMax(Abs(*p\y), Abs(*q\y))))))

  ProcedureReturn result
EndProcedure

;>----------------------------------------------------------------------------------
; Module Functions Definition - Vector3 math
;-----------------------------------------------------------------------------------

; Vector With components value 0.0f
Procedure Vector3Zero(*result._Vector3)
  Init_Vector3(*result, 0.0, 0.0, 0.0)
EndProcedure

; Vector With components value 1.0f
Procedure Vector3One(*result._Vector3)
  Init_Vector3(*result, 1.0, 1.0, 1.0)
EndProcedure

; Add two vectors
Procedure Vector3Add(*result._Vector3, *v1._Vector3, *v2._Vector3)
  *result\x = *v1\x + *v2\x 
  *result\y = *v1\y + *v2\y 
  *result\z = *v1\z + *v2\z
EndProcedure

; Add vector And float value
Procedure Vector3AddValue(*result._Vector3, *v._Vector3, add.rl_float)
  *result\x = *v\x + add
  *result\y = *v\y + add
  *result\z = *v\z + add
EndProcedure

; Subtract two vectors
Procedure Vector3Subtract(*result._Vector3, *v1._Vector3, *v2._Vector3)
  *result\x = *v1\x - *v2\x
  *result\y = *v1\y - *v2\y
  *result\z = *v1\z - *v2\z
EndProcedure

; Subtract vector by float value
Procedure Vector3SubtractValue(*result._Vector3, *v._Vector3, sub.rl_float)
  *result\x = *v\x - sub
  *result\y = *v\y - sub
  *result\z = *v\z - sub
EndProcedure

; Multiply vector by scalar
Procedure Vector3Scale(*result._Vector3, *v._Vector3, scalar.rl_float)
  *result\x = *v\x * scalar
  *result\y = *v\y * scalar
  *result\z = *v\z * scalar
EndProcedure

; Multiply vector by vector
Procedure Vector3Multiply(*result._Vector3, *v1._Vector3, *v2._Vector3)
  *result\x = *v1\x * *v2\x
  *result\y = *v1\y * *v2\y
  *result\z = *v1\z * *v2\z
EndProcedure

; Calculate two vectors cross product
Procedure Vector3CrossProduct(*result._Vector3, *v1._Vector3, *v2._Vector3)
    *result\x = *v1\y * *v2\z - *v1\z * *v2\y
    *result\y = *v1\z * *v2\x - *v1\x * *v2\z
    *result\z = *v1\x * *v2\y - *v1\y * *v2\x
EndProcedure

; Calculate one vector perpendicular vector
Procedure Vector3Perpendicular(*result._Vector3, *v.Vector3)
  Protected.rl_float min = Abs(*v\x)
  Protected._Vector3 cardinalAxis
  Protected._Vector3 tmp
  
  Init_Vector3(@cardinalAxis, 1.0, 0.0, 0.0)

  If Abs(*v\y) < min
    min = Abs(*v\y)
    Init_Vector3(@tmp, 0.0, 1.0, 0.0)
    cardinalAxis = tmp
  EndIf

  If Abs(*v\z) < min
    Init_Vector3(@tmp, 0.0, 0.0, 1.0)
    cardinalAxis = tmp
  EndIf

  ; Cross product between vectors
  *result\x = *v\y * cardinalAxis\z - *v\z * cardinalAxis\y
  *result\y = *v\z * cardinalAxis\x - *v\x * cardinalAxis\z
  *result\z = *v\x * cardinalAxis\y - *v\y * cardinalAxis\x
EndProcedure

; Calculate vector length
Procedure.rl_float Vector3Length(*v._Vector3)
  Protected.rl_float result = Sqr(*v\x * *v\x + *v\y * *v\y + *v\z * *v\z)

  ProcedureReturn result
EndProcedure

; Calculate vector square length
Procedure.rl_float Vector3LengthSqr(*v._Vector3)
  Protected.rl_float result = *v\x * *v\x + *v\y * *v\y + *v\z * *v\z

  ProcedureReturn result
EndProcedure

; Calculate two vectors dot product
Procedure.rl_float Vector3DotProduct(*v1._Vector3, *v2._Vector3)
  Protected.rl_float result = *v1\x * *v2\x + *v1\y * *v2\y + *v1\z * *v2\z

  ProcedureReturn result
EndProcedure

; Calculate distance between two vectors
Procedure.rl_float Vector3Distance(*v1._Vector3, *v2._Vector3)
  Protected.rl_float result = 0.0

  Protected.rl_float dx = *v2\x - *v1\x
  Protected.rl_float dy = *v2\y - *v1\y
  Protected.rl_float dz = *v2\z - *v1\z
  
  result = Sqr(dx * dx + dy * dy + dz * dz)

  ProcedureReturn result
EndProcedure

; Calculate square distance between two vectors
Procedure.rl_float Vector3DistanceSqr(*v1._Vector3, *v2._Vector3)
  Protected.rl_float result = 0.0

  Protected.rl_float dx = *v2\x - *v1\x
  Protected.rl_float dy = *v2\y - *v1\y
  Protected.rl_float dz = *v2\z - *v1\z
  
  result = dx * dx + dy * dy + dz * dz

  ProcedureReturn result
EndProcedure

; Calculate angle between two vectors
Procedure.rl_float Vector3Angle(*v1._Vector3, *v2._Vector3)
  Protected.rl_float result = 0.0
  Protected.rl_float len, dot
  Protected._Vector3 cross
  
  cross\x = *v1\y * *v2\z - *v1\z * *v2\y
  cross\y = *v1\z * *v2\x - *v1\x * *v2\z
  cross\z = *v1\x * *v2\y - *v1\y * *v2\x
  
  len = Sqr(cross\x * cross\x + cross\y * cross\y + cross\z * cross\z)
  dot = (*v1\x * *v2\x + *v1\y * *v2\y + *v1\z * *v2\z)
  
  result = ATan2(len, dot)

  ProcedureReturn result
EndProcedure

; Negate provided vector (invert direction)
Procedure Vector3Negate(*result._Vector3, *v._Vector3)
  *result\x = -*v\x
  *result\y = -*v\y
  *result\z = -*v\z
EndProcedure

; Divide vector by vector
Procedure Vector3Divide(*result._Vector3, *v1._Vector3, *v2._Vector3)
  *result\x = *v1\x / *v2\x 
  *result\y = *v1\y / *v2\y 
  *result\z = *v1\z / *v2\z
EndProcedure

; Normalize provided vector
Procedure Vector3Normalize(*result._Vector3, *v._Vector3)
  *result = *v

  Protected.rl_float length, ilength
  
  length = Sqr(*v\x * *v\x + *v\y * *v\y + *v\z * *v\z)
  
  If length = 0.0
    length = 1.0
  EndIf
  
  ilength = 1.0 / length

  *result\x * ilength
  *result\y * ilength
  *result\z * ilength

EndProcedure

; Orthonormalize provided vectors
; Makes vectors normalized And orthogonal To each other
; Gram-Schmidt function implementation
Procedure Vector3OrthoNormalize(*v1._Vector3, *v2._Vector3)
  Protected.rl_float length = 0.0
  Protected.rl_float ilength = 0.0

  ; Vector3Normalize(@v1)
  Protected._Vector3 v
  Protected._Vector3 vn1, vn2
  
  Init_Vector3(@v, *v1\x, *v1\y, *v1\z)
  
  length = Sqr(v\x * v\x + v\y * v\y + v\z * v\z)
  
  If length = 0.0 
    length = 1.0
  EndIf
  
  ilength = 1.0 / length
  *v1\x * ilength
  *v1\y * ilength
  *v1\z * ilength

  ; Vector3CrossProduct(@*v1, @*v2)
  vn1\x = *v1\y * *v2\z - *v1\z * *v2\y 
  vn1\y = *v1\z * *v2\x - *v1\x * *v2\z 
  vn1\z = *v1\x * *v2\y - *v1\y * *v2\x

  ; Vector3Normalize(@vn1);
  v = vn1
  length = Sqr(v\x * v\x + v\y * v\y + v\z * v\z)
  
  If length = 0.0 
    length = 1.0
  EndIf
  
  ilength = 1.0 / length
  vn1\x * ilength
  vn1\y * ilength
  vn1\z * ilength

  ; Vector3CrossProduct(@vn1, @*v1)
  vn2\x = vn1\y * *v1\z - vn1\z * *v1\y 
  vn2\y = vn1\z * *v1\x - vn1\x * *v1\z 
  vn2\z = vn1\x * *v1\y - vn1\y * *v1\x

  *v2 = vn2
EndProcedure

; Transforms a Vector3 by a given Matrix
Procedure Vector3Transform(*result._Vector3, *v._Vector3, *mat.Matrix)
  Protected.rl_float x = *v\x
  Protected.rl_float y = *v\y
  Protected.rl_float z = *v\z

  *result\x = *mat\m0 * x + *mat\m4 * y + *mat\m8 * z + *mat\m12
  *result\y = *mat\m1 * x + *mat\m5 * y + *mat\m9 * z + *mat\m13
  *result\z = *mat\m2 * x + *mat\m6 * y + *mat\m10 * z + *mat\m14
EndProcedure

; Transform a vector by quaternion rotation
Procedure Vector3RotateByQuaternion(*result._Vector3, *v._Vector3, *q.Quaternion)
  *result\x = *v\x * (*q\x * *q\x + *q\w * *q\w - *q\y * *q\y - *q\z * *q\z) + 
              *v\y * (2 * *q\x * *q\y - 2 * *q\w * *q\z) + *v\z * (2 * *q\x * *q\z + 2 * *q\w * *q\y)
  *result\y = *v\x * (2 * *q\w * *q\z + 2 * *q\x * *q\y) + *v\y * (*q\w * *q\w - *q\x * *q\x + *q\y * *q\y - *q\z * *q\z) +
              *v\z * (-2 * *q\w * *q\x + 2 * *q\y * *q\z)
  *result\z = *v\x * (-2 * *q\w * *q\y + 2 * *q\x * *q\z) + *v\y * (2 * *q\w * *q\x + 2 * *q\y * *q\z) + 
              *v\z * (*q\w * *q\w - *q\x * *q\x - *q\y * *q\y + *q\z * *q\z)
EndProcedure

; Rotates a vector around an axis
Procedure Vector3RotateByAxisAngle(*result._Vector3, *v._Vector3, *axis._Vector3, angle.rl_float)
  ; Using Euler-Rodrigues Formula
  ; Ref.: https://en.wikipedia.org/w/index.php?title=Euler%E2%80%93Rodrigues_formula
  Protected.rl_float length, ilength
  Protected.rl_float a, b, c, d
  Protected._Vector3 w, wv, wwv
  
  *result = *v

  ; Vector3Normalize(axis);
  length = Sqr(*axis\x * *axis\x + *axis\y * *axis\y + *axis\z * *axis\z)
  
  If length = 0.0 
    length = 1.0
  EndIf
  
  ilength = 1.0 / length
  
  *axis\x * ilength
  *axis\y * ilength
  *axis\z * ilength

  angle / 2.0
  
  a = Sin(angle)
  b = *axis\x * a
  c = *axis\y * a
  d = *axis\z * a
  
  a = Cos(angle)
  
  Init_Vector3(@w, b, c, d)

  ; Vector3CrossProduct(w, v)
  wv\x = w\y * *v\z - w\z * *v\y 
  wv\y = w\z * *v\x - w\x * *v\z 
  wv\z = w\x * *v\y - w\y * *v\x

  ; Vector3CrossProduct(w, wv)
  wwv\x = w\y * wv\z - w\z * wv\y 
  wwv\y = w\z * wv\x - w\x * wv\z 
  wwv\z = w\x * wv\y - w\y * wv\x

  ; Vector3Scale(wv, 2 * a)
  a * 2
  wv\x * a
  wv\y * a
  wv\z * a

  ; Vector3Scale(wwv, 2)
  wwv\x * 2
  wwv\y * 2
  wwv\z * 2

  *result\x + wv\x
  *result\y + wv\y
  *result\z + wv\z

  *result\x + wwv\x
  *result\y + wwv\y
  *result\z + wwv\z
EndProcedure

; Calculate linear interpolation between two vectors
Procedure Vector3Lerp(*result._Vector3, *v1._Vector3, *v2._Vector3, amount.rl_float)
  *result\x = *v1\x + amount * (*v2\x - *v1\x)
  *result\y = *v1\y + amount * (*v2\y - *v1\y)
  *result\z = *v1\z + amount * (*v2\z - *v1\z)
EndProcedure

; Calculate reflected vector To normal
Procedure Vector3Reflect(*result._Vector3, *v._Vector3, *normal._Vector3)
  ; I is the original vector
  ; N is the normal of the incident plane
  ; R = I - (2*N*(DotProduct[I, N]))
  Protected.rl_float dotProduct = (*v\x * *normal\x + *v\y * *normal\y + *v\z * *normal\z)

  *result\x = *v\x - (2.0 * *normal\x) * dotProduct
  *result\y = *v\y - (2.0 * *normal\y) * dotProduct
  *result\z = *v\z - (2.0 * *normal\z) * dotProduct
EndProcedure

; Get min value For each pair of components
Procedure Vector3Min(*result._Vector3, *v1._Vector3, *v2._Vector3)
  *result\x = fMin(*v1\x, *v2\x)
  *result\y = fMin(*v1\y, *v2\y)
  *result\z = fMin(*v1\z, *v2\z)
EndProcedure

; Get max value For each pair of components
Procedure Vector3Max(*result._Vector3, *v1._Vector3, *v2._Vector3)
  *result\x = fMax(*v1\x, *v2\x)
  *result\y = fMax(*v1\y, *v2\y)
  *result\z = fMax(*v1\z, *v2\z)
EndProcedure

; Compute barycenter coordinates (u, v, w) For point p With respect To triangle (a, b, c)
; NOTE: Assumes P is on the plane of the triangle
Procedure Vector3Barycenter(*result._Vector3, *p._Vector3, *a._Vector3, *b._Vector3, *c._Vector3)
  Protected._Vector3 v0, v1, v2
  Protected.rl_float d00, d01, d11, d20, d21, denom
  
  Init_Vector3(@v0, *b\x - *a\x, *b\y - *a\y, *b\z - *a\z)    ; Vector3Subtract(b, a)
  Init_Vector3(@v1, *c\x - *a\x, *c\y - *a\y, *c\z - *a\z)    ; Vector3Subtract(c, a)
  Init_Vector3(@v2, *p\x - *a\x, *p\y - *a\y, *p\z - *a\z)    ; Vector3Subtract(p, a)
  
  d00 = (v0\x * v0\x + v0\y * v0\y + v0\z * v0\z)             ; Vector3DotProduct(v0, v0)
  d01 = (v0\x * v1\x + v0\y * v1\y + v0\z * v1\z)             ; Vector3DotProduct(v0, v1)
  d11 = (v1\x * v1\x + v1\y * v1\y + v1\z * v1\z)             ; Vector3DotProduct(v1, v1)
  d20 = (v2\x * v0\x + v2\y * v0\y + v2\z * v0\z)             ; Vector3DotProduct(v2, v0)
  d21 = (v2\x * v1\x + v2\y * v1\y + v2\z * v1\z)             ; Vector3DotProduct(v2, v1)

  denom = d00 * d11 - d01 * d01

  *result\y = (d11 * d20 - d01 * d21) / denom
  *result\z = (d00 * d21 - d01 * d20) / denom
  *result\x = 1.0 - (*result\z + *result\y)
EndProcedure

; Projects a Vector3 from screen space into object space
; NOTE: We are avoiding calling other raymath functions despite available
Procedure Vector3Unproject(*result._Vector3, *source._Vector3, *projection.Matrix, *view.Matrix)
  ; Calculate unproject matrix (multiply view patrix by projection matrix) And invert it
  Protected.Matrix matViewProj  ; MatrixMultiply(view, projection)
  
  matViewProj\m0 = *view\m0 * *projection\m0 + *view\m1 * *projection\m4 + *view\m2 * *projection\m8 + *view\m3 * *projection\m12
  matViewProj\m4 = *view\m0 * *projection\m1 + *view\m1 * *projection\m5 + *view\m2 * *projection\m9 + *view\m3 * *projection\m13
  matViewProj\m8 = *view\m0 * *projection\m2 + *view\m1 * *projection\m6 + *view\m2 * *projection\m10 + *view\m3 * *projection\m14
  matViewProj\m12 = *view\m0 * *projection\m3 + *view\m1 * *projection\m7 + *view\m2 * *projection\m11 + *view\m3 * *projection\m15
  matViewProj\m1 = *view\m4 * *projection\m0 + *view\m5 * *projection\m4 + *view\m6 * *projection\m8 + *view\m7 * *projection\m12
  matViewProj\m5 = *view\m4 * *projection\m1 + *view\m5 * *projection\m5 + *view\m6 * *projection\m9 + *view\m7 * *projection\m13
  matViewProj\m9 = *view\m4 * *projection\m2 + *view\m5 * *projection\m6 + *view\m6 * *projection\m10 + *view\m7 * *projection\m14
  matViewProj\m13 = *view\m4 * *projection\m3 + *view\m5 * *projection\m7 + *view\m6 * *projection\m11 + *view\m7 * *projection\m15
  matViewProj\m2 = *view\m8 * *projection\m0 + *view\m9 * *projection\m4 + *view\m10 * *projection\m8 + *view\m11 * *projection\m12
  matViewProj\m6 = *view\m8 * *projection\m1 + *view\m9 * *projection\m5 + *view\m10 * *projection\m9 + *view\m11 * *projection\m13
  matViewProj\m10 = *view\m8 * *projection\m2 + *view\m9 * *projection\m6 + *view\m10 * *projection\m10 + *view\m11 * *projection\m14
  matViewProj\m14 = *view\m8 * *projection\m3 + *view\m9 * *projection\m7 + *view\m10 * *projection\m11 + *view\m11 * *projection\m15
  matViewProj\m3 = *view\m12 * *projection\m0 + *view\m13 * *projection\m4 + *view\m14 * *projection\m8 + *view\m15 * *projection\m12
  matViewProj\m7 = *view\m12 * *projection\m1 + *view\m13 * *projection\m5 + *view\m14 * *projection\m9 + *view\m15 * *projection\m13
  matViewProj\m11 = *view\m12 * *projection\m2 + *view\m13 * *projection\m6 + *view\m14 * *projection\m10 + *view\m15 * *projection\m14
  matViewProj\m15 = *view\m12 * *projection\m3 + *view\m13 * *projection\m7 + *view\m14 * *projection\m11 + *view\m15 * *projection\m15

  ; Calculate inverted matrix -> MatrixInvert(matViewProj)
  ; Cache the matrix values (speed optimization)
  Protected.rl_float a00 = matViewProj\m0, a01 = matViewProj\m1, a02 = matViewProj\m2, a03 = matViewProj\m3
  Protected.rl_float a10 = matViewProj\m4, a11 = matViewProj\m5, a12 = matViewProj\m6, a13 = matViewProj\m7
  Protected.rl_float a20 = matViewProj\m8, a21 = matViewProj\m9, a22 = matViewProj\m10, a23 = matViewProj\m11
  Protected.rl_float a30 = matViewProj\m12, a31 = matViewProj\m13, a32 = matViewProj\m14, a33 = matViewProj\m15

  Protected.rl_float b00 = a00 * a11 - a01 * a10
  Protected.rl_float b01 = a00 * a12 - a02 * a10
  Protected.rl_float b02 = a00 * a13 - a03 * a10
  Protected.rl_float b03 = a01 * a12 - a02 * a11
  Protected.rl_float b04 = a01 * a13 - a03 * a11
  Protected.rl_float b05 = a02 * a13 - a03 * a12
  Protected.rl_float b06 = a20 * a31 - a21 * a30
  Protected.rl_float b07 = a20 * a32 - a22 * a30
  Protected.rl_float b08 = a20 * a33 - a23 * a30
  Protected.rl_float b09 = a21 * a32 - a22 * a31
  Protected.rl_float b10 = a21 * a33 - a23 * a31
  Protected.rl_float b11 = a22 * a33 - a23 * a32

  ; Calculate the invert determinant (inlined To avoid double-caching)
  Protected.rl_float invDet = 1.0 / (b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06)

  Protected.Matrix matViewProjInv
  
  matViewProjInv\m0 = (a11 * b11 - a12 * b10 + a13 * b09) * invDet
  matViewProjInv\m4 = (-a01 * b11 + a02 * b10 - a03 * b09) * invDet
  matViewProjInv\m8 = (a31 * b05 - a32 * b04 + a33 * b03) * invDet
  matViewProjInv\m12 = (-a21 * b05 + a22 * b04 - a23 * b03) * invDet
  matViewProjInv\m1 = (-a10 * b11 + a12 * b08 - a13 * b07) * invDet
  matViewProjInv\m5 = (a00 * b11 - a02 * b08 + a03 * b07) * invDet
  matViewProjInv\m9 = (-a30 * b05 + a32 * b02 - a33 * b01) * invDet
  matViewProjInv\m13 = (a20 * b05 - a22 * b02 + a23 * b01) * invDet
  matViewProjInv\m2 = (a10 * b10 - a11 * b08 + a13 * b06) * invDet
  matViewProjInv\m6 = (-a00 * b10 + a01 * b08 - a03 * b06) * invDet
  matViewProjInv\m10 = (a30 * b04 - a31 * b02 + a33 * b00) * invDet
  matViewProjInv\m14 = (-a20 * b04 + a21 * b02 - a23 * b00) * invDet
  matViewProjInv\m3 = (-a10 * b09 + a11 * b07 - a12 * b06) * invDet
  matViewProjInv\m7 = (a00 * b09 - a01 * b07 + a02 * b06) * invDet
  matViewProjInv\m11 = (-a30 * b03 + a31 * b01 - a32 * b00) * invDet
  matViewProjInv\m15 = (a20 * b03 - a21 * b01 + a22 * b00) * invDet

  ; Create quaternion from source point
  Protected.Quaternion quat
  quat\x = *source\x 
  quat\y = *source\y 
  quat\z = *source\z
  quat\w = 1.0

  ; Multiply quat point by unproject matrix
  Protected.Quaternion qtransformed   ; QuaternionTransform(quat, matViewProjInv)
  qtransformed\x = matViewProjInv\m0 * quat\x + matViewProjInv\m4 * quat\y + matViewProjInv\m8 * quat\z + matViewProjInv\m12 * quat\w
  qtransformed\y = matViewProjInv\m1 * quat\x + matViewProjInv\m5 * quat\y + matViewProjInv\m9 * quat\z + matViewProjInv\m13 * quat\w
  qtransformed\z = matViewProjInv\m2 * quat\x + matViewProjInv\m6 * quat\y + matViewProjInv\m10 * quat\z + matViewProjInv\m14 * quat\w
  qtransformed\w = matViewProjInv\m3 * quat\x + matViewProjInv\m7 * quat\y + matViewProjInv\m11 * quat\z + matViewProjInv\m15 * quat\w

  ; Normalized world points in vectors
  *result\x = qtransformed\x / qtransformed\w
  *result\y = qtransformed\y / qtransformed\w
  *result\z = qtransformed\z / qtransformed\w
EndProcedure

; Get Vector3 As float Array
Procedure Vector3ToFloatV(*result.float3, *v._Vector3)
  *result\v[0] = *v\x
  *result\v[1] = *v\y
  *result\v[2] = *v\z
EndProcedure

; Invert the given vector
Procedure Vector3Invert(*result._Vector3, *v._Vector3)
  *result\x = 1.0 / *v\x 
  *result\y = 1.0 / *v\y 
  *result\z = 1.0 / *v\z
EndProcedure

; Clamp the components of the vector between
; min And max values specified by the given vectors
Procedure Vector3Clamp(*result._Vector3, *v._Vector3, *min._Vector3, *max._Vector3)
  *result\x = fMin(*max\x, fMax(*min\x, *v\x))
  *result\y = fMin(*max\y, fMax(*min\y, *v\y))
  *result\z = fMin(*max\z, fMax(*min\z, *v\z))
EndProcedure

; Clamp the magnitude of the vector between two values
Procedure Vector3ClampValue(*result._Vector3, *v._Vector3, min.rl_float, max.rl_float)
  Protected.rl_float length, scale
  
  *result = *v
  
  length = (*v\x * *v\x) + (*v\y * *v\y) + (*v\z * *v\z)
  
  If length > 0
    length = Sqr(length)

    If length < min
      scale = min / length
      *result\x = *v\x * scale
      *result\y = *v\y * scale
      *result\z = *v\z * scale
    ElseIf length > max
      scale = max / length
      *result\x = *v\x * scale
      *result\y = *v\y * scale
      *result\z = *v\z * scale
    EndIf
  EndIf
EndProcedure

; Check whether two given vectors are almost equal
Procedure.rl_bool Vector3Equals(*p._Vector3, *q._Vector3)
  Protected.rl_bool result = Bool(((Abs(*p\x - *q\x)) <= (#EPSILON * fMax(1.0, fMax(Abs(*p\x), Abs(*q\x))))) And
                            ((Abs(*p\y - *q\y)) <= (#EPSILON * fMax(1.0, fMax(Abs(*p\y), Abs(*q\y))))) And
                            ((Abs(*p\z - *q\z)) <= (#EPSILON * fMax(1.0, fMax(Abs(*p\z), Abs(*q\z))))))

  ProcedureReturn result
EndProcedure

; Compute the direction of a refracted ray where v specifies the
; normalized direction of the incoming ray, n specifies the
; normalized normal vector of the Interface of two optical media,
; And r specifies the ratio of the refractive index of the medium
; from where the ray comes To the refractive index of the medium
; on the other side of the surface
Procedure Vector3Refract(*result._Vector3, *v._Vector3, *n._Vector3, r.rl_float)
  Protected.rl_float dot = *v\x * *n\x + *v\y * *n\y + *v\z * *n\z
  Protected.rl_float d = 1.0 - r * r * (1.0 - dot * dot)

  If d >= 0
    d = Sqr(d)
    *v\x = r * *v\x - (r * dot + d) * *n\x
    *v\y = r * *v\y - (r * dot + d) * *n\y
    *v\z = r * *v\z - (r * dot + d) * *n\z

    *result = *v
  EndIf

EndProcedure

;>----------------------------------------------------------------------------------
; Module Functions Definition - Matrix math
;-----------------------------------------------------------------------------------

; Compute matrix determinant
Procedure.rl_float MatrixDeterminant(*mat.Matrix)
  Protected.rl_float result = 0

  ; Cache the matrix values (speed optimization)
  Protected.rl_float a00 = *mat\m0, a01 = *mat\m1, a02 = *mat\m2, a03 = *mat\m3
  Protected.rl_float a10 = *mat\m4, a11 = *mat\m5, a12 = *mat\m6, a13 = *mat\m7
  Protected.rl_float a20 = *mat\m8, a21 = *mat\m9, a22 = *mat\m10, a23 = *mat\m11
  Protected.rl_float a30 = *mat\m12, a31 = *mat\m13, a32 = *mat\m14, a33 = *mat\m15

  result = a30 * a21 * a12 * a03 - a20 * a31 * a12 * a03 - a30 * a11 * a22 * a03 + a10 * a31 * a22 * a03 +
           a20 * a11 * a32 * a03 - a10 * a21 * a32 * a03 - a30 * a21 * a02 * a13 + a20 * a31 * a02 * a13 +
           a30 * a01 * a22 * a13 - a00 * a31 * a22 * a13 - a20 * a01 * a32 * a13 + a00 * a21 * a32 * a13 +
           a30 * a11 * a02 * a23 - a10 * a31 * a02 * a23 - a30 * a01 * a12 * a23 + a00 * a31 * a12 * a23 +
           a10 * a01 * a32 * a23 - a00 * a11 * a32 * a23 - a20 * a11 * a02 * a33 + a10 * a21 * a02 * a33 +
           a20 * a01 * a12 * a33 - a00 * a21 * a12 * a33 - a10 * a01 * a22 * a33 + a00 * a11 * a22 * a33

  ProcedureReturn result
EndProcedure

; Get the trace of the matrix (sum of the values along the diagonal)
Procedure.rl_float MatrixTrace(*mat.Matrix)
  Protected.rl_float result = (*mat\m0 + *mat\m5 + *mat\m10 + *mat\m15)

  ProcedureReturn result
EndProcedure

; Transposes provided matrix
Procedure MatrixTranspose(*result.Matrix, *mat.Matrix)
  *result\m0 = *mat\m0
  *result\m1 = *mat\m4
  *result\m2 = *mat\m8
  *result\m3 = *mat\m12
  *result\m4 = *mat\m1
  *result\m5 = *mat\m5
  *result\m6 = *mat\m9
  *result\m7 = *mat\m13
  *result\m8 = *mat\m2
  *result\m9 = *mat\m6
  *result\m10 = *mat\m10
  *result\m11 = *mat\m14
  *result\m12 = *mat\m3
  *result\m13 = *mat\m7
  *result\m14 = *mat\m11
  *result\m15 = *mat\m15
EndProcedure

; Invert provided matrix
Procedure MatrixInvert(*result.Matrix, *mat.Matrix)
  ; Cache the matrix values (speed optimization)
  Protected.rl_float a00 = *mat\m0, a01 = *mat\m1, a02 = *mat\m2, a03 = *mat\m3
  Protected.rl_float a10 = *mat\m4, a11 = *mat\m5, a12 = *mat\m6, a13 = *mat\m7
  Protected.rl_float a20 = *mat\m8, a21 = *mat\m9, a22 = *mat\m10, a23 = *mat\m11
  Protected.rl_float a30 = *mat\m12, a31 = *mat\m13, a32 = *mat\m14, a33 = *mat\m15

  Protected.rl_float b00 = a00 * a11 - a01 * a10
  Protected.rl_float b01 = a00 * a12 - a02 * a10
  Protected.rl_float b02 = a00 * a13 - a03 * a10
  Protected.rl_float b03 = a01 * a12 - a02 * a11
  Protected.rl_float b04 = a01 * a13 - a03 * a11
  Protected.rl_float b05 = a02 * a13 - a03 * a12
  Protected.rl_float b06 = a20 * a31 - a21 * a30
  Protected.rl_float b07 = a20 * a32 - a22 * a30
  Protected.rl_float b08 = a20 * a33 - a23 * a30
  Protected.rl_float b09 = a21 * a32 - a22 * a31
  Protected.rl_float b10 = a21 * a33 - a23 * a31
  Protected.rl_float b11 = a22 * a33 - a23 * a32

  ; Calculate the invert determinant (inlined To avoid double-caching)
  Protected.rl_float invDet = 1.0 / (b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06)

  *result\m0 = (a11 * b11 - a12 * b10 + a13 * b09) * invDet
  *result\m1 = (-a01 * b11 + a02 * b10 - a03 * b09) * invDet
  *result\m2 = (a31 * b05 - a32 * b04 + a33 * b03) * invDet
  *result\m3 = (-a21 * b05 + a22 * b04 - a23 * b03) * invDet
  *result\m4 = (-a10 * b11 + a12 * b08 - a13 * b07) * invDet
  *result\m5 = (a00 * b11 - a02 * b08 + a03 * b07) * invDet
  *result\m6 = (-a30 * b05 + a32 * b02 - a33 * b01) * invDet
  *result\m7 = (a20 * b05 - a22 * b02 + a23 * b01) * invDet
  *result\m8 = (a10 * b10 - a11 * b08 + a13 * b06) * invDet
  *result\m9 = (-a00 * b10 + a01 * b08 - a03 * b06) * invDet
  *result\m10 = (a30 * b04 - a31 * b02 + a33 * b00) * invDet
  *result\m11 = (-a20 * b04 + a21 * b02 - a23 * b00) * invDet
  *result\m12 = (-a10 * b09 + a11 * b07 - a12 * b06) * invDet
  *result\m13 = (a00 * b09 - a01 * b07 + a02 * b06) * invDet
  *result\m14 = (-a30 * b03 + a31 * b01 - a32 * b00) * invDet
  *result\m15 = (a20 * b03 - a21 * b01 + a22 * b00) * invDet
EndProcedure

; Get identity matrix
Procedure MatrixIdentity(*result.Matrix)
  *result\m0 = 1.0 
  *result\m4 = 0.0
  *result\m8 = 0.0
  *result\m12 = 0.0
  *result\m1 = 0.0
  *result\m5 = 1.0
  *result\m9 = 0.0 
  *result\m13 = 0.0
  *result\m2 = 0.0 
  *result\m6 = 0.0 
  *result\m10 = 1.0 
  *result\m14 = 0.0
  *result\m3 = 0.0 
  *result\m7 = 0.0
  *result\m11 = 0.0
  *result\m15 = 1.0
EndProcedure

; Add two matrices
Procedure MatrixAdd(*result.Matrix, *left.Matrix, *right.Matrix)
  *result\m0 = *left\m0 + *right\m0
  *result\m1 = *left\m1 + *right\m1
  *result\m2 = *left\m2 + *right\m2
  *result\m3 = *left\m3 + *right\m3
  *result\m4 = *left\m4 + *right\m4
  *result\m5 = *left\m5 + *right\m5
  *result\m6 = *left\m6 + *right\m6
  *result\m7 = *left\m7 + *right\m7
  *result\m8 = *left\m8 + *right\m8
  *result\m9 = *left\m9 + *right\m9
  *result\m10 = *left\m10 + *right\m10
  *result\m11 = *left\m11 + *right\m11
  *result\m12 = *left\m12 + *right\m12
  *result\m13 = *left\m13 + *right\m13
  *result\m14 = *left\m14 + *right\m14
  *result\m15 = *left\m15 + *right\m15
EndProcedure

; Subtract two matrices (left - right)
Procedure MatrixSubtract(*result.Matrix, *left.Matrix, *right.Matrix)
  *result\m0 = *left\m0 - *right\m0
  *result\m1 = *left\m1 - *right\m1
  *result\m2 = *left\m2 - *right\m2
  *result\m3 = *left\m3 - *right\m3
  *result\m4 = *left\m4 - *right\m4
  *result\m5 = *left\m5 - *right\m5
  *result\m6 = *left\m6 - *right\m6
  *result\m7 = *left\m7 - *right\m7
  *result\m8 = *left\m8 - *right\m8
  *result\m9 = *left\m9 - *right\m9
  *result\m10 = *left\m10 - *right\m10
  *result\m11 = *left\m11 - *right\m11
  *result\m12 = *left\m12 - *right\m12
  *result\m13 = *left\m13 - *right\m13
  *result\m14 = *left\m14 - *right\m14
  *result\m15 = *left\m15 - *right\m15
EndProcedure

; Get two matrix multiplication
; NOTE: When multiplying matrices... the order matters!
Procedure MatrixMultiply(*result.Matrix, *left.Matrix, *right.Matrix)
  *result\m0 = *left\m0 * *right\m0 + *left\m1 * *right\m4 + *left\m2 * *right\m8 + *left\m3 * *right\m12
  *result\m1 = *left\m0 * *right\m1 + *left\m1 * *right\m5 + *left\m2 * *right\m9 + *left\m3 * *right\m13
  *result\m2 = *left\m0 * *right\m2 + *left\m1 * *right\m6 + *left\m2 * *right\m10 + *left\m3 * *right\m14
  *result\m3 = *left\m0 * *right\m3 + *left\m1 * *right\m7 + *left\m2 * *right\m11 + *left\m3 * *right\m15
  *result\m4 = *left\m4 * *right\m0 + *left\m5 * *right\m4 + *left\m6 * *right\m8 + *left\m7 * *right\m12
  *result\m5 = *left\m4 * *right\m1 + *left\m5 * *right\m5 + *left\m6 * *right\m9 + *left\m7 * *right\m13
  *result\m6 = *left\m4 * *right\m2 + *left\m5 * *right\m6 + *left\m6 * *right\m10 + *left\m7 * *right\m14
  *result\m7 = *left\m4 * *right\m3 + *left\m5 * *right\m7 + *left\m6 * *right\m11 + *left\m7 * *right\m15
  *result\m8 = *left\m8 * *right\m0 + *left\m9 * *right\m4 + *left\m10 * *right\m8 + *left\m11 * *right\m12
  *result\m9 = *left\m8 * *right\m1 + *left\m9 * *right\m5 + *left\m10 * *right\m9 + *left\m11 * *right\m13
  *result\m10 = *left\m8 * *right\m2 + *left\m9 * *right\m6 + *left\m10 * *right\m10 + *left\m11 * *right\m14
  *result\m11 = *left\m8 * *right\m3 + *left\m9 * *right\m7 + *left\m10 * *right\m11 + *left\m11 * *right\m15
  *result\m12 = *left\m12 * *right\m0 + *left\m13 * *right\m4 + *left\m14 * *right\m8 + *left\m15 * *right\m12
  *result\m13 = *left\m12 * *right\m1 + *left\m13 * *right\m5 + *left\m14 * *right\m9 + *left\m15 * *right\m13
  *result\m14 = *left\m12 * *right\m2 + *left\m13 * *right\m6 + *left\m14 * *right\m10 + *left\m15 * *right\m14
  *result\m15 = *left\m12 * *right\m3 + *left\m13 * *right\m7 + *left\m14 * *right\m11 + *left\m15 * *right\m15
EndProcedure

; Get translation matrix
Procedure MatrixTranslate(*result.Matrix, x.rl_float, y.rl_float, z.rl_float)
  *result\m0 = 1.0 
  *result\m4 = 0.0
  *result\m8 = 0.0
  *result\m12 = x
  *result\m1 = 0.0
  *result\m5 = 1.0
  *result\m9 = 0.0 
  *result\m13 = y
  *result\m2 = 0.0 
  *result\m6 = 0.0 
  *result\m10 = 1.0 
  *result\m14 = z
  *result\m3 = 0.0 
  *result\m7 = 0.0
  *result\m11 = 0.0
  *result\m15 = 1.0
EndProcedure

; Create rotation matrix from axis And angle
; NOTE: Angle should be provided in radians
Procedure MatrixRotate(*result.Matrix, *axis._Vector3, angle.rl_float)
  Protected.rl_float x = *axis\x, y = *axis\y, z = *axis\z
  
  Protected.rl_float lengthSquared = x * x + y * y + z * z
  
  Protected.rl_float ilength, sinres, cosres, t
  
  If ((lengthSquared <> 1.0) And (lengthSquared <> 0.0))
    ilength = 1.0 / Sqr(lengthSquared)
    x * ilength
    y * ilength
    z * ilength
  EndIf
  
  sinres = Sin(angle)
  cosres = Cos(angle)
  t = 1.0 - cosres
  
  *result\m0 = x * x * t + cosres
  *result\m1 = y * x * t + z * sinres
  *result\m2 = z * x * t - y * sinres
  *result\m3 = 0.0
  
  *result\m4 = x * y * t - z * sinres
  *result\m5 = y * y * t + cosres
  *result\m6 = z * y * t + x * sinres
  *result\m7 = 0.0
  
  *result\m8 = x * z * t + y * sinres
  *result\m9 = y * z * t - x * sinres
  *result\m10 = z * z * t + cosres
  *result\m11 = 0.0
  
  *result\m12 = 0.0
  *result\m13 = 0.0
  *result\m14 = 0.0
  *result\m15 = 1.0
EndProcedure

; Get x-rotation matrix
; NOTE: Angle must be provided in radians
Procedure MatrixRotateX(*result.Matrix, angle.rl_float)
  ; MatrixIdentity()
  *result\m0 = 1.0 
  *result\m4 = 0.0
  *result\m8 = 0.0
  *result\m12 = 0.0
  *result\m1 = 0.0
  *result\m5 = 1.0
  *result\m9 = 0.0 
  *result\m13 = 0.0
  *result\m2 = 0.0 
  *result\m6 = 0.0 
  *result\m10 = 1.0 
  *result\m14 = 0.0
  *result\m3 = 0.0 
  *result\m7 = 0.0
  *result\m11 = 0.0
  *result\m15 = 1.0

  Protected.rl_float cosres = Cos(angle)
  Protected.rl_float sinres = Sin(angle)

  *result\m5 = cosres
  *result\m6 = sinres
  *result\m9 = -sinres
  *result\m10 = cosres
EndProcedure

; Get y-rotation matrix
; NOTE: Angle must be provided in radians
Procedure MatrixRotateY(*result.Matrix, angle.rl_float)
  ; MatrixIdentity()
  *result\m0 = 1.0 
  *result\m4 = 0.0
  *result\m8 = 0.0
  *result\m12 = 0.0
  *result\m1 = 0.0
  *result\m5 = 1.0
  *result\m9 = 0.0 
  *result\m13 = 0.0
  *result\m2 = 0.0 
  *result\m6 = 0.0 
  *result\m10 = 1.0 
  *result\m14 = 0.0
  *result\m3 = 0.0 
  *result\m7 = 0.0
  *result\m11 = 0.0
  *result\m15 = 1.0
  
  Protected.rl_float cosres = Cos(angle)
  Protected.rl_float sinres = Sin(angle)
  
  *result\m0 = cosres
  *result\m2 = -sinres
  *result\m8 = sinres
  *result\m10 = cosres
EndProcedure

; Get z-rotation matrix
; NOTE: Angle must be provided in radians
Procedure MatrixRotateZ(*result.Matrix, angle.rl_float)
  ; MatrixIdentity()
  *result\m0 = 1.0 
  *result\m4 = 0.0
  *result\m8 = 0.0
  *result\m12 = 0.0
  *result\m1 = 0.0
  *result\m5 = 1.0
  *result\m9 = 0.0 
  *result\m13 = 0.0
  *result\m2 = 0.0 
  *result\m6 = 0.0 
  *result\m10 = 1.0 
  *result\m14 = 0.0
  *result\m3 = 0.0 
  *result\m7 = 0.0
  *result\m11 = 0.0
  *result\m15 = 1.0
    
  Protected.rl_float cosres = Cos(angle)
  Protected.rl_float sinres = Sin(angle)

  *result\m0 = cosres
  *result\m1 = sinres
  *result\m4 = -sinres
  *result\m5 = cosres
EndProcedure


; Get xyz-rotation matrix
; NOTE: Angle must be provided in radians
Procedure MatrixRotateXYZ(*result.Matrix, *angle._Vector3)
  ; MatrixIdentity()
  *result\m0 = 1.0 
  *result\m4 = 0.0
  *result\m8 = 0.0
  *result\m12 = 0.0
  *result\m1 = 0.0
  *result\m5 = 1.0
  *result\m9 = 0.0 
  *result\m13 = 0.0
  *result\m2 = 0.0 
  *result\m6 = 0.0 
  *result\m10 = 1.0 
  *result\m14 = 0.0
  *result\m3 = 0.0 
  *result\m7 = 0.0
  *result\m11 = 0.0
  *result\m15 = 1.0

  Protected.rl_float cosz = Cos(-*angle\z)
  Protected.rl_float sinz = Sin(-*angle\z)
  Protected.rl_float cosy = Cos(-*angle\y)
  Protected.rl_float siny = Sin(-*angle\y)
  Protected.rl_float cosx = Cos(-*angle\x)
  Protected.rl_float sinx = Sin(-*angle\x)

  *result\m0 = cosz * cosy
  *result\m1 = (cosz * siny * sinx) - (sinz * cosx)
  *result\m2 = (cosz * siny * cosx) + (sinz * sinx)

  *result\m4 = sinz * cosy
  *result\m5 = (sinz * siny * sinx) + (cosz * cosx)
  *result\m6 = (sinz * siny * cosx) - (cosz * sinx)

  *result\m8 = -siny
  *result\m9 = cosy * sinx
  *result\m10= cosy * cosx
EndProcedure

; Get zyx-rotation matrix
; NOTE: Angle must be provided in radians
Procedure MatrixRotateZYX(*result.Matrix, *angle._Vector3)
  Protected.rl_float cz = Cos(*angle\z)
  Protected.rl_float sz = Sin(*angle\z)
  Protected.rl_float cy = Cos(*angle\y)
  Protected.rl_float sy = Sin(*angle\y)
  Protected.rl_float cx = Cos(*angle\x)
  Protected.rl_float sx = Sin(*angle\x)

  *result\m0 = cz * cy
  *result\m4 = cz * sy * sx - cx * sz
  *result\m8 = sz * sx + cz * cx * sy
  *result\m12 = 0

  *result\m1 = cy * sz
  *result\m5 = cz * cx + sz * sy * sx
  *result\m9 = cx * sz * sy - cz * sx
  *result\m13 = 0

  *result\m2 = -sy
  *result\m6 = cy * sx
  *result\m10 = cy * cx
  *result\m14 = 0

  *result\m3 = 0
  *result\m7 = 0
  *result\m11 = 0
  *result\m15 = 1
EndProcedure

; Get scaling matrix
Procedure MatrixScale(*result.Matrix, x.rl_float, y.rl_float, z.rl_float)
  *result\m0 = x 
  *result\m4 = 0.0
  *result\m8 = 0.0
  *result\m12 = 0.0
  *result\m1 = 0.0
  *result\m5 = y
  *result\m9 = 0.0 
  *result\m13 = 0.0
  *result\m2 = 0.0 
  *result\m6 = 0.0 
  *result\m10 = z 
  *result\m14 = 0.0
  *result\m3 = 0.0 
  *result\m7 = 0.0
  *result\m11 = 0.0
  *result\m15 = 1.0
EndProcedure

; Get perspective projection matrix
Procedure MatrixFrustum(*result.Matrix, left.rl_double, right.rl_double, bottom.rl_double, top.rl_double, near.rl_double, far.rl_double)
  Protected.rl_float rl = right - left
  Protected.rl_float tb = top - bottom
  Protected.rl_float fn = far - near

  *result\m0 = (near * 2.0) / rl
  *result\m1 = 0.0
  *result\m2 = 0.0
  *result\m3 = 0.0

  *result\m4 = 0.0
  *result\m5 = (near * 2.0) / tb
  *result\m6 = 0.0
  *result\m7 = 0.0

  *result\m8 = (right + left) / rl
  *result\m9 = (top + bottom) / tb
  *result\m10 = -(far + near) / fn
  *result\m11 = -1.0

  *result\m12 = 0.0
  *result\m13 = 0.0
  *result\m14 = -(far * near * 2.0) / fn
  *result\m15 = 0.0
EndProcedure

; Get perspective projection matrix
; NOTE: Fovy angle must be provided in radians
Procedure MatrixPerspective(*result.Matrix, fovy.rl_double, aspect.rl_double, near.rl_double, far.rl_double)
  Protected.rl_double top = near * Tan(fovy * 0.5)
  Protected.rl_double bottom = -top
  Protected.rl_double right = top * aspect
  Protected.rl_double left = -right

  ; MatrixFrustum(-right, right, -top, top, near, far)
  Protected.rl_float rl = right - left
  Protected.rl_float tb = top - bottom
  Protected.rl_float fn = far - near

  *result\m0 = (near * 2.0) / rl
  *result\m5 = (near * 2.0) / tb
  *result\m8 = (right + left) / rl
  *result\m9 = (top + bottom) / tb
  *result\m10 = -(far + near) / fn
  *result\m11 = -1.0
  *result\m14 = -(far * near * 2.0) / fn
EndProcedure

; Get orthographic projection matrix
Procedure MatrixOrtho(*result.Matrix, left.rl_double, right.rl_double, bottom.rl_double, top.rl_double, near.rl_double, far.rl_double)
  Protected.rl_float rl = right - left
  Protected.rl_float tb = top - bottom
  Protected.rl_float fn = far - near

  *result\m0 = 2.0 / rl
  *result\m1 = 0.0
  *result\m2 = 0.0
  *result\m3 = 0.0
  *result\m4 = 0.0
  *result\m5 = 2.0 / tb
  *result\m6 = 0.0
  *result\m7 = 0.0
  *result\m8 = 0.0
  *result\m9 = 0.0
  *result\m10 = -2.0 / fn
  *result\m11 = 0.0
  *result\m12 = -(left + right) / rl
  *result\m13 = -(top + bottom) / tb
  *result\m14 = -(far + near) / fn
  *result\m15 = 1.0
EndProcedure

; Get camera look-at matrix (view matrix)
Procedure MatrixLookAt(*result.Matrix, *eye._Vector3, *target._Vector3, *up._Vector3)
  Protected.rl_float length = 0.0
  Protected.rl_float ilength = 0.0

  ; Vector3Subtract(eye, target)
  Protected._Vector3 vz 
  Init_Vector3(@vz, *eye\x - *target\x, *eye\y - *target\y, *eye\z - *target\z)

  ; Vector3Normalize(vz)
  Protected._Vector3 v = vz
  
  length = Sqr(v\x * v\x + v\y * v\y + v\z * v\z)
  
  If length = 0
    length = 1.0
  EndIf
  
  ilength = 1.0 / length
  
  vz\x * ilength
  vz\y * ilength
  vz\z * ilength

  ; Vector3CrossProduct(up, vz)
  Protected._Vector3 vx 
  Init_Vector3(@vx, *up\y * vz\z - *up\z * vz\y, *up\z * vz\x - *up\x * vz\z, *up\x * vz\y - *up\y * vz\x)

  ; Vector3Normalize(x)
  v = vx
  
  length = Sqr(v\x * v\x + v\y * v\y + v\z * v\z)
  
  If length = 0 
    length = 1.0
  EndIf
  
  ilength = 1.0 / length
  
  vx\x * ilength
  vx\y * ilength
  vx\z * ilength

  ; Vector3CrossProduct(vz, vx)
  Protected._Vector3 vy 
  Init_Vector3(@vy, vz\y * vx\z - vz\z * vx\y, vz\z * vx\x - vz\x * vx\z, vz\x * vx\y - vz\y * vx\x)

  *result\m0 = vx\x
  *result\m1 = vy\x
  *result\m2 = vz\x
  *result\m3 = 0.0
  *result\m4 = vx\y
  *result\m5 = vy\y
  *result\m6 = vz\y
  *result\m7 = 0.0
  *result\m8 = vx\z
  *result\m9 = vy\z
  *result\m10 = vz\z
  *result\m11 = 0.0
  *result\m12 = -(vx\x * *eye\x + vx\y * *eye\y + vx\z * *eye\z)   ; Vector3DotProduct(vx, eye)
  *result\m13 = -(vy\x * *eye\x + vy\y * *eye\y + vy\z * *eye\z)   ; Vector3DotProduct(vy, eye)
  *result\m14 = -(vz\x * *eye\x + vz\y * *eye\y + vz\z * *eye\z)   ; Vector3DotProduct(vz, eye)
  *result\m15 = 1.0
EndProcedure

; Get float Array of matrix Data
Procedure MatrixToFloatV(*result.float16, *mat.Matrix)
  *result\v[0] = *mat\m0
  *result\v[1] = *mat\m1
  *result\v[2] = *mat\m2
  *result\v[3] = *mat\m3
  *result\v[4] = *mat\m4
  *result\v[5] = *mat\m5
  *result\v[6] = *mat\m6
  *result\v[7] = *mat\m7
  *result\v[8] = *mat\m8
  *result\v[9] = *mat\m9
  *result\v[10] = *mat\m10
  *result\v[11] = *mat\m11
  *result\v[12] = *mat\m12
  *result\v[13] = *mat\m13
  *result\v[14] = *mat\m14
  *result\v[15] = *mat\m15
EndProcedure

;>----------------------------------------------------------------------------------
; Module Functions Definition - Quaternion math
;-----------------------------------------------------------------------------------

; Add two quaternions
Procedure QuaternionAdd(*result.Quaternion, *q1.Quaternion, *q2.Quaternion)
  *result\x = *q1\x + *q2\x 
  *result\y = *q1\y + *q2\y 
  *result\z = *q1\z + *q2\z 
  *result\w = *q1\w + *q2\w
EndProcedure

; Add quaternion And float value
Procedure QuaternionAddValue(*result.Quaternion, *q.Quaternion, add.rl_float)
  *result\x = *q\x + add 
  *result\y = *q\y + add 
  *result\z = *q\z + add 
  *result\w = *q\w + add
EndProcedure

; Subtract two quaternions
Procedure QuaternionSubtract(*result.Quaternion, *q1.Quaternion, *q2.Quaternion)
  *result\x = *q1\x - *q2\x 
  *result\y = *q1\y - *q2\y 
  *result\z = *q1\z - *q2\z 
  *result\w = *q1\w - *q2\w
EndProcedure

; Subtract quaternion And float value
Procedure QuaternionSubtractValue(*result.Quaternion, *q.Quaternion, sub.rl_float)
  *result\x = *q\x - sub 
  *result\y = *q\y - sub 
  *result\z = *q\z - sub 
  *result\w = *q\w - sub
EndProcedure

; Get identity quaternion
Procedure QuaternionIdentity(*result.Quaternion)
  *result\x = 0.0 
  *result\y = 0.0 
  *result\z = 0.0 
  *result\w = 1.0
EndProcedure

; Computes the length of a quaternion
Procedure.rl_float QuaternionLength(*q.Quaternion)
  Protected.rl_float result = Sqr(*q\x * *q\x + *q\y * *q\y + *q\z * *q\z + *q\w * *q\w)

  ProcedureReturn result
EndProcedure

; Normalize provided quaternion
Procedure QuaternionNormalize(*result.Quaternion, *q.Quaternion)
  Protected.rl_float length = Sqr(*q\x * *q\x + *q\y * *q\y + *q\z * *q\z + *q\w * *q\w)
  Protected.rl_float ilength
  
  If length = 0 
    length = 1.0
  EndIf
  
  ilength = 1.0 / length

  *result\x = *q\x * ilength
  *result\y = *q\y * ilength
  *result\z = *q\z * ilength
  *result\w = *q\w * ilength
EndProcedure

; Invert provided quaternion
Procedure QuaternionInvert(*result.Quaternion, *q.Quaternion)
  *result = *q

  Protected.rl_float lengthSq = *q\x * *q\x + *q\y * *q\y + *q\z * *q\z + *q\w * *q\w
  Protected.rl_float invLength
  
  If lengthSq <> 0
    invLength = 1.0 / lengthSq

    *result\x * -invLength
    *result\y * -invLength
    *result\z * -invLength
    *result\w * invLength
  EndIf
EndProcedure

; Calculate two quaternion multiplication
Procedure QuaternionMultiply(*result.Quaternion, *q1.Quaternion, *q2.Quaternion)
  Protected.rl_float qax = *q1\x, qay = *q1\y, qaz = *q1\z, qaw = *q1\w
  Protected.rl_float qbx = *q2\x, qby = *q2\y, qbz = *q2\z, qbw = *q2\w

  *result\x = qax * qbw + qaw * qbx + qay * qbz - qaz * qby
  *result\y = qay * qbw + qaw * qby + qaz * qbx - qax * qbz
  *result\z = qaz * qbw + qaw * qbz + qax * qby - qay * qbx
  *result\w = qaw * qbw - qax * qbx - qay * qby - qaz * qbz
EndProcedure

; Scale quaternion by float value
Procedure QuaternionScale(*result.Quaternion, *q.Quaternion, mul.rl_float)
  *result\x = *q\x * mul
  *result\y = *q\y * mul
  *result\z = *q\z * mul
  *result\w = *q\w * mul
EndProcedure

; Divide two quaternions
Procedure QuaternionDivide(*result.Quaternion, *q1.Quaternion, *q2.Quaternion)
  *result\x = *q1\x / *q2\x 
  *result\y = *q1\y / *q2\y 
  *result\z = *q1\z / *q2\z 
  *result\w = *q1\w / *q2\w
EndProcedure

; Calculate linear interpolation between two quaternions
Procedure QuaternionLerp(*result.Quaternion, *q1.Quaternion, *q2.Quaternion, amount.rl_float)
  *result\x = *q1\x + amount * (*q2\x - *q1\x)
  *result\y = *q1\y + amount * (*q2\y - *q1\y)
  *result\z = *q1\z + amount * (*q2\z - *q1\z)
  *result\w = *q1\w + amount * (*q2\w - *q1\w)
EndProcedure

; Calculate slerp-optimized interpolation between two quaternions
Procedure QuaternionNlerp(*result.Quaternion, *q1.Quaternion, *q2.Quaternion, amount.rl_float)
  ; QuaternionLerp(q1, q2, amount)
  *result\x = *q1\x + amount * (*q2\x - *q1\x)
  *result\y = *q1\y + amount * (*q2\y - *q1\y)
  *result\z = *q1\z + amount * (*q2\z - *q1\z)
  *result\w = *q1\w + amount * (*q2\w - *q1\w)

  ; QuaternionNormalize(q)
  Protected.Quaternion q 
  q\x = *result\x
  q\y = *result\y
  q\z = *result\z
  q\w = *result\w
  
  Protected.rl_float length = Sqr(q\x * q\x + q\y * q\y + q\z * q\z + q\w * q\w)
  Protected.rl_float ilength
  
  If length = 0 
    length = 1.0
  EndIf
  
  ilength = 1.0 / length

  *result\x = q\x * ilength
  *result\y = q\y * ilength
  *result\z = q\z * ilength
  *result\w = q\w * ilength
EndProcedure

; Calculates spherical linear interpolation between two quaternions
Procedure QuaternionSlerp(*result.Quaternion, *q1.Quaternion, *q2.Quaternion, amount.rl_float)
  Protected.rl_float cosHalfTheta = *q1\x * *q2\x + *q1\y * *q2\y + *q1\z * *q2\z + *q1\w * *q2\w
  Protected.rl_float halfTheta, sinHalfTheta
  Protected.rl_float ratioA, ratioB
  
  If cosHalfTheta < 0
    *q2\x = -*q2\x 
    *q2\y = -*q2\y 
    *q2\z = -*q2\z 
    *q2\w = -*q2\w
    cosHalfTheta = -cosHalfTheta
  EndIf

  If Abs(cosHalfTheta) >= 1.0
    *result = *q1
  ElseIf cosHalfTheta > 0.95 
    QuaternionNlerp(*result, *q1, *q2, amount)
  Else
    halfTheta = ACos(cosHalfTheta)
    sinHalfTheta = Sqr(1.0 - cosHalfTheta * cosHalfTheta)

    If Abs(sinHalfTheta) < 0.001
      *result\x = (*q1\x * 0.5 + *q2\x * 0.5)
      *result\y = (*q1\y * 0.5 + *q2\y * 0.5)
      *result\z = (*q1\z * 0.5 + *q2\z * 0.5)
      *result\w = (*q1\w * 0.5 + *q2\w * 0.5)
    Else
      ratioA = Sin((1 - amount) * halfTheta) / sinHalfTheta
      ratioB = Sin(amount * halfTheta) / sinHalfTheta

      *result\x = (*q1\x * ratioA + *q2\x * ratioB)
      *result\y = (*q1\y * ratioA + *q2\y * ratioB)
      *result\z = (*q1\z * ratioA + *q2\z * ratioB)
      *result\w = (*q1\w * ratioA + *q2\w * ratioB)
    EndIf
  EndIf
EndProcedure

; Calculate quaternion based on the rotation from one vector To another
Procedure QuaternionFromVector3ToVector3(*result.Quaternion, *from._Vector3, *to._Vector3)
  Protected.rl_float cos2Theta = *from\x * *to\x + *from\y * *to\y + *from\z * *to\z  ; Vector3DotProduct(from, to)
  Protected.Quaternion q
  Protected.rl_float length, ilength
  Protected._Vector3 cross 
  Init_Vector3(@cross, *from\y * *to\z - *from\z * *to\y, *from\z * *to\x - *from\x * *to\z, *from\x * *to\y - *from\y * *to\x) ; Vector3CrossProduct(from, to)

  *result\x = cross\x
  *result\y = cross\y
  *result\z = cross\z
  *result\w = 1.0 + cos2Theta

  ; QuaternionNormalize(q)
  ; NOTE: Normalize To essentially nlerp the original And identity To 0.5
  q\x = *result\x
  q\y = *result\y
  q\z = *result\z
  q\w = *result\w
  
  length = Sqr(q\x * q\x + q\y * q\y + q\z * q\z + q\w * q\w)
  
  If length = 0 
    length = 1.0
  EndIf
  
  ilength = 1.0 / length

  *result\x = q\x * ilength
  *result\y = q\y * ilength
  *result\z = q\z * ilength
  *result\w = q\w * ilength
EndProcedure

; Get a quaternion For a given rotation matrix
Procedure QuaternionFromMatrix(*result.Quaternion, *mat.Matrix)
  Protected.rl_float fourWSquaredMinus1 = *mat\m0 + *mat\m5 + *mat\m10
  Protected.rl_float fourXSquaredMinus1 = *mat\m0 - *mat\m5 - *mat\m10
  Protected.rl_float fourYSquaredMinus1 = *mat\m5 - *mat\m0 - *mat\m10
  Protected.rl_float fourZSquaredMinus1 = *mat\m10 - *mat\m0 - *mat\m5

  Protected.rl_int biggestIndex = 0
  Protected.rl_float fourBiggestSquaredMinus1 = fourWSquaredMinus1
  
  If fourXSquaredMinus1 > fourBiggestSquaredMinus1
    fourBiggestSquaredMinus1 = fourXSquaredMinus1
    biggestIndex = 1
  EndIf

  If fourYSquaredMinus1 > fourBiggestSquaredMinus1
    fourBiggestSquaredMinus1 = fourYSquaredMinus1
    biggestIndex = 2
  EndIf

  If (fourZSquaredMinus1 > fourBiggestSquaredMinus1)
    fourBiggestSquaredMinus1 = fourZSquaredMinus1
    biggestIndex = 3
  EndIf

  Protected.rl_float biggestVal = Sqr(fourBiggestSquaredMinus1 + 1.0) * 0.5
  Protected.rl_float mult = 0.25 / biggestVal

  Select biggestIndex
    Case 0
      *result\w = biggestVal
      *result\x = (*mat\m6 - *mat\m9) * mult
      *result\y = (*mat\m8 - *mat\m2) * mult
      *result\z = (*mat\m1 - *mat\m4) * mult
    Case 1
      *result\x = biggestVal
      *result\w = (*mat\m6 - *mat\m9) * mult
      *result\y = (*mat\m1 + *mat\m4) * mult
      *result\z = (*mat\m8 + *mat\m2) * mult
    Case 2
      *result\y = biggestVal
      *result\w = (*mat\m8 - *mat\m2) * mult
      *result\x = (*mat\m1 + *mat\m4) * mult
      *result\z = (*mat\m6 + *mat\m9) * mult
    Case 3
      *result\z = biggestVal
      *result\w = (*mat\m1 - *mat\m4) * mult
      *result\x = (*mat\m8 + *mat\m2) * mult
      *result\y = (*mat\m6 + *mat\m9) * mult
  EndSelect
EndProcedure

; Get a matrix For a given quaternion
Procedure QuaternionToMatrix(*result.Matrix, *q.Quaternion)
  ; MatrixIdentity()
  *result\m0 = 1.0 
  *result\m4 = 0.0
  *result\m8 = 0.0
  *result\m12 = 0.0
  *result\m1 = 0.0
  *result\m5 = 1.0
  *result\m9 = 0.0 
  *result\m13 = 0.0
  *result\m2 = 0.0 
  *result\m6 = 0.0 
  *result\m10 = 1.0 
  *result\m14 = 0.0
  *result\m3 = 0.0 
  *result\m7 = 0.0
  *result\m11 = 0.0
  *result\m15 = 1.0

  Protected.rl_float a2 = *q\x * *q\x
  Protected.rl_float b2 = *q\y * *q\y
  Protected.rl_float c2 = *q\z * *q\z
  Protected.rl_float ac = *q\x * *q\z
  Protected.rl_float ab = *q\x * *q\y
  Protected.rl_float bc = *q\y * *q\z
  Protected.rl_float ad = *q\w * *q\x
  Protected.rl_float bd = *q\w * *q\y
  Protected.rl_float cd = *q\w * *q\z

  *result\m0 = 1 - 2 * (b2 + c2)
  *result\m1 = 2 * (ab + cd)
  *result\m2 = 2 * (ac - bd)

  *result\m4 = 2 * (ab - cd)
  *result\m5 = 1 - 2 * (a2 + c2)
  *result\m6 = 2 * (bc + ad)

  *result\m8 = 2 * (ac + bd)
  *result\m9 = 2 * (bc - ad)
  *result\m10 = 1 - 2 * (a2 + b2)
EndProcedure

; Get rotation quaternion For an angle And axis
; NOTE: Angle must be provided in radians
Procedure QuaternionFromAxisAngle(*result.Quaternion, *axis._Vector3, angle.rl_float)
  *result\x = 0.0 
  *result\y = 0.0 
  *result\z = 0.0 
  *result\w = 1.0

  Protected.rl_float axisLength = Sqr(*axis\x * *axis\x + *axis\y * *axis\y + *axis\z * *axis\z)
  Protected.rl_float length, ilength, sinres, cosres
  Protected._Vector3 v
  Protected.Quaternion q
  
  If axisLength <> 0
    angle * 0.5

    length = 0.0
    ilength = 0.0

    ; Vector3Normalize(axis)
    v\x = *axis\x
    v\y = *axis\y
    v\z = *axis\z
    
    length = Sqr(v\x * v\x + v\y * v\y + v\z * v\z)
    
    If length = 0 
      length = 1.0
    EndIf
    
    ilength = 1.0 / length
    
    *axis\x * ilength
    *axis\y * ilength
    *axis\z * ilength

    sinres = Sin(angle)
    cosres = Cos(angle)

    *result\x = *axis\x * sinres
    *result\y = *axis\y * sinres
    *result\z = *axis\z * sinres
    *result\w = cosres

    ; QuaternionNormalize(q)
    q\x = *result\x
    q\y = *result\y
    q\z = *result\z
    q\w = *result\w
    
    length = Sqr(q\x * q\x + q\y * q\y + q\z * q\z + q\w * q\w)
    
    If length = 0 
      length = 1.0
    EndIf
    
    ilength = 1.0 / length
    
    *result\x = q\x * ilength
    *result\y = q\y * ilength
    *result\z = q\z * ilength
    *result\w = q\w * ilength
  EndIf
EndProcedure

; Get the rotation angle And axis For a given quaternion
Procedure QuaternionToAxisAngle(*q.Quaternion, *outAxis._Vector3, *outAngle.float)
  Protected.rl_float length, ilength, resAngle, den
  Protected._Vector3 resAxis
  
  If Abs(*q\w) > 1.0
    ; QuaternionNormalize(q)
    length = Sqr(*q\x * *q\x + *q\y * *q\y + *q\z * *q\z + *q\w * *q\w)
    
    If length = 0 
      length = 1.0
    EndIf
    
    ilength = 1.0 / length

    *q\x = *q\x * ilength
    *q\y = *q\y * ilength
    *q\z = *q\z * ilength
    *q\w = *q\w * ilength
  EndIf

  Init_Vector3(@resAxis, 0.0, 0.0, 0.0)
  
  resAngle = 2.0 * ACos(*q\w)
  den = Sqr(1.0 - *q\w * *q\w)

  If den > 0.0001
    resAxis\x = *q\x / den
    resAxis\y = *q\y / den
    resAxis\z = *q\z / den
  Else
    ; This occurs when the angle is zero.
    ; Not a problem: just set an arbitrary normalized axis.
    resAxis\x = 1.0
  EndIf

  *outAxis = resAxis
  
  PokeF(*outAngle, resAngle)
  
EndProcedure

; Get the quaternion equivalent To Euler angles
; NOTE: Rotation order is ZYX
Procedure QuaternionFromEuler(*result.Quaternion, pitch.rl_float, yaw.rl_float, roll.rl_float)
  Protected.rl_float x0 = Cos(pitch * 0.5)
  Protected.rl_float x1 = Sin(pitch * 0.5)
  Protected.rl_float y0 = Cos(yaw * 0.5)
  Protected.rl_float y1 = Sin(yaw * 0.5)
  Protected.rl_float z0 = Cos(roll * 0.5)
  Protected.rl_float z1 = Sin(roll * 0.5)

  *result\x = x1 * y0 * z0 - x0 * y1 * z1
  *result\y = x0 * y1 * z0 + x1 * y0 * z1
  *result\z = x0 * y0 * z1 - x1 * y1 * z0
  *result\w = x0 * y0 * z0 + x1 * y1 * z1
EndProcedure

; Get the Euler angles equivalent To quaternion (roll, pitch, yaw)
; NOTE: Angles are returned in a Vector3 struct in radians
Procedure QuaternionToEuler(*result._Vector3, *q.Quaternion)
  ; Roll (x-axis rotation)
  Protected.rl_float x0 = 2.0 * (*q\w * *q\x + *q\y * *q\z)
  Protected.rl_float x1 = 1.0 - 2.0 * (*q\x * *q\x + *q\y * *q\y)
  
  *result\x = ATan2(x0, x1)

  ; Pitch (y-axis rotation)
  Protected.rl_float y0 = 2.0 * (*q\w * *q\y - *q\z * *q\x)
  
  If y0 > 1.0
    y0 = 1.0 
  Else
    y0 = y0
  EndIf
  
  If y0 < -1.0
    y0 = -1.0 
  Else
    y0 = y0
  EndIf
  
  *result\y = ASin(y0)

  ; Yaw (z-axis rotation)
  Protected.rl_float z0 = 2.0 * (*q\w * *q\z + *q\x * *q\y)
  Protected.rl_float z1 = 1.0 - 2.0 * (*q\y * *q\y + *q\z * *q\z)
  
  *result\z = ATan2(z0, z1)
EndProcedure

; Transform a quaternion given a transformation matrix
Procedure QuaternionTransform(*result.Quaternion, *q.Quaternion, *mat.Matrix)
  *result\x = *mat\m0 * *q\x + *mat\m4 * *q\y + *mat\m8 * *q\z + *mat\m12 * *q\w
  *result\y = *mat\m1 * *q\x + *mat\m5 * *q\y + *mat\m9 * *q\z + *mat\m13 * *q\w
  *result\z = *mat\m2 * *q\x + *mat\m6 * *q\y + *mat\m10 * *q\z + *mat\m14 * *q\w
  *result\w = *mat\m3 * *q\x + *mat\m7 * *q\y + *mat\m11 * *q\z + *mat\m15 * *q\w
EndProcedure

; Check whether two given quaternions are almost equal
Procedure.rl_bool QuaternionEquals(*p.Quaternion, *q.Quaternion)
  Protected.rl_bool result = Bool((((Abs(*p\x - *q\x)) <= (#EPSILON * fMax(1.0, fMax(Abs(*p\x), Abs(*q\x))))) And
                  ((Abs(*p\y - *q\y)) <= (#EPSILON * fMax(1.0, fMax(Abs(*p\y), Abs(*q\y))))) And
                  ((Abs(*p\z - *q\z)) <= (#EPSILON * fMax(1.0, fMax(Abs(*p\z), Abs(*q\z))))) And
                  ((Abs(*p\w - *q\w)) <= (#EPSILON * fMax(1.0, fMax(Abs(*p\w), Abs(*q\w)))))) Or
                  (((Abs(*p\x + *q\x)) <= (#EPSILON * fMax(1.0, fMax(Abs(*p\x), Abs(*q\x))))) And
                  ((Abs(*p\y + *q\y)) <= (#EPSILON * fMax(1.0, fMax(Abs(*p\y), Abs(*q\y))))) And
                  ((Abs(*p\z + *q\z)) <= (#EPSILON * fMax(1.0, fMax(Abs(*p\z), Abs(*q\z))))) And
                  ((Abs(*p\w + *q\w)) <= (#EPSILON * fMax(1.0, fMax(Abs(*p\w), Abs(*q\w)))))))

  ProcedureReturn result
EndProcedure
; IDE Options = PureBasic 6.20 Beta 3 - C Backend (MacOS X - x64)
; CursorPosition = 66
; FirstLine = 62
; Folding = ---------------------
; Optimizer
; EnableThread
; EnableXP
; Compiler = PureBasic 6.00 LTS - C Backend (MacOS X - x64)