//
//  GlobeView.swift
//  wkswift
//
//  Created by Marshall Thames on 5/7/25.
//

import SwiftUI
import SceneKit


struct GlobeView: NSViewRepresentable {
    let grid: Grid
    
    func makeNSView(context: Context) -> SCNView {
        let scene = SCNScene()
        let sphere = SCNSphere(radius: 1.0)
        sphere.segmentCount = 64

        // Generate texture
        let texture = GridPlotter(grid: grid, width: 2048, height: 1024).render()
        let material = SCNMaterial()
        material.diffuse.contents = texture
        sphere.firstMaterial = material

        let node = SCNNode(geometry: sphere)
        scene.rootNode.addChildNode(node)

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 3)
        scene.rootNode.addChildNode(cameraNode)

        let view = ZoomableSCNView()
        view.scene = scene
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        return view
    }

    func updateNSView(_ nsView: SCNView, context: Context) {}
}

class ZoomableSCNView: SCNView {
    override func scrollWheel(with event: NSEvent) {
        guard let cameraNode = pointOfView else { return }
        
        let zDistance = cameraNode.position.z
        var zoomAmount = event.deltaY * 0.1   // Invert if direction feels wrong

        // Move camera forward/backward along its local z-axis
        let moveVector = SCNVector3(0, 0, zoomAmount)
        let transformed = cameraNode.presentation.convertVector(moveVector, to: nil)
        let oldZ = cameraNode.position.z
        cameraNode.position += transformed
        if cameraNode.position.z <= 1 {
            cameraNode.position.z = ((oldZ - 1) / 2) + 1
        }
        
    }

}

func +=(lhs: inout SCNVector3, rhs: SCNVector3) {
    lhs = SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
}

