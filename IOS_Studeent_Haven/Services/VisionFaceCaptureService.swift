//
//  VisionFaceCaptureService.swift
//  IOS_Student_Haven
//
//  Uses Apple Vision framework to capture and analyze face from photo
//

import Foundation
import Vision
import UIKit
import CoreImage

class VisionFaceCaptureService {
    
    static let shared = VisionFaceCaptureService()
    
    private init() {}
    
    // MARK: - Face Detection
    
    /// Detect face in image and extract facial landmarks
    func detectFace(
        in image: UIImage,
        completion: @escaping (Result<FaceAnalysis, FaceError>) -> Void
    ) {
        guard let cgImage = image.cgImage else {
            completion(.failure(.invalidImage))
            return
        }
        
        // Create face detection request
        let faceDetectionRequest = VNDetectFaceLandmarksRequest { request, error in
            if let error = error {
                completion(.failure(.detectionFailed(error.localizedDescription)))
                return
            }
            
            guard let observations = request.results as? [VNFaceObservation],
                  let faceObservation = observations.first else {
                completion(.failure(.noFaceDetected))
                return
            }
            
            // Extract facial features
            let analysis = self.analyzeFace(observation: faceObservation, imageSize: image.size)
            completion(.success(analysis))
        }
        
        // Perform request
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([faceDetectionRequest])
            } catch {
                completion(.failure(.detectionFailed(error.localizedDescription)))
            }
        }
    }
    
    // MARK: - Face Analysis
    
    private func analyzeFace(observation: VNFaceObservation, imageSize: CGSize) -> FaceAnalysis {
        var landmarks = FaceLandmarks()
        
        // Extract all facial landmarks
        if let faceContour = observation.landmarks?.faceContour {
            landmarks.faceContour = normalizePoints(faceContour.normalizedPoints, imageSize: imageSize)
        }
        
        if let leftEye = observation.landmarks?.leftEye {
            landmarks.leftEye = normalizePoints(leftEye.normalizedPoints, imageSize: imageSize)
        }
        
        if let rightEye = observation.landmarks?.rightEye {
            landmarks.rightEye = normalizePoints(rightEye.normalizedPoints, imageSize: imageSize)
        }
        
        if let leftEyebrow = observation.landmarks?.leftEyebrow {
            landmarks.leftEyebrow = normalizePoints(leftEyebrow.normalizedPoints, imageSize: imageSize)
        }
        
        if let rightEyebrow = observation.landmarks?.rightEyebrow {
            landmarks.rightEyebrow = normalizePoints(rightEyebrow.normalizedPoints, imageSize: imageSize)
        }
        
        if let nose = observation.landmarks?.nose {
            landmarks.nose = normalizePoints(nose.normalizedPoints, imageSize: imageSize)
        }
        
        if let noseCrest = observation.landmarks?.noseCrest {
            landmarks.noseCrest = normalizePoints(noseCrest.normalizedPoints, imageSize: imageSize)
        }
        
        if let medianLine = observation.landmarks?.medianLine {
            landmarks.medianLine = normalizePoints(medianLine.normalizedPoints, imageSize: imageSize)
        }
        
        if let outerLips = observation.landmarks?.outerLips {
            landmarks.outerLips = normalizePoints(outerLips.normalizedPoints, imageSize: imageSize)
        }
        
        if let innerLips = observation.landmarks?.innerLips {
            landmarks.innerLips = normalizePoints(innerLips.normalizedPoints, imageSize: imageSize)
        }
        
        if let leftPupil = observation.landmarks?.leftPupil {
            landmarks.leftPupil = normalizePoints(leftPupil.normalizedPoints, imageSize: imageSize)
        }
        
        if let rightPupil = observation.landmarks?.rightPupil {
            landmarks.rightPupil = normalizePoints(rightPupil.normalizedPoints, imageSize: imageSize)
        }
        
        // Calculate face metrics
        let boundingBox = observation.boundingBox
        let faceWidth = boundingBox.width * imageSize.width
        let faceHeight = boundingBox.height * imageSize.height
        
        // Estimate age category from face proportions
        let ageCategory = estimateAgeCategory(
            faceWidth: faceWidth,
            faceHeight: faceHeight,
            landmarks: landmarks
        )
        
        return FaceAnalysis(
            landmarks: landmarks,
            boundingBox: boundingBox,
            roll: observation.roll?.doubleValue ?? 0,
            pitch: observation.pitch?.doubleValue ?? 0,
            yaw: observation.yaw?.doubleValue ?? 0,
            faceWidth: Float(faceWidth),
            faceHeight: Float(faceHeight),
            estimatedAge: ageCategory
        )
    }
    
    private func normalizePoints(_ points: [CGPoint], imageSize: CGSize) -> [CGPoint] {
        return points.map { point in
            CGPoint(
                x: point.x * imageSize.width,
                y: (1 - point.y) * imageSize.height  // Flip Y coordinate
            )
        }
    }
    
    private func estimateAgeCategory(faceWidth: CGFloat, faceHeight: CGFloat, landmarks: FaceLandmarks) -> Int {
        // Simple heuristic: face proportions change with age
        let aspectRatio = faceHeight / faceWidth
        
        // Younger faces tend to be rounder, older faces more elongated
        if aspectRatio < 1.3 {
            return 25  // Younger adult
        } else if aspectRatio < 1.4 {
            return 35  // Adult
        } else if aspectRatio < 1.5 {
            return 45  // Middle-aged
        } else {
            return 55  // Senior
        }
    }
}

// MARK: - Models

struct FaceAnalysis {
    let landmarks: FaceLandmarks
    let boundingBox: CGRect
    let roll: Double  // Head rotation around Z axis
    let pitch: Double  // Head rotation around X axis
    let yaw: Double  // Head rotation around Y axis
    let faceWidth: Float
    let faceHeight: Float
    let estimatedAge: Int
}

struct FaceLandmarks {
    var faceContour: [CGPoint] = []
    var leftEye: [CGPoint] = []
    var rightEye: [CGPoint] = []
    var leftEyebrow: [CGPoint] = []
    var rightEyebrow: [CGPoint] = []
    var nose: [CGPoint] = []
    var noseCrest: [CGPoint] = []
    var medianLine: [CGPoint] = []
    var outerLips: [CGPoint] = []
    var innerLips: [CGPoint] = []
    var leftPupil: [CGPoint] = []
    var rightPupil: [CGPoint] = []
}

// MARK: - Errors

enum FaceError: LocalizedError {
    case invalidImage
    case noFaceDetected
    case detectionFailed(String)
    case multipleFacesDetected
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Unable to process the provided image"
        case .noFaceDetected:
            return "No face detected in the image. Please take a clear photo of your face."
        case .detectionFailed(let reason):
            return "Face detection failed: \(reason)"
        case .multipleFacesDetected:
            return "Multiple faces detected. Please take a photo with only your face visible."
        }
    }
}
