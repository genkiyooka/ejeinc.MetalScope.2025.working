//
//  InterfaceOrientationUpdater.swift
//  MetalScope
//
//  Created by Jun Tanaka on 2017/01/31.
//  Copyright © 2017 eje Inc. All rights reserved.
//

import SceneKit
import UIKit

internal final class InterfaceOrientationUpdater : InterfaceOrientationObserver {
    let orientationNode: OrientationNode

    init(orientationNode: OrientationNode) {
        self.orientationNode = orientationNode
    }

    override func onUpdateInterfaceOrientation() {
        orientationNode.updateInterfaceOrientation()
    }

    override func onUpdateInterfaceOrientationTransition(context: any UIViewControllerTransitionCoordinatorContext) {
        SCNTransaction.lock()
        SCNTransaction.begin()
        SCNTransaction.animationDuration = context.transitionDuration
        SCNTransaction.animationTimingFunction = context.completionCurve.caMediaTimingFunction
        SCNTransaction.disableActions = !context.isAnimated

        self.updateInterfaceOrientation();

        SCNTransaction.commit()
        SCNTransaction.unlock()
        }

}

private extension UIView.AnimationCurve {
    var caMediaTimingFunction: CAMediaTimingFunction {
        let name: String

        switch self {
        case .easeIn:
            name = convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.easeIn)
        case .easeOut:
            name = convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.easeOut)
        case .easeInOut:
            name = convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.easeInEaseOut)
        case .linear:
            name = convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.linear)
        @unknown default:
            name = convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.linear)
        }
        
        return CAMediaTimingFunction(name: convertToCAMediaTimingFunctionName(name))
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCAMediaTimingFunctionName(_ input: CAMediaTimingFunctionName) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAMediaTimingFunctionName(_ input: String) -> CAMediaTimingFunctionName {
	return CAMediaTimingFunctionName(rawValue: input)
}
