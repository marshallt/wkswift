//
//  SphericalGeometry.swift
//  wkswift
//
//  Created by Marshall Thames on 4/29/25.
//

import Foundation

struct SphericalVelocity {
    var vector: Vec3
    
    // Constructor ensures the velocity is tangent to sphere at position
    init(at position: Vec3, direction: Vec3, speed: Double) {
        // Create a vector in the tangent plane
       let normalized = position.normalize()
       // Reject the component of direction parallel to position
       let tangentDirection = direction - normalized * direction.dot(normalized)
       // Scale by speed
       self.vector = tangentDirection.normalize() * speed
    }

    // Helper function to get direction along great circle
    func greatCircleDirection(from p1: Vec3, to p2: Vec3) -> Vec3 {
        // Cross product gives vector perpendicular to both positions
        let perpendicular = p1.cross(p2)
        
        // Cross again to get the tangent vector along the great circle
        let direction = p1.cross(perpendicular).normalize()
        
        return direction
    }
}
