//
//  Simulator.swift
//  wkswift
//
//  Created by Marshall Thames on 4/29/25.
//

import Foundation

//func resolveCollision(crust1: Crust, crust2: Crust) -> (SphericalVelocity, SphericalVelocity) {
//    let pos1 = crust1.position
//    let pos2 = crust2.position
//    let vel1 = crust1.sphericalVelocity.vector
//    let vel2 = crust2.sphericalVelocity.vector
//    let mass1 = crust1.mass
//    let mass2 = crust2.mass
//    
//    // Get the normalized vector from crust1 to crust2 along the great circle
//    let contact = greatCircleDirection(from: pos1, to: pos2)
//    
//    // Project velocities onto the contact direction
//    let v1Along = vel1.dot(contact)
//    let v2Along = vel2.dot(contact)
//    
//    // Calculate new velocities along contact direction (1D elastic collision)
//    let newV1Along = ((mass1 - mass2) * v1Along + 2 * mass2 * v2Along) / (mass1 + mass2)
//    let newV2Along = ((mass2 - mass1) * v2Along + 2 * mass1 * v1Along) / (mass1 + mass2)
//    
//    // Calculate the change in sphericalVelocity along contact vector
//    let deltaV1 = contact * (newV1Along - v1Along)
//    let deltaV2 = contact * (newV2Along - v2Along)
//    
//    // Add the change to the original velocities
//    let newVel1Vector = vel1 + deltaV1
//    let newVel2Vector = vel2 + deltaV2
//    
//    // Ensure they remain tangent to the sphere
//    let newVel1 = SphericalVelocity(at: pos1, direction: newVel1Vector, speed: newVel1Vector.magnitude())
//    let newVel2 = SphericalVelocity(at: pos2, direction: newVel2Vector, speed: newVel2Vector.magnitude())
//    
//    return (newVel1, newVel2)
//}
