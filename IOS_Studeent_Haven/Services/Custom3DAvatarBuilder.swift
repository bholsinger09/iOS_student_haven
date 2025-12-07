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
        
        // Create realistic head using capsule for smooth shape
        let headGeometry = SCNCapsule(capRadius: 0.09, height: 0.20)
        headGeometry.radialSegmentCount = 36
        headGeometry.heightSegmentCount = 12
        
        // Realistic skin material
        let headMaterial = SCNMaterial()
        headMaterial.diffuse.contents = UIColor(appearance.skinTone.color)
        headMaterial.specular.contents = UIColor.white.withAlphaComponent(0.1)
        headMaterial.shininess = 0.05
        headMaterial.roughness.contents = 0.8
        headMaterial.lightingModel = .physicallyBased
        headGeometry.materials = [headMaterial]
        
        let faceNode = SCNNode(geometry: headGeometry)
        faceNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        headNode.addChildNode(faceNode)
        
        // Add neck
        let neckGeometry = SCNCylinder(radius: 0.05, height: 0.10)
        neckGeometry.radialSegmentCount = 24
        let neckMaterial = SCNMaterial()
        neckMaterial.diffuse.contents = UIColor(appearance.skinTone.color)
        neckMaterial.lightingModel = .physicallyBased
        neckGeometry.materials = [neckMaterial]
        let neckNode = SCNNode(geometry: neckGeometry)
        neckNode.position = SCNVector3(0, -0.15, 0)
        headNode.addChildNode(neckNode)
        
        // Realistic eyes
        let leftEye = buildRealisticEye(appearance: appearance)
        let rightEye = buildRealisticEye(appearance: appearance)
        leftEye.position = SCNVector3(-0.04, 0.03, 0.08)
        rightEye.position = SCNVector3(0.04, 0.03, 0.08)
        headNode.addChildNode(leftEye)
        headNode.addChildNode(rightEye)
        
        // Eyebrows
        let leftBrow = buildEyebrow(hairColor: appearance.hairColor)
        let rightBrow = buildEyebrow(hairColor: appearance.hairColor)
        leftBrow.position = SCNVector3(-0.04, 0.06, 0.08)
        rightBrow.position = SCNVector3(0.04, 0.06, 0.08)
        headNode.addChildNode(leftBrow)
        headNode.addChildNode(rightBrow)
        
        // Nose with realistic shape
        let noseGeometry = SCNCapsule(capRadius: 0.012, height: 0.035)
        noseGeometry.radialSegmentCount = 16
        let noseMaterial = SCNMaterial()
        noseMaterial.diffuse.contents = UIColor(appearance.skinTone.color).withAlphaComponent(0.95)
        noseMaterial.lightingModel = .physicallyBased
        noseGeometry.materials = [noseMaterial]
        let noseNode = SCNNode(geometry: noseGeometry)
        noseNode.position = SCNVector3(0, -0.01, 0.09)
        headNode.addChildNode(noseNode)
        
        // Mouth
        let mouth = buildMouth(skinTone: appearance.skinTone)
        mouth.position = SCNVector3(0, -0.05, 0.08)
        headNode.addChildNode(mouth)
        
        // Ears
        let leftEar = buildEar(skinTone: appearance.skinTone)
        let rightEar = buildEar(skinTone: appearance.skinTone)
        leftEar.position = SCNVector3(-0.09, 0, 0.02)
        rightEar.position = SCNVector3(0.09, 0, 0.02)
        headNode.addChildNode(leftEar)
        headNode.addChildNode(rightEar)
        
        // Hair
        if appearance.hairStyle != .bald {
            let hair = buildHair(style: appearance.hairStyle, color: appearance.hairColor)
            hair.position = SCNVector3(0, 0.08, 0)
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
        
        // Realistic upper torso (chest) - smooth rounded shape
        let upperTorsoGeometry = SCNCapsule(
            capRadius: CGFloat(0.16 * bodyType),
            height: 0.30
        )
        (upperTorsoGeometry as SCNCapsule).radialSegmentCount = 36
        (upperTorsoGeometry as SCNCapsule).heightSegmentCount = 12
        
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
        upperTorsoGeometry.materials = [torsoMaterial]
        
        let upperTorsoNode = SCNNode(geometry: upperTorsoGeometry)
        upperTorsoNode.position = SCNVector3(0, 0.08, 0)
        torsoNode.addChildNode(upperTorsoNode)
        
        // Lower torso (abdomen) - tapered shape
        let lowerTorsoGeometry = SCNCapsule(
            capRadius: CGFloat(0.14 * bodyType),
            height: 0.22
        )
        (lowerTorsoGeometry as SCNCapsule).radialSegmentCount = 36
        lowerTorsoGeometry.materials = [torsoMaterial]
        
        let lowerTorsoNode = SCNNode(geometry: lowerTorsoGeometry)
        lowerTorsoNode.position = SCNVector3(0, -0.13, 0)
        torsoNode.addChildNode(lowerTorsoNode)
        
        // Shoulders (make them broader and more defined)
        let shoulderGeometry = SCNSphere(radius: CGFloat(0.08 * bodyType))
        shoulderGeometry.segmentCount = 24
        let shoulderMaterial = SCNMaterial()
        shoulderMaterial.diffuse.contents = UIColor(shirtColor)
        shoulderMaterial.roughness.contents = 0.6
        shoulderMaterial.lightingModel = .physicallyBased
        shoulderGeometry.materials = [shoulderMaterial]
        
        let leftShoulder = SCNNode(geometry: shoulderGeometry)
        leftShoulder.position = SCNVector3(CGFloat(-0.18 * bodyType), 0.18, 0)
        torsoNode.addChildNode(leftShoulder)
        
        let rightShoulder = SCNNode(geometry: shoulderGeometry)
        rightShoulder.position = SCNVector3(CGFloat(0.18 * bodyType), 0.18, 0)
        torsoNode.addChildNode(rightShoulder)
        
        return torsoNode
    }
    
    private static func buildArm(isLeft: Bool, skinTone: SkinTone, bodyType: Float) -> SCNNode {
        let armNode = SCNNode()
        
        let skinMaterial = SCNMaterial()
        skinMaterial.diffuse.contents = UIColor(skinTone.color)
        skinMaterial.roughness.contents = 0.8
        skinMaterial.lightingModel = .physicallyBased
        
        // Upper arm - tapered capsule for muscle definition
        let upperArmGeometry = SCNCapsule(
            capRadius: CGFloat(0.045 * bodyType),
            height: 0.24
        )
        (upperArmGeometry as SCNCapsule).radialSegmentCount = 24
        upperArmGeometry.materials = [skinMaterial]
        
        let upperArmNode = SCNNode(geometry: upperArmGeometry)
        upperArmNode.position = SCNVector3(0, -0.12, 0)
        armNode.addChildNode(upperArmNode)
        
        // Elbow joint
        let elbowGeometry = SCNSphere(radius: CGFloat(0.04 * bodyType))
        elbowGeometry.segmentCount = 20
        elbowGeometry.materials = [skinMaterial]
        let elbowNode = SCNNode(geometry: elbowGeometry)
        elbowNode.position = SCNVector3(0, -0.24, 0)
        armNode.addChildNode(elbowNode)
        
        // Forearm - slightly thinner capsule
        let forearmGeometry = SCNCapsule(
            capRadius: CGFloat(0.038 * bodyType),
            height: 0.24
        )
        (forearmGeometry as SCNCapsule).radialSegmentCount = 24
        forearmGeometry.materials = [skinMaterial]
        
        let forearmNode = SCNNode(geometry: forearmGeometry)
        forearmNode.position = SCNVector3(0, -0.36, 0)
        armNode.addChildNode(forearmNode)
        
        // Wrist
        let wristGeometry = SCNSphere(radius: CGFloat(0.032 * bodyType))
        wristGeometry.segmentCount = 20
        wristGeometry.materials = [skinMaterial]
        let wristNode = SCNNode(geometry: wristGeometry)
        wristNode.position = SCNVector3(0, -0.48, 0)
        armNode.addChildNode(wristNode)
        
        // Hand - more detailed
        let handGeometry = SCNBox(
            width: CGFloat(0.05 * bodyType),
            height: 0.08,
            length: 0.02,
            chamferRadius: 0.01
        )
        handGeometry.materials = [skinMaterial]
        let handNode = SCNNode(geometry: handGeometry)
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
        
        // Upper leg (thigh) - muscular capsule shape
        let thighGeometry = SCNCapsule(capRadius: 0.068, height: 0.34)
        (thighGeometry as SCNCapsule).radialSegmentCount = 28
        thighGeometry.materials = [legMaterial]
        
        let thighNode = SCNNode(geometry: thighGeometry)
        thighNode.position = SCNVector3(0, -0.17, 0)
        legNode.addChildNode(thighNode)
        
        // Knee joint
        let kneeGeometry = SCNSphere(radius: 0.055)
        kneeGeometry.segmentCount = 24
        kneeGeometry.materials = [legMaterial]
        let kneeNode = SCNNode(geometry: kneeGeometry)
        kneeNode.position = SCNVector3(0, -0.34, 0)
        legNode.addChildNode(kneeNode)
        
        // Lower leg (calf) - tapered shape
        let calfGeometry = SCNCapsule(capRadius: 0.052, height: 0.34)
        (calfGeometry as SCNCapsule).radialSegmentCount = 28
        calfGeometry.materials = [legMaterial]
        
        let calfNode = SCNNode(geometry: calfGeometry)
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
