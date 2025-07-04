//
//  Rotation.swift
//  MetalScope
//
//  Created by Jun Tanaka on 2017/01/17.
//  Copyright © 2017 eje Inc. All rights reserved.
//

public struct DeviceRotation {
    
    public var matrix: RotationMatrix3

    public init(_ matrix: RotationMatrix3 = RotationMatrix3Identity()) {
        self.matrix = matrix
    }

    public init(matrix: RotationMatrix3) {
        self.matrix = matrix
    }
}

extension DeviceRotation {
    public static let identity = DeviceRotation()
}

extension DeviceRotation {

    public init(nativeMatrix3: RotationMatrix3) {
        self.init(matrix: nativeMatrix3)
    }

    public var nativeMatrix3: RotationMatrix3 {
        get {
            return matrix
        }
        set(value) {
            matrix = value
        }
    }
}

extension DeviceRotation {
    public init(nativeQuaternion: RotationQuaternion) {
        self.init(RotationMatrix3MakeWithQuaternion(nativeQuaternion))
    }

    public var nativeQuarternion: RotationQuaternion {
        get {
            return RotationQuaternionMakeWithMatrix3(self.nativeMatrix3)
        }
        set(value) {
            self.nativeMatrix3 = RotationMatrix3MakeWithQuaternion(value)
        }
    }
}

extension DeviceRotation {
    public init(radians: Float, aroundVector vector: RotationVector3) {
        self.init(matrix:RotationMatrix3MakeRotation(radians, vector.x, vector.y, vector.z))
    }

    public init(x: Float) {
        self.init(matrix:RotationMatrix3MakeXRotation(x))
    }

    public init(y: Float) {
        self.init(matrix:RotationMatrix3MakeYRotation(y))
    }

    public init(z: Float) {
        self.init(matrix:RotationMatrix3MakeZRotation(z))
    }
}

extension DeviceRotation {
    private mutating func rotate(byRadians radians: Float, aroundAxis axis: RotationVector3) {
        self.matrix = RotationMatrix3RotateWithVector3(self.nativeMatrix3, radians, axis)
    }

    private mutating func rotate(byX radians: Float) {
        self.matrix = RotationMatrix3RotateX(self.nativeMatrix3, radians)
    }

    private mutating func rotate(byY radians: Float) {
        self.matrix = RotationMatrix3RotateY(self.nativeMatrix3, radians)
    }

    private mutating func rotate(byZ radians: Float) {
        self.matrix = RotationMatrix3RotateZ(self.nativeMatrix3, radians)
    }

	public func rotated(byRadians radians: Float, aroundAxis axis: RotationVector3) -> DeviceRotation {
	let matrix = RotationMatrix3RotateWithVector3(self.nativeMatrix3, radians, axis)
		return DeviceRotation(matrix: matrix)
    }

    public func rotated(byX radians: Float) -> DeviceRotation {
    let matrix = RotationMatrix3RotateX(self.nativeMatrix3, radians)
		return DeviceRotation(matrix: matrix)
    }

    public func rotated(byY radians: Float) -> DeviceRotation {
	let matrix = RotationMatrix3RotateY(self.nativeMatrix3, radians)
		return DeviceRotation(matrix: matrix)
    }

    public func rotated(byZ radians: Float) -> DeviceRotation {
    let matrix = RotationMatrix3RotateZ(self.nativeMatrix3, radians)
		return DeviceRotation(matrix: matrix)
    }
}

extension DeviceRotation {
    private mutating func invert() {
        self.nativeQuarternion = RotationQuaternionInvert(self.nativeQuarternion)
    }

    private mutating func normalize() {
        self.nativeQuarternion = RotationQuaternionNormalize(self.nativeQuarternion)
    }

    public func inverted() -> DeviceRotation {
    let nativeQuarternion = RotationQuaternionInvert(self.nativeQuarternion)
		return DeviceRotation(nativeQuaternion: nativeQuarternion)
    }

    public func normalized() -> DeviceRotation {
    let nativeQuarternion = RotationQuaternionNormalize(self.nativeQuarternion)
		return DeviceRotation(nativeQuaternion: nativeQuarternion)
    }
}

extension DeviceRotation {
//    public func rotated(byRadians radians: Float, aroundAxis axis: RotationVector3) -> DeviceRotation {
//        var r = self
//        r.rotate(byRadians: radians, aroundAxis: axis)
//        return r
//    }
//
//    public func rotated(byX x: Float) -> DeviceRotation {
//        var r = self
//        r.rotate(byX: x)
//        return r
//    }
//
//    public func rotated(byY y: Float) -> DeviceRotation {
//        var r = self
//        r.rotate(byY: y)
//        return r
//    }
//
//    public func rotated(byZ z: Float) -> DeviceRotation {
//        var r = self
//        r.rotate(byZ: z)
//        return r
//    }
//
//    public func inverted() -> DeviceRotation {
//        var r = self
//        r.invert()
//        return r
//    }
//
//    public func normalized() -> DeviceRotation {
//        var r = self
//        r.normalize()
//        return r
//    }
}

public func * (lhs: DeviceRotation, rhs: DeviceRotation) -> DeviceRotation {
    return DeviceRotation(matrix:RotationMatrix3Multiply(lhs.matrix, rhs.matrix))
}

public func * (lhs: DeviceRotation, rhs: RotationVector3) -> RotationVector3 {
    return Rotation3MultiplyVector3(lhs.matrix, rhs)
}
