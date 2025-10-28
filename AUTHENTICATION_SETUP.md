# Authentication Setup Guide

## Overview
Your Nurtra app now has a complete authentication system with Firebase supporting:
- ✅ Email/Password Sign-In
- ✅ Google Sign-In
- ✅ Apple Sign-In

## Files Created

1. **AuthenticationManager.swift** - Handles all authentication logic
2. **LoginView.swift** - Login screen with all sign-in options
3. **SignUpView.swift** - Sign-up screen for new users
4. **Info.plist** - URL scheme configuration (needs update)

## Final Setup Steps

### 1. Update Info.plist with Google Sign-In URL Scheme

The `Info.plist` file has been created, but you need to add the correct Google Sign-In URL scheme:

1. Download the latest `GoogleService-Info.plist` from your Firebase Console:
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Select your project: **nurtra-75777**
   - Go to Project Settings > Your iOS App
   - Download `GoogleService-Info.plist`

2. Look for the `REVERSED_CLIENT_ID` value in the downloaded plist

3. Update `nurtra/Info.plist` by replacing the placeholder:
   ```xml
   <string>com.googleusercontent.apps.420916737489-XXXXXXXXXXXXXXXXXXXXXXX</string>
   ```
   with your actual `REVERSED_CLIENT_ID`, for example:
   ```xml
   <string>com.googleusercontent.apps.420916737489-abc123xyz456.apps.googleusercontent.com</string>
   ```

### 2. Configure Info.plist in Xcode

Since the project uses `GENERATE_INFOPLIST_FILE = YES`, you need to tell Xcode to use the custom Info.plist:

1. Open `nurtra.xcodeproj` in Xcode
2. Select the **nurtra** target
3. Go to the **Build Settings** tab
4. Search for "Info.plist File"
5. Set the value to: `nurtra/Info.plist`
6. Or set `GENERATE_INFOPLIST_FILE` to `NO` and use the custom Info.plist

### 3. Enable Authentication Providers in Firebase Console

Make sure all authentication methods are enabled in Firebase:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Authentication** > **Sign-in method**
4. Enable the following providers:
   - ✅ **Email/Password** - Enable
   - ✅ **Google** - Enable (Web SDK configuration is automatic)
   - ✅ **Apple** - Enable and configure:
     - You'll need an Apple Developer account
     - Add your Bundle ID: `com.psycholabs.nurtra`
     - Configure Services ID and Key in Apple Developer Portal

### 4. Apple Sign-In Configuration

For Apple Sign-In to work, you need to:

1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Find your App ID for `com.psycholabs.nurtra`
4. Enable **Sign in with Apple** capability
5. In Xcode:
   - Select your target
   - Go to **Signing & Capabilities**
   - Click **+ Capability**
   - Add **Sign in with Apple**

### 5. Build and Run

1. Open the project in Xcode:
   ```bash
   open nurtra.xcodeproj
   ```

2. Select a simulator or device
3. Build and run (⌘+R)

## How It Works

### Authentication Flow

1. **App Launch**: 
   - `AuthenticationManager` checks if user is already signed in
   - Shows `LoginView` if not authenticated
   - Shows `MainAppView` if authenticated

2. **Sign In Methods**:
   - **Email/Password**: Direct Firebase authentication
   - **Google**: Uses Google Sign-In SDK, then authenticates with Firebase
   - **Apple**: Uses Sign in with Apple, then authenticates with Firebase

3. **State Management**:
   - `@StateObject` in `Nurtra_V2App` maintains auth state
   - `@EnvironmentObject` provides auth manager to all views
   - Automatic UI updates when auth state changes

### Key Components

- **AuthenticationManager**: `@MainActor` class managing all auth operations
- **LoginView**: Main entry point with all sign-in options
- **SignUpView**: Email registration with password validation
- **ForgotPasswordView**: Password reset via email
- **MainAppView**: Protected content shown after authentication

## Testing

### Test Email Sign-Up/Sign-In
1. Click "Sign Up" on login screen
2. Enter email and password (min 6 characters)
3. Click "Sign Up"
4. You should be authenticated and see the main app

### Test Google Sign-In
1. Click "Continue with Google" button
2. Select a Google account
3. Grant permissions
4. You should be authenticated

### Test Apple Sign-In
1. Click the Apple Sign-In button
2. Authenticate with Face ID/Touch ID/Password
3. Choose to share or hide email
4. You should be authenticated

### Test Sign Out
1. Click "Sign Out" button in main app
2. You should return to login screen

## Troubleshooting

### Google Sign-In Not Working
- Verify `REVERSED_CLIENT_ID` is correct in `Info.plist`
- Check that `GoogleService-Info.plist` is in the project
- Ensure Google provider is enabled in Firebase Console
- Check Xcode console for error messages

### Apple Sign-In Not Working
- Ensure Sign in with Apple capability is added in Xcode
- Verify App ID has Sign in with Apple enabled in Developer Portal
- Make sure Apple provider is enabled in Firebase Console
- Test on a real device (Apple Sign-In requires it for testing)

### Email Sign-In Errors
- Check Firebase Console for email/password provider enabled
- Verify password is at least 6 characters
- Check for valid email format

## Security Notes

- All authentication is handled by Firebase Auth
- Passwords are never stored locally
- User sessions are managed by Firebase SDK
- Sign out properly clears all auth state

## Next Steps

Consider adding:
- Profile management screen
- Email verification flow
- Password strength requirements
- Biometric authentication option
- Remember me functionality
- Social profile data sync

---

**Important**: Make sure to update the `REVERSED_CLIENT_ID` in `Info.plist` before testing Google Sign-In!


