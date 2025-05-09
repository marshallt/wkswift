//
//  GridPlotter.swift
//  wkswift
//
//  Created by Marshall Thames on 5/7/25.
//

import Foundation
import SwiftUI


struct GridPlotter {
    let grid: Grid
    let width: Int
    let height: Int
    var context: CGContext
    
    init(grid: Grid, width: Int, height: Int) {
        self.grid = grid
        self.width = width
        self.height = height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        self.context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
    }
    
        
    func render() -> NSImage? {
                
        // Background
        context.setFillColor(NSColor.systemBlue.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        
//        context.setFillColor(NSColor.green.cgColor)
//        let point = project(latLon: .init(lat: 0, lon: 0))
//        context.fill(CGRect(x: Double(point.x - 20), y: Double(point.y - 20), width: 40, height: 40))
        
        drawCell(cellCoord: .init(face: 0, u: 5, v: 5), fillColor: .yellow)
        drawCell(cellCoord: .init(face: 1, u: 0, v: 0))
        drawCell(cellCoord: .init(face: 2, u: 15, v: 15))
        drawCell(cellCoord: .init(face: 4, u: 7, v: 7))

        let cgImage = context.makeImage()!
        return NSImage(cgImage: cgImage, size: NSSize(width: width, height: height))
    }
    
    func project(latLon: LatLon) -> CGPoint {
        return CGPoint(
            x: CGFloat(width) * CGFloat(latLon.lon + 180) / 360,
            y: CGFloat(height) * CGFloat(90 - latLon.lat) / 180
        )
    }
    
    func reverseProject(point: CGPoint) -> LatLon {
        return LatLon(
            lat: 90 - Double(point.y) * 180 / Double(height),
            lon: Double(point.x) * 360 / Double(width) - 180
        )
    }
    
    func drawCell(cellCoord: CellCoord, strokeColor: NSColor = .yellow, fillColor: NSColor = .white) {
        let points = grid.getCellSphereVecs(cellCoord)
        drawPolygon(points, strokeColor: strokeColor, fillColor: fillColor)
    }
    
    func drawPolygon(_ points: [Vec3], strokeColor: NSColor = .yellow, fillColor: NSColor = .white) {
        guard points.count > 2 else { fatalError("\(#function) expects at least 3 points") }
        
        let screenPoints = points.map { vec -> CGPoint in
            let latLon = vec.toLatLon()
            return project(latLon: latLon)
        }
        
        let path = CGMutablePath()
        
        path.move(to: screenPoints[0])
        for point in screenPoints[1...] {
            path.addLine(to: point)
        }
        
        path.closeSubpath()
            
        context.saveGState()
        context.addPath(path)
        context.setFillColor(fillColor.cgColor)
        context.setStrokeColor(strokeColor.cgColor)
        context.fillPath()
        context.strokePath()
        context.restoreGState()
    }
}
