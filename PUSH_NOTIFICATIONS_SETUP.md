# 📱 Push Notifications Setup Guide

This guide will walk you through setting up Firebase Cloud Functions to send personalized motivational push notifications using OpenAI.

## 🎯 Overview

The system works as follows:
1. User taps "Test Motivational Push" button in the app
2. App calls Firebase Cloud Function `sendMotivationalNotification`
3. Cloud Function:
   - Fetches user's onboarding data from Firestore
   - Generates a personalized message using OpenAI
   - Sends a push notification to the user's device via FCM

## 📋 Prerequisites

Before starting, make sure you have:
- ✅ Firebase project set up with Firestore
- ✅ iOS app configured with Firebase (GoogleService-Info.plist)
- ✅ Push notifications enabled in iOS app (already done in nurtraApp.swift)
- ✅ OpenAI API key
- ✅ Node.js v18 or higher installed
- ✅ Firebase CLI installed

## 🚀 Step 1: Install Firebase CLI

If you haven't installed Firebase CLI yet:

```bash
npm install -g firebase-tools
```

Log in to Firebase:

```bash
firebase login
```

## 🔧 Step 2: Initialize Firebase Project

Navigate to your project directory:

```bash
cd /Users/giangmichaeldao/project/nurtra
```

Initialize Firebase (if not already done):

```bash
firebase init
```

Select:
- ✅ Functions: Configure and deploy Cloud Functions
- Choose your existing Firebase project
- Select JavaScript
- Install dependencies with npm

## 📦 Step 3: Install Dependencies

Navigate to the functions directory and install dependencies:

```bash
cd functions
npm install
```

This will install:
- `firebase-admin`: For Firebase services
- `firebase-functions`: For Cloud Functions
- `openai`: For OpenAI API integration

## 🔑 Step 4: API Key Configuration (Automatic)

The deployment script will automatically extract your OpenAI API key from `Secrets.swift` and configure it for Firebase Cloud Functions. No manual configuration needed!

**Prerequisites:**
- Ensure your OpenAI API key is properly set in `nurtra/Secrets.swift`
- The key should be in the format: `static let openAIAPIKey = "sk-your-actual-key-here"`

**What happens during deployment:**
1. The script reads your API key from `Secrets.swift`
2. Automatically configures Firebase with the extracted key
3. Validates the key format before deployment

If you need to update your API key, simply modify `Secrets.swift` and redeploy.

## 🚀 Step 5: Deploy Cloud Functions

Deploy the functions to Firebase using the automated script:

```bash
cd functions
./deploy.sh
```

Or manually:
```bash
cd /Users/giangmichaeldao/project/nurtra
firebase deploy --only functions
```

This will deploy the `sendMotivationalNotification` function.

After deployment, you should see output like:
```
✔ Deploy complete!

Functions:
  sendMotivationalNotification(us-central1)
```

## 📱 Step 6: Test the Feature

### A. Test in the iOS App

1. **Build and run the app** on a physical device (push notifications don't work reliably in simulator)

2. **Complete onboarding** if you haven't already (this provides context for personalized messages)

3. **Ensure notifications are enabled**:
   - Go to Settings > Notifications > Nurtra
   - Enable "Allow Notifications"

4. **Tap the "Test Motivational Push" button** on the home screen

5. **Check the notification**:
   - You should see a success alert in the app
   - A push notification should appear with a personalized message
   - Check your notification center if you missed it

### B. Test with Firebase Console

You can also test sending notifications directly from Firebase Console:

1. Go to Firebase Console > Cloud Messaging
2. Click "Send your first message"
3. Enter a test message
4. Select your app
5. Send

### C. Troubleshooting

If notifications aren't working:

1. **Check FCM Token**:
   ```swift
   // In Xcode console, look for:
   🔥 FCM TOKEN (copy this):
   [your-fcm-token]
   ```

2. **Test FCM Token manually** using curl:
   ```bash
   curl -X POST "https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send" \
     -H "Authorization: Bearer YOUR_SERVER_KEY" \
     -H "Content-Type: application/json" \
     -d '{
       "message": {
         "token": "YOUR_FCM_TOKEN",
         "notification": {
           "title": "Test",
           "body": "Hello!"
         }
       }
     }'
   ```

3. **Check Cloud Function Logs**:
   ```bash
   firebase functions:log
   ```

4. **Common Issues**:
   - ❌ "Invalid FCM token": User needs to restart app to refresh token
   - ❌ "OpenAI API error": Check API key configuration
   - ❌ "No onboarding data": User needs to complete onboarding survey
   - ❌ Notifications not showing: Check iOS notification permissions

## 🧪 Step 7: Local Testing (Optional)

You can test functions locally using Firebase emulators:

```bash
cd /Users/giangmichaeldao/project/nurtra
firebase emulators:start --only functions
```

Then in your app, configure Functions to use the emulator:

```swift
// Add this in AppDelegate or nurtraApp.swift
#if DEBUG
Functions.functions().useEmulator(withHost: "localhost", port: 5001)
#endif
```

## 📊 Monitoring

### View Function Logs

```bash
firebase functions:log
```

### View Function Usage

Go to Firebase Console > Functions to see:
- Invocation count
- Execution time
- Error rate
- Memory usage

### Cost Monitoring

Firebase Cloud Functions pricing:
- Free tier: 2M invocations/month
- After free tier: $0.40 per million invocations

OpenAI pricing (GPT-3.5-turbo):
- ~$0.0015 per notification (with ~100 token response)

## 🔐 Security Notes

1. **API Keys**: 
   - Never commit API keys to git
   - Use Firebase environment config for cloud functions
   - Keep Secrets.swift out of version control

2. **Cloud Function Security**:
   - Function requires authentication (context.auth check)
   - Only sends to authenticated user's device
   - Rate limiting is built into Firebase

3. **User Data**:
   - Only accesses user's own data
   - No cross-user data exposure
   - Complies with privacy best practices

## 🔄 Updating the Function

To update the cloud function after making changes:

```bash
cd /Users/giangmichaeldao/project/nurtra
firebase deploy --only functions
```

To update only specific function:

```bash
firebase deploy --only functions:sendMotivationalNotification
```

## 🎨 Customizing Messages

The AI prompt can be customized in `functions/index.js`:

```javascript
const systemPrompt = `You are a compassionate and supportive friend...`;
```

Adjust the:
- Tone (compassionate, firm, casual, etc.)
- Length (currently 2-3 sentences)
- Style (friend, coach, therapist)
- Temperature (0.8 = creative, 0.2 = focused)

## 📈 Next Steps

Consider adding:
- 🕐 **Scheduled notifications**: Use Firebase scheduled functions to send periodic reminders
- 🎯 **Smart timing**: Analyze user patterns to send at optimal times
- 📊 **Analytics**: Track notification effectiveness
- 🔔 **Multiple notification types**: Celebrate milestones, check-ins, etc.
- 🧠 **Improved AI context**: Include recent activity, time of day, etc.

## 🆘 Getting Help

If you encounter issues:

1. Check the logs: `firebase functions:log`
2. Check Xcode console for iOS-side errors
3. Verify all setup steps were completed
4. Test with Firebase Console first
5. Check Firebase documentation: https://firebase.google.com/docs/functions

## ✅ Testing Checklist

Before considering the setup complete:

- [ ] Firebase CLI installed and authenticated
- [ ] Cloud function deployed successfully
- [ ] OpenAI API key configured
- [ ] App builds and runs on physical device
- [ ] Notifications permission granted
- [ ] FCM token visible in console logs
- [ ] Test button appears on home screen
- [ ] Tapping button shows "Sending..." state
- [ ] Success alert appears after tap
- [ ] Push notification appears on device
- [ ] Message is personalized based on user data
- [ ] Function logs show successful execution

---

**🎉 Once all steps are complete, you should be able to send personalized motivational push notifications to users!**

