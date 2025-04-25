//
//  CellCoord_test.swift
//  wkswiftTests
//
//  Created by Marshall Thames on 4/25/25.
//

import Foundation

import Testing
@testable import wkswift

struct CellCoord_test {
    var ccs = CellCoordSet()
    
    @Test("CellCoordSet.Add functionality")
    mutating func testCellCoordSet_Add() {
        ccs.add(CellCoord(face: 1, u: 1, v: 1))
        ccs.add(CellCoord(face: 1, u: 2, v: 1))
        ccs.add(CellCoord(face: 1, u: 3, v: 1))
        ccs.add(CellCoord(face: 1, u: 4, v: 1))
        ccs.add(CellCoord(face: 2, u: 1, v: 1))
        ccs.add(CellCoord(face: 2, u: 2, v: 1))

        #expect(ccs.count == 6, "Count should be 6 but got \(ccs.count)")
    }
    
    @Test("CellCoordSet.Delete functionality")
    mutating func testCellCoordSet_Delete() {
        
        ccs.add(CellCoord(face: 1, u: 1, v: 1))
        ccs.add(CellCoord(face: 1, u: 2, v: 1))
        ccs.add(CellCoord(face: 1, u: 3, v: 1))
        ccs.add(CellCoord(face: 1, u: 4, v: 1))
        ccs.add(CellCoord(face: 2, u: 1, v: 1))
        ccs.add(CellCoord(face: 2, u: 2, v: 1))
        
        ccs.delete(CellCoord(face: 1, u: 1, v: 1))
        ccs.delete(CellCoord(face: 1, u: 2, v: 1))
        ccs.delete(CellCoord(face: 2, u: 1, v: 1))
        ccs.delete(CellCoord(face: 2, u: 2, v: 1))

        #expect(ccs.count == 2, "Count should be 2 but got \(ccs.count)")
    }

}
