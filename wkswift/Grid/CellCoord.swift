//
//  CellCoord.swift
//  wkswift
//
//  Created by Marshall Thames on 4/25/25.
//

public struct CellCoord: CustomStringConvertible, Hashable {
    public let face: Int
    public let u: Int
    public let v: Int
    
    public var description: String {
        "(\(face) / \(u), \(v))"
    }
}

public struct CellCoordSet: CustomStringConvertible {
    private var m: [CellCoord: Int]
    private var s: [CellCoord]
    
    init() {
        m = [CellCoord: Int]()
        s = [CellCoord]()
    }
    
    public mutating func clear() {
        m = [CellCoord: Int]()
        s = [CellCoord]()
    }
    
    private mutating func addElement(_ c: CellCoord) {
        if m[c] != nil {
            return
        }
        s.append(c)
        m[c] = s.count - 1
        checkLength()
    }
    
    public mutating func add(_ cc: CellCoord...) {
        for c in cc {
            addElement(c)
        }
    }
    
    public func contains(_ cc: CellCoord) -> Bool {
        return m[cc] != nil
    }
    
    public mutating func delete(_ c: CellCoord) {
        if let i = m[c] {
            if i != s.count - 1 { // if i is NOT the last element
                // swap i for last element
                let lastCellCoord = s[s.count - 1]
                s[s.count - 1] = s[i]
                s[i] = lastCellCoord
                m[lastCellCoord] = i
            }
            s.removeLast()
            m.removeValue(forKey: c)
        }
        checkLength()
    }
    
    var count: Int {
        return m.count
    }
    
    public func get(_ i: Int) -> CellCoord {
        return s[i]
    }
    
    public func random() -> CellCoord {
        let i = Int.random(in:0..<m.count)
        return s[i]
    }
    
    public mutating func popRandom() -> CellCoord {
        if count == 0 {
            fatalError("Cannot popRandom from empty CellCoordSet")
        }
        let cc = random()
        delete(cc)
        return cc
    }
    
    public var description: String {
        var result = "Map\n------------------\n"
        for (cc, i) in m {
            result += "\(cc) = \(i)\n"
        }
        result += "\n"
        result += "Slice\n----------------\n"
        for (i, cc) in s.enumerated() {
            result += "[\(i)] : \(cc)\n"
        }
        return result
    }
    
    private func checkLength() {
        if s.count != m.count {
            fatalError("CellCoordSet checkLength() failed. m count = \(m.count). s count = \(s.count)")
        }
    }
}
