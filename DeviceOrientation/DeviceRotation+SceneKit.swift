//
//  Rotation+SceneKit.swift
//  MetalScope
//
//  Created by Jun Tanaka on 2017/01/17.
//  Copyright © 2017 eje Inc. All rights reserved.
//

import SceneKit

extension DeviceRotation {
    private init(scnQuaternion q: SCNQuaternion) {
        self.init(nativeQuaternion:NativeQuaternionMake(q.x, q.y, q.z, q.w))
    }

    public var scnQuaternion: SCNQuaternion {
        let q = self.nativeQuarternion
        return SCNQuaternion(x: q.x, y: q.y, z: q.z, w: q.w)
    }
}

#if ROTATION_GLKIT

import GLKit

extension Rotation {
    public init(_ scnMatrix4: SCNMatrix4) {
        let glkMatrix4 = SCNMatrix4ToGLKMatrix4(scnMatrix4)
        let glkMatrix3 = GLKMatrix4GetMatrix3(glkMatrix4)
        self.init(nativeMatrix3:NativeMatrix3FromGLKMatrix3(glkMatrix3))
    }

    public var scnMatrix4: SCNMatrix4 {
        let glkMatrix4 = GLKMatrix4MakeWithQuaternion(self.glkQuartenion)
        let scnMatrix4 = SCNMatrix4FromGLKMatrix4(glkMatrix4)
        return scnMatrix4
    }
}

#else

import simd

extension DeviceRotation {
    public init(_ scnMatrix4: SCNMatrix4) {
        let simdMatrix4 = simd_float4x4(scnMatrix4)
        let simdMatrix3 = SIMDMatrix3MakeWithSIMDMatrix4(float4x4:simdMatrix4) // Drop translation
        self.init(nativeMatrix3: simdMatrix3)
    }

    public var scnMatrix4: SCNMatrix4 {
        let matrix3 = SIMDMatrix3FromNativeMatrix3(self.nativeMatrix3)
        let matrix4 = SIMDMatrix4MakeWithSIMDMatrix3(float3x3:matrix3)
        return SCNMatrix4(matrix4)
    }
}

#endif
