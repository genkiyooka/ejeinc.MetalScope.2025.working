//
//  Rotation+GLKit.swift
//  MetalScope
//
//  Created by dg on 5/25/25.
//  Copyright © 2025 eje Inc. All rights reserved.
//

import GLKit

#if ROTATION_GLKIT

extension Rotation {
    public init(glkMatrix3: GLKMatrix3) {
        self.init(matrix: NativeMatrix3FromGLKMatrix3(glkMatrix3))
    }

    public var glkMatrix3: GLKMatrix3 {
        get {
            return GLKMatrix3FromNative(self.nativeMatrix3)
        }
        set(value) {
            self.nativeMatrix3 = NativeMatrix3FromGLKMatrix3(value)
        }
    }
}

extension Rotation {
    public init(glkQuaternion: GLKQuaternion) {
        self.init(glkMatrix3:GLKMatrix3MakeWithQuaternion(glkQuaternion))
    }

    public var glkQuartenion: GLKQuaternion {
        get {
            return GLKQuaternionMakeWithMatrix3(self.glkMatrix3)
        }
        set(value) {
            self.glkMatrix3 = GLKMatrix3MakeWithQuaternion(value)
        }
    }
}

#endif /* ROTATION_GLKIT */

