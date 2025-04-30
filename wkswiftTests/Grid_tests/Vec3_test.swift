//
//  Vec3_test.swift
//  wkswiftTests
//
//  Created by Marshall Thames on 4/25/25.
//

import Foundation
import Testing
@testable import wkswift 

struct Vec3Tests {
    // Test case structures
    struct Vec3ToFloat {
        let input: Vec3
        let expected: Double
    }
    
    struct SphericalToVec3 {
        let input: LatLon
        let expected: Vec3
    }
    
    struct Vec3ToVec3 {
        let input: Vec3
        let expected: Vec3
    }
    
    struct Vec3PairToVec3 {
         let a: Vec3
         let b: Vec3
         let expected: Vec3
     }
     
     struct Vec3PairToFloat {
         let a: Vec3
         let b: Vec3
         let expected: Double
     }
    
    @Test("Test creating Vec3 from LatLon")
    func testVec3_NewVec3FromSpherical() {
        let testCases: [SphericalToVec3] = [
            SphericalToVec3(input: LatLon(lat: 0, lon: 0), expected: Vec3(x: 0, y: 0, z: -1)),
            SphericalToVec3(input: LatLon(lat: 90, lon: 0), expected: Vec3(x: 0, y: 1, z: 0)),
            SphericalToVec3(input: LatLon(lat: 0, lon: -90), expected: Vec3(x: -1, y: 0, z: 0)),
            SphericalToVec3(input: LatLon(lat: -45, lon: -45), expected: Vec3(x: -0.5, y: -0.7071067811865475, z: -0.5)),
            SphericalToVec3(input: LatLon(lat: 45, lon: -45), expected: Vec3(x: -0.5, y: 0.7071067811865475, z: -0.5)),
            SphericalToVec3(input: LatLon(lat: -45, lon: 45), expected: Vec3(x: 0.5, y: -0.7071067811865475, z: -0.5)),
            SphericalToVec3(input: LatLon(lat: 45, lon: 45), expected: Vec3(x: 0.5, y: 0.7071067811865475, z: -0.5)),
            SphericalToVec3(input: LatLon(lat: 30, lon: 100), expected: Vec3(x: 0.8528685320, y: 0.5, z: 0.1503837332)),
            SphericalToVec3(input: LatLon(lat: -30, lon: 100), expected: Vec3(x: 0.8528685320, y: -0.5, z: 0.1503837332)),
            SphericalToVec3(input: LatLon(lat: -30, lon: -100), expected: Vec3(x: -0.8528685320, y: -0.5, z: 0.1503837332)),
            SphericalToVec3(input: LatLon(lat: 80, lon: -10), expected: Vec3(x: -0.0301536896, y: 0.9848077530, z: -0.1710100717))
        ]
        
        for tc in testCases {
            let result = Vec3.newSphereVecFromLatLon(tc.input)
            #expect(result.isAlmostEqual(to: tc.expected, epsilon: 1e-9),
                "With \(tc.input), expected \(tc.expected) but got \(result)")
        }
    }
    
    @Test("Test Vec3 magnitude calculation")
    func testVec3_Magnitude() {
        let testCases: [Vec3ToFloat] = [
            Vec3ToFloat(input: Vec3(x: 0, y: 0, z: 0), expected: 0.0),
            Vec3ToFloat(input: Vec3(x: 0, y: 0, z: 1), expected: 1.0),
            Vec3ToFloat(input: Vec3(x: -3, y: 0, z: 1), expected: 3.16227766017),
            Vec3ToFloat(input: Vec3(x: 3.5, y: 1.2, z: 2.1), expected: 4.25440947724)
        ]
        
        for tc in testCases {
            let result = tc.input.magnitude()
            #expect(result.isAlmostEqual(to: tc.expected, epsilon: 1e-9),
                "With \(tc.input), expected \(tc.expected) but got \(result)")
        }
    }
    
    @Test("Test Vec3 normalization")
    func testVec3_Normalize() {
        let testCases: [Vec3ToVec3] = [
            Vec3ToVec3(input: Vec3(x: 1, y: 1, z: 1),
                      expected: Vec3(x: 0.577350269, y: 0.577350269, z: 0.577350269)),
            Vec3ToVec3(input: Vec3(x: -3, y: 0, z: 1),
                      expected: Vec3(x: -0.948683298, y: 0.000000000, z: 0.316227766)),
            Vec3ToVec3(input: Vec3(x: 3.5, y: 1.2, z: 2.1),
                      expected: Vec3(x: 0.822675866, y: 0.282060297, z: 0.493605519))
        ]
        
        for tc in testCases {
            let result = tc.input.normalize()
            #expect(result.isAlmostEqual(to: tc.expected, epsilon: 1e-9),
                "With \(tc.input), expected \(tc.expected) but got \(result)")
        }
    }
    
    @Test("Test Vec3 dot product")
        func testVec3_Dot() {
            let testCases: [Vec3PairToFloat] = [
                Vec3PairToFloat(a: Vec3(x: 1, y: 0, z: 0), b: Vec3(x: 1, y: 0, z: 0), expected: 1.0),
                Vec3PairToFloat(a: Vec3(x: 1, y: 0, z: 0), b: Vec3(x: 0, y: 1, z: 0), expected: 0.0),
                Vec3PairToFloat(a: Vec3(x: 2, y: 3, z: 4), b: Vec3(x: 5, y: 6, z: 7), expected: 56.0),
                Vec3PairToFloat(a: Vec3(x: -1, y: 2, z: -3), b: Vec3(x: 4, y: -5, z: 6), expected: -32.0)
            ]
            
            for tc in testCases {
                let result = tc.a.dot(tc.b)
                let staticResult = Vec3.dot(tc.a, tc.b)
                
                #expect(result.isAlmostEqual(to: tc.expected, epsilon: 1e-9),
                    "With \(tc.a) dot \(tc.b), expected \(tc.expected) but got \(result)")
                #expect(staticResult.isAlmostEqual(to: tc.expected, epsilon: 1e-9),
                    "With static dot(\(tc.a), \(tc.b)), expected \(tc.expected) but got \(staticResult)")
            }
        }
        
        @Test("Test Vec3 cross product")
        func testVec3_Cross() {
            let testCases: [Vec3PairToVec3] = [
                Vec3PairToVec3(
                    a: Vec3(x: 1, y: 0, z: 0),
                    b: Vec3(x: 0, y: 1, z: 0),
                    expected: Vec3(x: 0, y: 0, z: 1)
                ),
                Vec3PairToVec3(
                    a: Vec3(x: 2, y: 3, z: 4),
                    b: Vec3(x: 5, y: 6, z: 7),
                    expected: Vec3(x: -3, y: 6, z: -3)
                ),
                Vec3PairToVec3(
                    a: Vec3(x: -1, y: 2, z: -3),
                    b: Vec3(x: 4, y: -5, z: 6),
                    expected: Vec3(x: -3, y: -6, z: -3)
                )
            ]
            
            for tc in testCases {
                let result = tc.a.cross(tc.b)
                let staticResult = Vec3.cross(tc.a, tc.b)
                
                #expect(result.isAlmostEqual(to: tc.expected, epsilon: 1e-9),
                    "With \(tc.a) cross \(tc.b), expected \(tc.expected) but got \(result)")
                #expect(staticResult.isAlmostEqual(to: tc.expected, epsilon: 1e-9),
                    "With static cross(\(tc.a), \(tc.b)), expected \(tc.expected) but got \(staticResult)")
            }
        }
        
        @Test("Test Vec3 addition")
        func testVec3_Addition() {
            let testCases: [Vec3PairToVec3] = [
                Vec3PairToVec3(
                    a: Vec3(x: 1, y: 2, z: 3),
                    b: Vec3(x: 4, y: 5, z: 6),
                    expected: Vec3(x: 5, y: 7, z: 9)
                ),
                Vec3PairToVec3(
                    a: Vec3(x: -1, y: -2, z: -3),
                    b: Vec3(x: 1, y: 2, z: 3),
                    expected: Vec3(x: 0, y: 0, z: 0)
                ),
                Vec3PairToVec3(
                    a: Vec3(x: 0.5, y: 1.5, z: 2.5),
                    b: Vec3(x: 0.1, y: 0.2, z: 0.3),
                    expected: Vec3(x: 0.6, y: 1.7, z: 2.8)
                )
            ]
            
            for tc in testCases {
                let result = tc.a + tc.b
                
                #expect(result.isAlmostEqual(to: tc.expected, epsilon: 1e-9),
                    "With \(tc.a) + \(tc.b), expected \(tc.expected) but got \(result)")
            }
        }
        
        @Test("Test Vec3 subtraction")
        func testVec3_Subtraction() {
            let testCases: [Vec3PairToVec3] = [
                Vec3PairToVec3(
                    a: Vec3(x: 5, y: 7, z: 9),
                    b: Vec3(x: 4, y: 5, z: 6),
                    expected: Vec3(x: 1, y: 2, z: 3)
                ),
                Vec3PairToVec3(
                    a: Vec3(x: 1, y: 2, z: 3),
                    b: Vec3(x: 1, y: 2, z: 3),
                    expected: Vec3(x: 0, y: 0, z: 0)
                ),
                Vec3PairToVec3(
                    a: Vec3(x: 0.6, y: 1.7, z: 2.8),
                    b: Vec3(x: 0.1, y: 0.2, z: 0.3),
                    expected: Vec3(x: 0.5, y: 1.5, z: 2.5)
                )
            ]
            
            for tc in testCases {
                let result = tc.a - tc.b
                
                #expect(result.isAlmostEqual(to: tc.expected, epsilon: 1e-9),
                    "With \(tc.a) - \(tc.b), expected \(tc.expected) but got \(result)")
            }
        }
        
        @Test("Test Vec3 scalar multiplication")
        func testVec3_ScalarMultiplication() {
            let testCases: [(vec: Vec3, scalar: Double, expected: Vec3)] = [
                (Vec3(x: 1, y: 2, z: 3), 2.0, Vec3(x: 2, y: 4, z: 6)),
                (Vec3(x: -1, y: -2, z: -3), 3.0, Vec3(x: -3, y: -6, z: -9)),
                (Vec3(x: 1, y: 2, z: 3), 0.0, Vec3(x: 0, y: 0, z: 0)),
                (Vec3(x: 1, y: 2, z: 3), -1.0, Vec3(x: -1, y: -2, z: -3))
            ]
            
            for tc in testCases {
                let result1 = tc.vec * tc.scalar
                let result2 = tc.scalar * tc.vec
                let result3 = tc.vec.scale(by: tc.scalar)
                
                #expect(result1.isAlmostEqual(to: tc.expected, epsilon: 1e-9),
                    "With \(tc.vec) * \(tc.scalar), expected \(tc.expected) but got \(result1)")
                #expect(result2.isAlmostEqual(to: tc.expected, epsilon: 1e-9),
                    "With \(tc.scalar) * \(tc.vec), expected \(tc.expected) but got \(result2)")
                #expect(result3.isAlmostEqual(to: tc.expected, epsilon: 1e-9),
                    "With \(tc.vec).scale(by: \(tc.scalar)), expected \(tc.expected) but got \(result3)")
            }
        }
        
        @Test("Test Vec3 scalar division")
        func testVec3_ScalarDivision() {
            let testCases: [(vec: Vec3, scalar: Double, expected: Vec3)] = [
                (Vec3(x: 2, y: 4, z: 6), 2.0, Vec3(x: 1, y: 2, z: 3)),
                (Vec3(x: -3, y: -6, z: -9), 3.0, Vec3(x: -1, y: -2, z: -3)),
                (Vec3(x: 1, y: 2, z: 3), 0.5, Vec3(x: 2, y: 4, z: 6))
            ]
            
            for tc in testCases {
                let result = tc.vec / tc.scalar
                
                #expect(result.isAlmostEqual(to: tc.expected, epsilon: 1e-9),
                    "With \(tc.vec) / \(tc.scalar), expected \(tc.expected) but got \(result)")
            }
        }
        
        @Test("Test Vec3 midpoint calculation")
        func testVec3_Midpoint() {
            let testCases: [Vec3PairToVec3] = [
                Vec3PairToVec3(
                    a: Vec3(x: 0, y: 0, z: 0),
                    b: Vec3(x: 2, y: 4, z: 6),
                    expected: Vec3(x: 1, y: 2, z: 3)
                ),
                Vec3PairToVec3(
                    a: Vec3(x: -2, y: -4, z: -6),
                    b: Vec3(x: 2, y: 4, z: 6),
                    expected: Vec3(x: 0, y: 0, z: 0)
                ),
                Vec3PairToVec3(
                    a: Vec3(x: 1.5, y: 2.5, z: 3.5),
                    b: Vec3(x: 2.5, y: 3.5, z: 4.5),
                    expected: Vec3(x: 2.0, y: 3.0, z: 4.0)
                )
            ]
            
            for tc in testCases {
                let result = tc.a.midpoint(with: tc.b)
                
                #expect(result.isAlmostEqual(to: tc.expected, epsilon: 1e-9),
                    "Midpoint of \(tc.a) and \(tc.b), expected \(tc.expected) but got \(result)")
            }
        }
        
        @Test("Test Vec3 to LatLon conversion")
        func testVec3_ToLatLon() {
            let testCases: [(vec: Vec3, expected: LatLon)] = [
                (Vec3(x: 0, y: 0, z: -1), LatLon(lat: 0, lon: 0)),
                (Vec3(x: 0, y: 1, z: 0), LatLon(lat: 90, lon: 0)),
                (Vec3(x: -1, y: 0, z: 0), LatLon(lat: 0, lon: -90)),
                (Vec3(x: 0, y: 0, z: 1), LatLon(lat: 0, lon: 180))
            ]
            
            for tc in testCases {
                let result = tc.vec.toLatLon()
                
                #expect(result.lat.isAlmostEqual(to: tc.expected.lat, epsilon: 1e-9) &&
                       result.lon.isAlmostEqual(to: tc.expected.lon, epsilon: 1e-9),
                       "Converting \(tc.vec) to LatLon, expected \(tc.expected) but got \(result)")
            }
        }
        
        @Test("Test Vec3 magnitude squared calculation")
        func testVec3_MagnitudeSquared() {
            let testCases: [Vec3ToFloat] = [
                Vec3ToFloat(input: Vec3(x: 0, y: 0, z: 0), expected: 0.0),
                Vec3ToFloat(input: Vec3(x: 1, y: 0, z: 0), expected: 1.0),
                Vec3ToFloat(input: Vec3(x: 3, y: 4, z: 0), expected: 25.0),
                Vec3ToFloat(input: Vec3(x: 2, y: 2, z: 2), expected: 12.0)
            ]
            
            for tc in testCases {
                let result = tc.input.magnitudeSquared()
                
                #expect(result.isAlmostEqual(to: tc.expected, epsilon: 1e-9),
                    "MagnitudeSquared of \(tc.input), expected \(tc.expected) but got \(result)")
            }
        }
        
        @Test("Test Vec3 equality")
        func testVec3_Equality() {
            let testCases: [(a: Vec3, b: Vec3, expected: Bool)] = [
                (Vec3(x: 1, y: 2, z: 3), Vec3(x: 1, y: 2, z: 3), true),
                (Vec3(x: 1, y: 2, z: 3), Vec3(x: 3, y: 2, z: 1), false),
                (Vec3(x: 0, y: 0, z: 0), Vec3(x: 0, y: 0, z: 0), true),
                (Vec3(x: 1.0000001, y: 2, z: 3), Vec3(x: 1, y: 2, z: 3), false)
            ]
            
            for tc in testCases {
                let result = tc.a == tc.b
                
                #expect(result == tc.expected,
                       "\(tc.a) == \(tc.b), expected \(tc.expected) but got \(result)")
            }
        }
        
        @Test("Test Vec3 isAlmostEqual")
        func testVec3_IsAlmostEqual() {
            let testCases: [(a: Vec3, b: Vec3, epsilon: Double, expected: Bool)] = [
                (Vec3(x: 1, y: 2, z: 3), Vec3(x: 1, y: 2, z: 3), 1e-9, true),
                (Vec3(x: 1, y: 2, z: 3), Vec3(x: 1.0000001, y: 2, z: 3), 1e-6, true),
                (Vec3(x: 1, y: 2, z: 3), Vec3(x: 1.0000001, y: 2, z: 3), 1e-8, false),
                (Vec3(x: 1, y: 2, z: 3), Vec3(x: 3, y: 2, z: 1), 1e-9, false)
            ]
            
            for tc in testCases {
                let result = tc.a.isAlmostEqual(to: tc.b, epsilon: tc.epsilon)
                
                #expect(result == tc.expected,
                       "\(tc.a).isAlmostEqual(to: \(tc.b), epsilon: \(tc.epsilon)), expected \(tc.expected) but got \(result)")
            }
        }
        
        @Test("Test Vec3 description")
        func testVec3_Description() {
            let testCases: [(vec: Vec3, expected: String)] = [
                (Vec3(x: 1, y: 2, z: 3), "(1.0, 2.0, 3.0)"),
                (Vec3(x: -1.5, y: 0, z: 2.75), "(-1.5, 0.0, 2.75)")
            ]
            
            for tc in testCases {
                let result = tc.vec.description
                
                #expect(result == tc.expected,
                       "Description of \(tc.vec), expected \(tc.expected) but got \(result)")
            }
        }
}
