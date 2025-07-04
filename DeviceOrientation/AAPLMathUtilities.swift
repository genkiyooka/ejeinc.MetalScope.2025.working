import Foundation
import simd
import Metal

extension Float {

	func clampedRangeTau() -> Float {
		let kTwoPI_TAU: Float = 2.0 * .pi
		// Wrap each component to the range [0, 2π)
		// Use the fmodf function to get the remainder of value / pi.
		// This will give a value in the range (-pi, pi).
		let result = fmodf(self, kTwoPI_TAU)
		// If the result is negative, add kTwoPI_TAU to bring it into the [0, kTwoPI_TAU) range.
		if result < 0 {
			return (result + kTwoPI_TAU)
			}
		else {
			return result
		}
	}

}

extension SIMD3<Float> {

	func clampedRangeTau() -> SIMD3<Float> {
		return SIMD3<Float>(x.clampedRangeTau(),y.clampedRangeTau(),z.clampedRangeTau())
	}

}

@inlinable
public func SIMDMatrix3MakeWithSIMDQuaternion(_ quaternion: simd_quatf) -> simd_float3x3 {
    return simd_float3x3(quaternion)
}

@inlinable
func SIMDVector3MakeWithFloat4(float4: simd_float4) -> simd_float3 {
    return simd_float3.init(float4.x, float4.y, float4.z)
}

@inlinable
func SIMDVector4MakeWithFloat3(float3: simd_float3) -> simd_float4 {
    return simd_float4.init(float3.x, float3.y, float3.z, 0)
}

@inlinable
func SIMDMatrix4MakeWithSIMDMatrix3(float3x3: simd_float3x3) -> simd_float4x4 {
let column0 = SIMDVector4MakeWithFloat3(float3:float3x3.columns.0)
let column1 = SIMDVector4MakeWithFloat3(float3:float3x3.columns.1)
let column2 = SIMDVector4MakeWithFloat3(float3:float3x3.columns.2)
let identity3 = simd_float4.init(x: 0, y: 0, z: 0, w: 1)
    return simd_float4x4.init(column0, column1, column2, identity3)
}

@inlinable
func SIMDQuaternion(eulerOrientation: simd_float2) -> simd_quatf {
let pitch = eulerOrientation.x  // rotation around X
let yaw = eulerOrientation.y    // rotation around Y
// Apply intrinsic Tait-Bryan angles in ZYX order (roll → yaw → pitch)
let qx = simd_quatf(angle: pitch, axis: SIMD3<Float>(1, 0, 0))
let qy = simd_quatf(angle: yaw, axis: SIMD3<Float>(0, 1, 0))
// Combine rotations in ZYX order
	return qy * qx
}

@inlinable
func SIMDQuaternion(eulerOrientation: simd_float3) -> simd_quatf {
let pitch = eulerOrientation.x  // rotation around X
let yaw = eulerOrientation.y    // rotation around Y
let roll = eulerOrientation.z   // rotation around Z
// Apply intrinsic Tait-Bryan angles in ZYX order (roll → yaw → pitch)
let qx = simd_quatf(angle: pitch, axis: SIMD3<Float>(1, 0, 0))
let qy = simd_quatf(angle: yaw, axis: SIMD3<Float>(0, 1, 0))
let qz = simd_quatf(angle: roll, axis: SIMD3<Float>(0, 0, 1))
// Combine rotations in ZYX order
	return qz * qy * qx
}

extension simd_float3x3 {

	init(rotationZYX eulerAngles: SIMD3<Float>) {
		let radians = eulerAngles.clampedRangeTau();
		let cx = cos(radians.x), sx = sin(radians.x)
		let cy = cos(radians.y), sy = sin(radians.y)
		let cz = cos(radians.z), sz = sin(radians.z)
		let rotationMatrix = simd_float3x3(
			SIMD3<Float>(cy * cz, cy * sz, -sy),
			SIMD3<Float>(sx * sy * cz - cx * sz, sx * sy * sz + cx * cz, sx * cy),
			SIMD3<Float>(cx * sy * cz + sx * sz, cx * sy * sz - sx * cz, cx * cy)
			)
		self.init(rotationMatrix)
		}
}

extension simd_float4x4 {
    init(_ m00: Float, _ m10: Float, _ m20: Float, _ m30: Float,
         _ m01: Float, _ m11: Float, _ m21: Float, _ m31: Float,
         _ m02: Float, _ m12: Float, _ m22: Float, _ m32: Float,
         _ m03: Float, _ m13: Float, _ m23: Float, _ m33: Float) {
        self.init([m00, m01, m02, m03],
                  [m10, m11, m12, m13],
                  [m20, m21, m22, m23],
                  [m30, m31, m32, m33])
    }

	init(float3x3: simd_float3x3) {
		let column0 = SIMDVector4MakeWithFloat3(float3:float3x3.columns.0)
		let column1 = SIMDVector4MakeWithFloat3(float3:float3x3.columns.1)
		let column2 = SIMDVector4MakeWithFloat3(float3:float3x3.columns.2)
		let identity3 = simd_float4.init(x: 0, y: 0, z: 0, w: 1)
			self.init(column0, column1, column2, identity3)
		}

    init(fieldOfView: Float, aspectRatio: Float, nearZ: Float, farZ: Float, metalCoordinates:Bool) {
        let yVal = 1 / tan(fieldOfView * 0.5)
        let xVal = yVal / aspectRatio
        let zVal = farZ / (nearZ - farZ)
        
        let diagonalYVal = metalCoordinates ? -yVal : yVal
        
        self.init(diagonal: SIMD4(xVal, diagonalYVal, zVal, 0))
        self[2, 3] = -1
        self[3, 2] = zVal * nearZ
    }


    init(rotationAngle: Float, axis: SIMD3<Float>) {
        self.init()
        // Note: rotationInAngle is in radians
        let unitAxis = normalize(axis)
        let cos = cosf(rotationAngle)
        let sin = sinf(rotationAngle)
        let cosI = 1 - cos
        let xVal = unitAxis.x, yVal = unitAxis.y, zVal = unitAxis.z
        
        self[0] = vector_float4(cos + xVal * xVal * cosI,
                                yVal * xVal * cosI + zVal * sin,
                                zVal * xVal * cosI - yVal * sin,
                                0)
        self[1] = vector_float4(xVal * yVal * cosI - zVal * sin,
                                cos + yVal * yVal * cosI,
                                zVal * yVal * cosI + xVal * sin,
                                0)
        self[2] = vector_float4(xVal * zVal * cosI + yVal * sin,
                                yVal * zVal * cosI - xVal * sin,
                                cos + zVal * zVal * cosI,
                                0)
        self[3] = vector_float4(0, 0, 0, 1)
    }
    
    init(translationX: Float, translationY: Float, translationZ: Float) {
        self.init(1.0)
        self[3, 0] = translationX
        self[3, 1] = translationY
        self[3, 2] = translationZ
    }
    
    static func perspectiveRightHand(fovyRadians: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> simd_float4x4 {
        let ys = 1.0 / tanf(fovyRadians * 0.5)
        let xs = ys / aspectRatio
        let zs = farZ / (nearZ - farZ)
		return matrix_float4x4.init(columns:(vector_float4(xs,  0, 0,   0),
											 vector_float4( 0, ys, 0,   0),
											 vector_float4( 0,  0, zs, -1),
											 vector_float4( 0,  0, zs * nearZ, 0)))
//        return simd_float4x4(xs, 0, 0, 0,
//                             0, ys, 0, 0,
//                             0, 0, zs, nearZ * zs,
//                             0, 0, -1, 0)
    }

    static func perspectiveLeftHand(fovyRadians: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> simd_float4x4 {
        let ys = 1.0 / tanf(fovyRadians * 0.5)
        let xs = ys / aspectRatio
        let zs = farZ / (farZ - nearZ)
		return matrix_float4x4.init(columns:(vector_float4(xs,  0, 0,   0),
											 vector_float4( 0, ys, 0,   0),
											 vector_float4( 0,  0, zs, -1),
											 vector_float4( 0,  0, zs * nearZ, 0)))
//        return simd_float4x4(xs, 0, 0, 0,
//                             0, ys, 0, 0,
//                             0, 0, zs, -nearZ * zs,
//                             0, 0,  1, 0)
    }

    static func rotation(_ radians: Float, _ axis: SIMD3<Float>) -> simd_float4x4 {
        let axis = simd_normalize(axis)
        let ct = cosf(radians)
        let st = sinf(radians)
        let ci = 1 - ct
        let x = axis.x
        let y = axis.y
        let z = axis.z

        return simd_float4x4(ct + x * x * ci, x * y * ci - z * st, x * z * ci + y * st, 0,
                             y * x * ci + z * st, ct + y * y * ci, y * z * ci - x * st, 0,
                             z * x * ci - y * st, z * y * ci + x * st, ct + z * z * ci, 0,
                             0, 0, 0, 1)
    }

    static func translation(_ t: SIMD3<Float>) -> simd_float4x4 {
        return simd_float4x4(1, 0, 0, t.x,
                             0, 1, 0, t.y,
                             0, 0, 1, t.z,
                             0, 0, 0, 1)
    }

    static var identity: simd_float4x4 {
        return simd_float4x4(1, 0, 0, 0,
                             0, 1, 0, 0,
                             0, 0, 1, 0,
                             0, 0, 0, 1)
    }

    static func lookAtRH(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> simd_float4x4 {
        let zAxis = simd_normalize(eye - center)  // Right-handed: forward is -Z
        let xAxis = simd_normalize(simd_cross(up, zAxis))
        let yAxis = simd_cross(zAxis, xAxis)

        let translation = SIMD3<Float>(
            -simd_dot(xAxis, eye),
            -simd_dot(yAxis, eye),
            -simd_dot(zAxis, eye)
        )

        return simd_float4x4(
            SIMD4<Float>(xAxis.x, yAxis.x, zAxis.x, 0),
            SIMD4<Float>(xAxis.y, yAxis.y, zAxis.y, 0),
            SIMD4<Float>(xAxis.z, yAxis.z, zAxis.z, 0),
            SIMD4<Float>(translation.x, translation.y, translation.z, 1)
        )
    }

    static func lookAtLH(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> simd_float4x4 {
        let zAxis = simd_normalize(center - eye)  // Left-handed: forward is +Z
        let xAxis = simd_normalize(simd_cross(up, zAxis))
        let yAxis = simd_cross(zAxis, xAxis)

        let translation = SIMD3<Float>(
            -simd_dot(xAxis, eye),
            -simd_dot(yAxis, eye),
            -simd_dot(zAxis, eye)
        )

        return simd_float4x4(
            SIMD4<Float>(xAxis.x, yAxis.x, zAxis.x, 0),
            SIMD4<Float>(xAxis.y, yAxis.y, zAxis.y, 0),
            SIMD4<Float>(xAxis.z, yAxis.z, zAxis.z, 0),
            SIMD4<Float>(translation.x, translation.y, translation.z, 1)
        )
    }

	static let kMetalCoordinatesTransform = simd_float4x4(	1,  0, 0, 0,
															0, -1, 0, 0,
															0,  0, 1, 0,
															0,  0, 0, 1)


}

//func matrix_perspective_right_hand(fovyRadians fovy: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
//    let ys = 1 / tanf(fovy * 0.5)
//    let xs = ys / aspectRatio
//    let zs = farZ / (nearZ - farZ)
//    return matrix_float4x4.init(columns:(vector_float4(xs,  0, 0,   0),
//                                         vector_float4( 0, ys, 0,   0),
//                                         vector_float4( 0,  0, zs, -1),
//                                         vector_float4( 0,  0, zs * nearZ, 0)))
//}

func radians_from_degrees(_ degrees: Float) -> Float {
    return (degrees / 180) * .pi
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
	else if (test < -0.499) { // singularity at south pole
		angles.x = -2 * atan2(qfloat.x,qfloat.w)
		angles.y = -(.pi / 2)
		angles.z = 0
		return angles
		}

let sqx = qfloat.x*qfloat.x;
let sqy = qfloat.y*qfloat.y;
let sqz = qfloat.z*qfloat.z;
	angles.x = atan2(2*qfloat.y*qfloat.w-2*qfloat.x*qfloat.z, 1 - 2*sqy - 2*sqz)
	angles.y = asin(2*test)
	angles.z = atan2(2*qfloat.x*qfloat.w-2*qfloat.y*qfloat.z, 1 - 2*sqx - 2*sqz)
	return angles;
}

func eulerAnglesFrom(simdQuaternion quat: simd_quatf) -> (pitch: Float, roll: Float, yaw: Float) {
let eulerAnglesVector3 = eulerVector3From(simdQuaternion: quat)
	return (eulerAnglesVector3.x,eulerAnglesVector3.y,eulerAnglesVector3.z)
}

