# Adaptive Focus Studio

Adaptive Focus Studio is an offline-first Flutter application for creating focus presets, running timed focus sessions, reviewing session history, and receiving local smart duration recommendations through Session Scout.

The project is developed for **CSC 6360 - Mobile App Development, Section 002** at Georgia State University.

---

## Team

**Team Name:** Boomers

- Harshit Jain
- Parsh Jadon

---

## Project Overview

Adaptive Focus Studio helps users manage focused study or work sessions using reusable presets, local persistence, progress tracking, and personalized duration suggestions.

The application is designed to work without a cloud backend.

Core user flow:

```text
Create Preset
    ↓
Start Focus Session
    ↓
Pause / Resume / Finish / Reset
    ↓
Save Session History
    ↓
Review Insights
    ↓
Receive Session Scout Recommendation
```

---

## Main Features

### Focus Presets

Users can create reusable focus configurations containing:

- preset name
- mood
- planned duration

Preset data is stored locally using SQLite.

### Focus Timer

The focus-session timer supports:

- start
- pause
- resume
- finish
- reset
- progress tracking
- session status display

Timer state is managed using Riverpod.

### History & Insights

The History & Insights screen provides:

- completed-session history
- mood filtering
- average completed duration
- completed-session count
- local summary export

Some history values are currently awaiting final repository integration.

### Session Scout

Session Scout is the application's local smart-helper feature.

It recommends a focus duration using the user's recent successful sessions.

Rules:

```text
Use 3 most recent finished sessions
Match the selected mood
Calculate the median duration
Clamp recommendation between 10 and 60 minutes
Use 25 minutes as the baseline
```

If fewer than three valid matching sessions exist:

```text
Not enough history
```

Session Scout does not automatically start sessions or save data.

The user must explicitly apply the recommendation and can still edit the duration afterward.

For full details, see:

[AI_FEATURE.md](AI_FEATURE.md)

---

## Settings

Application settings are persisted locally using SharedPreferences.

Current settings include:

- default focus duration
- reduced motion
- sound preference
- session reminders

---

## Local Notifications

The application supports local focus-session completion notifications using:

```text
flutter_local_notifications
```

When reminders are enabled, the app can display a notification when a focus session reaches the finished state.

No cloud notification service is required.

---

## File Export

The application includes a local file export feature.

The History & Insights screen can export a text summary containing information such as:

- total completed sessions
- average duration
- selected mood
- Session Scout baseline
- generation date

File access is handled locally using:

```text
path_provider
dart:io
```

---

## Background Processing

Session insight calculations can run outside the main UI isolate using Flutter's:

```text
compute()
```

The `InsightsService` calculates:

- completed-session count
- average completed duration

Cancelled, unfinished, and invalid sessions are ignored.

---

## Animations

The application includes both implicit and explicit Flutter animations.

### Implicit Animation

`AnimatedContainer` is used for focus-session status changes.

### Explicit Animation

`AnimationController` and `ScaleTransition` are used for the session-completion animation.

Reduced-motion settings can disable or shorten animations.

---

## Technology Stack

- Flutter
- Dart
- Riverpod
- SQLite
- SharedPreferences
- flutter_local_notifications
- path_provider
- Flutter Test

---

## Architecture

Adaptive Focus Studio follows a layered architecture.

```text
UI / Screens
    ↓
Riverpod State Management
    ↓
Business Logic / Services
    ↓
Repositories
    ↓
SQLite / SharedPreferences
```

The UI is kept separate from direct database access.

Detailed architecture documentation is available in:

[ARCHITECTURE.md](ARCHITECTURE.md)

---

## Main Data Models

### FocusPreset

```text
id
label
moodTag
plannedSeconds
```

### SessionLog

```text
id
presetId
startedAt
completedSeconds
moodTagSnapshot
status
source
note
```

`SessionLog.presetId` references `FocusPreset.id`.

---

## Project Structure

A simplified structure is shown below:

```text
lib/
├── database/
│   └── database_helper.dart
│
├── models/
│   ├── focus_preset.dart
│   └── session_log.dart
│
├── providers/
│   ├── settings_provider.dart
│   └── timer_provider.dart
│
├── screens/
│   ├── dashboard/
│   ├── focus_session/
│   ├── history/
│   ├── preset_editor/
│   └── settings/
│
├── services/
│   ├── insights_service.dart
│   ├── notification_service.dart
│   ├── session_export_service.dart
│   └── settings_service.dart
│
├── smart_helper/
│   └── session_scout.dart
│
├── widgets/
│   ├── preset_card.dart
│   └── session_scout_card.dart
│
└── main.dart
```

Repository files may be added or updated as final SQLite integration is completed.

---

## Offline-First Design

Adaptive Focus Studio is designed to work without an internet connection.

The application relies on:

- SQLite
- SharedPreferences
- local files
- local notifications
- local calculations

The application does not require:

- Firebase
- Firestore
- cloud authentication
- remote databases
- cloud AI
- external recommendation APIs

---

## Setup

### Requirements

Install:

- Flutter SDK
- Dart SDK
- Android Studio and/or Xcode
- VS Code or another Flutter-compatible editor

Verify Flutter installation:

```bash
flutter doctor
```

---

## Clone the Repository

```bash
git clone https://github.com/harshitjain25/adaptive-focus-studio.git
cd adaptive-focus-studio
```

---

## Install Dependencies

```bash
flutter pub get
```

---

## Run the Application

Check available devices:

```bash
flutter devices
```

Run on a selected device:

```bash
flutter run -d <device-id>
```

Or run using:

```bash
flutter run
```

For native functionality such as file-system operations and local notifications, testing on an Android or iOS device/emulator is recommended.

---

## Static Analysis

Run:

```bash
flutter analyze
```

The goal is:

```text
No issues found
```

---

## Run Tests

Run all tests:

```bash
flutter test
```

Run an individual test file:

```bash
flutter test test/session_scout_test.dart
```

Example test areas include:

- Session Scout algorithm
- timer state management
- background insight calculations
- widgets
- database behavior

---

## Current Testing Strategy

### Unit Tests

Used for:

- timer logic
- Session Scout
- background insights
- database constraints

### Widget Tests

Used for:

- dashboard rendering
- reusable widgets
- screen behavior

### Integration Tests

The final end-to-end flow is intended to verify:

```text
Create Preset
    ↓
Start Session
    ↓
Finish Session
    ↓
Store SessionLog
    ↓
View History
    ↓
Generate Session Scout Recommendation
```

---

## Persistence

### SQLite

Used for structured application data:

- FocusPreset
- SessionLog

### SharedPreferences

Used for lightweight settings:

- default duration
- reduced motion
- sound enabled
- reminders enabled

### Local Files

Used for session-summary export.

---

## Privacy

Adaptive Focus Studio processes user focus data locally.

Session Scout does not send focus history to external services.

No user focus-history data is required to leave the device for recommendation generation.

---

## Current Project Status

Implemented:

- five-screen Flutter application structure
- preset editor UI and validation
- Riverpod timer management
- start / pause / resume / finish / reset workflow
- persistent settings
- reusable preset card
- Session Scout algorithm
- Session Scout UI
- implicit animation
- explicit completion animation
- reduced-motion support
- local file export
- background insight processing
- local notifications
- unit tests
- widget tests
- architecture documentation
- smart-feature documentation

Final integration work includes connecting all screens to the completed SQLite repository layer and replacing temporary sample values with persisted application data.

---

## Documentation

Additional project documentation:

- [ARCHITECTURE.md](ARCHITECTURE.md)
- [AI_FEATURE.md](AI_FEATURE.md)

---

## Development Workflow

The team uses feature branches and pull requests.

Example:

```bash
git checkout main
git pull origin main
git checkout -b feature-name
```

After completing and testing a feature:

```bash
git add .
git commit -m "Meaningful commit message"
git push -u origin feature-name
```

A pull request is then created with:

```text
base: main
compare: feature-name
```

---

## Course

**CSC 6360 - Mobile App Development**  
**Section 002**  
Georgia State University  
Fall 2026
