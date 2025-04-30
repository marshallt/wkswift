//
//  Quaternion_test.swift
//  wkswiftTests
//
//  Created by Marshall Thames on 4/29/25.
//

import Foundation
import Testing
@testable import wkswift

struct QuaternionTests {
    // Test case helpers
    struct QuaternionToFloat {
        let input: Quaternion
        let expected: Double
    }
    
    struct QuaternionPairToQuaternion {
        let a: Quaternion
        let b: Quaternion
        let expected: Quaternion
    }
    
    struct QuaternionToVec3 {
        let q: Quaternion
        let v: Vec3
        let expected: Vec3
    }
    
    struct AxisAngleToQuaternion {
        let axis: Vec3
        let angle: Double
        let expected: Quaternion
    }
    
    struct EulerToQuaternion {
        let roll: Double
        let pitch: Double
        let yaw: Double
        let expected: Quaternion
    }
    
    struct QuaternionToAxisAngle {
        let q: Quaternion
        let expectedAxis: Vec3
        let expectedAngle: Double
    }
    
    struct QuaternionToEuler {
        let q: Quaternion
        let expectedRoll: Double
        let expectedPitch: Double
        let expectedYaw: Double
    }
    
    struct VecPairToQuaternion {
        let from: Vec3
        let to: Vec3
        let expected: Quaternion
    }
    
    // Test identity and basic properties
    @Test("Quaternion identity property")
    func testIdentity() {
        let identity = Quaternion.identity
        #expect(identity.w == 1.0)
        #expect(identity.x == 0.0)
        #expect(identity.y == 0.0)
        #expect(identity.z == 0.0)
        
        // Test that identity rotation doesn't change a vector
        let v = Vec3(x: 1, y: 2, z: 3)
        let rotated = identity.rotate(v)
        #expect(rotated.isAlmostEqual(to: v, epsilon: 1e-10))
    }
    
    @Test("Quaternion initialization")
    func testInitialization() {
        let q1 = Quaternion(w: 1, x: 2, y: 3, z: 4)
        #expect(q1.w == 1)
        #expect(q1.x == 2)
        #expect(q1.y == 3)
        #expect(q1.z == 4)
        
        let v = Vec3(x: 2, y: 3, z: 4)
        let q2 = Quaternion(scalar: 1, vector: v)
        #expect(q2.w == 1)
        #expect(q2.x == 2)
        #expect(q2.y == 3)
        #expect(q2.z == 4)
        
        // Test the vector property
        #expect(q1.vector.isAlmostEqual(to: v, epsilon: 1e-10))
    }
    
    @Test("Quaternion magnitude and normalization")
    func testMagnitudeAndNormalization() {
        let testCases: [QuaternionToFloat] = [
            QuaternionToFloat(input: Quaternion(w: 1, x: 0, y: 0, z: 0), expected: 1.0),
            QuaternionToFloat(input: Quaternion(w: 1, x: 1, y: 1, z: 1), expected: 2.0),
            QuaternionToFloat(input: Quaternion(w: 2, x: 3, y: 4, z: 5), expected: 7.3484692283495345)
        ]
        
        for tc in testCases {
            let result = tc.input.magnitude()
            #expect(result.isAlmostEqual(to: tc.expected, epsilon: 1e-10),
                   "Magnitude of \(tc.input) expected \(tc.expected) but got \(result)")
            
            let magnitudeSquared = tc.input.magnitudeSquared()
            #expect(magnitudeSquared.isAlmostEqual(to: tc.expected * tc.expected, epsilon: 1e-10),
                   "MagnitudeSquared of \(tc.input) expected \(tc.expected * tc.expected) but got \(magnitudeSquared)")
            
            let normalized = tc.input.normalize()
            #expect(normalized.magnitude().isAlmostEqual(to: 1.0, epsilon: 1e-10),
                   "Normalized quaternion should have magnitude 1")
        }
        
        // Test normalizing an already normalized quaternion
        let q = Quaternion(w: 1, x: 0, y: 0, z: 0)
        let normalized = q.normalize()
        #expect(normalized.isAlmostEqual(to: q, epsilon: 1e-10),
               "Normalizing an already normalized quaternion should return the same quaternion")
    }
    
    @Test("Quaternion conjugate")
    func testConjugate() {
        let testCases: [QuaternionPairToQuaternion] = [
            QuaternionPairToQuaternion(
                a: Quaternion(w: 1, x: 2, y: 3, z: 4),
                b: Quaternion.identity,
                expected: Quaternion(w: 1, x: -2, y: -3, z: -4)
            ),
            QuaternionPairToQuaternion(
                a: Quaternion(w: -1, x: -2, y: -3, z: -4),
                b: Quaternion.identity,
                expected: Quaternion(w: -1, x: 2, y: 3, z: 4)
            ),
            QuaternionPairToQuaternion(
                a: Quaternion.identity,
                b: Quaternion.identity,
                expected: Quaternion.identity
            )
        ]
        
        for tc in testCases {
            let result = tc.a.conjugate()
            #expect(result.isAlmostEqual(to: tc.expected, epsilon: 1e-10),
                   "Conjugate of \(tc.a) expected \(tc.expected) but got \(result)")
        }
    }
    
    @Test("Quaternion inverse")
    func testInverse() {
        let testCases: [QuaternionPairToQuaternion] = [
            QuaternionPairToQuaternion(
                a: Quaternion(w: 1, x: 0, y: 0, z: 0),
                b: Quaternion.identity,
                expected: Quaternion(w: 1, x: 0, y: 0, z: 0)
            ),
            QuaternionPairToQuaternion(
                a: Quaternion(w: 0, x: 1, y: 0, z: 0).normalize(),
                b: Quaternion.identity,
                expected: Quaternion(w: 0, x: -1, y: 0, z: 0).normalize()
            ),
            QuaternionPairToQuaternion(
                a: Quaternion(w: 1, x: 1, y: 1, z: 1).normalize(),
                b: Quaternion.identity,
                expected: Quaternion(w: 1, x: -1, y: -1, z: -1).normalize()
            )
        ]
        
        for tc in testCases {
            let result = tc.a.inverse()
            #expect(result.isAlmostEqual(to: tc.expected, epsilon: 1e-10),
                   "Inverse of \(tc.a) expected \(tc.expected) but got \(result)")
            
            // Test that q * q^-1 = identity
            let product = tc.a.multiply(result)
            #expect(product.isAlmostEqual(to: Quaternion.identity, epsilon: 1e-10),
                   "q * q^-1 should equal identity")
        }
    }
    
    @Test("Quaternion multiplication")
    func testMultiplication() {
        let testCases: [QuaternionPairToQuaternion] = [
            QuaternionPairToQuaternion(
                a: Quaternion.identity,
                b: Quaternion.identity,
                expected: Quaternion.identity
            ),
            QuaternionPairToQuaternion(
                a: Quaternion(w: 1, x: 2, y: 3, z: 4),
                b: Quaternion.identity,
                expected: Quaternion(w: 1, x: 2, y: 3, z: 4)
            ),
            QuaternionPairToQuaternion(
                a: Quaternion(w: 1, x: 0, y: 0, z: 0),
                b: Quaternion(w: 0, x: 1, y: 0, z: 0),
                expected: Quaternion(w: 0, x: 1, y: 0, z: 0)
            ),
            QuaternionPairToQuaternion(
                a: Quaternion(w: 0.7071067811865475, x: 0.7071067811865475, y: 0, z: 0).normalize(),
                b: Quaternion(w: 0.7071067811865475, x: 0, y: 0.7071067811865475, z: 0).normalize(),
                expected: Quaternion(w: 0.5, x: 0.5, y: 0.5, z: 0.5)
            )
        ]
        
        for tc in testCases {
            let result1 = tc.a.multiply(tc.b)
            let result2 = tc.a * tc.b
            
            #expect(result1.isAlmostEqual(to: tc.expected, epsilon: 1e-10),
                   "Multiplication of \(tc.a) and \(tc.b) expected \(tc.expected) but got \(result1)")
            
            #expect(result2.isAlmostEqual(to: tc.expected, epsilon: 1e-10),
                   "Operator * of \(tc.a) and \(tc.b) expected \(tc.expected) but got \(result2)")
        }
    }
    
    @Test("Quaternion vector rotation")
    func testVectorRotation() {
        let testCases: [QuaternionToVec3] = [
            // No rotation (identity quaternion)
            QuaternionToVec3(
                q: Quaternion.identity,
                v: Vec3(x: 1, y: 0, z: 0),
                expected: Vec3(x: 1, y: 0, z: 0)
            ),
            // 90 degree rotation around Z axis
            QuaternionToVec3(
                q: Quaternion.fromAxisAngle(axis: Vec3(x: 0, y: 0, z: 1), angle: Double.pi/2),
                v: Vec3(x: 1, y: 0, z: 0),
                expected: Vec3(x: 0, y: 1, z: 0)
            ),
            // 180 degree rotation around Y axis
            QuaternionToVec3(
                q: Quaternion.fromAxisAngle(axis: Vec3(x: 0, y: 1, z: 0), angle: Double.pi),
                v: Vec3(x: 1, y: 0, z: 0),
                expected: Vec3(x: -1, y: 0, z: 0)
            ),
            // 120 degree rotation around (1,1,1) axis
            QuaternionToVec3(
                q: Quaternion.fromAxisAngle(axis: Vec3(x: 1, y: 1, z: 1), angle: 2*Double.pi/3),
                v: Vec3(x: 1, y: 0, z: 0),
                expected: Vec3(x: 0, y: 1, z: 0)
            )
        ]
        
        for tc in testCases {
            let result1 = tc.q.rotate(tc.v)
            let result2 = tc.q * tc.v
            
            #expect(result1.isAlmostEqual(to: tc.expected, epsilon: 1e-10),
                   "Rotation of \(tc.v) by \(tc.q) expected \(tc.expected) but got \(result1)")
            
            #expect(result2.isAlmostEqual(to: tc.expected, epsilon: 1e-10),
                   "Operator * of \(tc.q) and \(tc.v) expected \(tc.expected) but got \(result2)")
        }
    }
    
    @Test("Quaternion from axis-angle")
    func testFromAxisAngle() {
        let testCases: [AxisAngleToQuaternion] = [
            // No rotation
            AxisAngleToQuaternion(
                axis: Vec3(x: 0, y: 0, z: 1),
                angle: 0,
                expected: Quaternion.identity
            ),
            // 90 degree rotation around Z axis
            AxisAngleToQuaternion(
                axis: Vec3(x: 0, y: 0, z: 1),
                angle: Double.pi/2,
                expected: Quaternion(w: 0.7071067811865475, x: 0, y: 0, z: 0.7071067811865475)
            ),
            // 180 degree rotation around Y axis
            AxisAngleToQuaternion(
                axis: Vec3(x: 0, y: 1, z: 0),
                angle: Double.pi,
                expected: Quaternion(w: 0, x: 0, y: 1, z: 0)
            ),
            // Test with non-normalized axis
            AxisAngleToQuaternion(
                axis: Vec3(x: 0, y: 0, z: 2),
                angle: Double.pi/2,
                expected: Quaternion(w: 0.7071067811865475, x: 0, y: 0, z: 0.7071067811865475)
            )
        ]
        
        for tc in testCases {
            let result = Quaternion.fromAxisAngle(axis: tc.axis, angle: tc.angle)
            
            #expect(result.isAlmostEqual(to: tc.expected, epsilon: 1e-10),
                   "Quaternion from axis \(tc.axis) and angle \(tc.angle) expected \(tc.expected) but got \(result)")
            
            // Also test the degrees version
            let resultDegrees = Quaternion.fromAxisAngle(axis: tc.axis, angleDegrees: tc.angle * toDegrees)
            
            #expect(resultDegrees.isAlmostEqual(to: tc.expected, epsilon: 1e-10),
                   "Quaternion from axis \(tc.axis) and angle \(tc.angle * toDegrees) degrees expected \(tc.expected) but got \(resultDegrees)")
        }
    }
    
    @Test("Quaternion to axis-angle")
    func testToAxisAngle() {
        let testCases: [QuaternionToAxisAngle] = [
            // No rotation
            QuaternionToAxisAngle(
                q: Quaternion.identity,
                expectedAxis: Vec3(x: 1, y: 0, z: 0),  // Any axis works for zero rotation
                expectedAngle: 0
            ),
            // 90 degree rotation around Z axis
            QuaternionToAxisAngle(
                q: Quaternion(w: 0.7071067811865475, x: 0, y: 0, z: 0.7071067811865475),
                expectedAxis: Vec3(x: 0, y: 0, z: 1),
                expectedAngle: Double.pi/2
            ),
            // 180 degree rotation around Y axis
            QuaternionToAxisAngle(
                q: Quaternion(w: 0, x: 0, y: 1, z: 0),
                expectedAxis: Vec3(x: 0, y: 1, z: 0),
                expectedAngle: Double.pi
            )
        ]
        
        for tc in testCases {
            let (resultAxis, resultAngle) = tc.q.toAxisAngle()
            
            // For zero rotation, any axis is valid
            if tc.expectedAngle.isAlmostEqual(to: 0, epsilon: 1e-10) {
                #expect(resultAngle.isAlmostEqual(to: tc.expectedAngle, epsilon: 1e-10),
                       "Angle from quaternion \(tc.q) expected \(tc.expectedAngle) but got \(resultAngle)")
            } else {
                #expect(resultAxis.isAlmostEqual(to: tc.expectedAxis, epsilon: 1e-10) ||
                       resultAxis.isAlmostEqual(to: tc.expectedAxis.scale(by: -1), epsilon: 1e-10),
                       "Axis from quaternion \(tc.q) expected \(tc.expectedAxis) but got \(resultAxis)")
                
                #expect(resultAngle.isAlmostEqual(to: tc.expectedAngle, epsilon: 1e-10),
                       "Angle from quaternion \(tc.q) expected \(tc.expectedAngle) but got \(resultAngle)")
            }
        }
    }
    
    @Test("Quaternion from Euler angles")
    func testFromEuler() {
        let testCases: [EulerToQuaternion] = [
            // No rotation
            EulerToQuaternion(
                roll: 0, pitch: 0, yaw: 0,
                expected: Quaternion.identity
            ),
            // 90 degree pitch (Y rotation)
            EulerToQuaternion(
                roll: 0, pitch: Double.pi/2, yaw: 0,
                expected: Quaternion(w: 0.7071067811865475, x: 0.0, y: 0.7071067811865475, z: 0)
            ),
            // 90 degree yaw (Z rotation)
            EulerToQuaternion(
                roll: 0, pitch: 0, yaw: Double.pi/2,
                expected: Quaternion(w: 0.7071067811865475, x: 0, y: 0, z: 0.7071067811865475)
            ),
            // 90 degree roll (X rotation)
            EulerToQuaternion(
                roll: Double.pi/2, pitch: 0, yaw: 0,
                expected: Quaternion(w: 0.7071067811865475, x: 0.7071067811865475, y: 0, z: 0)
            ),
            // Combined rotation
            EulerToQuaternion(
                roll: Double.pi/4, pitch: Double.pi/4, yaw: Double.pi/4,
                expected: Quaternion(w: 0.8446232, x: 0.1913417, y: 0.4619398, z: 0.1913417)
            )
        ]
        
        for tc in testCases {
            let result = Quaternion.fromEuler(roll: tc.roll, pitch: tc.pitch, yaw: tc.yaw)
            
            #expect(result.isAlmostEqual(to: tc.expected, epsilon: 1e-6),
                   "Quaternion from Euler angles (r:\(tc.roll), p:\(tc.pitch), y:\(tc.yaw)) expected \(tc.expected) but got \(result)")
            
            // Also test the degrees version
            let resultDegrees = Quaternion.fromEulerDegrees(
                roll: tc.roll * toDegrees,
                pitch: tc.pitch * toDegrees,
                yaw: tc.yaw * toDegrees,
            )
            
            #expect(resultDegrees.isAlmostEqual(to: tc.expected, epsilon: 1e-6),
                   "Quaternion from Euler angles in degrees expected \(tc.expected) but got \(resultDegrees)")
        }
    }
    
    @Test("Quaternion to Euler angles")
    func testToEuler() {
        let testCases: [QuaternionToEuler] = [
            // No rotation
            QuaternionToEuler(
                q: Quaternion.identity,
                expectedRoll: 0, expectedPitch: 0, expectedYaw: 0,
            ),
            // 90 degree pitch (X rotation)
            QuaternionToEuler(
                q: Quaternion(w: 0.7071067811865475, x: 0.7071067811865475, y: 0, z: 0),
                expectedRoll: Double.pi/2, expectedPitch: 0, expectedYaw: 0,
            ),
            // 90 degree yaw (Y rotation)
            QuaternionToEuler(
                q: Quaternion(w: 0.7071067811865475, x: 0, y: 0.7071067811865475, z: 0),
                expectedRoll: 0, expectedPitch: Double.pi/2, expectedYaw: 0,
            ),
            // 90 degree roll (Z rotation)
            QuaternionToEuler(
                q: Quaternion(w: 0.7071067811865475, x: 0, y: 0, z: 0.7071067811865475),
                expectedRoll: 0, expectedPitch: 0, expectedYaw: Double.pi/2,
            )
        ]
        
        for tc in testCases {
            let (resultRoll, resultPitch, resultYaw) = tc.q.toEuler()
            
            #expect( resultRoll.isAlmostEqual(to: tc.expectedRoll, epsilon: 1e-6) &&
                     resultPitch.isAlmostEqual(to: tc.expectedPitch, epsilon: 1e-6) &&
                     resultYaw.isAlmostEqual(to: tc.expectedYaw, epsilon: 1e-6),
                  
                     "Euler angles from quaternion \(tc.q) expected (r:\(tc.expectedRoll), p:\(tc.expectedPitch), y:\(tc.expectedYaw)) but got (r:\(resultRoll), p:\(resultPitch), y:\(resultYaw))")
            
            // Also test the degrees version
            let (rollDeg, pitchDeg, yawDeg) = tc.q.toEulerDegrees()
            
            let expectedRoll = tc.expectedRoll * toDegrees
            let expectedPitch = tc.expectedPitch * toDegrees
            let expectedYaw = tc.expectedYaw * toDegrees
            
            
            #expect(rollDeg.isAlmostEqual(to: expectedRoll, epsilon: 1e-5) &&
                    pitchDeg.isAlmostEqual(to: expectedPitch, epsilon: 1e-5) &&
                    yawDeg.isAlmostEqual(to: expectedYaw, epsilon: 1e-5),
                    "Euler angles in degrees from quaternion \(tc.q) expected (r:\(expectedRoll), p:\(expectedPitch), y:\(expectedYaw)) but got (r:\(rollDeg), p:\(pitchDeg), y:\(yawDeg))")
        }
    }
    
    @Test("Quaternion from vectors")
    func testFromVectors() {
        let testCases: [VecPairToQuaternion] = [
            // No rotation (same vectors)
            VecPairToQuaternion(
                from: Vec3(x: 1, y: 0, z: 0),
                to: Vec3(x: 1, y: 0, z: 0),
                expected: Quaternion.identity
            ),
            // 90 degree rotation in XY plane
            VecPairToQuaternion(
                from: Vec3(x: 1, y: 0, z: 0),
                to: Vec3(x: 0, y: 1, z: 0),
                expected: Quaternion.fromAxisAngle(axis: Vec3(x: 0, y: 0, z: 1), angle: Double.pi/2)
            ),
            // 180 degree rotation (opposite vectors)
            VecPairToQuaternion(
                from: Vec3(x: 0, y: 0, z: 1),
                to: Vec3(x: 0, y: 0, z: -1),
                expected: Quaternion.fromAxisAngle(axis: Vec3(x: 1, y: 0, z: 0), angle: Double.pi)
            )
        ]
        
        for tc in testCases {
            let result = Quaternion.fromVectors(from: tc.from, to: tc.to)
            
            // Check that the result rotates 'from' to 'to'
            let rotated = result.rotate(tc.from)
            #expect(rotated.isAlmostEqual(to: tc.to, epsilon: 1e-6),
                   "Rotation from \(tc.from) to \(tc.to) produced \(rotated)")
        }
    }
    
    @Test("Quaternion SLERP")
    func testSlerp() {
        // Test SLERP with identical quaternions
        let q1 = Quaternion(w: 1, x: 0, y: 0, z: 0)
        let result1 = Quaternion.slerp(q1, q1, t: 0.5)
        #expect(result1.isAlmostEqual(to: q1, epsilon: 1e-10),
               "SLERP between identical quaternions should return the same quaternion")
        
        // Test SLERP with 90 degree rotation
        let q2 = Quaternion.fromAxisAngle(axis: Vec3(x: 0, y: 0, z: 1), angle: 0)
        let q3 = Quaternion.fromAxisAngle(axis: Vec3(x: 0, y: 0, z: 1), angle: Double.pi/2)
        
        // At t=0, should be q2
        let result2 = Quaternion.slerp(q2, q3, t: 0)
        #expect(result2.isAlmostEqual(to: q2, epsilon: 1e-10),
               "SLERP at t=0 should be the first quaternion")
        
        // At t=1, should be q3
        let result3 = Quaternion.slerp(q2, q3, t: 1)
        #expect(result3.isAlmostEqual(to: q3, epsilon: 1e-10),
               "SLERP at t=1 should be the second quaternion")
        
        // At t=0.5, should be 45 degree rotation
        let result4 = Quaternion.slerp(q2, q3, t: 0.5)
        let expected4 = Quaternion.fromAxisAngle(axis: Vec3(x: 0, y: 0, z: 1), angle: Double.pi/4)
        #expect(result4.isAlmostEqual(to: expected4, epsilon: 1e-10),
               "SLERP at t=0.5 for 90 degree rotation should be 45 degree rotation")
    }
    
    @Test("Quaternion equality and almost equality")
    func testEquality() {
        let q1 = Quaternion(w: 1, x: 2, y: 3, z: 4)
        let q2 = Quaternion(w: 1, x: 2, y: 3, z: 4)
        let q3 = Quaternion(w: 4, x: 3, y: 2, z: 1)
        
        // Test exact equality
        #expect(q1 == q2, "Identical quaternions should be equal")
        #expect(q1 != q3, "Different quaternions should not be equal")
        
        // Test almost equality
        let q4 = Quaternion(w: 1.0000001, x: 2, y: 3, z: 4)
        #expect(q1.isAlmostEqual(to: q4, epsilon: 1e-6),
               "Almost identical quaternions should be almost equal")
        #expect(!q1.isAlmostEqual(to: q3, epsilon: 1e-6),
               "Different quaternions should not be almost equal")
        
        // Test that the same rotation with negative quaternion is almost equal
        let q5 = Quaternion(w: -1, x: -2, y: -3, z: -4)
        
        // Normalize both to test rotation equality
        let q1n = q1.normalize()
        let q5n = q5.normalize()
        
        // This test depends on your isAlmostEqual implementation
        // If you want q and -q to represent the same rotation and be "almost equal":
        // #expect(q1n.isAlmostEqual(to: q5n, epsilon: 1e-10),
        //        "Quaternions representing the same rotation should be almost equal")
    }
    
    @Test("Quaternion arithmetic operators")
    func testArithmeticOperators() {
        let q1 = Quaternion(w: 1, x: 2, y: 3, z: 4)
        let q2 = Quaternion(w: 5, x: 6, y: 7, z: 8)
        
        // Addition
        let sum = q1 + q2
        let expectedSum = Quaternion(w: 6, x: 8, y: 10, z: 12)
        #expect(sum == expectedSum, "Quaternion addition")
        
        // Subtraction
        let difference = q2 - q1
        let expectedDifference = Quaternion(w: 4, x: 4, y: 4, z: 4)
        #expect(difference == expectedDifference, "Quaternion subtraction")
        
        // Scalar multiplication
        let scaled = q1 * 2.0
        let expectedScaled = Quaternion(w: 2, x: 4, y: 6, z: 8)
        #expect(scaled == expectedScaled, "Quaternion scalar multiplication (right)")
        
        let scaled2 = 2.0 * q1
        #expect(scaled2 == expectedScaled, "Quaternion scalar multiplication (left)")
        
        // Negation
        let negated = -q1
        let expectedNegated = Quaternion(w: -1, x: -2, y: -3, z: -4)
        #expect(negated == expectedNegated, "Quaternion negation")
    }
    
    @Test("Quaternion great circle rotation")
    func testGreatCircleRotation() {
        // Test rotation from one point to another on the unit sphere
        let from = Vec3(x: 1, y: 0, z: 0).normalize()
        let to = Vec3(x: 0, y: 1, z: 0).normalize()
        
        let rotation = Quaternion.greatCircleRotation(from: from, to: to)
        
        // Apply the rotation
        let result = rotation.rotate(from)
        
        // Check that the result is the destination vector
        #expect(result.isAlmostEqual(to: to, epsilon: 1e-6),
               "Great circle rotation from \(from) to \(to) failed")
        
        // Test with identical vectors
        let sameVec = Vec3(x: 0, y: 0, z: 1).normalize()
        let identRotation = Quaternion.greatCircleRotation(from: sameVec, to: sameVec)
        #expect(identRotation.isAlmostEqual(to: Quaternion.identity, epsilon: 1e-10),
               "Great circle rotation between identical vectors should be identity")
    }
    
    @Test("Quaternion great circle step")
    func testGreatCircleStep() {
        // Test stepping along great circle
        let position = Vec3(x: 1, y: 0, z: 0).normalize()
        let velocity = Vec3(x: 0, y: 1, z: 0) // Tangent velocity
        
        // Step with 90 degree distance
        let step = Quaternion.greatCircleStep(position: position, velocity: velocity, distance: Double.pi/2)
        let newPosition = step.rotate(position)
        
        // Should end up at (0, 1, 0)
        let expected = Vec3(x: 0, y: 1, z: 0)
        #expect(newPosition.isAlmostEqual(to: expected, epsilon: 1e-6),
               "Great circle step resulted in \(newPosition) but expected \(expected)")
        
        // Test with zero velocity
        let zeroVel = Vec3(x: 0, y: 0, z: 0)
        let zeroStep = Quaternion.greatCircleStep(position: position, velocity: zeroVel, distance: 1.0)
        #expect(zeroStep.isAlmostEqual(to: Quaternion.identity, epsilon: 1e-10),
               "Great circle step with zero velocity should be identity")
        
        // Test with radial velocity (not tangent to sphere)
        let radialVel = Vec3(x: 1, y: 0, z: 0) // Parallel to position
        let radialStep = Quaternion.greatCircleStep(position: position, velocity: radialVel, distance: 1.0)
        #expect(radialStep.isAlmostEqual(to: Quaternion.identity, epsilon: 1e-10),
               "Great circle step with radial velocity should be identity")
    }
    
    @Test("Quaternion sphere collision velocity")
    func testSphereCollisionVelocity() {
        // Test head-on collision between equal masses
        let pos1 = Vec3(x: 1, y: 0, z: 0).normalize()
        let vel1 = Vec3(x: 0, y: 1, z: 0) // Tangent velocity
        let mass1 = 1.0
        
        let pos2 = Vec3(x: 0, y: 1, z: 0).normalize()
        let vel2 = Vec3(x: 1, y: 0, z: 0) // Tangent velocity
        let mass2 = 1.0
        
        let (newVel1, newVel2) = Quaternion.sphereCollisionVelocity(
            pos1: pos1, vel1: vel1, mass1: mass1,
            pos2: pos2, vel2: vel2, mass2: mass2,
            restitution: 1.0 // Perfectly elastic
        )
        
        // With equal masses, perfectly elastic collision should swap velocities
        #expect(newVel1.isAlmostEqual(to: vel2, epsilon: 1e-6) &&
               newVel2.isAlmostEqual(to: vel1, epsilon: 1e-6),
               "Equal mass collision should swap velocities: vel1=\(vel1), newVel1=\(newVel1), vel2=\(vel2), newVel2=\(newVel2)")
        
        // Test collision with different masses
        let pos3 = Vec3(x: 1, y: 0, z: 0).normalize()
        let vel3 = Vec3(x: 0, y: 1, z: 0) // Tangent velocity
        let mass3 = 10.0 // Heavy object
        
        let pos4 = Vec3(x: 0, y: 1, z: 0).normalize()
        let vel4 = Vec3(x: -1, y: 0, z: 0) // Tangent velocity, opposite direction
        let mass4 = 1.0 // Light object
        
        let (newVel3, newVel4) = Quaternion.sphereCollisionVelocity(
            pos1: pos3, vel1: vel3, mass1: mass3,
            pos2: pos4, vel2: vel4, mass2: mass4,
            restitution: 1.0
        )
        
        // Heavy object should barely change direction
        #expect(Vec3.dot(newVel3, vel3) > 0.8,
               "Heavy object should maintain most of its velocity direction")
        
        // Light object should bounce away significantly
        #expect(Vec3.dot(newVel4, vel4) < 0,
               "Light object should reverse direction after collision with heavy object")
        
        // Test inelastic collision
        let (newVel5, newVel6) = Quaternion.sphereCollisionVelocity(
            pos1: pos1, vel1: vel1, mass1: mass1,
            pos2: pos2, vel2: vel2, mass2: mass2,
            restitution: 0.0 // Completely inelastic
        )
        
        // With completely inelastic collision, velocities along contact normal should be zero
        let contactNormal = Quaternion.greatCircleRotation(from: pos1, to: pos2).toAxisAngle().axis
        let vel5Along = Vec3.dot(newVel5, contactNormal)
        let vel6Along = Vec3.dot(newVel6, contactNormal)
        
        #expect(abs(vel5Along) < 1e-6 && abs(vel6Along) < 1e-6,
               "Inelastic collision should have zero velocity along contact normal")
    }
    
    @Test("Quaternion description and hashing")
    func testDescriptionAndHashing() {
        let q = Quaternion(w: 1.2345, x: 2.3456, y: 3.4567, z: 4.5678)
        let description = q.description
        
        // Verify description contains all components
        #expect(description.contains("1.2345") &&
               description.contains("2.3456") &&
               description.contains("3.4567") &&
               description.contains("4.5678"),
               "Description should contain all quaternion components")
        
        // Test hashing
        var hasher1 = Hasher()
        var hasher2 = Hasher()
        
        q.hash(into: &hasher1)
        q.hash(into: &hasher2)
        
        let hash1 = hasher1.finalize()
        let hash2 = hasher2.finalize()
        
        #expect(hash1 == hash2, "Same quaternion should produce the same hash value")
        
        let q2 = Quaternion(w: 4.5678, x: 3.4567, y: 2.3456, z: 1.2345)
        var hasher3 = Hasher()
        q2.hash(into: &hasher3)
        let hash3 = hasher3.finalize()
        
        #expect(hash1 != hash3, "Different quaternions should have different hash values")
    }
}
