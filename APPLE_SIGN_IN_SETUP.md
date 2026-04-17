# Apple Sign In Setup Guide

## Overview
This guide will help you enable "Sign in with Apple" for your Student Haven iOS app.

## Files Added
1. **AppleSignInViewModel.swift** - Handles Apple Sign In authentication logic
2. **SignInWithAppleButton.swift** - Custom SwiftUI component for the Apple Sign In button
3. **NotificationNames.swift** - Centralized notification names
4. **Updated LoginView.swift** - Now includes the Sign in with Apple button

## Xcode Project Configuration

### Step 1: Enable Sign in with Apple Capability
1. Open your project in Xcode (`IOS_Student_Haven.xcodeproj`)
2. Select your app target (`IOS_Studeent_Haven`)
3. Go to the **Signing & Capabilities** tab
4. Click the **+ Capability** button
5. Search for and add **"Sign in with Apple"**

### Step 2: Configure Your Apple Developer Account
1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Select your App ID (Bundle ID)
4. Enable **Sign in with Apple** capability
5. Click **Edit** and configure the Sign in with Apple settings
6. Save your changes

### Step 3: Update Bundle Identifier (if needed)
Make sure your Bundle ID matches the one configured in the Apple Developer Portal.

### Step 4: Add Privacy Usage Description (Optional)
If you want to explain why you're requesting user information, add this to your `Info.plist`:

```xml
<key>NSAppleIDAuthUsageDescription</key>
<string>Sign in with your Apple ID to access Student Haven</string>
```

## How It Works

### User Flow
1. User taps "Sign in with Apple" button on the login screen
2. Apple's authentication sheet appears
3. User authenticates with Face ID/Touch ID or Apple ID password
4. User can choose to:
   - Share their email or hide it (Apple provides a private relay email)
   - Share their name
5. On success, the app receives:
   - User ID (unique identifier from Apple)
   - Email (real or private relay)
   - Full name (optional, only on first sign-in)
   - Identity token for backend verification

### Implementation Details

**AppleSignInViewModel:**
- Manages the Apple Sign In flow
- Handles authorization results
- Creates a User object from Apple ID credentials
- Posts notification to update app state

**SignInWithAppleButton:**
- SwiftUI wrapper for `ASAuthorizationAppleIDButton`
- Handles the Apple Sign In UI presentation
- Integrates with the ViewModel for authentication

**LoginView:**
- Now includes both email/password and Apple Sign In
- Disabled state management during authentication
- Error handling for both auth methods

## Backend Integration (TODO)

Currently, the implementation creates a mock session with Apple ID data. For production:

1. **Send identity token to your backend:**
   ```swift
   // In AppleSignInViewModel.processAppleAuthorization
   let response = try await yourBackendAPI.authenticateWithApple(
       identityToken: identityToken,
       userId: userId
   )
   ```

2. **Backend should:**
   - Verify the identity token with Apple's servers
   - Create or update user in your database
   - Return a session token
   - Link Apple ID with user account

3. **Update AuthRepositoryProtocol:**
   Add a method for Apple Sign In:
   ```swift
   func loginWithApple(identityToken: String, userId: String) async throws -> AuthSession
   ```

## Testing

### Test in Simulator
1. Make sure you're signed in with an Apple ID in the simulator
2. Go to **Settings** > **Apple ID**
3. Sign in with your Apple ID
4. Run the app and test Sign in with Apple

### Test on Device
1. Connect your iPhone/iPad
2. Make sure you're signed in with an Apple ID
3. Build and run the app
4. Test the Sign in with Apple flow

### Important Notes
- First-time sign-in returns the user's name (if they choose to share it)
- Subsequent sign-ins only return the user ID
- Store user information on first sign-in
- Apple provides a unique user ID per app

## Security Considerations

1. **Always verify the identity token** on your backend
2. **Store the user identifier** for future authentication
3. **Handle email privacy** - users can hide their real email
4. **Implement account recovery** - provide alternative authentication methods
5. **Handle revocation** - users can revoke access from their Apple ID settings

## UI/UX Best Practices

✅ **DO:**
- Place Sign in with Apple as the primary option (Apple requirement)
- Use the official Apple button design
- Handle loading states
- Provide clear error messages

❌ **DON'T:**
- Modify the Apple button's appearance beyond allowed customization
- Make Apple Sign In harder to access than other methods
- Require additional registration after Apple Sign In

## Troubleshooting

**Issue: "Sign in with Apple" button doesn't appear**
- Check that the capability is enabled in Xcode
- Verify Bundle ID matches Apple Developer Portal
- Clean build folder (Cmd + Shift + K)

**Issue: Authentication fails**
- Ensure you're signed in with an Apple ID
- Check that the App ID is configured correctly
- Verify network connectivity

**Issue: Can't get user email**
- User may have chosen to hide their email
- Use the private relay email provided by Apple
- Email is only provided on first sign-in

## Resources

- [Apple Sign In Documentation](https://developer.apple.com/sign-in-with-apple/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/#sign-in-with-apple)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple)

## Next Steps

1. ✅ Add Sign in with Apple capability in Xcode
2. ✅ Test the implementation
3. 🔲 Integrate with your backend API
4. 🔲 Implement token refresh logic
5. 🔲 Handle account linking (if users have existing accounts)
6. 🔲 Add analytics for Apple Sign In usage
