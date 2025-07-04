//
//  Rotation+CoreMotion.swift
//  MetalScope
//
//  Created by Jun Tanaka on 2017/01/17.
//  Copyright © 2017 eje Inc. All rights reserved.
//

import CoreMotion

extension DeviceRotation {
    public init(deviceQuaternion: CMQuaternion) {
        self.init(nativeQuaternion:NativeQuaternionMake(
            Float(deviceQuaternion.x),
            Float(deviceQuaternion.y),
            Float(deviceQuaternion.z),
            Float(deviceQuaternion.w)
        ))
    }

    public init(deviceAttitude: CMAttitude) {
        self.init(deviceQuaternion:deviceAttitude.quaternion)
    }

    public init(deviceMotion: CMDeviceMotion) {
        self.init(deviceAttitude:deviceMotion.attitude)
    }
}
