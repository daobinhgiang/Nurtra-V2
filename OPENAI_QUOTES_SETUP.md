# OpenAI Motivational Quotes Feature - Setup Guide

## Overview

This feature automatically generates 10 personalized motivational quotes using OpenAI's Chat API after a user completes the onboarding survey. The quotes are generated in the background and saved to Firestore.

## Implementation Summary

### Files Created
1. **`nurtra/OpenAIService.swift`** - Handles OpenAI API communication
2. **`nurtra/QuoteGenerationService.swift`** - Coordinates the quote generation flow
3. **`nurtra/Secrets.swift`** - Secure storage for API key (in .gitignore)
4. **`OPENAI_QUOTES_SETUP.md`** - This setup guide

### Files Modified
1. **`nurtra/FirestoreManager.swift`** - Added quote storage methods
2. **`nurtra/OnboardingSurveyView.swift`** - Triggers quote generation
3. **`nurtra/Info.plist`** - Added OPENAI_API_KEY reference

## Setup Instructions

### Step 1: Add Your OpenAI API Key

1. **Get your API key** from [OpenAI Platform](https://platform.openai.com/api-keys)

2. **Update `nurtra/Secrets.swift`**:
   ```swift
   enum Secrets {
       static let openAIAPIKey = "sk-your-actual-api-key-here"
   }
   ```

3. **Important Security**: `Secrets.swift` is already in `.gitignore` to prevent accidentally committing your API key

### Step 2: Update Firestore Security Rules

Add rules to allow users to read/write their user document (quotes are stored in the same document):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read and write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Step 3: Test the Feature

1. **Build and run** the app
2. **Sign up** with a new account
3. **Complete** the onboarding survey
4. **Check console logs** for quote generation progress:
   ```
   🎯 Starting quote generation in background...
   📝 Calling OpenAI API...
   ✨ Generated 10 quotes:
     1. [Quote text]
     2. [Quote text]
     ...
   💾 Saving quotes to Firestore...
   ✅ Quote generation completed successfully!
   ```

5. **Verify in Firestore Console**:
   - Navigate to Firestore Database
   - Go to `users/{userId}` document
   - You should see a `motivationalQuotes` field with 10 numbered quotes (quote1, quote2, etc.)
   - You should also see `motivationalQuotesGeneratedAt` timestamp

## How It Works

### Flow Diagram

```
User completes onboarding
         ↓
OnboardingSurveyView.submitSurvey()
         ↓
Save responses to Firestore
         ↓
QuoteGenerationService.generateQuotesInBackground() [Background Task]
         ↓
OpenAIService.generateMotivationalQuotes()
         ↓
Build personalized prompt from survey responses
         ↓
Call OpenAI Chat API (gpt-3.5-turbo)
         ↓
Parse 10 quotes from response
         ↓
FirestoreManager.saveMotivationalQuotes()
         ↓
Save each quote as separate document
         ↓
User can access quotes later (when UI is built)
```

### Key Features

1. **Non-Blocking**: Runs in background using `Task.detached`
2. **Personalized**: Uses all 8 onboarding responses to create tailored quotes
3. **Error Handling**: Graceful failure - user not blocked if generation fails
4. **Firestore Structure**: Each quote is a separate document for easy querying
5. **Logging**: Comprehensive console logs for debugging

## API Details

### OpenAI Request
- **Model**: `gpt-3.5-turbo`
- **Temperature**: `0.9` (for creative variation)
- **Max Tokens**: `1000`
- **System Prompt**: Specialized therapist role for eating disorder recovery

### Prompt Template
The prompt includes:
- Duration of struggle
- Frequency of binges
- Importance of recovery
- Vision without binge eating
- Common thoughts during binges
- Triggers
- What matters most
- Recovery values

### Response Parsing
- Expects numbered list format (1. Quote\n2. Quote\n...)
- Extracts exactly 10 quotes
- Validates quote count before saving

## Firestore Data Structure

```
users/
  {userId}/
    - onboardingCompleted: true
    - onboardingCompletedAt: Timestamp
    - onboardingResponses: {
        struggleDuration: [...],
        bingeFrequency: [...],
        importanceReason: [...],
        lifeWithoutBinge: [...],
        bingeThoughts: [...],
        bingeTriggers: [...],
        whatMattersMost: [...],
        recoveryValues: [...]
      }
    - motivationalQuotes: {
        quote1: "Your first personalized quote...",
        quote2: "Your second personalized quote...",
        quote3: "Your third personalized quote...",
        ...
        quote10: "Your tenth personalized quote..."
      }
    - motivationalQuotesGeneratedAt: Timestamp
```

**Benefits of this structure:**
- All user data in one document (easier to query)
- Consistent with onboardingResponses format
- Simple numbered fields (quote1, quote2, etc.)
- No subcollections needed
- Single read/write operation

## Retrieving Quotes

To display quotes in your UI later:

```swift
let firestoreManager = FirestoreManager()

do {
    let quotes = try await firestoreManager.fetchMotivationalQuotes()
    // quotes is an array of MotivationalQuote objects
    // Display in your UI
} catch {
    print("Error fetching quotes: \(error)")
}
```

## Troubleshooting

### "Missing API Key" Warning
- Ensure `Config.xcconfig` is properly configured
- Check that it's linked in Build Settings
- Verify API key is not empty or still contains placeholder

### API Errors
- **401 Unauthorized**: Check API key validity
- **429 Rate Limit**: You've exceeded OpenAI rate limits
- **500 Server Error**: OpenAI service issue, will retry later

### No Quotes Generated
- Check console logs for errors
- Verify Firestore security rules allow write access
- Ensure user is authenticated when generating quotes

### Quotes Not Appearing in Firestore
- Check Firestore security rules
- Verify user document path: `users/{userId}/motivationalQuotes`
- Look for error logs in console

## Cost Estimation

Using `gpt-3.5-turbo`:
- **Input tokens**: ~400-600 tokens (prompt with onboarding data)
- **Output tokens**: ~300-500 tokens (10 quotes)
- **Cost per user**: ~$0.0010-0.0015 USD
- **For 1000 users**: ~$1.00-1.50 USD

*Prices as of October 2024. Check [OpenAI Pricing](https://openai.com/pricing) for current rates.*

## Production Recommendations

### Option 1: Use Firebase Cloud Functions (Recommended)

For better security and scalability, implement as a Cloud Function:

```javascript
// functions/index.js
exports.generateQuotes = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap, context) => {
    const responses = snap.data().onboardingResponses;
    const quotes = await callOpenAI(responses);
    await saveQuotes(context.params.userId, quotes);
  });
```

**Benefits**:
- API key stays server-side
- Better rate limiting control
- Automatic retry logic
- Monitoring and logging
- No client-side API exposure

### Option 2: Keep Client-Side (Current Implementation)

If keeping client-side:
- Use Firebase Remote Config for API key
- Implement request signing
- Add usage monitoring
- Set up alerts for unusual activity

## Next Steps

1. **Build UI** to display quotes to users
2. **Add refresh feature** to regenerate quotes
3. **Implement favorites** for users to save preferred quotes
4. **Add sharing** functionality
5. **Track analytics** on quote generation success/failure

## Support

For issues or questions:
- Check console logs for detailed error messages
- Verify all setup steps are completed
- Test with a fresh user account
- Check Firestore Console for data

## Security Notes

⚠️ **IMPORTANT**: 
- Never commit `Config.xcconfig` with real API keys
- Add to `.gitignore` immediately
- For production, use Firebase Cloud Functions
- Monitor OpenAI usage in your dashboard
- Set up spending limits on OpenAI account

