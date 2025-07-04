//
//  Rotation+simd.swift
//  MetalScope
//
//  Created by dg on 5/25/25.
//  Copyright © 2025 eje Inc. All rights reserved.
//

import simd
import GLKit

public typealias SIMDVector3 = SIMD3<Float>
public typealias SIMDVector4 = SIMD4<Float>
public typealias SIMDMatrix3 = simd_float3x3
public typealias SIMDQuaternion = simd_quatf

// MARK: -

/* map quaternion values to GLKit xyzw */
extension SIMDQuaternion {
    var x:Float {
        return self.imag.x
        }
    var y:Float {
        return self.imag.y
        }
    var z:Float {
        return self.imag.z
        }
    var w:Float {
        return self.real
        }
}

@inlinable
func SIMDVector3MakeWithFloat4(float4: simd_float4) -> SIMDVector3 {
    return simd_float3.init(float4.x, float4.y, float4.z)
}

@inlinable
func SIMDVector4MakeWithFloat3(float3: simd_float3) -> SIMDVector4 {
    return simd_float4.init(float3.x, float3.y, float3.z, 0)
}

@inlinable
func SIMDMatrix3MakeWithSIMDMatrix4(float4x4: simd_float4x4) -> SIMDMatrix3 {
let column0 = SIMDVector3MakeWithFloat4(float4:float4x4.columns.0)
let column1 = SIMDVector3MakeWithFloat4(float4:float4x4.columns.1)
let column2 = SIMDVector3MakeWithFloat4(float4:float4x4.columns.2)
    return simd_float3x3.init(column0, column1, column2)
}

@inlinable
func SIMDMatrix4MakeWithSIMDMatrix3(float3x3: simd_float3x3) -> simd_float4x4 {
let column0 = SIMDVector4MakeWithFloat3(float3:float3x3.columns.0)
let column1 = SIMDVector4MakeWithFloat3(float3:float3x3.columns.1)
let column2 = SIMDVector4MakeWithFloat3(float3:float3x3.columns.2)
let identity3 = simd_float4.init(x: 0, y: 0, z: 0, w: 1)
    return simd_float4x4.init(column0, column1, column2, identity3)
}

// MARK: -

@inlinable
public func SIMDMatrix3MakeWithSIMDQuaternion(_ quaternion: SIMDQuaternion) -> SIMDMatrix3 {
    return simd_float3x3(quaternion)
}

@inlinable
public func SIMDQuaternionMakeWithSIMDMatrix3(_ matrix: SIMDMatrix3) -> SIMDQuaternion {
    return simd_quatf(matrix)
}

@inlinable
func GLKMatrix3FromSIMDMatrix3(_ simd: simd_float3x3) -> GLKMatrix3 {
    return GLKMatrix3Make(
        simd.columns.0.x, simd.columns.0.y, simd.columns.0.z,
        simd.columns.1.x, simd.columns.1.y, simd.columns.1.z,
        simd.columns.2.x, simd.columns.2.y, simd.columns.2.z
    )
}

@inlinable
func SIMDMatrix3FromGLKMatrix3(_ glk: GLKMatrix3) -> simd_float3x3 {
    return simd_float3x3(columns: (
        SIMD3<Float>(glk.m00, glk.m01, glk.m02),
        SIMD3<Float>(glk.m10, glk.m11, glk.m12),
        SIMD3<Float>(glk.m20, glk.m21, glk.m22)
    ))
}


func eulerVector3From(simdQuaternion quat: simd_quatf) -> SIMD3<Float> {

var angles = SIMD3<Float>();
let qfloat = quat.vector

// heading = x, attitude = y, bank = z

let test = qfloat.x*qfloat.y + qfloat.z*qfloat.w;

if (test > 0.499) { // singularity at north pole
    
    angles.x = 2 * atan2(qfloat.x,qfloat.w)
    angles.y = (.pi / 2)
    angles.z = 0
    return  angles
}
if (test < -0.499) { // singularity at south pole
    angles.x = -2 * atan2(qfloat.x,qfloat.w)
    angles.y = -(.pi / 2)
    angles.z = 0
    return angles
}


let sqx = qfloat.x*qfloat.x;
let sqy = qfloat.y*qfloat.y;
let sqz = qfloat.z*qfloat.z;
	angles.x = atan2(2*qfloat.y*qfloat.w-2*qfloat.x*qfloat.z , 1 - 2*sqy - 2*sqz)
	angles.y = asin(2*test)
	angles.z = atan2(2*qfloat.x*qfloat.w-2*qfloat.y*qfloat.z , 1 - 2*sqx - 2*sqz)
	return angles;
}

func eulerAnglesFrom(simdQuaternion quat: simd_quatf) -> (pitch: Float, roll: Float, yaw: Float) {
let eulerAnglesVector3 = eulerVector3From(simdQuaternion: quat)
	return (eulerAnglesVector3.x,eulerAnglesVector3.y,eulerAnglesVector3.z)
}

extension DeviceRotation {

    public init(simdMatrix3: SIMDMatrix3) {
        self.init(matrix: NativeMatrix3FromSIMDMatrix3(simdMatrix3))
    }

    public var simdMatrix3: SIMDMatrix3 {
        get {
            return SIMDMatrix3FromNativeMatrix3(self.matrix)
        }
        set(value) {
            self.matrix = NativeMatrix3FromSIMDMatrix3(value)
        }
    }
}

extension DeviceRotation {
    public init(_ simdQuaternion: SIMDQuaternion) {
        self.init(simdMatrix3:SIMDMatrix3MakeWithSIMDQuaternion(simdQuaternion))
    }

    public var simdQuartenion: SIMDQuaternion {
        get {
            return SIMDQuaternionMakeWithSIMDMatrix3(self.simdMatrix3)
        }
        set(value) {
            self.simdMatrix3 = SIMDMatrix3MakeWithSIMDQuaternion(value)
        }
    }
}
