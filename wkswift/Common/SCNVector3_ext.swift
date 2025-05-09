//
//  SCNVector3_ext.swift
//  wkswift
//
//  Created by Marshall Thames on 5/7/25.
//

import SceneKit

extension SCNVector3 {
    var length: CGFloat {
        return sqrt(x * x + y * y + z * z)
    }

    func normalized() -> SCNVector3 {
        let len = length
        return len == 0 ? self : self / len
    }

    static func / (vector: SCNVector3, scalar: CGFloat) -> SCNVector3 {
        return SCNVector3(vector.x / scalar, vector.y / scalar, vector.z / scalar)
    }
}

