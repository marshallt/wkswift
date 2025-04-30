//
//  Grid.swift
//  wkswift
//
//  Created by Marshall Thames on 4/25/25.
//

import Foundation


// Grid struct to manage the cubic grid
public struct Grid: Sendable {
    public let resolution: Int
    public let spacing: Double
    public let cellsPerFace: Int
    public let pointsPerFace: Int
    public let numPoints: Int
    public let numCells: Int
    
    public private(set) var cellCoords: [CellCoord]
    public private(set) var cubePoints: [Vec3]
    public private(set) var cubeCenters: [Vec3]
    public private(set) var spherePoints: [Vec3]
    public private(set) var sphereCenters: [Vec3]
    public private(set) var sphericalPoints: [LatLon]
    public private(set) var sphericalCenters: [LatLon]
    
    public init(resolution: Int) {
        guard resolution % 2 == 0 else {
            fatalError("Resolution must be an even number")
        }
        
        self.resolution = resolution
        self.spacing = 2.0 / Double(resolution)
        self.cellsPerFace = resolution * resolution
        self.pointsPerFace = (resolution + 1) * (resolution + 1)
        self.numPoints = pointsPerFace * 6
        self.numCells = resolution * resolution * 6
        
        self.cellCoords = [CellCoord](repeating: CellCoord(face: 0, u: 0, v: 0), count: numCells)
        self.cubePoints = [Vec3](repeating: Vec3(x: 0, y: 0, z: 0), count: numPoints)
        self.cubeCenters = [Vec3](repeating: Vec3(x: 0, y: 0, z: 0), count: numCells)
        self.spherePoints = [Vec3](repeating: Vec3(x: 0, y: 0, z: 0), count: numPoints)
        self.sphereCenters = [Vec3](repeating: Vec3(x: 0, y: 0, z: 0), count: numCells)
        self.sphericalPoints = [LatLon](repeating: LatLon(lat: 0, lon: 0), count: numPoints)
        self.sphericalCenters = [LatLon](repeating: LatLon(lat: 0, lon: 0), count: numCells)
        
        populateCellCoords()
        buildFace0()
        buildOtherFaces()
        populateSphereVecs()
        populateCubeCenters()
        populateSphereCenters()
    }
    
    private mutating func populateCellCoords() {
        var i = 0
        for face in 0..<6 {
            for v in 0..<resolution {
                for u in 0..<resolution {
                    cellCoords[i] = CellCoord(face: face, u: u, v: v)
                    i += 1
                }
            }
        }
    }
    
    private mutating func buildFace0() {
        let initialZ = 1.0
        var currZ = 1.0
        var currY = 1.0
        let xPlane = -1.0
        var i = 0
        
        for y in 0...resolution {
            currZ = initialZ
            for _ in 0...resolution {
                cubePoints[i] = Vec3(x: xPlane, y: currY, z: currZ)
                i += 1
                currZ -= spacing
            }
            currY -= spacing
        }
    }
    
    private mutating func buildOtherFaces() {
        let edge = 1.0
        let frontIndex = pointsPerFace * 1
        let rightIndex = pointsPerFace * 2
        let backIndex = pointsPerFace * 3
        let topIndex = pointsPerFace * 4
        let bottomIndex = pointsPerFace * 5
        
        for i in 0..<pointsPerFace {
            let p = cubePoints[i]
            
            // Face 1
            cubePoints[frontIndex + i] = Vec3(x: -p.z, y: p.y, z: -edge)
            
            // Face 2
            cubePoints[rightIndex + i] = Vec3(x: edge, y: p.y, z: -p.z)
            
            // Face 3
            cubePoints[backIndex + i] = Vec3(x: p.z, y: p.y, z: edge)
            
            // Face 4
            cubePoints[topIndex + i] = Vec3(x: -p.z, y: edge, z: p.y)
            
            // Face 5
            cubePoints[bottomIndex + i] = Vec3(x: -p.z, y: -edge, z: -p.y)
        }
    }
    
    private mutating func populateCubeCenters() {
        var i = 0
        for face in 0..<6 {
            for v in 0..<resolution {
                for u in 0..<resolution {
                    let p = getCellCubeVecs(CellCoord(face: face, u: u, v: v))
                    let m = p[0].midpoint(with: p[2])
                    cubeCenters[i] = m
                    i += 1
                }
            }
        }
    }
    
    private mutating func populateSphereCenters() {
        for i in 0..<numCells {
            sphereCenters[i] = cubeVecToSphereVec(cubeCenters[i])
            sphericalCenters[i] = LatLon(sphereVec: sphereCenters[i])
        }
    }
    
    private mutating func populateSphereVecs() {
        for i in 0..<numPoints {
            spherePoints[i] = cubeVecToSphereVec(cubePoints[i])
            sphericalPoints[i] = LatLon(sphereVec: spherePoints[i])
        }
    }
    
    public func getCellCubeVecs(_ cellCoord: CellCoord) -> [Vec3] {
        let i = cellCoord.face * pointsPerFace + (cellCoord.v * (resolution + 1)) + cellCoord.u
        return [
            cubePoints[i],
            cubePoints[i + 1],
            cubePoints[i + resolution + 2],
            cubePoints[i + resolution + 1]
        ]
    }
    
    public func getCellSphereVecs(_ cellCoord: CellCoord) -> [Vec3] {
        let i = cellCoord.face * pointsPerFace + (cellCoord.v * (resolution + 1)) + cellCoord.u
        return [
            spherePoints[i],
            spherePoints[i + 1],
            spherePoints[i + resolution + 2],
            spherePoints[i + resolution + 1]
        ]
    }
    
    public func cubeVecToSphereVec(_ p: Vec3) -> Vec3 {
        // From http://mathproofs.blogspot.com/2005/07/mapping-cube-to-sphere.html
        let result = Vec3(
            x: p.x * sqrt(1 - (p.y * p.y) / 2 - (p.z * p.z) / 2 + (p.y * p.y * p.z * p.z) / 3),
            y: p.y * sqrt(1 - (p.z * p.z) / 2 - (p.x * p.x) / 2 + (p.z * p.z * p.x * p.x) / 3),
            z: p.z * sqrt(1 - (p.x * p.x) / 2 - (p.y * p.y) / 2 + (p.x * p.x * p.y * p.y) / 3)
        )
        
        guard !result.x.isNaN && !result.y.isNaN && !result.z.isNaN else {
            fatalError("Point \(p) yielded \(result)")
        }
        
        return result.normalize()
    }
    
    // SphereVecToCubeVec
    // http://petrocket.blogspot.com/2010/04/sphere-to-cube-mapping.html
    // Returns the point on the Unit Cube from a point on the Unit Sphere
    public func sphereVecToCubeVec(_ s: Vec3) -> Vec3 {
        let x = s.x
        let y = s.y
        let z = s.z
        
        let fx = abs(x)
        let fy = abs(y)
        let fz = abs(z)
        
        var resX = 0.0
        var resY = 0.0
        var resZ = 0.0
        
        let inverseSqrt2 = 0.70710676908493042
        
        if fy >= fx && fy >= fz { // ON Y FACE - top or bottom
            let a2 = x * x * 2.0
            let b2 = z * z * 2.0
            let inner = -a2 + b2 - 3
            let innersqrt = -sqrt((inner * inner) - 12.0 * a2)
            
            if x == -0.0 {
                resX = 0.0
            } else {
                resX = sqrt(innersqrt + a2 - b2 + 3.0) * inverseSqrt2
            }
            
            if z == -0.0 {
                resZ = 0.0
            } else {
                resZ = sqrt(innersqrt - a2 + b2 + 3.0) * inverseSqrt2
            }
            
            if x > 1.0 {
                resX = 1.0
            }
            
            if z > 1.0 {
                resZ = 1.0
            }
            
            if x < 0 {
                resX = -resX
            }
            
            if z < 0 {
                resZ = -resZ
            }
            
            if y > 0 {
                // Top face
                resY = 1.0
            } else {
                // Bottom face
                resY = -1.0
            }
        } else if fx >= fy && fx >= fz { // ON X FACE
            let a2 = y * y * 2.0
            let b2 = z * z * 2.0
            let inner = -a2 + b2 - 3
            let innersqrt = -sqrt((inner * inner) - 12.0 * a2)
            
            if y == -0.0 {
                resY = 0.0
            } else {
                resY = sqrt(innersqrt + a2 - b2 + 3.0) * inverseSqrt2
            }
            
            if z == -0.0 {
                resZ = 0.0
            } else {
                resZ = sqrt(innersqrt - a2 + b2 + 3.0) * inverseSqrt2
            }
            
            if y > 1.0 {
                resY = 1.0
            }
            if z > 1.0 {
                resZ = 1.0
            }
            
            if y < 0 {
                resY = -resY
            }
            if z < 0 {
                resZ = -resZ
            }
            
            if x > 0 {
                // Right face
                resX = 1.0
            } else {
                // Left face
                resX = -1.0
            }
        } else { // Z FACE
            let a2 = x * x * 2.0
            let b2 = y * y * 2.0
            let inner = -a2 + b2 - 3
            let innersqrt = -sqrt((inner * inner) - 12.0 * a2)
            
            if x == -0.0 {
                resX = 0.0
            } else {
                resX = sqrt(innersqrt + a2 - b2 + 3.0) * inverseSqrt2
            }
            
            if y == -0.0 {
                resY = 0.0
            } else {
                resY = sqrt(innersqrt - a2 + b2 + 3.0) * inverseSqrt2
            }
            
            if x > 1.0 {
                resX = 1.0
            }
            if y > 1.0 {
                resY = 1.0
            }
            
            if x < 0 {
                resX = -resX
            }
            if y < 0 {
                resY = -resY
            }
            
            if z > 0 {
                // Back face - these are reversed from StackOverflow solution because z is inverted in javafx
                resZ = 1.0
            } else {
                // Front face
                resZ = -1.0
            }
        }
        
        return Vec3(x: resX, y: resY, z: resZ)
    }
    
    public func cellIndexToCellCoord(_ i: Int) -> CellCoord {
        let face = i / cellsPerFace
        var j = i - face * cellsPerFace
        let v = j / resolution
        j -= v * resolution
        let u = j
        return CellCoord(face: face, u: u, v: v)
    }
    
    public func cellCoordToCellIndex(_ c: CellCoord) -> Int {
        return c.face * resolution * resolution + c.v * resolution + c.u
    }
    
    public func cellCoordToCubeCenterVec(_ cc: CellCoord) -> Vec3 {
        let i = cellCoordToCellIndex(cc)
        return cubeCenters[i]
    }
    
    public func cellCoordToCenterLatLon(_ cc: CellCoord) -> LatLon {
        let i = cellCoordToCellIndex(cc)
        return sphericalCenters[i]
    }
    
    public func cellCoordToSphereCenterVec(_ cc: CellCoord) -> Vec3 {
        let i = cellCoordToCellIndex(cc)
        return sphereCenters[i]
    }
    
    public func cubeVecToCellCoord(_ c: Vec3) -> CellCoord {
        let fx = abs(c.x)
        let fy = abs(c.y)
        let fz = abs(c.z)
        var face = 0
        var u = 0
        var v = 0
        
        if fx >= fy && fx >= fz { // X face (0 or 2)
            if c.x < 0 { // Face 0
                face = 0
                (u, v) = getUV(-c.z, -c.y)
            } else { // Face 2
                face = 2
                (u, v) = getUV(c.z, -c.y)
            }
        } else if fz > fx && fz > fy { // Z face (1 or 3)
            if c.z < 0 { // Face 1
                face = 1
                (u, v) = getUV(c.x, -c.y)
            } else { // Face 3
                face = 3
                (u, v) = getUV(-c.x, -c.y)
            }
        } else { // Y face
            if c.y < 0 { // Face 5
                face = 5
                (u, v) = getUV(c.x, c.z)
            } else { // Face 4
                face = 4
                (u, v) = getUV(c.x, -c.z)
            }
        }
        
        return CellCoord(face: face, u: u, v: v)
    }
    
    // GetUV returns the points u, v of the Cell on the 2D plane of a cube face
    public func getUV(_ s: Double, _ t: Double) -> (Int, Int) {
        var u = Int((s + 1) / spacing)
        if u >= resolution {
            u = resolution - 1
        }
        
        var v = Int((t + 1) / spacing)
        if v >= resolution {
            v = resolution - 1
        }
        
        return (u, v)
    }
    
    public func sphereVecToCellCoord(_ sv: Vec3) -> CellCoord {
        let cv = sphereVecToCubeVec(sv)
        return cubeVecToCellCoord(cv)
    }
    
    public func latLonToCellCoord(_ ll: LatLon) -> CellCoord {
        let sv = Vec3.newSphereVecFromLatLon(ll)
        let cv = sphereVecToCubeVec(sv)
        return cubeVecToCellCoord(cv)
    }
    
    public func latLonToCellIndex(_ ll: LatLon) -> Int {
        let cc = latLonToCellCoord(ll)
        return cellCoordToCellIndex(cc)
    }
    
    public func getNeighborCellCoords(_ cc: CellCoord) -> [CellCoord] {
        var res = [CellCoord]()
        res.reserveCapacity(8)
        
        for i in 0..<8 { // For each direction
            if let neighbor = getNeighbor(cc, direction: i) {
                res.append(neighbor)
            }
        }
        
        return res
    }
    
    public func getNeighbor(_ cc: CellCoord, direction: Int) -> CellCoord? {
        let offset = Direction[direction]
        let newU = cc.u + offset.u
        let newV = cc.v + offset.v
        let onU = newU >= 0 && newU < resolution
        let onV = newV >= 0 && newV < resolution
        
        if onU && onV { // If both are on, it's easy
            return CellCoord(face: cc.face, u: newU, v: newV)
        }
        
        if !onU && !onV { // If both are off, return nil
            return nil
        }
        
        var newFace = cc.face
        var adjustedU = newU
        var adjustedV = newV
        
        if !onU {
            if cc.u == 0 { // Off left
                switch cc.face {
                case 0:
                    newFace = 3
                    adjustedU = resolution - 1
                case 1, 2, 3:
                    newFace = cc.face - 1
                    adjustedU = resolution - 1
                case 4:
                    newFace = 0
                    adjustedU = newV
                    adjustedV = 0
                case 5:
                    newFace = 0
                    adjustedU = resolution - cc.v - 1
                    // adjustedV remains newV
                default:
                    return nil
                }
            } else { // Off right
                switch cc.face {
                case 3:
                    newFace = 0
                    adjustedU = 0
                case 0, 1, 2:
                    newFace = cc.face + 1
                    adjustedU = 0
                case 4:
                    newFace = 2
                    adjustedU = resolution - cc.v - 1
                    // adjustedV remains newV
                case 5:
                    newFace = 2
                    adjustedU = cc.v
                    // adjustedV remains newV
                default:
                    return nil
                }
            }
        } else { // Otherwise, newV must be off
            if cc.v == 0 { // Off up
                switch cc.face {
                case 0:
                    newFace = 4
                    adjustedV = newU
                    adjustedU = 0
                case 1:
                    newFace = 4
                    adjustedV = resolution - 1
                    // adjustedU remains newU
                case 2:
                    newFace = 4
                    adjustedV = resolution - newU - 1
                    // adjustedU remains newU
                case 3:
                    newFace = 4
                    adjustedU = resolution - newU - 1
                    adjustedV = 0
                case 4:
                    newFace = 3
                    adjustedU = resolution - newU - 1
                    adjustedV = 0
                case 5:
                    newFace = 1
                    adjustedV = resolution - 1
                    // adjustedU remains newU
                default:
                    return nil
                }
            } else { // Off down
                switch cc.face {
                case 0:
                    newFace = 5
                    adjustedV = resolution - newU - 1
                    adjustedU = 0
                case 1:
                    newFace = 5
                    adjustedV = 0
                    // adjustedU remains newU
                case 2:
                    newFace = 5
                    adjustedV = newU
                    adjustedU = resolution - 1
                case 3:
                    newFace = 5
                    adjustedU = resolution - newU - 1
                    adjustedV = resolution - 1
                case 4:
                    newFace = 1
                    adjustedV = 0
                case 5:
                    newFace = 3
                    adjustedU = resolution - newU - 1
                    adjustedV = resolution - 1
                default:
                    return nil
                }
            }
        }
        
        return CellCoord(face: newFace, u: adjustedU, v: adjustedV)
    }
    
    public func getNeighborCellIndexes(_ cc: CellCoord) -> [Int] {
        let neighbors = getNeighborCellCoords(cc)
        return neighbors.map { cellCoordToCellIndex($0) }
    }
    
    public func description() -> String {
        var result = ""
        var i = 0
        
        for face in 0..<6 {
            for v in 0...resolution {
                result += "{\(face) / _, \(v): "
                for u in 0...resolution {
                    result += "\(cubePoints[i]) "
                    i += 1
                }
                result += "\n"
            }
        }
        
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("grid.txt")
            do {
                try result.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                print("Failed to write grid to file: \(error)")
            }
        }
        
        return result
    }
}


