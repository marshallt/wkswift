//
//  Grid_test.swift
//  wkswiftTests
//
//  Created by Marshall Thames on 4/29/25.
//

import Testing

@testable import wkswift

struct Grid_test {
    // Set up a shared grid for tests
    let resolution: Int
    let grid: Grid

    init() {
        resolution = 8
        grid = Grid(resolution: resolution)
    }
    
    @Test
    func testNewGrid() {
        let want = 486
        let got = grid.cubePoints.count
        #expect(got == want, "With Resolution \(resolution), wanted \(want) cube points but got \(got)")
    }

    @Test
    func testCellIndexFromCellCoord() {
        let cases: [(cc: CellCoord, want: Int)] = [
            (CellCoord(face: 0, u: 0, v: 1), 8),
            (CellCoord(face: 0, u: 1, v: 1), 9),
            (CellCoord(face: 0, u: 3, v: 3), 27),
            (CellCoord(face: 1, u: 0, v: 0), 64),
            (CellCoord(face: 1, u: 3, v: 0), 67),
            (CellCoord(face: 1, u: 0, v: 2), 80),
            (CellCoord(face: 2, u: 0, v: 3), 152),
            (CellCoord(face: 2, u: 0, v: 0), 128),
            (CellCoord(face: 2, u: 2, v: 3), 154),
        ]
        
        for (cc, want) in cases {
            let got = grid.cellCoordToCellIndex(cc)
            #expect(got == want, "With CellCoord \(cc), wanted \(want) but got \(got)")
        }
    }

    @Test
    func testGetCellCubePoints() {
        let cases: [(cc: CellCoord, want: [Vec3])] = [
            (CellCoord(face: 0, u: 0, v: 0), [
                Vec3(x: -1, y: 1, z: 1), Vec3(x: -1, y: 1, z: 0.75),
                Vec3(x: -1, y: 0.75, z: 0.75), Vec3(x: -1, y: 0.75, z: 1)
            ]),
            (CellCoord(face: 1, u: 0, v: 0), [
                Vec3(x: -1, y: 1, z: -1), Vec3(x: -0.75, y: 1, z: -1),
                Vec3(x: -0.75, y: 0.75, z: -1), Vec3(x: -1, y: 0.75, z: -1)
            ]),
            (CellCoord(face: 2, u: 0, v: 0), [
                Vec3(x: 1, y: 1, z: -1), Vec3(x: 1, y: 1, z: -0.75),
                Vec3(x: 1, y: 0.75, z: -0.75), Vec3(x: 1, y: 0.75, z: -1)
            ]),
            (CellCoord(face: 3, u: 0, v: 0), [
                Vec3(x: 1, y: 1, z: 1), Vec3(x: 0.75, y: 1, z: 1),
                Vec3(x: 0.75, y: 0.75, z: 1), Vec3(x: 1, y: 0.75, z: 1)
            ]),
            (CellCoord(face: 4, u: 0, v: 0), [
                Vec3(x: -1, y: 1, z: 1), Vec3(x: -0.75, y: 1, z: 1),
                Vec3(x: -0.75, y: 1, z: 0.75), Vec3(x: -1, y: 1, z: 0.75)
            ]),
            (CellCoord(face: 5, u: 0, v: 0), [
                Vec3(x: -1, y: -1, z: -1), Vec3(x: -0.75, y: -1, z: -1),
                Vec3(x: -0.75, y: -1, z: -0.75), Vec3(x: -1, y: -1, z: -0.75)
            ])
        ]
        
        for (cc, want) in cases {
            let got = grid.getCellCubeVecs(cc)
            for i in 0..<4 {
                #expect(got[i].isAlmostEqual(to: want[i], epsilon: 1e-9), "For cellCoord \(cc)\n    wanted \(want)\n    but got \(got)")
            }
        }
    }

    @Test
    func testSphereVecToCubeVec() {
        let cp = grid.cubeCenters[32]
        let sp = grid.cubeVecToSphereVec(cp)
        let got = grid.sphereVecToCubeVec(sp)
        #expect(got.isAlmostEqual(to: cp, epsilon: 1e-5), "Cube point \(cp) yielded sphere point \(sp) then cube point \(got)")
    }

    @Test
    func testCubeVecToCellCoord() {
        let cases: [(v: Vec3, want: CellCoord)] = [
            // face 0
            (Vec3(x: -1, y: 1, z: 1), CellCoord(face: 0, u: 0, v: 0)),
            (Vec3(x: -1, y: -1, z: -1), CellCoord(face: 0, u: 7, v: 7)),
            (Vec3(x: -1, y: 0.3, z: -0.73), CellCoord(face: 0, u: 6, v: 2)),
            // face 1
            (Vec3(x: -0.99, y: 0.99, z: -1), CellCoord(face: 1, u: 0, v: 0)),
            (Vec3(x: 0.99, y: -0.99, z: -1), CellCoord(face: 1, u: 7, v: 7)),
            (Vec3(x: 0.6, y: 0.3, z: -1), CellCoord(face: 1, u: 6, v: 2)),
            // face 2
            (Vec3(x: 1, y: 0.99, z: -0.99), CellCoord(face: 2, u: 0, v: 0)),
            (Vec3(x: 1, y: -0.99, z: 0.99), CellCoord(face: 2, u: 7, v: 7)),
            (Vec3(x: 1, y: 0.3, z: -0.76), CellCoord(face: 2, u: 0, v: 2)),
            // face 3
            (Vec3(x: 0.99, y: 0.99, z: 1), CellCoord(face: 3, u: 0, v: 0)),
            (Vec3(x: -0.99, y: -0.99, z: 1), CellCoord(face: 3, u: 7, v: 7)),
            (Vec3(x: -0.65, y: 0.3, z: 1), CellCoord(face: 3, u: 6, v: 2)),
            // face 4
            (Vec3(x: -0.99, y: 1, z: 0.99), CellCoord(face: 4, u: 0, v: 0)),
            (Vec3(x: 0.99, y: 1, z: -0.99), CellCoord(face: 4, u: 7, v: 7)),
            (Vec3(x: -0.65, y: 1, z: 0.3), CellCoord(face: 4, u: 1, v: 2)),
            // face 5
            (Vec3(x: -0.99, y: -1, z: -0.99), CellCoord(face: 5, u: 0, v: 0)),
            (Vec3(x: 0.99, y: -1, z: 0.99), CellCoord(face: 5, u: 7, v: 7)),
            (Vec3(x: -0.65, y: -1, z: 0.3), CellCoord(face: 5, u: 1, v: 5))
        ]
        
        for (v, want) in cases {
            let got = grid.cubeVecToCellCoord(v)
            #expect(got == want, "For point \(v)\n    wanted \(want)\n    but got \(got)")
        }
    }

    @Test
    func testSphereVecToCellCoord() {
        let cases: [(v: Vec3, want: CellCoord)] = [
            // face 0
            (Vec3(x: -1, y: 0.99, z: 0.99), CellCoord(face: 0, u: 0, v: 0)),
            (Vec3(x: -1, y: -0.99, z: -0.99), CellCoord(face: 0, u: 7, v: 7)),
            (Vec3(x: -1, y: 0.3, z: -0.73), CellCoord(face: 0, u: 6, v: 2)),
            // face 1
            (Vec3(x: -0.99, y: 0.99, z: -1), CellCoord(face: 1, u: 0, v: 0)),
            (Vec3(x: 0.99, y: -0.99, z: -1), CellCoord(face: 1, u: 7, v: 7)),
            (Vec3(x: 0.6, y: 0.3, z: -1), CellCoord(face: 1, u: 6, v: 2)),
            // face 2
            (Vec3(x: 1, y: 0.99, z: -0.99), CellCoord(face: 2, u: 0, v: 0)),
            (Vec3(x: 1, y: -0.99, z: 0.99), CellCoord(face: 2, u: 7, v: 7)),
            (Vec3(x: 1, y: 0.3, z: -0.76), CellCoord(face: 2, u: 0, v: 2)),
            // face 3
            (Vec3(x: 0.99, y: 0.99, z: 1), CellCoord(face: 3, u: 0, v: 0)),
            (Vec3(x: -0.99, y: -0.99, z: 1), CellCoord(face: 3, u: 7, v: 7)),
            (Vec3(x: -0.65, y: 0.3, z: 1), CellCoord(face: 3, u: 6, v: 2)),
            // face 4
            (Vec3(x: -0.99, y: 1, z: 0.99), CellCoord(face: 4, u: 0, v: 0)),
            (Vec3(x: 0.99, y: 1, z: -0.99), CellCoord(face: 4, u: 7, v: 7)),
            (Vec3(x: -0.65, y: 1, z: 0.3), CellCoord(face: 4, u: 1, v: 2)),
            // face 5
            (Vec3(x: -0.99, y: -1, z: -0.99), CellCoord(face: 5, u: 0, v: 0)),
            (Vec3(x: 0.99, y: -1, z: 0.99), CellCoord(face: 5, u: 7, v: 7)),
            (Vec3(x: -0.65, y: -1, z: 0.3), CellCoord(face: 5, u: 1, v: 5))
        ]
        
        for (v, want) in cases {
            let sv = grid.cubeVecToSphereVec(v)
            let got = grid.sphereVecToCellCoord(sv)
            #expect(got == want, "For point \(v)\n    wanted \(want)\n    but got \(got)")
        }
    }

    @Test
    func testGetNeighbor() {
        let cases: [(cc: CellCoord, d: Int, wantCC: CellCoord, wantOK: Bool)] = [
            (cc: CellCoord(face: 2, u: 7, v: 0), d: 1, wantCC: CellCoord(face: -1, u: -1, v: -1), wantOK: false),
            (cc: CellCoord(face: 0, u: 0, v: 0), d: 7, wantCC: CellCoord(face: -1, u: -1, v: -1), wantOK: false),
            (cc: CellCoord(face: 4, u: 7, v: 7), d: 3, wantCC: CellCoord(face: -1, u: -1, v: -1), wantOK: false),
            
            (cc: CellCoord(face: 0, u: 7, v: 3), d: 2, wantCC: CellCoord(face: 1, u: 0, v: 3), wantOK: true), // 0-right
            (cc: CellCoord(face: 0, u: 2, v: 7), d: 3, wantCC: CellCoord(face: 5, u: 0, v: 4), wantOK: true), // 0-down
            (cc: CellCoord(face: 0, u: 6, v: 0), d: 7, wantCC: CellCoord(face: 4, u: 0, v: 5), wantOK: true), // 0-up
            (cc: CellCoord(face: 0, u: 0, v: 5), d: 5, wantCC: CellCoord(face: 3, u: 7, v: 6), wantOK: true), // 0-left
            
            (cc: CellCoord(face: 2, u: 7, v: 5), d: 1, wantCC: CellCoord(face: 3, u: 0, v: 4), wantOK: true), // 2-right
            (cc: CellCoord(face: 2, u: 0, v: 5), d: 6, wantCC: CellCoord(face: 1, u: 7, v: 5), wantOK: true), // 2-left
            (cc: CellCoord(face: 2, u: 6, v: 7), d: 5, wantCC: CellCoord(face: 5, u: 7, v: 5), wantOK: true), // 2-down
            (cc: CellCoord(face: 2, u: 6, v: 0), d: 1, wantCC: CellCoord(face: 4, u: 7, v: 0), wantOK: true), // 2-up
            
            (cc: CellCoord(face: 3, u: 0, v: 5), d: 5, wantCC: CellCoord(face: 2, u: 7, v: 6), wantOK: true), // 3-left
            (cc: CellCoord(face: 3, u: 7, v: 5), d: 3, wantCC: CellCoord(face: 0, u: 0, v: 6), wantOK: true), // 3-right
            (cc: CellCoord(face: 3, u: 5, v: 0), d: 1, wantCC: CellCoord(face: 4, u: 1, v: 0), wantOK: true), // 3-up
            (cc: CellCoord(face: 3, u: 1, v: 7), d: 5, wantCC: CellCoord(face: 5, u: 7, v: 7), wantOK: true), // 3-down
            
            (cc: CellCoord(face: 4, u: 3, v: 0), d: 7, wantCC: CellCoord(face: 3, u: 5, v: 0), wantOK: true), // 4-up
            (cc: CellCoord(face: 4, u: 0, v: 5), d: 5, wantCC: CellCoord(face: 0, u: 6, v: 0), wantOK: true), // 4-left
            (cc: CellCoord(face: 4, u: 7, v: 2), d: 1, wantCC: CellCoord(face: 2, u: 5, v: 1), wantOK: true), // 4-right
            (cc: CellCoord(face: 4, u: 2, v: 7), d: 3, wantCC: CellCoord(face: 1, u: 3, v: 0), wantOK: true), // 4-down
            
            (cc: CellCoord(face: 0, u: 2, v: 0), d: 7, wantCC: CellCoord(face: 4, u: 0, v: 1), wantOK: true), // 0-up
            (cc: CellCoord(face: 0, u: 6, v: 0), d: 7, wantCC: CellCoord(face: 4, u: 0, v: 5), wantOK: true), // 0-up
            (cc: CellCoord(face: 0, u: 0, v: 5), d: 5, wantCC: CellCoord(face: 3, u: 7, v: 6), wantOK: true), // 0-left
            
            (cc: CellCoord(face: 1, u: 7, v: 3), d: 3, wantCC: CellCoord(face: 2, u: 0, v: 4), wantOK: true), // 1-right
            (cc: CellCoord(face: 1, u: 3, v: 0), d: 0, wantCC: CellCoord(face: 4, u: 3, v: 7), wantOK: true), // 1-up
            (cc: CellCoord(face: 1, u: 3, v: 3), d: 2, wantCC: CellCoord(face: 1, u: 4, v: 3), wantOK: true), // 1-on face
            (cc: CellCoord(face: 1, u: 0, v: 3), d: 6, wantCC: CellCoord(face: 0, u: 7, v: 3), wantOK: true)  // 1-left
        ]
        
        for (cc, d, wantCC, wantOK) in cases {
            
            if let gotCC = grid.getNeighbor(cc, direction: d) {
                #expect(gotCC == wantCC, "CellCoord \(cc) and Direction \(d) yielded neighbor of \(gotCC) rather than \(wantCC)")
            } else {
                #expect(wantOK == false, "CellCoord \(cc) and Direction \(d) yielded no neighbor but should have")

            }
        }
    }
}



