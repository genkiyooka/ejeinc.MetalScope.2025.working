//
//  EulerViewController.swift
//  MetalSkybox
//
//  Created by dg on 5/28/25.
//

import UIKit
import simd

struct QuaternionWrapper {
    var _quaternion: simd_quatf

    init(quaternion: simd_quatf) {
        _quaternion = quaternion
    }

    func toNSValue() -> NSValue {
        // Convert the quaternion to simd_float4 (x, y, z, w)
        var vector = simd_float4(_quaternion.vector)
        return NSValue(bytes: &vector, objCType: QuaternionWrapper.simdTypeEncoding)
    }

    static func fromNSValue(_ value: NSValue) -> simd_quatf? {
        guard strcmp(value.objCType, simdTypeEncoding) == 0 else { return nil }
        var vector = simd_float4()
        value.getValue(&vector)
        return simd_quatf(vector:vector)
    }

    private static var simdTypeEncoding: UnsafePointer<CChar> {
		return NSValue(nonretainedObject:simd_float4(0,0,0,0)).objCType
    }
}


@objc
public class EulerViewController: XibViewController {

	public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

	public var quaternion:simd_quatf = simd_quatf() {
		didSet {
			updateLabels()
			}
		}

	var representedObject: Any? {
		get {
			let quaternionValue = QuaternionWrapper(quaternion:self.quaternion)
			// Return the stored or computed value
			return quaternionValue.toNSValue()
			}
		set {
			// Store or respond to the new value
			if let quaternion = QuaternionWrapper.fromNSValue(newValue as! NSValue) {
				self.quaternion = quaternion
				}
			}
		}

	@IBOutlet weak var outletPitch: UILabel!
	@IBOutlet weak var outletRoll: UILabel!
	@IBOutlet weak var outletYaw: UILabel!

	private func updateLabels() {
		if let _ = outletPitch {
			DispatchQueue.main.async { [weak self] in
				if let strongSelf = self {
				let eulerAngles = eulerAnglesFrom(simdQuaternion:strongSelf.quaternion)
				let kFloatFormat = "% 0.2f"
					strongSelf.outletPitch.text = "\(String(format: kFloatFormat, eulerAngles.pitch))"
					strongSelf.outletRoll.text = "\(String(format: kFloatFormat, eulerAngles.roll))"
					strongSelf.outletYaw.text = "\(String(format: kFloatFormat, eulerAngles.yaw))"
					}
				}
			}
		}
}
