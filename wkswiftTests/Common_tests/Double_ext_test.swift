import Foundation
import Testing

struct FloatTestCase {
    let input: Double
    let expected: Double
}

struct AngleWrappingTests {
    func runTestCases(_ testCases: [FloatTestCase], function: (Double) -> Double, functionName: String) {
        for tc in testCases {
            let result = function(tc.input)
            #expect(result.isAlmostEqual(to: tc.expected, epsilon: 1e-9),
                    "With \(tc.input), expected \(tc.expected) but got \(result) for \(functionName)")
        }
    }
    
    @Test("Wrap90 functionality")
    func testWrap90() {
        let testCases: [FloatTestCase] = [
            FloatTestCase(input: 0, expected: 0),
            FloatTestCase(input: -90, expected: -90),
            FloatTestCase(input: 91, expected: 89),
            FloatTestCase(input: 180, expected: 0),
            FloatTestCase(input: -181, expected: 1),
            FloatTestCase(input: 270, expected: -90)
        ]
        
        runTestCases(testCases, function: { $0.wrap90() }, functionName: "wrap90")
    }
    
    @Test("Wrap180 functionality")
    func testWrap180() {
        let testCases: [FloatTestCase] = [
            FloatTestCase(input: 0, expected: 0),
            FloatTestCase(input: -180, expected: -180),
            FloatTestCase(input: 181, expected: -179),
            FloatTestCase(input: 360, expected: 0),
            FloatTestCase(input: -361, expected: -1),
            FloatTestCase(input: -270, expected: 90)
        ]
        
        runTestCases(testCases, function: { $0.wrap180() }, functionName: "wrap180")
    }
    
    @Test("Wrap360 functionality")
    func testWrap360() {
        let testCases: [FloatTestCase] = [
            FloatTestCase(input: 0, expected: 0),
            FloatTestCase(input: -180, expected: 180),
            FloatTestCase(input: 361, expected: 1),
            FloatTestCase(input: 360, expected: 0),
            FloatTestCase(input: -361, expected: 359),
            FloatTestCase(input: -270, expected: 90)
        ]
        
        runTestCases(testCases, function: { $0.wrap360() }, functionName: "wrap360")
    }
}
