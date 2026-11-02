# SKY CHAT — Android Studio project

This is an Android WebView wrapper around the SKY CHAT real-voice starter. It includes microphone permission handling and loads the bundled web app from Android assets using a secure appassets origin.

## What is included
- Android Studio / Gradle project (`app/`)
- SKY CHAT branded mobile interface and logo
- Microphone permission bridge for WebRTC audio
- Supabase schema for profiles, rooms, messages and roles
- Existing Supabase + LiveKit web starter UI

## Important: setup is still required
This project is not yet connected to your cloud accounts and is not a signed APK. Real sign-in, shared rooms, chat and live voice will work only after you configure your own Supabase and LiveKit projects.

1. Create a Supabase project and run `supabase/schema.sql` in its SQL Editor.
2. In `app/src/main/assets/index.html`, replace `https://YOUR_PROJECT.supabase.co` and `YOUR_SUPABASE_ANON_KEY` with your Supabase Project URL and anon/public key.
3. Deploy the secure `livekit-token` Supabase Edge Function from the earlier `SKY_CHAT_Real_Voice_Starter` package. Set `LIVEKIT_URL`, `LIVEKIT_API_KEY`, and `LIVEKIT_API_SECRET` as Supabase function secrets. Never put the LiveKit API secret or Supabase service-role key in this Android project.
4. Open this folder in Android Studio, allow Gradle sync, then choose Build → Build Bundle(s) / APK(s) → Build APK(s).
5. Install the generated debug APK on your Android phone for testing. For public distribution, create a signed release build and complete privacy, moderation and store compliance checks.

## Build requirements
- Android Studio with Android SDK 35
- JDK 17
- Internet access for Gradle dependency resolution and the app's Supabase/LiveKit JS modules

## Current limitations
- No APK binary is included; this is the Android Studio source project.
- Backend credentials and deployment are not included.
- Gifts, coin purchases, payments and cash-out are UI concepts only, not real money features.
- This starter has not undergone a security audit or production testing.
