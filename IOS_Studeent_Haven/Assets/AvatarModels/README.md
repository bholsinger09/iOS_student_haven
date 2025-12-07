# Avatar 3D Models - Setup Instructions

This app uses pre-made 3D avatar models stored in the app bundle for offline use.

## Required Models

The app expects the following GLB model files in `IOS_Studeent_Haven/Assets/AvatarModels/`:

### Male Avatars (5 models needed):
- `male_casual_1.glb` - Casual male (Caucasian, average build)
- `male_athletic_1.glb` - Athletic male (African, athletic build)
- `male_slim_1.glb` - Slim male (Asian, slim build)
- `male_casual_2.glb` - Casual male (Latino, average build)
- `male_formal_1.glb` - Formal male (Caucasian, average build)

### Female Avatars (5 models needed):
- `female_casual_1.glb` - Casual female (Caucasian, average build)
- `female_athletic_1.glb` - Athletic female (African, athletic build)
- `female_slim_1.glb` - Slim female (Asian, slim build)
- `female_casual_2.glb` - Casual female (Latino, average build)
- `female_formal_1.glb` - Formal female (Caucasian, average build)

### Non-binary Avatars (2 models needed):
- `neutral_casual_1.glb` - Neutral casual (Caucasian, slim build)
- `neutral_casual_2.glb` - Neutral casual (Mixed, average build)

## Where to Find Free 3D Models

### Option 1: Mixamo (Adobe - Best Option)
1. Visit https://www.mixamo.com
2. Sign in with Adobe account (free)
3. Browse the Characters section
4. Select diverse characters matching the list above
5. Download as FBX, then convert to GLB using online converter

### Option 2: Quaternius (CC0 License - Completely Free)
1. Visit https://quaternius.com/packs.html
2. Download "Ultimate Animated Character Pack"
3. Includes diverse humanoid models
4. Already in GLB/GLTF format

### Option 3: Sketchfab (Various Licenses)
1. Visit https://sketchfab.com
2. Search for "human character" or "avatar"
3. Filter by "Downloadable" and "Free"
4. Check license (look for CC0 or CC-BY)
5. Download as GLB format

### Option 4: Ready Player Me Export (If Available)
1. Create avatars at https://readyplayer.me
2. Some third-party tools can export GLB files
3. Note: This may violate Terms of Service - use cautiously

### Option 5: Blender Creation (Custom)
1. Use Blender to create custom avatars
2. Export as GLB format
3. Ensures full control and licensing

## Converting Models to GLB

If you download FBX or other formats, convert using:

### Online Converters:
- https://products.aspose.app/3d/conversion/fbx-to-glb
- https://anyconv.com/fbx-to-glb-converter/

### Command Line (Blender):
```bash
blender --background --python convert_to_glb.py -- input.fbx output.glb
```

## Model Requirements

Each GLB model should:
- Be a complete humanoid character (rigged or unrigged)
- Include basic clothing/texture
- Be between 1.5-2.0 meters tall (will be auto-scaled)
- Be under 5MB in size (mobile optimization)
- Have named materials for customization:
  - "skin" or "body" materials for skin tone replacement
  - "hair" materials for hair color replacement
  - "shirt"/"top" materials for top clothing
  - "pants"/"bottom" materials for bottom clothing
  - "shoe" materials for footwear

## Adding Models to Xcode Project

1. Place GLB files in `IOS_Studeent_Haven/Assets/AvatarModels/`
2. In Xcode, right-click project → "Add Files to IOS_Student_Haven"
3. Select the AvatarModels folder
4. Ensure "Create folder references" is selected (BLUE folder, not yellow)
5. Ensure target is checked for IOS_Student_Haven

## Placeholder Behavior

If models are missing:
- App will show placeholder geometric avatars with labels
- Still functional for testing
- Replace with real models before production

## License Compliance

Ensure all 3D models used:
- Have appropriate licenses for commercial use
- Are attributed if required by license
- Do not violate terms of service
- Consider adding attribution section in app settings

## Recommended: Start with Mixamo

For quickest setup:
1. Go to Mixamo.com
2. Download 12 diverse characters
3. Convert to GLB
4. Rename to match expected filenames
5. Total time: ~30 minutes
