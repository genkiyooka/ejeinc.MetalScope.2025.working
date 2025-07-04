//
//  DeviceOrientationSourceDelegate.swift
//  MetalSkybox
//
//  Created by dg on 6/8/25.
//

import UIKit
import CoreMotion
import simd

@objc(DeviceOrientationSourceDelegate)
public protocol DeviceOrientationSourceDelegate: NSObjectProtocol {
    @objc(deviceOrientationSource:motionVector:)
    func deviceOrientationSource(_ source: DeviceOrientationSource, motionVector: simd_float3)
}

@objc(DeviceOrientationSource)
public class DeviceOrientationSource: NSObject {

    @objc(sSharedDeviceOrientationSource)
    public static let shared = DeviceOrientationSource()

    @objc public weak var delegate: DeviceOrientationSourceDelegate?

    @objc public let motionManager = CMMotionManager()

    @objc public private(set) var referenceAttitude: CMAttitude?
    @objc public private(set) var currentAttitude: CMAttitude?

    @objc public private(set) var isActive: Bool = false

    private var sourceTimer: DispatchSourceTimer?
    private var lastVector = simd_float3()
    private let lowPassFactor = 0.95

    @objc public static let defaultSamplingInterval: TimeInterval = 0.125

    @objc public var samplingInterval: TimeInterval = DeviceOrientationSource.defaultSamplingInterval {
        didSet {
            if motionManager.isDeviceMotionAvailable {
                motionManager.deviceMotionUpdateInterval = samplingInterval
                setupSamplingTimer(with: samplingInterval)
                motionManager.startDeviceMotionUpdates()
                isActive = true
            }
        }
    }

    private override init() {
        super.init()
    }

    deinit {
        stop()
    }

    private func stop() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
        }
        sourceTimer?.cancel()
        sourceTimer = nil
        referenceAttitude = nil
        currentAttitude = nil
        isActive = false
    }

    private func setupSamplingTimer(with interval: TimeInterval) {
        sourceTimer?.cancel()

        let queue = DispatchQueue.global(qos: .default)
        sourceTimer = DispatchSource.makeTimerSource(queue: queue)
        sourceTimer?.schedule(deadline: .now(), repeating: interval, leeway: .milliseconds(100))
        sourceTimer?.setEventHandler { [weak self] in
            guard let self = self, let delegate = self.delegate else { return }
            delegate.deviceOrientationSource(self, motionVector: self.motionVector)
        	}
        sourceTimer?.resume()
    }

    @objc public func recalibrate() {
		referenceAttitude = motionManager.deviceMotion?.attitude.copy() as? CMAttitude
    }

    @objc public var motionVector: simd_float3 {
		currentAttitude = motionManager.deviceMotion?.attitude

        if referenceAttitude == nil {
            // Cache Start Orientation to calibrate the device. Wait for a short time to give MotionManager enough time to initialize
            perform(#selector(recalibrate), with: nil, afterDelay: 0.125)
        } else if let currentAttitude = currentAttitude, let referenceAttitude = referenceAttitude {
            // Use start orientation to calibrate
            currentAttitude.multiply(byInverseOf: referenceAttitude)
        }

        guard let attitude = currentAttitude else {
            return simd_float3()
        }

        return simd_make_float3(Float(attitude.yaw), Float(attitude.roll), Float(attitude.pitch))
    }

    @objc public func motionVectorWithLowPass() -> simd_float3 {
        return lowPass(with: motionVector)
    }

    private func lowPass(with vector: simd_float3) -> simd_float3 {
        var result = vector
        result.x = vector.x * Float(lowPassFactor) + lastVector.x * (1.0 - Float(lowPassFactor))
        result.y = vector.y * Float(lowPassFactor) + lastVector.y * (1.0 - Float(lowPassFactor))
        result.z = vector.z * Float(lowPassFactor) + lastVector.z * (1.0 - Float(lowPassFactor))
        lastVector = result
        return result // The original implementation had a bug here, returning the unfiltered vector. This is corrected.
    }

	/* ChatGPT generated */
	public func motionVector(interfaceOrientation: UIInterfaceOrientation) -> simd_float3 {
		let v = self.motionVector
		var motionVectorRelativeToUIOrientation = v
		switch interfaceOrientation {
		case .portrait:
			motionVectorRelativeToUIOrientation.x =  v.x
			motionVectorRelativeToUIOrientation.y =  0.0
			motionVectorRelativeToUIOrientation.z =  0.0
//			motionVectorRelativeToUIOrientation.y =	 v.y.clampedRangeTau()
//			motionVectorRelativeToUIOrientation.z =  v.z.clampedRangeTau()
			break
		case .portraitUpsideDown:
			// Flip pitch and roll by 180 degrees (π radians)
			motionVectorRelativeToUIOrientation.x = -v.x.clampedRangeTau()
			motionVectorRelativeToUIOrientation.y = (v.y + .pi).truncatingRemainder(dividingBy: 2.0 * .pi)
			motionVectorRelativeToUIOrientation.z = -v.z.clampedRangeTau()
		case .landscapeLeft:
			// Swap pitch and yaw, invert pitch
			motionVectorRelativeToUIOrientation.x = -v.y.clampedRangeTau() // pitch = -yaw
			motionVectorRelativeToUIOrientation.y =  v.x.clampedRangeTau() // yaw = pitch
			motionVectorRelativeToUIOrientation.z =  v.z.clampedRangeTau() // roll unchanged
		case .landscapeRight:
			// Swap pitch and yaw, invert yaw
			motionVectorRelativeToUIOrientation.x =  v.y.clampedRangeTau() // pitch = yaw
			motionVectorRelativeToUIOrientation.y = -v.x.clampedRangeTau() // yaw = -pitch
			motionVectorRelativeToUIOrientation.z =  v.z.clampedRangeTau() // roll unchanged
		default:
			break
			}
		return motionVectorRelativeToUIOrientation
	}

    public func motionVectorRightHanded(interfaceOrientation: UIInterfaceOrientation) -> simd_float3 {
	let v = self.motionVector
	var motionVectorRelativeToUIOrientation = v
		print("motionVectorRightHanded(\(interfaceOrientation)")
        switch interfaceOrientation {
        case .portrait:
			motionVectorRelativeToUIOrientation = simd_make_float3( v.x, v.y, -v.z).clampedRangeTau()
        case .portraitUpsideDown:
            // Invert pitch and yaw
            motionVectorRelativeToUIOrientation = simd_make_float3(-v.x,-v.y, -v.z).clampedRangeTau()
        case .landscapeLeft:
            // Rotate axes 90° CCW
            motionVectorRelativeToUIOrientation = simd_make_float3( v.x, v.z,  v.y).clampedRangeTau()
        case .landscapeRight:
            // Rotate axes 90° CW
            motionVectorRelativeToUIOrientation = simd_make_float3( v.x,-v.z, -v.y).clampedRangeTau()
        default:
            break
        }
        return motionVectorRelativeToUIOrientation
    }

   	public func motionVectorLeftHanded(interfaceOrientation: UIInterfaceOrientation) -> simd_float3 {
	let v = self.motionVector
	var motionVectorRelativeToUIOrientation = v
		print("motionVectorLeftHanded(\(interfaceOrientation)")
        switch interfaceOrientation {
        case .portrait:
            motionVectorRelativeToUIOrientation = simd_make_float3(v.x, v.y, v.z)
        case .portraitUpsideDown:
            // Invert pitch and yaw
            motionVectorRelativeToUIOrientation = simd_make_float3(-v.x, -v.y, v.z)
        case .landscapeLeft:
            // Rotate axes 90° CCW
            motionVectorRelativeToUIOrientation = simd_make_float3(v.x, v.z, -v.y)
        case .landscapeRight:
            // Rotate axes 90° CW
            motionVectorRelativeToUIOrientation = simd_make_float3(v.x, -v.z, v.y)
        default:
            break
        }
        return motionVectorRelativeToUIOrientation
    }
}
