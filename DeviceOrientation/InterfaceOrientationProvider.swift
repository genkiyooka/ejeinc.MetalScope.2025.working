//
//  InterfaceOrientationProvider.swift
//  MetalScope
//
//  Created by Jun Tanaka on 2017/01/17.
//  Copyright © 2017 eje Inc. All rights reserved.
//

import UIKit

public protocol InterfaceOrientationProvider {
    func interfaceOrientation(atTime time: TimeInterval) -> UIInterfaceOrientation
}

extension UIInterfaceOrientation: InterfaceOrientationProvider {
    public func interfaceOrientation(atTime time: TimeInterval) -> UIInterfaceOrientation {
        return self
    }
}

extension UIApplication: InterfaceOrientationProvider {
    public func interfaceOrientation(atTime time: TimeInterval) -> UIInterfaceOrientation {
        return statusBarOrientation.interfaceOrientation(atTime: time)
    }
}

internal final class DefaultInterfaceOrientationProvider: InterfaceOrientationProvider {
    func interfaceOrientation(atTime time: TimeInterval) -> UIInterfaceOrientation {
        return UIApplication.shared.interfaceOrientation(atTime: time)
    }
}

internal class InterfaceOrientationObserver {

    private var isTransitioning = false
    private var deviceOrientationDidChangeNotificationObserver: NSObjectProtocol?

    init() {
    }

    deinit {
        stopAutomaticInterfaceOrientationUpdates()
    }

    func onUpdateInterfaceOrientation() {
    }

    func onUpdateInterfaceOrientationTransition(context: any UIViewControllerTransitionCoordinatorContext) {
    }
        
    func updateInterfaceOrientation() {
        onUpdateInterfaceOrientation();
    }

    func updateInterfaceOrientation(with transitionCoordinator: UIViewControllerTransitionCoordinator) {
        isTransitioning = true
        transitionCoordinator.animate(alongsideTransition: { context in
            self.onUpdateInterfaceOrientationTransition(context: context)
        }, completion: { _ in
            self.isTransitioning = false
        })
    }

    func startAutomaticInterfaceOrientationUpdates() {
        guard deviceOrientationDidChangeNotificationObserver == nil else {
            return
        }

        UIDevice.current.beginGeneratingDeviceOrientationNotifications()

        let observer = NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            guard UIDevice.current.orientation.isValidInterfaceOrientation, self?.isTransitioning == false else {
                return
            }
            self?.onUpdateInterfaceOrientation()
        }

        deviceOrientationDidChangeNotificationObserver = observer
    }

    func stopAutomaticInterfaceOrientationUpdates() {
        guard let observer = deviceOrientationDidChangeNotificationObserver else {
            return
        }

        UIDevice.current.endGeneratingDeviceOrientationNotifications()

        NotificationCenter.default.removeObserver(observer)

        deviceOrientationDidChangeNotificationObserver = nil
    }
}
