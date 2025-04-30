//
//  Quaternion.swift
//  wkswift
//
//  Created by Marshall Thames on 4/29/25.
//

import Foundation

/// A quaternion for representing rotations in 3D space
/// Follows the convention w + xi + yj + zk where w is the scalar part
public struct Quaternion: CustomStringConvertible, Equatable, Hashable, Sendable {
    // MARK: - Properties
    
    /// The scalar (real) component
    public var w: Double
    
    /// The x component of the vector (imaginary) part
    public var x: Double
    
    /// The y component of the vector (imaginary) part
    public var y: Double
    
    /// The z component of the vector (imaginary) part
    public var z: Double
    
    /// The vector part of the quaternion
    public var vector: Vec3 {
        get { Vec3(x: x, y: y, z: z) }
        set { (x, y, z) = (newValue.x, newValue.y, newValue.z) }
    }
    
    // MARK: - Static Properties
    
    /// The identity quaternion (no rotation)
    public static let identity = Quaternion(w: 1, x: 0, y: 0, z: 0)
    
    // MARK: - Initialization
    
    /// Initialize a quaternion with its components
    public init(w: Double, x: Double, y: Double, z: Double) {
        self.w = w
        self.x = x
        self.y = y
        self.z = z
    }
    
    /// Initialize a quaternion from a scalar and vector part
    public init(scalar: Double, vector: Vec3) {
        self.w = scalar
        self.x = vector.x
        self.y = vector.y
        self.z = vector.z
    }
    
    // MARK: - Factories
    
    /// Create a quaternion from an axis-angle representation in radians
    public static func fromAxisAngle(axis: Vec3, angle: Double) -> Quaternion {
        guard axis.magnitudeSquared() > 0 else {
            return .identity
        }
        
        let halfAngle = angle * 0.5
        let s = sin(halfAngle)
        
        let normalizedAxis = axis.normalize()
        
        return Quaternion(
            w: cos(halfAngle),
            x: normalizedAxis.x * s,
            y: normalizedAxis.y * s,
            z: normalizedAxis.z * s
        )
    }
    
    /// Create a quaternion from an axis-angle representation in degrees
    public static func fromAxisAngle(axis: Vec3, angleDegrees: Double) -> Quaternion {
        return fromAxisAngle(axis: axis, angle: angleDegrees * toRadians)
    }
    
    /// Create a quaternion from a rotation between two vectors
    public static func fromVectors(from: Vec3, to: Vec3) -> Quaternion {
        guard from.magnitudeSquared() > 0 && to.magnitudeSquared() > 0 else {
            return .identity
        }
        
        let fromNorm = from.normalize()
        let toNorm = to.normalize()
        
        let dot = Vec3.dot(fromNorm, toNorm)
        
        // If vectors are very similar, return identity
        if dot > 0.99999 {
            return .identity
        }
        
        // If vectors are opposite, find a perpendicular rotation axis
        if dot < -0.99999 {
            // Find an axis perpendicular to fromNorm
            var axis = Vec3.cross(Vec3(x: 1, y: 0, z: 0), fromNorm)
            if axis.magnitudeSquared() < 0.00001 {
                axis = Vec3.cross(Vec3(x: 0, y: 1, z: 0), fromNorm)
            }
            return fromAxisAngle(axis: axis.normalize(), angle: .pi)
        }
        
        // General case
        let rotationAxis = Vec3.cross(fromNorm, toNorm).normalize()
        let rotationAngle = acos(dot)
        
        return fromAxisAngle(axis: rotationAxis, angle: rotationAngle)
    }
    
    /// Create a quaternion from Euler angles (in radians)
    /// Pitch - X Axis, Yaw - Y Axis, Roll - Z Axis
    public static func fromEuler(roll: Double, pitch: Double, yaw: Double ) -> Quaternion {
        // Calculate half angles for efficiency
        let cy = cos(yaw * 0.5)
        let sy = sin(yaw * 0.5)
        let cp = cos(pitch * 0.5)
        let sp = sin(pitch * 0.5)
        let cr = cos(roll * 0.5)
        let sr = sin(roll * 0.5)

        let w = cr * cp * cy + sr * sp * sy
        let x = sr * cp * cy - cr * sp * sy
        let y = cr * sp * cy + sr * cp * sy
        let z = cr * cp * sy - sr * sp * cy

        return Quaternion(w: w, x: x, y: y, z: z)
    }
    
    /// Create a quaternion from Euler angles (in degrees)
    public static func fromEulerDegrees(roll: Double, pitch: Double, yaw: Double ) -> Quaternion {
        return fromEuler(
            roll: roll * toRadians,
            pitch: pitch * toRadians,
            yaw: yaw * toRadians,
        )
    }
    
    // MARK: - Methods
    
    /// Get the squared magnitude of the quaternion
    public func magnitudeSquared() -> Double {
        return w * w + x * x + y * y + z * z
    }
    
    /// Get the magnitude (length) of the quaternion
    public func magnitude() -> Double {
        return sqrt(magnitudeSquared())
    }
    
    /// Get the conjugate of the quaternion (w, -x, -y, -z)
    public func conjugate() -> Quaternion {
        return Quaternion(w: w, x: -x, y: -y, z: -z)
    }
    
    /// Get the inverse of the quaternion (conjugate / magnitudeSquared)
    public func inverse() -> Quaternion {
        let magSq = magnitudeSquared()
        guard magSq > 0 else {
            return .identity
        }
        
        let invMagSq = 1.0 / magSq
        return Quaternion(
            w: w * invMagSq,
            x: -x * invMagSq,
            y: -y * invMagSq,
            z: -z * invMagSq
        )
    }
    
    /// Normalize the quaternion to unit length
    public func normalize() -> Quaternion {
        let magSq = magnitudeSquared()
        
        // Check if already normalized (within epsilon)
        if abs(magSq - 1.0) < 1e-10 {
            return self
        }
        
        guard magSq > 0 else {
            return .identity
        }
        
        let invMag = 1.0 / sqrt(magSq)
        return Quaternion(
            w: w * invMag,
            x: x * invMag,
            y: y * invMag,
            z: z * invMag
        )
    }
    
    /// Multiply this quaternion by another (composition of rotations)
    public func multiply(_ other: Quaternion) -> Quaternion {
        return Quaternion(
            w: w * other.w - x * other.x - y * other.y - z * other.z,
            x: w * other.x + x * other.w + y * other.z - z * other.y,
            y: w * other.y - x * other.z + y * other.w + z * other.x,
            z: w * other.z + x * other.y - y * other.x + z * other.w
        )
    }
    
    /// Rotate a vector by this quaternion
    public func rotate(_ v: Vec3) -> Vec3 {
        // For unit quaternions, a more efficient formula is:
        // v' = v + 2 * cross(q.xyz, cross(q.xyz, v) + q.w * v)
        // But we'll use the general formula for robustness:
        
        // Get normalized quaternion for rotation
        let q = self.normalize()
        
        // Convert vector to pure quaternion
        let qv = Quaternion(w: 0, x: v.x, y: v.y, z: v.z)
        
        // Apply rotation: q * v * q^-1
        let rotated = q.multiply(qv).multiply(q.conjugate())
        
        return Vec3(x: rotated.x, y: rotated.y, z: rotated.z)
    }
    
    /// Convert to axis-angle representation
    public func toAxisAngle() -> (axis: Vec3, angleRadians: Double) {
        let q = self.normalize()
        
        // Clamp w to avoid numerical errors
        let w = min(max(q.w, -1.0), 1.0)
        let angle = 2.0 * acos(w)
        
        // Handle small angles where the axis becomes unstable
        let s = sqrt(1.0 - w * w)
        if s < 0.001 {
            // For small angles, any perpendicular axis works
            return (Vec3(x: 1, y: 0, z: 0), angle)
        }
        
        // Return the rotation axis and angle
        return (Vec3(x: q.x / s, y: q.y / s, z: q.z / s), angle)
    }
    
    /// Convert to Euler angles (in radians)
    public func toEuler() -> (roll: Double, pitch: Double, yaw: Double) {
        //let q = self.normalize()
        
        // Roll (x-axis rotation)
        let sinr_cosp = 2 * (w * x + y * z)
        let cosr_cosp = 1 - 2 * (x * x + y * y)
        let roll = atan2(sinr_cosp, cosr_cosp)

        // Pitch (y-axis rotation)
        let sinp = 2 * (w * y - z * x)
        let pitch: Double
        if abs(sinp) >= 1 {
            pitch = (sinp > 0) ? .pi / 2 : -.pi / 2  // use 90 degrees if out of range
        } else {
            pitch = asin(sinp)
        }
         // Yaw (z-axis rotation)
        let siny_cosp = 2 * (w * z + x * y)
        let cosy_cosp = 1 - 2 * (y * y + z * z)
        let yaw = atan2(siny_cosp, cosy_cosp)

        return (roll, pitch, yaw)
    }
    
    /// Convert to Euler angles (in degrees)
    public func toEulerDegrees() -> (roll: Double, pitch: Double, yaw: Double) {
        let (roll, pitch, yaw) = toEuler()
        return (roll * toDegrees, pitch * toDegrees, yaw * toDegrees)
    }
    
    /// Spherical linear interpolation between quaternions
    public static func slerp(_ q1: Quaternion, _ q2: Quaternion, t: Double) -> Quaternion {
        // Clamp t to [0, 1] range
        let t = min(max(t, 0.0), 1.0)
        
        // Ensure quaternions are normalized
        let q1n = q1.normalize()
        var q2n = q2.normalize()
        
        // Calculate cosine of angle between quaternions
        var dot = q1n.w * q2n.w + q1n.x * q2n.x + q1n.y * q2n.y + q1n.z * q2n.z
        
        // If dot < 0, flip one quaternion to ensure shortest path
        if dot < 0 {
            q2n = Quaternion(w: -q2n.w, x: -q2n.x, y: -q2n.y, z: -q2n.z)
            dot = -dot
        }
        
        // If quaternions are very close, use linear interpolation
        if dot > 0.9995 {
            return Quaternion(
                w: q1n.w + t * (q2n.w - q1n.w),
                x: q1n.x + t * (q2n.x - q1n.x),
                y: q1n.y + t * (q2n.y - q1n.y),
                z: q1n.z + t * (q2n.z - q1n.z)
            ).normalize()
        }
        
        // Perform slerp
        let theta0 = acos(dot)
        let theta = theta0 * t
        let sinTheta = sin(theta)
        let sinTheta0 = sin(theta0)
        
        let s0 = cos(theta) - dot * sinTheta / sinTheta0
        let s1 = sinTheta / sinTheta0
        
        return Quaternion(
            w: s0 * q1n.w + s1 * q2n.w,
            x: s0 * q1n.x + s1 * q2n.x,
            y: s0 * q1n.y + s1 * q2n.y,
            z: s0 * q1n.z + s1 * q2n.z
        )
    }
    
    /// Check if quaternions are equal within a small epsilon
    public func isAlmostEqual(to other: Quaternion, epsilon: Double = 1e-8) -> Bool {
        // We need to handle the case where q and -q represent the same rotation
        let dotProduct = abs(w * other.w + x * other.x + y * other.y + z * other.z)
        let normProduct = magnitude() * other.magnitude()
        
        if abs(normProduct) < epsilon {
            return false
        }
        
        let cosAngle = dotProduct / normProduct
        return abs(cosAngle - 1.0) < epsilon
    }
    
    // MARK: - Protocol Conformance
    
    public var description: String {
        return String(format: "Quaternion(%.5f, %.5f, %.5f, %.5f)", w, x, y, z)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
        hasher.combine(w)
    }
    
    // MARK: - Operators
    
    public static func * (lhs: Quaternion, rhs: Quaternion) -> Quaternion {
        return lhs.multiply(rhs)
    }
    
    public static func * (lhs: Quaternion, rhs: Vec3) -> Vec3 {
        return lhs.rotate(rhs)
    }
    
    public static func * (lhs: Double, rhs: Quaternion) -> Quaternion {
        return Quaternion(w: lhs * rhs.w, x: lhs * rhs.x, y: lhs * rhs.y, z: lhs * rhs.z)
    }
    
    public static func * (lhs: Quaternion, rhs: Double) -> Quaternion {
        return Quaternion(w: lhs.w * rhs, x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
    }
    
    public static func + (lhs: Quaternion, rhs: Quaternion) -> Quaternion {
        return Quaternion(w: lhs.w + rhs.w, x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    
    public static func - (lhs: Quaternion, rhs: Quaternion) -> Quaternion {
        return Quaternion(w: lhs.w - rhs.w, x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
    
    public static func == (lhs: Quaternion, rhs: Quaternion) -> Bool {
        // Direct component comparison for Equatable
        return lhs.w == rhs.w && lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
    
    public static prefix func - (q: Quaternion) -> Quaternion {
        return Quaternion(w: -q.w, x: -q.x, y: -q.y, z: -q.z)
    }
}

// MARK: - Extensions for tectonic plate simulation

extension Quaternion {
    /// Great circle rotation between two points on a unit sphere
    public static func greatCircleRotation(from: Vec3, to: Vec3) -> Quaternion {
        // Get normalized positions
        let fromNorm = from.normalize()
        let toNorm = to.normalize()
        
        // Get rotation axis (perpendicular to both points)
        let axis = Vec3.cross(fromNorm, toNorm)
        
        // If points are too close or opposite, handle specially
        if axis.magnitudeSquared() < 1e-10 {
            // Check if points are nearly identical
            if Vec3.dot(fromNorm, toNorm) > 0.99999 {
                return .identity
            }
            
            // Points are nearly opposite - find any perpendicular axis
            var perpAxis = Vec3.cross(fromNorm, Vec3(x: 0, y: 1, z: 0))
            if perpAxis.magnitudeSquared() < 1e-10 {
                perpAxis = Vec3.cross(fromNorm, Vec3(x: 1, y: 0, z: 0))
            }
            return fromAxisAngle(axis: perpAxis.normalize(), angle: .pi)
        }
        
        // Get angle between points
        let angle = acos(min(max(Vec3.dot(fromNorm, toNorm), -1.0), 1.0))
        
        // Create rotation quaternion
        return fromAxisAngle(axis: axis.normalize(), angle: angle)
    }
    
    /// Create a quaternion to move along a great circle arc by a specified distance
    public static func greatCircleStep(position: Vec3, velocity: Vec3, distance: Double) -> Quaternion {
        // Ensure input vectors are normalized
        let pos = position.normalize()
        
        // Ensure velocity is tangent to sphere at position
        let tangentVel = velocity - pos * Vec3.dot(pos, velocity)
        if tangentVel.magnitudeSquared() < 1e-10 {
            return .identity
        }
        
        // Get normalized direction
        let direction = tangentVel.normalize()
        
        // Calculate rotation axis (perpendicular to position and direction)
        let axis = Vec3.cross(pos, direction)
        
        // Create rotation quaternion
        return fromAxisAngle(axis: axis, angle: distance)
    }
    
    /// Calculate velocity after a collision between two objects on a sphere
    public static func sphereCollisionVelocity(
        pos1: Vec3, vel1: Vec3, mass1: Double,
        pos2: Vec3, vel2: Vec3, mass2: Double,
        restitution: Double = 0.8
    ) -> (newVel1: Vec3, newVel2: Vec3) {
        // Normalize positions to ensure they're on the sphere
        let p1 = pos1.normalize()
        let p2 = pos2.normalize()
        
        // Calculate contact normal (direction from p1 to p2 along great circle)
        let contactNormal = Quaternion.greatCircleRotation(from: p1, to: p2).toAxisAngle().axis
        
        // Project velocities onto contact normal
        let v1Along = Vec3.dot(vel1, contactNormal)
        let v2Along = Vec3.dot(vel2, contactNormal)
        
        // Calculate new velocities along contact normal (1D elastic collision)
        let totalMass = mass1 + mass2
        let newV1Along = ((mass1 - mass2) * v1Along + 2 * mass2 * v2Along) / totalMass * restitution
        let newV2Along = ((mass2 - mass1) * v2Along + 2 * mass1 * v1Along) / totalMass * restitution
        
        // Calculate velocity components perpendicular to contact
        let v1Perp = vel1 - contactNormal * v1Along
        let v2Perp = vel2 - contactNormal * v2Along
        
        // Combine components for final velocities
        let newVel1 = v1Perp + contactNormal * newV1Along
        let newVel2 = v2Perp + contactNormal * newV2Along
        
        return (newVel1, newVel2)
    }
}
