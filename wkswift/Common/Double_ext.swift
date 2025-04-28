//
//  Double_ext.swift
//  wkswift
//
//  Created by Marshall Thames on 4/25/25.
//

import Foundation

extension Double {
    public func isAlmostEqual(to other: Double, epsilon: Double = 1e-8) -> Bool {
            return abs(self - other) < epsilon
        }
    
    // Wrap90 returns a value between (-90, 90], wrapping from positive to negative and vice versa
    public func wrap90() -> Double {
        if self >= -90 && self <= 90 {
            return self
        }
        let x = self
        let a = 90.0
        let p = 360.0
        return 4 * a / p * abs(((x - p / 4).truncatingRemainder(dividingBy: p) + p).truncatingRemainder(dividingBy: p) - p / 2) - a
    }
    
    // Wrap180 returns a value between (-180, 180]
    public func wrap180() -> Double {
        if self > -180 && self <= 180 {
            return self
        }
        let x = self
        let a = 180.0
        let p = 360.0
        return ((2 * a * x / p - p / 2).truncatingRemainder(dividingBy: p) + p).truncatingRemainder(dividingBy: p) - a
    }
    
    // Wrap360 returns a value between [0, 360)
    public func wrap360() -> Double {
        if 0 <= self && self < 360 {
            return self
        }
        let x = self
        let a = 180.0
        let p = 360.0
        return ((2 * a * x / p).truncatingRemainder(dividingBy: p) + p).truncatingRemainder(dividingBy: p)
    }
    
}
