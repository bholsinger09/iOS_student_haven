//
//  ARFaceScannerView.swift
//  IOS_Student_Haven
//
//  ARKit TrueDepth face scanning for photorealistic 3D avatars
//  Requires iPhone X or later with TrueDepth camera
//

import SwiftUI
import ARKit
import SceneKit

@available(iOS 13.0, *)
struct ARFaceScannerView: UIViewControllerRepresentable {
    @Binding var capturedFaceGeometry: ARFaceGeometry?
    @Binding var capturedPhoto: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> ARFaceScannerViewController {
        let controller = ARFaceScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ARFaceScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARFaceScannerDelegate {
        let parent: ARFaceScannerView
        
        init(_ parent: ARFaceScannerView) {
            self.parent = parent
        }
        
        func didCaptureFace(geometry: ARFaceGeometry, photo: UIImage) {
            parent.capturedFaceGeometry = geometry
            parent.capturedPhoto = photo
            parent.dismiss()
        }
        
        func didCancelCapture() {
            parent.dismiss()
        }
    }
}

// MARK: - ARFaceScanner Delegate

protocol ARFaceScannerDelegate: AnyObject {
    func didCaptureFace(geometry: ARFaceGeometry, photo: UIImage)
    func didCancelCapture()
}

// MARK: - ARFaceScanner ViewController

@available(iOS 13.0, *)
class ARFaceScannerViewController: UIViewController, ARSessionDelegate {
    weak var delegate: ARFaceScannerDelegate?
    
    private var sceneView: ARSCNView!
    private var captureButton: UIButton!
    private var cancelButton: UIButton!
    private var instructionLabel: UILabel!
    private var faceDetectedLabel: UILabel!
    
    private var currentFaceGeometry: ARFaceGeometry?
    private var isFaceDetected = false
    private var captureCount = 0
    private let requiredCaptures = 5 // Average multiple frames for better quality
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check TrueDepth availability
        guard ARFaceTrackingConfiguration.isSupported else {
            showUnsupportedAlert()
            return
        }
        
        setupUI()
        setupARSession()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // AR Scene View
        sceneView = ARSCNView(frame: view.bounds)
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        view.addSubview(sceneView)
        
        // Semi-transparent overlay for UI
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayView.isUserInteractionEnabled = false
        view.addSubview(overlayView)
        
        // Face guide overlay
        let faceGuide = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 350))
        faceGuide.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY - 50)
        faceGuide.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        faceGuide.layer.borderWidth = 2
        faceGuide.layer.cornerRadius = 125
        faceGuide.isUserInteractionEnabled = false
        view.addSubview(faceGuide)
        
        // Instruction label
        instructionLabel = UILabel()
        instructionLabel.text = "Position your face in the guide"
        instructionLabel.textAlignment = .center
        instructionLabel.textColor = .white
        instructionLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        instructionLabel.numberOfLines = 2
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)
        
        // Face detected indicator
        faceDetectedLabel = UILabel()
        faceDetectedLabel.text = "✓ Face Detected"
        faceDetectedLabel.textAlignment = .center
        faceDetectedLabel.textColor = .systemGreen
        faceDetectedLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        faceDetectedLabel.alpha = 0
        faceDetectedLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(faceDetectedLabel)
        
        // Capture button
        captureButton = UIButton(type: .system)
        captureButton.setTitle("Capture Face", for: .normal)
        captureButton.setTitleColor(.white, for: .normal)
        captureButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        captureButton.backgroundColor = UIColor.systemBlue
        captureButton.layer.cornerRadius = 25
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        captureButton.isEnabled = false
        captureButton.alpha = 0.5
        view.addSubview(captureButton)
        
        // Cancel button
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            faceDetectedLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 16),
            faceDetectedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.widthAnchor.constraint(equalToConstant: 200),
            captureButton.heightAnchor.constraint(equalToConstant: 50),
            
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    private func setupARSession() {
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        configuration.maximumNumberOfTrackedFaces = 1
        
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    @objc private func captureButtonTapped() {
        guard let faceGeometry = currentFaceGeometry else { return }
        
        // Capture screenshot of current view
        UIGraphicsBeginImageContextWithOptions(sceneView.bounds.size, false, UIScreen.main.scale)
        sceneView.drawHierarchy(in: sceneView.bounds, afterScreenUpdates: true)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Notify delegate
        if let photo = screenshot {
            delegate?.didCaptureFace(geometry: faceGeometry, photo: photo)
        }
        
        sceneView.session.pause()
    }
    
    @objc private func cancelButtonTapped() {
        sceneView.session.pause()
        delegate?.didCancelCapture()
    }
    
    private func showUnsupportedAlert() {
        let alert = UIAlertController(
            title: "TrueDepth Camera Required",
            message: "This device doesn't support face scanning. You'll need iPhone X or later with TrueDepth camera for this feature. You can still create a custom avatar.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.delegate?.didCancelCapture()
        })
        present(alert, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}

// MARK: - ARSCNViewDelegate

@available(iOS 13.0, *)
extension ARFaceScannerViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        updateFaceGeometry(with: faceAnchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        updateFaceGeometry(with: faceAnchor)
    }
    
    private func updateFaceGeometry(with faceAnchor: ARFaceAnchor) {
        currentFaceGeometry = faceAnchor.geometry
        
        DispatchQueue.main.async {
            if !self.isFaceDetected {
                self.isFaceDetected = true
                self.captureButton.isEnabled = true
                UIView.animate(withDuration: 0.3) {
                    self.captureButton.alpha = 1.0
                    self.faceDetectedLabel.alpha = 1.0
                }
                self.instructionLabel.text = "Hold steady and tap Capture"
            }
        }
    }
}
