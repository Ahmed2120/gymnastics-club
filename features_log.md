# Project Features Log

This file tracks all features added, edited, or removed in the Gymnastics Club project.

## [2026-04-24] Fix: Supabase Initialization & Build
- **Issue**: App failed with "No host specified in URI" error on local runs and Play Store.
- **Cause**: Missing `--dart-define-from-file=.env.json` flag during build/run, resulting in empty Supabase credentials.
- **Fix**: 
  - Added validation in `SupabaseConstants` and `SupabaseService`.
  - The app now throws a clear error if credentials are missing instead of failing with a URI error.
- **Resolution**: Rebuild the app with the correct environment flags.
- **Files Modified**: `lib/core/constants/supabase_constants.dart`, `lib/core/services/supabase_service.dart`

## [2026-03-26] News Details Bottom Sheet
- **Feature**: News Details Bottom Sheet
- **Status**: Added
- **Description**: News cards now truncate long content and show "اقرأ المزيد" instead of expanding inline. Tapping opens a premium draggable bottom sheet (`news_details_bottom_sheet.dart`) displaying the full news details (image, type badge, title, date, full content, and like button). Supports light and dark themes.
- **Files Added**: `lib/features/home/widgets/news_details_bottom_sheet.dart`
- **Files Modified**: `lib/features/home/screens/home.dart` – replaced `_ExpandedText` with `_NewsContentPreview`

## [2026-03-19] App Logger Implementation
- **Feature**: Centralized Logging System
- **Description**: Created `AppLogger` class in `lib/core/utils/app_logger.dart` to handle all app logs.
- **Security**: Added `kDebugMode` check to ensure logs are only printed during development and not in production.
- **Refactoring**: Replaced all `print` and `debugPrint` calls across the project with `AppLogger.log`.
- **Files Modified**: 12 files refactored in `gymnastics_club`.


## [2024-03-16] Achievement Spotlight Visual Update
- Updated theme to match user's image: White background card with a subtle Gold border.
- Corrected text colors: Dark Blue for titles, Gold/Brown for rank, and Muted Grey for date.
- Adjusted layout: Positioned yellow star icon before the "أحدث الإنجازات" title.
- Implemented a gold/yellow rounded square container for the trophy icon.
- Restored and themed the sparkle animations to match the gold aesthetic.
- Removed crimson-specific background patterns to maintain focus on the new aesthetic.

## Achievements Page Overhaul (2026-03-15)
- **Feature**: Hero HUD Header
  - **Status**: Updated
  - **Description**: Added a pulsating profile ring around the child's avatar and integrated dynamic rank titles.
- **Feature**: Medal Stats HUD
  - **Status**: Added
  - **Description**: Displays counts for Gold, Silver, and Bronze medals in a HUD-style glassmorphic panel.
- **Feature**: Trophy Gallery Experience
  - **Status**: Added
  - **Description**: Implemented Hero animations expanding achievement cards into a full-screen detail view.
- **Feature**: Achievement Certificate Detail View
  - **Status**: Added
  - **Description**: Full-screen detail screen for achievements with certificate-style layout.
- **Feature**: 3D Staggered Entry Animation
  - **Status**: Added
  - **Description**: Staggered cards entry with 3D rotation and flip effect.
- **Feature**: Sparkle Particles Background
  - **Status**: Added
  - **Description**: Upward drifting floating sparkles for a premium magical feel.
- **Feature**: Mastery Progress Bar
  - **Status**: Removed
  - **Description**: Removed the progress bar as per user request. (2026-03-16)

## Firebase Messaging & Dynamic Quotes (2026-03-16)
- **Feature**: Supabase Edge Function – `send_notification`
  - **Status**: Added
  - **Description**: A Deno Edge Function deployed to Supabase that sends FCM push notifications via the Firebase HTTP v1 API using a service account key. Called from the Dashboard.
- **Feature**: FCM Token Storage
  - **Status**: Added
  - **Description**: Added `fcm_token` columns to `parents` and `children` tables. Client app saves the token on login via `FcmService`.
- **Feature**: Achievement Notification
  - **Status**: Added
  - **Description**: When the Dashboard awards an achievement, it automatically fetches the parent's FCM token and triggers a push notification: "🏆 إنجاز جديد!".
- **Feature**: Dynamic Motivation Quotes
  - **Status**: Added
  - **Description**: Dashboard has a full CRUD screen for managing motivation quotes with an `is_active` flag. Client app Home page now fetches the active quote from Supabase instead of using hardcoded text.
