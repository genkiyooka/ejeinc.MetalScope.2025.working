//
//  Untitled.swift
//  MonoImage
//
//  Created by dg on 5/25/25.
//  Copyright © 2025 eje Inc. All rights reserved.
//

import GLKit
import simd

#if ROTATION_GLKIT

public typealias RotationVector3 = GLKVector3
public typealias RotationMatrix3 = GLKMatrix3
public typealias RotationQuaternion = GLKQuaternion

#else

public typealias RotationVector3 = SIMDVector3
public typealias RotationMatrix3 = SIMDMatrix3
public typealias RotationQuaternion = SIMDQuaternion

#endif

@inlinable
func GLKMatrix3FromNative(_ nativeMatrix: RotationMatrix3) -> GLKMatrix3 {
#if ROTATION_GLKIT
    return nativeMatrix
#else
    return GLKMatrix3FromSIMDMatrix3(nativeMatrix)
#endif
}

@inlinable
func SIMDMatrix3FromNative(_ nativeMatrix: RotationMatrix3) -> SIMDMatrix3 {
#if ROTATION_GLKIT
    return SIMDMatrix3FromGLKMatrix3(nativeMatrix)
#else
    return nativeMatrix
#endif
}

@inlinable
func NativeMatrix3FromGLKMatrix3(_ glkMatrix: GLKMatrix3) -> RotationMatrix3 {
#if ROTATION_GLKIT
    return glkMatrix
#else
    return SIMDMatrix3FromGLKMatrix3(glkMatrix)
#endif
}

@inlinable
func NativeMatrix3FromSIMDMatrix3(_ simdMatrix: SIMDMatrix3) -> RotationMatrix3 {
#if ROTATION_GLKIT
    return GLKMatrix3FromSIMDMatrix3(simdMatrix)
#else
    return simdMatrix
#endif
}

@inlinable
func SIMDMatrix3FromNativeMatrix3(_ nativeMatrix: RotationMatrix3) -> SIMDMatrix3 {
#if ROTATION_GLKIT
    return SIMDMatrix3FromGLKMatrix3(nativeMatrix)
#else
    return nativeMatrix
#endif
}

public func NativeQuaternionMake(_ x: Float, _ y: Float, _ z: Float, _ w: Float) -> RotationQuaternion {
#if ROTATION_GLKIT
    return GLKQuaternionMake(x,y,z,w)
#else
    return simd_quatf(ix:x,iy:y,iz:z,r:w)
#endif
}

#if ROTATION_GLKIT

@inlinable
public func RotationMatrix3MakeRotation(_ radians: Float, _ x: Float, _ y: Float, _ z: Float) -> RotationMatrix3 {
    return GLKMatrix3MakeRotation(radians, x, y, z)
}

@inlinable
public func RotationMatrix3Identity() -> RotationMatrix3 {
    return GLKMatrix3Identity
}

@inlinable
public func RotationMatrix3MakeXRotation(_ radians: Float) -> RotationMatrix3 {
    return GLKMatrix3MakeXRotation(radians)
}

@inlinable
public func RotationMatrix3MakeYRotation(_ radians: Float) -> RotationMatrix3 {
    return GLKMatrix3MakeYRotation(radians)
}

@inlinable
public func RotationMatrix3MakeZRotation(_ radians: Float) -> RotationMatrix3 {
    return GLKMatrix3MakeZRotation(radians)
}

@inlinable
public func Rotation3MultiplyVector3(_ matrixLeft: RotationMatrix3, _ vectorRight: RotationVector3) -> RotationVector3 {
    return GLKMatrix3MultiplyVector3(matrixLeft,vectorRight)
}

@inlinable
public func RotationMatrix3Multiply(_ lhs: RotationMatrix3, _ rhs: RotationMatrix3) -> RotationMatrix3 {
    return GLKMatrix3Multiply(lhs, rhs)
}

@inlinable
public func RotationMatrix3RotateWithVector3(_ matrix: RotationMatrix3, _ radians: Float, _ axisVector: RotationVector3) -> RotationMatrix3 {
    return GLKMatrix3RotateWithVector3(matrix,radians,axisVector)
}

@inlinable
public func RotationMatrix3RotateX(_ matrix: RotationMatrix3, _ radians: Float) -> RotationMatrix3 {
    return GLKMatrix3RotateX(matrix,radians)
}

@inlinable
public func RotationMatrix3RotateY(_ matrix: RotationMatrix3, _ radians: Float) -> RotationMatrix3 {
    return GLKMatrix3RotateY(matrix,radians)
}

@inlinable
public func RotationMatrix3RotateZ(_ matrix: RotationMatrix3, _ radians: Float) -> RotationMatrix3 {
    return GLKMatrix3RotateZ(matrix,radians)
}

@inlinable
public func RotationMatrix3MakeWithQuaternion(_ quaternion: RotationQuaternion) -> RotationMatrix3 {
    return GLKMatrix3MakeWithQuaternion(quaternion)
}

@inlinable
public func RotationQuaternionMakeWithMatrix3(_ matrix: RotationMatrix3) -> RotationQuaternion {
    return GLKQuaternionMakeWithMatrix3(matrix)
}

@inlinable
public func RotationQuaternionInvert(_ quaternion: RotationQuaternion) -> RotationQuaternion {
    return GLKQuaternionInvert(quaternion)
}

@inlinable
public func RotationQuaternionNormalize(_ quaternion: RotationQuaternion) -> RotationQuaternion {
    return GLKQuaternionNormalize(quaternion)
}

#else /* !ROTATION_GLKIT */

@inlinable
public func RotationMatrix3Identity() -> RotationMatrix3 {
    return matrix_identity_float3x3
}

@inlinable
public func RotationMatrix3MakeRotation(_ radians: Float, _ x: Float, _ y: Float, _ z: Float) -> RotationMatrix3 {
    let axis = normalize(SIMD3<Float>(x, y, z))
    return simd_float3x3(simd_quatf(angle: radians, axis: axis))
}

@inlinable
public func RotationMatrix3MakeXRotation(_ radians: Float) -> RotationMatrix3 {
    return simd_float3x3(simd_quatf(angle: radians, axis: SIMD3<Float>(1, 0, 0)))
}

@inlinable
public func RotationMatrix3MakeYRotation(_ radians: Float) -> RotationMatrix3 {
    return simd_float3x3(simd_quatf(angle: radians, axis: SIMD3<Float>(0, 1, 0)))
}

@inlinable
public func RotationMatrix3MakeZRotation(_ radians: Float) -> RotationMatrix3 {
    return simd_float3x3(simd_quatf(angle: radians, axis: SIMD3<Float>(0, 0, 1)))
}

@inlinable
public func RotationMatrix3Multiply(_ lhs: RotationMatrix3, _ rhs: RotationMatrix3) -> RotationMatrix3 {
    return simd_mul(lhs, rhs)
}

@inlinable
public func Rotation3MultiplyVector3(_ lhs: RotationMatrix3, _ rhs: RotationVector3) -> RotationVector3 {
    return lhs * rhs
}

@inlinable
public func RotationMatrix3RotateWithVector3(_ matrix: RotationMatrix3, _ radians: Float, _ axisVector: RotationVector3) -> RotationMatrix3 {
    let rotation = simd_float3x3(simd_quatf(angle: radians, axis: normalize(axisVector)))
    return simd_mul(matrix, rotation)
}

@inlinable
public func RotationMatrix3RotateX(_ matrix: RotationMatrix3, _ radians: Float) -> RotationMatrix3 {
    return simd_mul(matrix, RotationMatrix3MakeXRotation(radians))
}

@inlinable
public func RotationMatrix3RotateY(_ matrix: RotationMatrix3, _ radians: Float) -> RotationMatrix3 {
    return simd_mul(matrix, RotationMatrix3MakeYRotation(radians))
}

@inlinable
public func RotationMatrix3RotateZ(_ matrix: RotationMatrix3, _ radians: Float) -> RotationMatrix3 {
    return simd_mul(matrix, RotationMatrix3MakeZRotation(radians))
}

@inlinable
public func RotationMatrix3MakeWithQuaternion(_ quaternion: RotationQuaternion) -> RotationMatrix3 {
    return simd_float3x3(quaternion)
}

@inlinable
public func RotationQuaternionMakeWithMatrix3(_ matrix: RotationMatrix3) -> RotationQuaternion {
    return simd_quatf(matrix)
}

@inlinable
public func RotationQuaternionInvert(_ quaternion: RotationQuaternion) -> RotationQuaternion {
    return simd_inverse(quaternion)
}

@inlinable
public func RotationQuaternionNormalize(_ quaternion: RotationQuaternion) -> RotationQuaternion {
    return simd_normalize(quaternion)
}

#endif /* ROTATION_GLKIT */
