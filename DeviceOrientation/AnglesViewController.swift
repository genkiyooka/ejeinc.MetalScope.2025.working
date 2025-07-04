//
//  EulerViewController.swift
//  MetalSkybox
//
//  Created by dg on 5/28/25.
//

import UIKit
import simd

@objc(AnglesViewController)
public protocol AnglesViewControllerDelegate: NSObjectProtocol {

    func angleSliderX(_ slider: UISlider, valueChanged:CGFloat)
    func angleSliderY(_ slider: UISlider, valueChanged:CGFloat)
    func angleSliderZ(_ slider: UISlider, valueChanged:CGFloat)
}

@objc
public class AnglesViewController: XibViewController {

	func delegateSliderValues() {
		self.delegate?.angleSliderX(outletX, valueChanged: CGFloat(outletX.value))
		self.delegate?.angleSliderY(outletY, valueChanged: CGFloat(outletY.value))
		self.delegate?.angleSliderY(outletZ, valueChanged: CGFloat(outletZ.value))
		}
		
    @objc public weak var delegate: AnglesViewControllerDelegate? {
		didSet {
			delegateSliderValues()
			}
    	}

	@IBOutlet weak var outletX: UISlider!
	@IBOutlet weak var outletY: UISlider!
	@IBOutlet weak var outletZ: UISlider!

	@IBAction func actionSliderXChanged(_ sender: UISlider) {
		self.delegate?.angleSliderX(sender, valueChanged: CGFloat(sender.value))
		}

	@IBAction func actionSliderYChanged(_ sender: UISlider) {
		self.delegate?.angleSliderY(sender, valueChanged: CGFloat(sender.value))
		}

	@IBAction func actionSliderZChanged(_ sender: UISlider) {
		self.delegate?.angleSliderZ(sender, valueChanged: CGFloat(sender.value))
		}

	private func updateLabels() {
//		if let _ = outletPitch {
//			DispatchQueue.main.async { [weak self] in
//				if let strongSelf = self {
//				let eulerAngles = eulerAnglesFrom(simdQuaternion:strongSelf.quaternion)
//				let kFloatFormat = "% 0.2f"
//					strongSelf.outletPitch.text = "\(String(format: kFloatFormat, eulerAngles.pitch))"
//					strongSelf.outletRoll.text = "\(String(format: kFloatFormat, eulerAngles.roll))"
//					strongSelf.outletYaw.text = "\(String(format: kFloatFormat, eulerAngles.yaw))"
//					}
//				}
//			}
		}
}
