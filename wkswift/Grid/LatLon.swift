//
//  LatLon.swift
//  wkswift
//
//  Created by Marshall Thames on 4/25/25.
//

import Foundation

// In this module, we use the following variable names:
// Lat - latitude in degrees. North is positive, South is negative
// Lon - longitude in degrees. East is positive, West is negative
// Phi - latitude in radians
// Lambda - longitude in radians
// Rho - distance from center of sphere. Units don't matter as long as they're used consistently.
// Rho is rarely used because we usually assume points are on the Unit Sphere.

/// LatLon represents a point on the unit sphere
/// Lat and Lon are in DEGREES not radians.
public struct LatLon: Equatable {
    public let lat: Double
    public let lon: Double
    
    public init(lat: Double, lon: Double) {
        self.lat = lat
        self.lon = lon
    }
    
    public init (sphereVec p: Vec3) {
        guard p.magnitude().isAlmostEqual(to: 1.0, epsilon: 1e-9) else {
            fatalError("init(sphereVec:) Vec3 must have magnitude = 1.0. You provided point \(p) which has magnitude \(p.magnitude()).")
        }

        let phi = asin(p.y)
        
        // If it's the north or south pole, set longitude to zero. Otherwise, calculate longitude (lambda)
        var lambda = 0.0
        if !(phi.isAlmostEqual(to: halfPi, epsilon: 1e-6) || phi.isAlmostEqual(to: -halfPi, epsilon: 1e-6)) {
            lambda = atan2(p.x, -p.z)
        }
        self.lat = phi * toDegrees
        self.lon = lambda * toDegrees
    }
    
    public func isAlmostEqual(to other: LatLon, epsilon: Double = 1e-8) -> Bool {
        return lat.isAlmostEqual(to: other.lat, epsilon: epsilon) &&
               lon.isAlmostEqual(to: other.lon, epsilon: epsilon)
    }
    
    public func toSphereVec() -> Vec3 {
        return Vec3.newSphereVecFromLatLon(self)
    }
}

