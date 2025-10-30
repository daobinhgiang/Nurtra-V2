# 🚀 Quick Start: Push Notifications

Get personalized motivational push notifications working in 5 minutes!

## Prerequisites

- ✅ Physical iOS device (push notifications don't work well in simulator)
- ✅ Xcode installed
- ✅ OpenAI API key (you already have this in Secrets.swift)
- ✅ Node.js v18+ installed

## Step-by-Step Setup

### 1. Install Firebase CLI (if not already installed)

```bash
npm install -g firebase-tools
firebase login
```

### 2. Navigate to Project Directory

```bash
cd /Users/giangmichaeldao/project/nurtra
```

### 3. Initialize Firebase (if not done)

```bash
firebase init
```

Select:
- Functions
- Use your existing Firebase project

### 4. Configure OpenAI API Key

```bash
# API key is automatically extracted from Secrets.swift during deployment
```

### 5. Install Dependencies & Deploy

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

Or use the deployment script:

```bash
chmod +x functions/deploy.sh
./functions/deploy.sh
```

### 6. Update Firebase Project ID

Edit `.firebaserc` and replace `YOUR_FIREBASE_PROJECT_ID` with your actual Firebase project ID.

### 7. Test in the App

1. **Build and run** the app on a **physical device**
2. **Enable notifications** when prompted
3. **Complete onboarding** if you haven't already
4. **Tap the orange "Test Motivational Push" button** on the home screen
5. **Wait a few seconds** - you should see:
   - A success alert in the app
   - A push notification with a personalized message!

## 🎉 That's It!

You now have personalized AI-powered push notifications working!

## Troubleshooting

### "Cloud function failed"
- Run: `firebase deploy --only functions`
- Check logs: `firebase functions:log`

### "No FCM token"
- Restart the app
- Check notification permissions in iOS Settings

### "OpenAI error"
- Verify API key: `firebase functions:config:get`
- Check OpenAI account has credits

### Notification doesn't appear
- Make sure you're on a physical device (not simulator)
- Check iOS Settings > Notifications > Nurtra is enabled
- Look in Xcode console for FCM token logs

## View Logs

```bash
firebase functions:log
```

## Cost

Very minimal:
- ~$0.001 per notification (0.1 cents)
- Free tier covers 2M function calls/month

## Next Steps

See `PUSH_NOTIFICATIONS_SETUP.md` for:
- Detailed troubleshooting
- Customizing messages
- Scheduling notifications
- Production deployment tips

---

**Need help?** Check the full setup guide in `PUSH_NOTIFICATIONS_SETUP.md`

