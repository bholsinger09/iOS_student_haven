# AI Avatar Integration - Setup Guide

## Overview
The app now supports **AI-generated realistic 3D avatars** using the Avaturn API. Users can either:
- Build a custom avatar from scratch (procedural generation)
- Take a photo and generate a photo-realistic AI avatar

## Getting Started with Avaturn

### 1. Sign Up for Avaturn API
1. Visit https://avaturn.me
2. Create an account
3. Navigate to the API section
4. Get your API key

### 2. Configure API Key
Open `Services/AvaturnAPIService.swift` and replace:
```swift
private let apiKey = "YOUR_AVATURN_API_KEY"
```
With your actual API key:
```swift
private let apiKey = "sk_live_YOUR_ACTUAL_KEY_HERE"
```

### 3. Pricing
- **Free Tier**: 10 avatar generations/month
- **Starter**: $29/month - 100 avatars
- **Pro**: $99/month - 500 avatars
- **Enterprise**: Custom pricing

Each avatar generation costs approximately $0.20-0.30

## How It Works

### User Flow
1. User taps "Create Avatar" in My Avatar section
2. Chooses between "Custom" or "AI Avatar"
3. If AI Avatar:
   - Takes photo or chooses from library
   - Photo is uploaded to Avaturn API
   - AI generates realistic 3D model (~10-30 seconds)
   - GLB model is downloaded and cached locally
   - Avatar appears in 3D with full rotation support

### Technical Flow
```
Photo Capture → Avaturn API Upload → 3D Model Generation → 
GLB Download → Local Storage → SceneKit Rendering
```

### Files Added
- **Services/AvaturnAPIService.swift** - API integration
- **Services/GLBModelLoader.swift** - 3D model loader for GLB files
- **Views/PhotoCaptureView.swift** - Camera/photo library interface
- **Models/AvatarModels.swift** - Added `aiAvatarId` and `aiModelURL` fields

### Files Modified
- **Views/AvatarCreatorView.swift** - Added AI avatar option
- **Views/AvatarRenderer3D.swift** - Supports both procedural and GLB models

## Features

### AI Avatar Capabilities
✅ Photo-realistic 3D models from selfies
✅ Full body generation with proper proportions
✅ Age-appropriate body shapes (18-65+)
✅ Gender-specific modeling
✅ Customizable clothing (mapped to app's clothing store)
✅ Offline support (cached GLB models)
✅ Smooth 360° rotation
✅ Physically-based rendering (PBR)

### Fallback Behavior
If Avaturn API fails or is unavailable, the app automatically falls back to the procedural avatar builder with no user disruption.

## Camera Permissions
Add to `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to create your realistic 3D avatar</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to create your realistic 3D avatar</string>
```

## Storage Requirements
- Average GLB model size: 2-5 MB
- Models cached in: `Documents/avatars/`
- Automatic cleanup available via `AvaturnAPIService.deleteCachedAvatar()`

## Testing Without API Key
The app will build and run without a valid API key. The "AI Avatar" option will appear but will fallback to procedural generation if API calls fail.

## Alternative Options (for reference)
If Avaturn doesn't meet your needs:
- **Ready Player Me**: Free but requires web-based creation
- **Meshcapade**: Higher quality, $0.50-1.00 per avatar
- **Apple Vision Framework**: Free but requires ARKit/camera always

## Support
Avaturn documentation: https://docs.avaturn.me
Avaturn Discord: https://discord.gg/avaturn
