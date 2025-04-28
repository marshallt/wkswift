//
//  Vec3.swift
//  wkswift
//
//  Created by Marshall Thames on 4/25/25.
//

import Foundation

// We follow the WebGL/OpenGL/Metal convention
// +X is RIGHT, +Y is UP, +Z is INTO the screen

public let toRadians = Double.pi / 180.0
public let toDegrees = 180.0 / Double.pi
public let doublePi = 2.0 * Double.pi
public let halfPi = Double.pi / 2.0

public struct Vec3: CustomStringConvertible, Equatable {
    public var x, y, z: Double
    
    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    public func isAlmostEqual(to other: Vec3, epsilon: Double = 1e-8) -> Bool {
        return x.isAlmostEqual(to: other.x, epsilon: epsilon) &&
               y.isAlmostEqual(to: other.y, epsilon: epsilon) &&
               z.isAlmostEqual(to: other.z, epsilon: epsilon)
    }
    
    public func magnitudeSquared() -> Double {
        return x*x + y*y + z*z
    }
    
    public func magnitude() -> Double {
        return sqrt(magnitudeSquared())
    }
    
    public func normalize() -> Vec3 {
        let magnitude = self.magnitude()
        guard magnitude != 0.0 else {
            fatalError("Can't normalize a Vec3 of magnitude zero.")
        }
        
        if magnitude.isAlmostEqual(to: 1.0) {
            return self
        }
        
        return Vec3(
            x: x / magnitude,
            y: y / magnitude,
            z: z / magnitude
        )
    }
    
    public func midpoint(with other: Vec3) -> Vec3 {
        return Vec3(
            x: (other.x + x) / 2.0,
            y: (other.y + y) / 2.0,
            z: (other.z + z) / 2.0
        )
    }
    
    public func scale(by factor: Double) -> Vec3 {
        return Vec3(
            x: x * factor,
            y: y * factor,
            z: z * factor
        )
    }
    
    public func toLatLon() -> LatLon {
        return LatLon(sphereVec: self)
    }
    
    public static func newSphereVecFromLatLon(_ latLon: LatLon) -> Vec3 {
        let phi = latLon.lat * toRadians
        let lambda = latLon.lon * toRadians
        return Vec3(
            x: cos(phi) * sin(lambda),
            y: sin(phi),
            z: -cos(phi) * cos(lambda)
        )
    }
    
    public var description: String {
        return "(\(x), \(y), \(z))"
    }
    
    // Standard operators for vectors
    public static func + (lhs: Vec3, rhs: Vec3) -> Vec3 {
        return Vec3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    
    public static func - (lhs: Vec3, rhs: Vec3) -> Vec3 {
        return Vec3(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
    
    public static func * (lhs: Vec3, rhs: Double) -> Vec3 {
        return lhs.scale(by: rhs)
    }
    
    public static func * (lhs: Double, rhs: Vec3) -> Vec3 {
        return rhs.scale(by: lhs)
    }
    
    public static func / (lhs: Vec3, rhs: Double) -> Vec3 {
        guard rhs != 0 else {
            fatalError("Division by zero")
        }
        return Vec3(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
    }
    
    // Dot product
    public static func dot(_ lhs: Vec3, _ rhs: Vec3) -> Double {
        return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
    }
    
    // Cross product
    public static func cross(_ lhs: Vec3, _ rhs: Vec3) -> Vec3 {
        return Vec3(
            x: lhs.y * rhs.z - lhs.z * rhs.y,
            y: lhs.z * rhs.x - lhs.x * rhs.z,
            z: lhs.x * rhs.y - lhs.y * rhs.x
        )
    }
}
