# ElevenLabs Text-to-Speech Setup Guide

## Overview

This feature adds audio playback of motivational quotes using ElevenLabs' text-to-speech API. Users can click the speaker button next to "Next Quote" to hear the current quote spoken aloud.

## Implementation Summary

### Files Created
1. **`nurtra/ElevenLabsService.swift`** - Handles ElevenLabs API communication and audio playback
2. **`ELEVENLABS_SETUP.md`** - This setup guide

### Files Modified
1. **`nurtra/Secrets.swift`** - Added ElevenLabs API key and voice ID
2. **`nurtra/CravingView.swift`** - Added audio button and ElevenLabs integration

## Setup Instructions

### Step 1: Add ElevenLabsService.swift to Xcode Project

1. **Open Xcode** with your nurtra.xcodeproj
2. **Right-click** on the "nurtra" folder in the project navigator
3. **Select** "Add Files to 'nurtra'"
4. **Navigate** to the nurtra folder and select `ElevenLabsService.swift`
5. **Make sure** "Add to target: nurtra" is checked
6. **Click** "Add"

### Step 2: Get Your ElevenLabs API Key

1. **Sign up** at [ElevenLabs](https://elevenlabs.io/)
2. **Go to** your profile settings
3. **Copy** your API key from the API section

### Step 3: Update Your API Key

1. **Open** `nurtra/Secrets.swift`
2. **Replace** `"YOUR_ELEVENLABS_API_KEY_HERE"` with your actual API key:
   ```swift
   static let elevenLabsAPIKey = "your-actual-api-key-here"
   ```

### Step 4: Voice Configuration (Optional)

The default voice is Rachel (ID: `21m00Tcm4TlvDq8ikWAM`) - a calm, soothing voice perfect for motivational content.

To use a different voice:
1. **Browse voices** at [ElevenLabs Voice Library](https://elevenlabs.io/voice-library)
2. **Copy the voice ID** from your chosen voice
3. **Update** `elevenLabsVoiceID` in `Secrets.swift`

### Step 5: Test the Feature

1. **Build and run** the app
2. **Navigate** to the Craving page
3. **Tap the speaker button** next to "Next Quote"
4. **Listen** to your motivational quote!

## Features

- **High-quality speech synthesis** using ElevenLabs' multilingual model
- **Seamless integration** with existing quote system
- **Audio controls** - automatically stops previous audio when playing new quote
- **Error handling** for network issues and API errors
- **Secure API key storage** in Secrets.swift (already in .gitignore)

## Troubleshooting

### "ElevenLabs API key not configured" Warning
- Ensure you've replaced the placeholder in `Secrets.swift`
- Check that the API key doesn't contain placeholder text

### No Audio Playback
- Check device volume and silent mode
- Verify network connection for API calls
- Check console logs for specific error messages

### API Errors
- **401 Unauthorized**: Check API key validity
- **429 Rate Limit**: You've exceeded ElevenLabs rate limits
- **500 Server Error**: ElevenLabs service issue, try again later

## API Usage & Costs

- **Free tier**: 10,000 characters per month
- **Paid plans**: Available for higher usage
- **Character count**: Each quote uses ~50-200 characters depending on length
- **Optimization**: Audio is generated on-demand (not cached)

## Security Notes

- API key is stored in `Secrets.swift` which is in `.gitignore`
- Never commit your actual API key to version control
- ElevenLabs API calls are made over HTTPS

## Future Enhancements

Potential improvements you could add:
- **Audio caching** to avoid re-generating the same quote
- **Voice selection** in app settings
- **Playback controls** (pause/resume)
- **Speed/pitch adjustment** options
