//
//  ARFaceMeshBuilder.swift
//  IOS_Student_Haven
//
//  Generates 3D face mesh from Vision facial landmarks using ARKit geometry
//

import Foundation
import SceneKit
import ARKit
import Vision

@available(iOS 17.0, *)
class ARFaceMeshBuilder {
    
    static let shared = ARFaceMeshBuilder()
    
    private init() {}
    
    // MARK: - Mesh Generation
    
    /// Build 3D face mesh from facial landmarks
    func buildFaceMesh(from analysis: FaceAnalysis, skinTone: SkinTone) -> SCNNode {
        let faceNode = SCNNode()
        faceNode.name = "ar_face"
        
        // Create base face geometry using ARFaceGeometry
        let faceGeometry = ARSCNFaceGeometry(device: MTLCreateSystemDefaultDevice()!)
        
        // Convert to SCNGeometry for customization
        guard let scnGeometry = createFaceGeometry(from: analysis, skinTone: skinTone) else {
            // Fallback to landmark-based mesh
            return createLandmarkBasedMesh(from: analysis, skinTone: skinTone)
        }
        
        let meshNode = SCNNode(geometry: scnGeometry)
        faceNode.addChildNode(meshNode)
        
        // Add eyes
        let leftEye = buildEye(landmarks: analysis.landmarks.leftEye, pupil: analysis.landmarks.leftPupil)
        leftEye.position = calculateEyePosition(eyeLandmarks: analysis.landmarks.leftEye, isLeft: true)
        faceNode.addChildNode(leftEye)
        
        let rightEye = buildEye(landmarks: analysis.landmarks.rightEye, pupil: analysis.landmarks.rightPupil)
        rightEye.position = calculateEyePosition(eyeLandmarks: analysis.landmarks.rightEye, isLeft: false)
        faceNode.addChildNode(rightEye)
        
        // Add eyebrows
        let leftBrow = buildEyebrow(landmarks: analysis.landmarks.leftEyebrow)
        faceNode.addChildNode(leftBrow)
        
        let rightBrow = buildEyebrow(landmarks: analysis.landmarks.rightEyebrow)
        faceNode.addChildNode(rightBrow)
        
        // Add nose
        let nose = buildNose(landmarks: analysis.landmarks.nose, crest: analysis.landmarks.noseCrest)
        faceNode.addChildNode(nose)
        
        // Add mouth
        let mouth = buildMouth(outer: analysis.landmarks.outerLips, inner: analysis.landmarks.innerLips)
        faceNode.addChildNode(mouth)
        
        // Scale to reasonable size
        let scale: Float = 0.01  // Convert from image coordinates to scene units
        faceNode.scale = SCNVector3(scale, scale, scale)
        
        return faceNode
    }
    
    // MARK: - Face Geometry
    
    private func createFaceGeometry(from analysis: FaceAnalysis, skinTone: SkinTone) -> SCNGeometry? {
        // Create smooth face mesh from contour points
        let contour = analysis.landmarks.faceContour
        guard contour.count >= 3 else { return nil }
        
        var vertices: [SCNVector3] = []
        var indices: [Int32] = []
        var normals: [SCNVector3] = []
        var texCoords: [CGPoint] = []
        
        // Create vertices from face contour with depth
        let centerX = analysis.faceWidth / 2
        let centerY = analysis.faceHeight / 2
        
        for (index, point) in contour.enumerated() {
            let x = Float(point.x - CGFloat(centerX))
            let y = Float(point.y - CGFloat(centerY))
            
            // Calculate Z depth based on distance from center (simulate face curvature)
            let distanceFromCenter = sqrt(pow(x, 2) + pow(y, 2))
            let maxDistance = Float(analysis.faceWidth / 2)
            let normalizedDistance = min(distanceFromCenter / maxDistance, 1.0)
            let z = (1.0 - pow(normalizedDistance, 2)) * 30.0  // Parabolic depth
            
            vertices.append(SCNVector3(x, y, z))
            
            // Calculate normal (pointing forward with slight curve)
            let normal = SCNVector3(
                x / maxDistance * 0.3,
                y / maxDistance * 0.3,
                1.0
            )
            normals.append(normalize(normal))
            
            // Texture coordinates
            texCoords.append(CGPoint(
                x: Double(point.x) / Double(analysis.faceWidth),
                y: Double(point.y) / Double(analysis.faceHeight)
            ))
        }
        
        // Create triangles using fan triangulation from center
        let centerVertex = SCNVector3(0, 0, 35)  // Center point slightly forward
        vertices.append(centerVertex)
        normals.append(SCNVector3(0, 0, 1))
        texCoords.append(CGPoint(x: 0.5, y: 0.5))
        let centerIndex = Int32(vertices.count - 1)
        
        for i in 0..<contour.count {
            let next = (i + 1) % contour.count
            indices.append(Int32(i))
            indices.append(Int32(next))
            indices.append(centerIndex)
        }
        
        // Create geometry sources
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let normalSource = SCNGeometrySource(normals: normals)
        let texCoordSource = SCNGeometrySource(textureCoordinates: texCoords)
        
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        
        let geometry = SCNGeometry(sources: [vertexSource, normalSource, texCoordSource], elements: [element])
        
        // Apply skin material
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(skinTone.color)
        material.lightingModel = .physicallyBased
        material.roughness.contents = 0.7
        material.metalness.contents = 0.0
        geometry.materials = [material]
        
        return geometry
    }
    
    private func createLandmarkBasedMesh(from analysis: FaceAnalysis, skinTone: SkinTone) -> SCNNode {
        // Fallback: create mesh from landmarks
        let node = SCNNode()
        
        // Create face plane with skin texture
        let faceWidth = CGFloat(analysis.faceWidth) * 0.01
        let faceHeight = CGFloat(analysis.faceHeight) * 0.01
        
        let faceGeometry = SCNPlane(width: faceWidth, height: faceHeight)
        faceGeometry.cornerRadius = faceWidth * 0.3
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(skinTone.color)
        material.lightingModel = .physicallyBased
        material.roughness.contents = 0.7
        faceGeometry.materials = [material]
        
        let faceNode = SCNNode(geometry: faceGeometry)
        node.addChildNode(faceNode)
        
        return node
    }
    
    // MARK: - Facial Features
    
    private func buildEye(landmarks: [CGPoint], pupil: [CGPoint]) -> SCNNode {
        let eyeNode = SCNNode()
        
        // Eyeball
        let eyeballGeometry = SCNSphere(radius: 0.15)
        eyeballGeometry.segmentCount = 32
        let eyeballMaterial = SCNMaterial()
        eyeballMaterial.diffuse.contents = UIColor.white
        eyeballMaterial.lightingModel = .physicallyBased
        eyeballMaterial.specular.contents = UIColor.white.withAlphaComponent(0.5)
        eyeballGeometry.materials = [eyeballMaterial]
        
        let eyeballNode = SCNNode(geometry: eyeballGeometry)
        eyeNode.addChildNode(eyeballNode)
        
        // Iris
        let irisGeometry = SCNCylinder(radius: 0.10, height: 0.02)
        irisGeometry.radialSegmentCount = 32
        let irisMaterial = SCNMaterial()
        irisMaterial.diffuse.contents = UIColor.systemBlue
        irisMaterial.lightingModel = .physicallyBased
        irisGeometry.materials = [irisMaterial]
        
        let irisNode = SCNNode(geometry: irisGeometry)
        irisNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        irisNode.position = SCNVector3(0, 0, 0.15)
        eyeNode.addChildNode(irisNode)
        
        // Pupil
        let pupilGeometry = SCNCylinder(radius: 0.04, height: 0.03)
        pupilGeometry.radialSegmentCount = 24
        let pupilMaterial = SCNMaterial()
        pupilMaterial.diffuse.contents = UIColor.black
        pupilMaterial.lightingModel = .physicallyBased
        pupilGeometry.materials = [pupilMaterial]
        
        let pupilNode = SCNNode(geometry: pupilGeometry)
        pupilNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        pupilNode.position = SCNVector3(0, 0, 0.16)
        eyeNode.addChildNode(pupilNode)
        
        return eyeNode
    }
    
    private func buildEyebrow(landmarks: [CGPoint]) -> SCNNode {
        let browNode = SCNNode()
        
        guard landmarks.count >= 2 else { return browNode }
        
        // Create curve from landmarks
        let browGeometry = SCNBox(width: 0.6, height: 0.12, length: 0.15, chamferRadius: 0.06)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.darkGray
        material.lightingModel = .physicallyBased
        browGeometry.materials = [material]
        
        let browShape = SCNNode(geometry: browGeometry)
        
        // Position at average of landmarks
        let avgX = landmarks.reduce(0.0) { $0 + $1.x } / CGFloat(landmarks.count)
        let avgY = landmarks.reduce(0.0) { $0 + $1.y } / CGFloat(landmarks.count)
        browShape.position = SCNVector3(Float(avgX) * 0.01, Float(avgY) * 0.01, 0.3)
        
        browNode.addChildNode(browShape)
        return browNode
    }
    
    private func buildNose(landmarks: [CGPoint], crest: [CGPoint]) -> SCNNode {
        let noseNode = SCNNode()
        
        let noseGeometry = SCNCapsule(capRadius: 0.15, height: 0.5)
        noseGeometry.radialSegmentCount = 20
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.95, green: 0.87, blue: 0.8, alpha: 1.0)
        material.lightingModel = .physicallyBased
        material.roughness.contents = 0.7
        noseGeometry.materials = [material]
        
        let noseShape = SCNNode(geometry: noseGeometry)
        noseShape.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        
        if let avgPoint = averagePoint(landmarks) {
            noseShape.position = SCNVector3(Float(avgPoint.x) * 0.01, Float(avgPoint.y) * 0.01, 0.4)
        }
        
        noseNode.addChildNode(noseShape)
        return noseNode
    }
    
    private func buildMouth(outer: [CGPoint], inner: [CGPoint]) -> SCNNode {
        let mouthNode = SCNNode()
        
        // Outer lips
        let outerGeometry = SCNCapsule(capRadius: 0.08, height: 0.8)
        outerGeometry.radialSegmentCount = 24
        let outerMaterial = SCNMaterial()
        outerMaterial.diffuse.contents = UIColor.systemPink.withAlphaComponent(0.7)
        outerMaterial.lightingModel = .physicallyBased
        outerGeometry.materials = [outerMaterial]
        
        let outerNode = SCNNode(geometry: outerGeometry)
        outerNode.eulerAngles = SCNVector3(0, 0, Float.pi / 2)
        
        if let avgPoint = averagePoint(outer) {
            outerNode.position = SCNVector3(Float(avgPoint.x) * 0.01, Float(avgPoint.y) * 0.01, 0.2)
        }
        
        mouthNode.addChildNode(outerNode)
        return mouthNode
    }
    
    // MARK: - Helper Functions
    
    private func calculateEyePosition(eyeLandmarks: [CGPoint], isLeft: Bool) -> SCNVector3 {
        guard let avgPoint = averagePoint(eyeLandmarks) else {
            return SCNVector3(isLeft ? -0.3 : 0.3, 0, 0.5)
        }
        
        return SCNVector3(
            Float(avgPoint.x) * 0.01,
            Float(avgPoint.y) * 0.01,
            0.5
        )
    }
    
    private func averagePoint(_ points: [CGPoint]) -> CGPoint? {
        guard !points.isEmpty else { return nil }
        let sum = points.reduce(CGPoint.zero) { CGPoint(x: $0.x + $1.x, y: $0.y + $1.y) }
        return CGPoint(x: sum.x / CGFloat(points.count), y: sum.y / CGFloat(points.count))
    }
    
    private func normalize(_ vector: SCNVector3) -> SCNVector3 {
        let length = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        guard length > 0 else { return vector }
        return SCNVector3(vector.x / length, vector.y / length, vector.z / length)
    }
}
