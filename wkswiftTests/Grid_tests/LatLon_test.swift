//
//  LatLon_test.swift
//  wkswiftTests
//
//  Created by Marshall Thames on 4/25/25.
//

import Foundation
import Testing

@testable import wkswift // Replace with your actual module name

struct FromVec3TestCase {
    let input: Vec3
    let expected: LatLon
}

struct LatLonTests {
    @Test("Test conversion from Vec3 to LatLon")
    func testNewFromVec3() {
        let testCases: [FromVec3TestCase] = [
            FromVec3TestCase(input: Vec3(x: 0, y: 0, z: 1), expected: LatLon(lat: 0, lon: 180)),
            FromVec3TestCase(input: Vec3(x: 0, y: 0, z: -1), expected: LatLon(lat: 0, lon: 0)),
            FromVec3TestCase(input: Vec3(x: 0, y: 1, z: 0), expected: LatLon(lat: 90, lon: 0)),
            FromVec3TestCase(input: Vec3(x: 0, y: -1, z: 0), expected: LatLon(lat: -90, lon: 0)),
            FromVec3TestCase(input: Vec3(x: 1, y: 0, z: 0), expected: LatLon(lat: 0, lon: 90)),
            FromVec3TestCase(input: Vec3(x: -1, y: 0, z: 0), expected: LatLon(lat: 0, lon: -90))
        ]
        
        for tc in testCases {
            let result = LatLon(sphereVec: tc.input) 
            #expect(result.isAlmostEqual(to: tc.expected, epsilon: 1e-9),
                "With \(tc.input), expected \(tc.expected) but got \(result)")
        }
    }
}
