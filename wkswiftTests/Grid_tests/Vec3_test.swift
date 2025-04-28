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
}
