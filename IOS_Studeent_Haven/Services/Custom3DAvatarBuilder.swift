//
//  Custom3DAvatarBuilder.swift
//  IOS_Student_Haven
//
//  Builds 3D avatars procedurally using SceneKit geometry
//

import Foundation
import SceneKit
import SwiftUI

class Custom3DAvatarBuilder {
    
    // MARK: - Build Complete Avatar
    static func buildAvatar(from avatar: Avatar) -> SCNNode {
        let avatarNode = SCNNode()
        avatarNode.name = "avatar"
        
        // Get body proportions based on age
        let proportions = avatar.ageCategory.bodyProportions
        let bodyTypeScale = getBodyTypeScale(avatar.appearance.bodyType)
        let heightScale = getHeightScale(avatar.appearance.height)
        
        // Build body parts
        let head = buildHead(appearance: avatar.appearance, proportions: proportions)
        let torso = buildTorso(appearance: avatar.appearance, bodyType: bodyTypeScale, outfit: avatar.currentOutfit)
        let leftArm = buildArm(isLeft: true, skinTone: avatar.appearance.skinTone, bodyType: bodyTypeScale)
        let rightArm = buildArm(isLeft: false, skinTone: avatar.appearance.skinTone, bodyType: bodyTypeScale)
        let leftLeg = buildLeg(isLeft: true, skinTone: avatar.appearance.skinTone, outfit: avatar.currentOutfit)
        let rightLeg = buildLeg(isLeft: false, skinTone: avatar.appearance.skinTone, outfit: avatar.currentOutfit)
        
        // Position parts
        head.position = SCNVector3(0, 0.65, 0)
        torso.position = SCNVector3(0, 0.15, 0)
        leftArm.position = SCNVector3(-0.25, 0.30, 0)
        rightArm.position = SCNVector3(0.25, 0.30, 0)
        leftLeg.position = SCNVector3(-0.1, -0.3, 0)
        rightLeg.position = SCNVector3(0.1, -0.3, 0)
        
        // Apply proportions
        head.scale = SCNVector3(proportions.headSize, proportions.headSize, proportions.headSize)
        torso.scale = SCNVector3(proportions.shoulderWidth, 1.0, 1.0)
        leftArm.scale = SCNVector3(1.0, heightScale, 1.0)
        rightArm.scale = SCNVector3(1.0, heightScale, 1.0)
        leftLeg.scale = SCNVector3(1.0, heightScale, 1.0)
        rightLeg.scale = SCNVector3(1.0, heightScale, 1.0)
        
        // Add to avatar node
        avatarNode.addChildNode(head)
        avatarNode.addChildNode(torso)
        avatarNode.addChildNode(leftArm)
        avatarNode.addChildNode(rightArm)
        avatarNode.addChildNode(leftLeg)
        avatarNode.addChildNode(rightLeg)
        
        // Add clothing/accessories
        if let shoes = avatar.currentOutfit.shoes {
            addShoes(to: avatarNode, item: shoes, leftLegPos: leftLeg.position, rightLegPos: rightLeg.position)
        }
        
        if let outerwear = avatar.currentOutfit.outerwear {
            addOuterwear(to: avatarNode, item: outerwear, torsoPos: torso.position)
        }
        
        // Center the avatar
        avatarNode.position = SCNVector3(0, -0.5, 0)
        
        return avatarNode
    }
    
    // MARK: - Build Head
    private static func buildHead(appearance: Appearance, proportions: BodyProportions) -> SCNNode {
        let headNode = SCNNode()
        
        // Main cranium - larger for realistic proportions
        let craniumGeometry = SCNSphere(radius: 0.12)
        craniumGeometry.segmentCount = 80  // Very high for smoothness
        
        // Advanced skin material
        let skinMaterial = SCNMaterial()
        skinMaterial.diffuse.contents = UIColor(appearance.skinTone.color)
        skinMaterial.specular.contents = UIColor.white.withAlphaComponent(0.05)
        skinMaterial.shininess = 0.02
        skinMaterial.roughness.contents = 0.7
        skinMaterial.metalness.contents = 0.0
        skinMaterial.lightingModel = .physicallyBased
        skinMaterial.normal.intensity = 0.2
        // Add ambient occlusion for depth
        skinMaterial.ambientOcclusion.contents = UIColor.darkGray.withAlphaComponent(0.3)
        skinMaterial.ambientOcclusion.intensity = 0.5
        craniumGeometry.materials = [skinMaterial]
        
        let craniumNode = SCNNode(geometry: craniumGeometry)
        craniumNode.scale = SCNVector3(0.92, 1.0, 0.95)  // Realistic head shape
        headNode.addChildNode(craniumNode)
        
        // Forehead definition
        let foreheadGeometry = SCNSphere(radius: 0.08)
        foreheadGeometry.segmentCount = 48
        foreheadGeometry.materials = [skinMaterial]
        let foreheadNode = SCNNode(geometry: foreheadGeometry)
        foreheadNode.scale = SCNVector3(1.0, 0.6, 0.7)
        foreheadNode.position = SCNVector3(0, 0.05, 0.08)
        headNode.addChildNode(foreheadNode)
        
        // Upper face
        let upperFaceGeometry = SCNSphere(radius: 0.09)
        upperFaceGeometry.segmentCount = 60
        upperFaceGeometry.materials = [skinMaterial]
        let upperFaceNode = SCNNode(geometry: upperFaceGeometry)
        upperFaceNode.scale = SCNVector3(0.85, 0.65, 0.95)
        upperFaceNode.position = SCNVector3(0, 0, 0.075)
        headNode.addChildNode(upperFaceNode)
        
        // Cheekbones with better definition
        for xPos: Float in [-0.065, 0.065] {
            let cheekGeometry = SCNSphere(radius: 0.035)
            cheekGeometry.segmentCount = 32
            cheekGeometry.materials = [skinMaterial]
            let cheekNode = SCNNode(geometry: cheekGeometry)
            cheekNode.scale = SCNVector3(0.8, 0.9, 1.1)
            cheekNode.position = SCNVector3(xPos, -0.015, 0.085)
            headNode.addChildNode(cheekNode)
        }
        
        // Lower face/jaw structure
        let jawGeometry = SCNSphere(radius: 0.08)
        jawGeometry.segmentCount = 48
        jawGeometry.materials = [skinMaterial]
        let jawNode = SCNNode(geometry: jawGeometry)
        jawNode.scale = SCNVector3(0.75, 0.8, 0.85)
        jawNode.position = SCNVector3(0, -0.08, 0.06)
        headNode.addChildNode(jawNode)
        
        // Chin definition
        let chinGeometry = SCNSphere(radius: 0.035)
        chinGeometry.segmentCount = 32
        chinGeometry.materials = [skinMaterial]
        let chinNode = SCNNode(geometry: chinGeometry)
        chinNode.scale = SCNVector3(0.8, 0.7, 1.0)
        chinNode.position = SCNVector3(0, -0.11, 0.065)
        headNode.addChildNode(chinNode)
        
        // Neck - realistic taper
        let neckGeometry = SCNSphere(radius: 0.055)
        neckGeometry.segmentCount = 36
        neckGeometry.materials = [skinMaterial]
        let neckNode = SCNNode(geometry: neckGeometry)
        neckNode.scale = SCNVector3(0.85, 1.0, 0.85)
        neckNode.position = SCNVector3(0, -0.14, 0.01)
        headNode.addChildNode(neckNode)
        
        // Throat
        let throatGeometry = SCNSphere(radius: 0.045)
        throatGeometry.segmentCount = 28
        throatGeometry.materials = [skinMaterial]
        let throatNode = SCNNode(geometry: throatGeometry)
        throatNode.scale = SCNVector3(0.75, 0.6, 0.75)
        throatNode.position = SCNVector3(0, -0.16, 0.03)
        headNode.addChildNode(throatNode)
        
        // Realistic eyes with better positioning
        let leftEye = buildRealisticEye(appearance: appearance)
        let rightEye = buildRealisticEye(appearance: appearance)
        leftEye.position = SCNVector3(-0.042, 0.025, 0.095)
        rightEye.position = SCNVector3(0.042, 0.025, 0.095)
        leftEye.scale = SCNVector3(1.1, 1.1, 1.1)  // Slightly larger
        rightEye.scale = SCNVector3(1.1, 1.1, 1.1)
        headNode.addChildNode(leftEye)
        headNode.addChildNode(rightEye)
        
        // Eyebrows - more prominent
        let leftBrow = buildEyebrow(hairColor: appearance.hairColor)
        let rightBrow = buildEyebrow(hairColor: appearance.hairColor)
        leftBrow.position = SCNVector3(-0.045, 0.055, 0.095)
        rightBrow.position = SCNVector3(0.045, 0.055, 0.095)
        leftBrow.scale = SCNVector3(1.2, 1.0, 1.0)
        rightBrow.scale = SCNVector3(1.2, 1.0, 1.0)
        headNode.addChildNode(leftBrow)
        headNode.addChildNode(rightBrow)
        
        // Nose bridge
        let noseBridgeGeometry = SCNBox(width: 0.018, height: 0.045, length: 0.025, chamferRadius: 0.008)
        noseBridgeGeometry.materials = [skinMaterial]
        let noseBridgeNode = SCNNode(geometry: noseBridgeGeometry)
        noseBridgeNode.position = SCNVector3(0, 0.005, 0.10)
        headNode.addChildNode(noseBridgeNode)
        
        // Nose tip
        let noseTipGeometry = SCNSphere(radius: 0.020)
        noseTipGeometry.segmentCount = 24
        noseTipGeometry.materials = [skinMaterial]
        let noseTipNode = SCNNode(geometry: noseTipGeometry)
        noseTipNode.scale = SCNVector3(0.8, 0.85, 1.0)
        noseTipNode.position = SCNVector3(0, -0.020, 0.105)
        headNode.addChildNode(noseTipNode)
        
        // Nostrils
        for xPos: Float in [-0.012, 0.012] {
            let nostrilGeometry = SCNSphere(radius: 0.008)
            nostrilGeometry.segmentCount = 16
            let nostrilMaterial = SCNMaterial()
            nostrilMaterial.diffuse.contents = UIColor.black.withAlphaComponent(0.6)
            nostrilGeometry.materials = [nostrilMaterial]
            let nostrilNode = SCNNode(geometry: nostrilGeometry)
            nostrilNode.scale = SCNVector3(1.0, 0.6, 0.8)
            nostrilNode.position = SCNVector3(xPos, -0.025, 0.102)
            headNode.addChildNode(nostrilNode)
        }
        
        // Mouth area
        let mouth = buildMouth(skinTone: appearance.skinTone)
        mouth.position = SCNVector3(0, -0.055, 0.092)
        mouth.scale = SCNVector3(1.15, 1.0, 1.0)
        headNode.addChildNode(mouth)
        
        // Ears
        let leftEar = buildEar(skinTone: appearance.skinTone)
        let rightEar = buildEar(skinTone: appearance.skinTone)
        leftEar.position = SCNVector3(-0.09, 0, 0.02)
        rightEar.position = SCNVector3(0.09, 0, 0.02)
        headNode.addChildNode(leftEar)
        headNode.addChildNode(rightEar)
        
        // Hair - larger and better positioned
        if appearance.hairStyle != .bald {
            let hair = buildHair(style: appearance.hairStyle, color: appearance.hairColor)
            hair.position = SCNVector3(0, 0.065, -0.015)
            hair.scale = SCNVector3(1.15, 1.1, 1.15)  // Fuller hair
            headNode.addChildNode(hair)
        }
        
        return headNode
    }
    
    private static func buildRealisticEye(appearance: Appearance) -> SCNNode {
        let eyeNode = SCNNode()
        
        // Eyeball base (slightly flattened sphere)
        let eyeballGeometry = SCNSphere(radius: 0.016)
        eyeballGeometry.segmentCount = 32
        let eyeballMaterial = SCNMaterial()
        eyeballMaterial.diffuse.contents = UIColor.white
        eyeballMaterial.specular.contents = UIColor.white.withAlphaComponent(0.3)
        eyeballMaterial.shininess = 0.8
        eyeballMaterial.lightingModel = .physicallyBased
        eyeballGeometry.materials = [eyeballMaterial]
        let eyeballNode = SCNNode(geometry: eyeballGeometry)
        eyeballNode.scale = SCNVector3(1.0, 1.0, 0.7)
        eyeNode.addChildNode(eyeballNode)
        
        // Iris (detailed)
        let irisGeometry = SCNCylinder(radius: 0.0095, height: 0.002)
        irisGeometry.radialSegmentCount = 32
        let irisMaterial = SCNMaterial()
        irisMaterial.diffuse.contents = UIColor(appearance.eyeColor.color)
        irisMaterial.specular.contents = UIColor.white.withAlphaComponent(0.5)
        irisMaterial.metalness.contents = 0.1
        irisMaterial.roughness.contents = 0.3
        irisMaterial.lightingModel = .physicallyBased
        irisGeometry.materials = [irisMaterial]
        let irisNode = SCNNode(geometry: irisGeometry)
        irisNode.position = SCNVector3(0, 0, 0.013)
        irisNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        eyeNode.addChildNode(irisNode)
        
        // Pupil (glossy black)
        let pupilGeometry = SCNCylinder(radius: 0.004, height: 0.003)
        pupilGeometry.radialSegmentCount = 24
        let pupilMaterial = SCNMaterial()
        pupilMaterial.diffuse.contents = UIColor.black
        pupilMaterial.specular.contents = UIColor.white
        pupilMaterial.shininess = 1.0
        pupilMaterial.lightingModel = .physicallyBased
        pupilGeometry.materials = [pupilMaterial]
        let pupilNode = SCNNode(geometry: pupilGeometry)
        pupilNode.position = SCNVector3(0, 0, 0.014)
        pupilNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        eyeNode.addChildNode(pupilNode)
        
        // Cornea highlight (glossy layer)
        let corneaGeometry = SCNSphere(radius: 0.017)
        corneaGeometry.segmentCount = 32
        let corneaMaterial = SCNMaterial()
        corneaMaterial.diffuse.contents = UIColor.white.withAlphaComponent(0.15)
        corneaMaterial.specular.contents = UIColor.white
        corneaMaterial.shininess = 1.0
        corneaMaterial.transparency = 0.3
        corneaMaterial.lightingModel = .physicallyBased
        corneaGeometry.materials = [corneaMaterial]
        let corneaNode = SCNNode(geometry: corneaGeometry)
        corneaNode.scale = SCNVector3(1.0, 1.0, 0.7)
        eyeNode.addChildNode(corneaNode)
        
        return eyeNode
    }
    
    private static func buildEyebrow(hairColor: HairColor) -> SCNNode {
        let browNode = SCNNode()
        
        let browGeometry = SCNBox(width: 0.03, height: 0.006, length: 0.008, chamferRadius: 0.003)
        let browMaterial = SCNMaterial()
        browMaterial.diffuse.contents = UIColor(hairColor.color).withAlphaComponent(0.9)
        browMaterial.lightingModel = .physicallyBased
        browGeometry.materials = [browMaterial]
        
        let browShapeNode = SCNNode(geometry: browGeometry)
        browNode.addChildNode(browShapeNode)
        
        return browNode
    }
    
    private static func buildMouth(skinTone: SkinTone) -> SCNNode {
        let mouthNode = SCNNode()
        
        // Upper lip
        let upperLipGeometry = SCNBox(width: 0.04, height: 0.006, length: 0.01, chamferRadius: 0.003)
        let lipMaterial = SCNMaterial()
        lipMaterial.diffuse.contents = UIColor.systemPink.withAlphaComponent(0.6)
        lipMaterial.lightingModel = .physicallyBased
        upperLipGeometry.materials = [lipMaterial]
        let upperLipNode = SCNNode(geometry: upperLipGeometry)
        upperLipNode.position = SCNVector3(0, 0.003, 0)
        mouthNode.addChildNode(upperLipNode)
        
        // Lower lip
        let lowerLipGeometry = SCNBox(width: 0.04, height: 0.008, length: 0.01, chamferRadius: 0.004)
        lowerLipGeometry.materials = [lipMaterial]
        let lowerLipNode = SCNNode(geometry: lowerLipGeometry)
        lowerLipNode.position = SCNVector3(0, -0.004, 0)
        mouthNode.addChildNode(lowerLipNode)
        
        return mouthNode
    }
    
    private static func buildEar(skinTone: SkinTone) -> SCNNode {
        let earNode = SCNNode()
        
        let earGeometry = SCNSphere(radius: 0.025)
        earGeometry.segmentCount = 24
        let earMaterial = SCNMaterial()
        earMaterial.diffuse.contents = UIColor(skinTone.color)
        earMaterial.lightingModel = .physicallyBased
        earGeometry.materials = [earMaterial]
        
        let earShapeNode = SCNNode(geometry: earGeometry)
        earShapeNode.scale = SCNVector3(0.4, 1.0, 0.6)
        earNode.addChildNode(earShapeNode)
        
        return earNode
    }
    
    private static func buildHair(style: HairStyle, color: HairColor) -> SCNNode {
        let hairNode = SCNNode()
        
        // Realistic hair with smooth geometry
        let hairGeometry: SCNGeometry
        switch style {
        case .short, .buzz:
            // Short hair cap
            let sphereGeometry = SCNSphere(radius: 0.105)
            sphereGeometry.segmentCount = 48
            hairGeometry = sphereGeometry
        case .medium, .wavy:
            // Medium length with volume
            hairGeometry = SCNCapsule(capRadius: 0.10, height: 0.15)
            (hairGeometry as! SCNCapsule).radialSegmentCount = 48
        case .long:
            // Long flowing hair
            hairGeometry = SCNCapsule(capRadius: 0.10, height: 0.25)
            (hairGeometry as! SCNCapsule).radialSegmentCount = 48
        case .curly:
            // Curly voluminous hair
            let sphereGeometry = SCNSphere(radius: 0.13)
            sphereGeometry.segmentCount = 48
            hairGeometry = sphereGeometry
        case .straight:
            // Straight sleek hair
            hairGeometry = SCNCapsule(capRadius: 0.095, height: 0.18)
            (hairGeometry as! SCNCapsule).radialSegmentCount = 48
        case .bald:
            return hairNode
        }
        
        // Realistic hair material
        let hairMaterial = SCNMaterial()
        hairMaterial.diffuse.contents = UIColor(color.color)
        hairMaterial.specular.contents = UIColor.white.withAlphaComponent(0.3)
        hairMaterial.shininess = 0.6
        hairMaterial.roughness.contents = 0.5
        hairMaterial.metalness.contents = 0.1
        hairMaterial.lightingModel = .physicallyBased
        hairGeometry.materials = [hairMaterial]
        
        let mainHairNode = SCNNode(geometry: hairGeometry)
        if style == .medium || style == .wavy || style == .long || style == .straight {
            mainHairNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
            mainHairNode.position = SCNVector3(0, 0.03, -0.02)
        }
        hairNode.addChildNode(mainHairNode)
        
        return hairNode
    }
    
    // MARK: - Build Body Parts
    private static func buildTorso(appearance: Appearance, bodyType: Float, outfit: Outfit) -> SCNNode {
        let torsoNode = SCNNode()
        
        // Create realistic chest with proper human proportions
        // Use sphere scaled to create natural chest shape
        let chestGeometry = SCNSphere(radius: 0.18)
        chestGeometry.segmentCount = 48
        let chestNode = SCNNode(geometry: chestGeometry)
        chestNode.scale = SCNVector3(bodyType * 0.85, 0.65, 0.55)  // Wide, less tall, less deep
        chestNode.position = SCNVector3(0, 0.15, 0)
        
        // Get shirt color, default to nice blue if no outfit
        let shirtColor: Color
        if let top = outfit.top {
            shirtColor = top.color.color
        } else {
            shirtColor = .blue  // Default shirt color
        }
        
        let torsoMaterial = SCNMaterial()
        torsoMaterial.diffuse.contents = UIColor(shirtColor)
        torsoMaterial.roughness.contents = 0.6
        torsoMaterial.lightingModel = .physicallyBased
        chestGeometry.materials = [torsoMaterial]
        torsoNode.addChildNode(chestNode)
        
        // Waist - tapered for natural body shape
        let waistGeometry = SCNSphere(radius: 0.15)
        waistGeometry.segmentCount = 48
        waistGeometry.materials = [torsoMaterial]
        let waistNode = SCNNode(geometry: waistGeometry)
        waistNode.scale = SCNVector3(bodyType * 0.72, 0.45, 0.48)  // Narrower waist
        waistNode.position = SCNVector3(0, 0.02, 0)
        torsoNode.addChildNode(waistNode)
        
        // Lower torso (abdomen/hips)
        let abdomenGeometry = SCNSphere(radius: 0.16)
        abdomenGeometry.segmentCount = 48
        abdomenGeometry.materials = [torsoMaterial]
        let abdomenNode = SCNNode(geometry: abdomenGeometry)
        abdomenNode.scale = SCNVector3(bodyType * 0.78, 0.40, 0.50)
        abdomenNode.position = SCNVector3(0, -0.10, 0)
        torsoNode.addChildNode(abdomenNode)
        
        // Realistic shoulders with proper deltoid shape
        let shoulderGeometry = SCNSphere(radius: 0.09)
        shoulderGeometry.segmentCount = 40
        let shoulderMaterial = SCNMaterial()
        shoulderMaterial.diffuse.contents = UIColor(shirtColor)
        shoulderMaterial.roughness.contents = 0.6
        shoulderMaterial.lightingModel = .physicallyBased
        shoulderGeometry.materials = [shoulderMaterial]
        
        let leftShoulder = SCNNode(geometry: shoulderGeometry)
        leftShoulder.scale = SCNVector3(bodyType * 1.0, 0.7, 0.7)  // Oval deltoid
        leftShoulder.position = SCNVector3(CGFloat(-0.20 * bodyType), 0.20, 0)
        torsoNode.addChildNode(leftShoulder)
        
        let rightShoulder = SCNNode(geometry: shoulderGeometry)
        rightShoulder.scale = SCNVector3(bodyType * 1.0, 0.7, 0.7)
        rightShoulder.position = SCNVector3(CGFloat(0.20 * bodyType), 0.20, 0)
        torsoNode.addChildNode(rightShoulder)
        
        return torsoNode
    }
    
    private static func buildArm(isLeft: Bool, skinTone: SkinTone, bodyType: Float) -> SCNNode {
        let armNode = SCNNode()
        
        let skinMaterial = SCNMaterial()
        skinMaterial.diffuse.contents = UIColor(skinTone.color)
        skinMaterial.roughness.contents = 0.75
        skinMaterial.lightingModel = .physicallyBased
        
        // Upper arm with natural bicep/tricep curve
        let upperArmGeometry = SCNSphere(radius: 0.06)
        upperArmGeometry.segmentCount = 32
        upperArmGeometry.materials = [skinMaterial]
        let upperArmNode = SCNNode(geometry: upperArmGeometry)
        upperArmNode.scale = SCNVector3(bodyType * 0.75, 2.0, 0.75)  // Elongated
        upperArmNode.position = SCNVector3(0, -0.12, 0)
        armNode.addChildNode(upperArmNode)
        
        // Elbow - smooth transition
        let elbowGeometry = SCNSphere(radius: 0.042)
        elbowGeometry.segmentCount = 28
        elbowGeometry.materials = [skinMaterial]
        let elbowNode = SCNNode(geometry: elbowGeometry)
        elbowNode.scale = SCNVector3(bodyType * 0.85, 0.8, 0.85)
        elbowNode.position = SCNVector3(0, -0.24, 0)
        armNode.addChildNode(elbowNode)
        
        // Forearm - natural taper
        let forearmGeometry = SCNSphere(radius: 0.055)
        forearmGeometry.segmentCount = 32
        forearmGeometry.materials = [skinMaterial]
        let forearmNode = SCNNode(geometry: forearmGeometry)
        forearmNode.scale = SCNVector3(bodyType * 0.65, 2.0, 0.65)
        forearmNode.position = SCNVector3(0, -0.36, 0)
        armNode.addChildNode(forearmNode)
        
        // Wrist - slim transition
        let wristGeometry = SCNSphere(radius: 0.035)
        wristGeometry.segmentCount = 24
        wristGeometry.materials = [skinMaterial]
        let wristNode = SCNNode(geometry: wristGeometry)
        wristNode.scale = SCNVector3(bodyType * 0.8, 0.6, 0.8)
        wristNode.position = SCNVector3(0, -0.48, 0)
        armNode.addChildNode(wristNode)
        
        // Hand - realistic proportions
        let handGeometry = SCNSphere(radius: 0.045)
        handGeometry.segmentCount = 28
        handGeometry.materials = [skinMaterial]
        let handNode = SCNNode(geometry: handGeometry)
        handNode.scale = SCNVector3(bodyType * 0.65, 0.9, 0.4)  // Flat palm shape
        handNode.position = SCNVector3(0, -0.54, 0)
        armNode.addChildNode(handNode)
        
        return armNode
    }
    
    private static func buildLeg(isLeft: Bool, skinTone: SkinTone, outfit: Outfit) -> SCNNode {
        let legNode = SCNNode()
        
        // Get pants color, default to nice jeans blue if no outfit
        let pantsColor: Color
        if let bottom = outfit.bottom {
            pantsColor = bottom.color.color
        } else {
            pantsColor = Color(red: 0.3, green: 0.4, blue: 0.6)  // Jeans blue
        }
        
        let legMaterial = SCNMaterial()
        legMaterial.diffuse.contents = UIColor(pantsColor)
        legMaterial.roughness.contents = 0.8
        legMaterial.lightingModel = .physicallyBased
        
        // Upper leg (thigh) - natural muscle shape
        let thighGeometry = SCNSphere(radius: 0.085)
        thighGeometry.segmentCount = 36
        thighGeometry.materials = [legMaterial]
        
        let thighNode = SCNNode(geometry: thighGeometry)
        thighNode.scale = SCNVector3(0.75, 2.0, 0.75)  // Elongated thigh
        thighNode.position = SCNVector3(0, -0.17, 0)
        legNode.addChildNode(thighNode)
        
        // Knee joint - natural roundness
        let kneeGeometry = SCNSphere(radius: 0.058)
        kneeGeometry.segmentCount = 32
        kneeGeometry.materials = [legMaterial]
        let kneeNode = SCNNode(geometry: kneeGeometry)
        kneeNode.scale = SCNVector3(0.85, 0.75, 0.85)
        kneeNode.position = SCNVector3(0, -0.34, 0)
        legNode.addChildNode(kneeNode)
        
        // Lower leg (calf) - natural taper
        let calfGeometry = SCNSphere(radius: 0.07)
        calfGeometry.segmentCount = 36
        calfGeometry.materials = [legMaterial]
        
        let calfNode = SCNNode(geometry: calfGeometry)
        calfNode.scale = SCNVector3(0.65, 2.2, 0.70)  // Tapered calf
        calfNode.position = SCNVector3(0, -0.51, 0)
        legNode.addChildNode(calfNode)
        
        // Ankle
        let ankleGeometry = SCNSphere(radius: 0.042)
        ankleGeometry.segmentCount = 20
        let skinMaterial = SCNMaterial()
        skinMaterial.diffuse.contents = UIColor(skinTone.color)
        skinMaterial.lightingModel = .physicallyBased
        ankleGeometry.materials = [skinMaterial]
        let ankleNode = SCNNode(geometry: ankleGeometry)
        ankleNode.position = SCNVector3(0, -0.68, 0)
        legNode.addChildNode(ankleNode)
        
        return legNode
    }
    
    // MARK: - Add Clothing
    private static func addShoes(to avatarNode: SCNNode, item: ClothingItem, leftLegPos: SCNVector3, rightLegPos: SCNVector3) {
        let shoeMaterial = SCNMaterial()
        shoeMaterial.diffuse.contents = UIColor(item.color.color)
        shoeMaterial.roughness.contents = 0.6
        shoeMaterial.metalness.contents = 0.05
        shoeMaterial.lightingModel = .physicallyBased
        
        let soleMaterial = SCNMaterial()
        soleMaterial.diffuse.contents = UIColor.darkGray
        soleMaterial.roughness.contents = 0.9
        soleMaterial.lightingModel = .physicallyBased
        
        // Build detailed shoes for each leg
        for (xPos, _) in [(leftLegPos.x, leftLegPos), (rightLegPos.x, rightLegPos)] {
            let shoeNode = SCNNode()
            shoeNode.position = SCNVector3(xPos, -0.72, 0.03)
            
            // Sole - rubber base
            let soleGeometry = SCNBox(width: 0.09, height: 0.025, length: 0.16, chamferRadius: 0.008)
            soleGeometry.materials = [soleMaterial]
            let soleNode = SCNNode(geometry: soleGeometry)
            soleNode.position = SCNVector3(0, 0, 0)
            shoeNode.addChildNode(soleNode)
            
            // Upper shoe body - curved capsule
            let upperGeometry = SCNCapsule(capRadius: 0.040, height: 0.11)
            (upperGeometry as SCNCapsule).radialSegmentCount = 20
            upperGeometry.materials = [shoeMaterial]
            let upperNode = SCNNode(geometry: upperGeometry)
            upperNode.eulerAngles = SCNVector3(0, 0, Float.pi / 2)
            upperNode.position = SCNVector3(0, 0.035, 0.01)
            shoeNode.addChildNode(upperNode)
            
            // Toe cap
            let toeGeometry = SCNSphere(radius: 0.040)
            toeGeometry.segmentCount = 16
            toeGeometry.materials = [shoeMaterial]
            let toeNode = SCNNode(geometry: toeGeometry)
            toeNode.scale = SCNVector3(0.9, 0.8, 1.4)
            toeNode.position = SCNVector3(0, 0.028, 0.07)
            shoeNode.addChildNode(toeNode)
            
            avatarNode.addChildNode(shoeNode)
        }
    }
    
    private static func addOuterwear(to avatarNode: SCNNode, item: ClothingItem, torsoPos: SCNVector3) {
        let fabricMaterial = SCNMaterial()
        fabricMaterial.diffuse.contents = UIColor(item.color.color)
        fabricMaterial.roughness.contents = 0.85
        fabricMaterial.metalness.contents = 0.0
        fabricMaterial.transparency = 0.95
        fabricMaterial.lightingModel = .physicallyBased
        
        let jacketNode = SCNNode()
        jacketNode.position = SCNVector3(torsoPos.x, torsoPos.y - 0.02, torsoPos.z)
        
        // Upper jacket body - capsule for smooth shape
        let upperGeometry = SCNCapsule(capRadius: 0.20, height: 0.35)
        (upperGeometry as SCNCapsule).radialSegmentCount = 32
        upperGeometry.materials = [fabricMaterial]
        let upperNode = SCNNode(geometry: upperGeometry)
        upperNode.position = SCNVector3(0, 0.08, 0)
        jacketNode.addChildNode(upperNode)
        
        // Lower jacket body
        let lowerGeometry = SCNCapsule(capRadius: 0.18, height: 0.28)
        (lowerGeometry as SCNCapsule).radialSegmentCount = 32
        lowerGeometry.materials = [fabricMaterial]
        let lowerNode = SCNNode(geometry: lowerGeometry)
        lowerNode.position = SCNVector3(0, -0.17, 0)
        jacketNode.addChildNode(lowerNode)
        
        // Collar detail
        let collarGeometry = SCNTorus(ringRadius: 0.11, pipeRadius: 0.022)
        collarGeometry.ringSegmentCount = 32
        collarGeometry.pipeSegmentCount = 16
        collarGeometry.materials = [fabricMaterial]
        let collarNode = SCNNode(geometry: collarGeometry)
        collarNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        collarNode.position = SCNVector3(0, 0.24, 0.02)
        jacketNode.addChildNode(collarNode)
        
        avatarNode.addChildNode(jacketNode)
    }
    
    // MARK: - Helper Functions
    private static func getBodyTypeScale(_ bodyType: BodyType) -> Float {
        switch bodyType {
        case .slim: return 0.85
        case .average: return 1.0
        case .athletic: return 1.1
        case .heavy: return 1.3
        }
    }
    
    private static func getHeightScale(_ height: Height) -> Float {
        switch height {
        case .short: return 0.9
        case .average: return 1.0
        case .tall: return 1.15
        }
    }
}
