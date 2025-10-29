# Auto-Playing Quotes Feature

## Overview

The Craving page now automatically plays motivational quotes in sequence using ElevenLabs text-to-speech. When users enter the page, the first quote starts playing automatically, and when it finishes, the next quote begins, creating a continuous loop of encouragement.

## How It Works

### Automatic Playback Flow
1. **User enters Craving page** → Quotes are fetched from Firestore
2. **First quote plays automatically** → Audio is generated and played via ElevenLabs
3. **Quote finishes** → Automatically moves to next quote (with looping: 1→2→3...→10→1)
4. **Next quote plays** → Process repeats indefinitely
5. **User leaves page** → Audio stops automatically

### User Experience
- **No manual interaction needed** - Quotes play automatically in sequence
- **Visual feedback** - Current quote text is displayed with a speaker icon
- **Seamless transitions** - Next quote starts immediately after current one finishes
- **Clean exit** - Audio stops when user navigates away

## Implementation Details

### Files Modified

#### 1. ElevenLabsService.swift
- **Added NSObject inheritance** and `AVAudioPlayerDelegate` conformance
- **Added completion callback** to `playTextToSpeech()` method
- **Implemented `audioPlayerDidFinishPlaying`** delegate method to trigger next quote
- **Callback-based architecture** allows sequential playback

#### 2. CravingView.swift
- **Removed "Next Quote" button** - No longer needed with auto-play
- **Added `playCurrentQuoteAndContinue()`** - Plays quote and sets up next one
- **Updated `.task` modifier** - Automatically starts playback after fetching quotes
- **Added `.onDisappear`** - Cleans up audio when leaving view
- **Simplified UI** - Just shows quote text and passive speaker icon

### Key Features

✅ **Automatic Sequential Playback**
- Quotes play one after another without user interaction
- Seamless transitions between quotes
- Infinite loop through all quotes

✅ **Smart Audio Management**
- Stops audio when user navigates away
- Handles errors gracefully (moves to next quote if generation fails)
- Prevents memory leaks with weak self references

✅ **Clean UI**
- Removed manual controls (Next Quote button)
- Shows passive speaker icon as indicator
- Maintains consistent styling with timer

✅ **Robust Error Handling**
- API failures automatically skip to next quote
- Network issues don't break the flow
- Console logs for debugging

## User Flow Example

```
User opens Craving page
↓
Quotes fetch from Firestore (1-2 seconds)
↓
Quote 1: "You are stronger than your cravings..." 🔊 (10 seconds)
↓
Quote 2: "Every moment of resistance is a victory..." 🔊 (12 seconds)
↓
Quote 3: "Your future self will thank you..." 🔊 (8 seconds)
↓
... continues through all 10 quotes ...
↓
Loops back to Quote 1
↓
Continues until user exits page
```

## Technical Architecture

### Audio Completion Chain
```swift
playCurrentQuoteAndContinue() 
  → ElevenLabsService.playTextToSpeech(text:onFinished:)
    → Generate speech from API
    → Play audio with AVAudioPlayer
    → AVAudioPlayerDelegate.audioPlayerDidFinishPlaying()
      → Call onFinished callback
        → Increment quote index
        → playCurrentQuoteAndContinue() // Recursive call
```

### Memory Safety
- Uses `[weak self]` captures to prevent retain cycles
- Cleans up callbacks after completion
- Stops audio player on view disappear

## Benefits Over Manual Control

1. **Continuous Engagement** - User doesn't need to tap repeatedly
2. **Hands-Free Support** - Perfect for moments of craving when user needs passive support
3. **Immersive Experience** - Voice guidance creates stronger emotional connection
4. **Reduced Friction** - No decisions required, just listen and breathe
5. **Better for Crisis Moments** - When experiencing a craving, less interaction is better

## Future Enhancements

Potential improvements:
- **Pause/Resume control** - Optional manual pause button
- **Playback speed** - Adjust speech rate
- **Quote shuffle mode** - Randomize order
- **Background audio** - Continue playing when app is backgrounded
- **Audio caching** - Cache generated speech to reduce API calls
