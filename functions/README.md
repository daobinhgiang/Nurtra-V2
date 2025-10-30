# Nurtra Cloud Functions

This directory contains Firebase Cloud Functions for the Nurtra app.

## Functions

### `sendMotivationalNotification`

A callable HTTP function that generates and sends personalized motivational push notifications to users.

**Trigger**: Called directly from the iOS app when user taps "Test Motivational Push" button

**Authentication**: Required (Firebase Auth)

**What it does**:
1. Fetches user's onboarding data from Firestore
2. Generates a personalized motivational message using OpenAI GPT-3.5
3. Sends a push notification via Firebase Cloud Messaging (FCM)

**Parameters**: None (uses authenticated user's ID from context)

**Returns**:
```javascript
{
  success: boolean,
  message: string,        // The generated message
  messageId: string      // FCM message ID
}
```

**Errors**:
- `unauthenticated`: User must be logged in
- `not-found`: User data not found in Firestore
- `failed-precondition`: No FCM token or invalid token
- `internal`: OpenAI API or FCM errors

## Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. API key is automatically configured from `Secrets.swift` during deployment

3. Deploy using the automated script:
   ```bash
   ./deploy.sh
   ```
   
   Or manually:
   ```bash
   firebase deploy --only functions
   ```

## Local Development

Run the emulator:
```bash
npm run serve
```

This starts the Functions emulator at http://localhost:5001

## Testing

### Test from iOS app
- Tap "Test Motivational Push" button

### Test with curl
```bash
curl -X POST https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/sendMotivationalNotification \
  -H "Authorization: Bearer YOUR_ID_TOKEN" \
  -H "Content-Type: application/json"
```

## Logs

View logs in console:
```bash
firebase functions:log
```

View logs in Firebase Console:
Go to Firebase Console > Functions > Logs

## Dependencies

- `firebase-admin`: Firebase Admin SDK for accessing Firestore and FCM
- `firebase-functions`: Cloud Functions SDK
- `openai`: OpenAI API client for GPT-3.5

## Environment Variables

- `openai.key`: OpenAI API key (automatically configured from `Secrets.swift`)

The API key is automatically extracted from `nurtra/Secrets.swift` during deployment. No manual configuration needed.

Get current config:
```bash
firebase functions:config:get
```

## Cost Estimates

**Firebase Cloud Functions**:
- Free tier: 2M invocations/month
- Cost per invocation: $0.40 per million
- Estimated: ~$0.0004 per notification

**OpenAI GPT-3.5-turbo**:
- Input: ~200 tokens at $0.0015/1K tokens
- Output: ~100 tokens at $0.002/1K tokens
- Estimated: ~$0.0005 per notification

**Total cost per notification**: ~$0.001 (0.1 cents)

For 1000 notifications/day: ~$30/month

## Security

- Function requires Firebase Authentication
- Only sends to authenticated user's own device
- No cross-user data access
- Rate limiting provided by Firebase
- API keys stored securely in Firebase config

## Troubleshooting

**"Invalid FCM token"**
- User needs to restart app to refresh token
- Check that app is requesting notification permissions

**"OpenAI API error"**
- Verify API key is set: `firebase functions:config:get`
- Check OpenAI account has credits
- Check API key permissions

**"No onboarding data"**
- User must complete onboarding survey first
- Function will use generic message as fallback

**Notification not appearing**
- Check iOS notification permissions
- Test on physical device (not simulator)
- Check FCM token in Xcode console logs
- Verify APNs certificates in Firebase Console

