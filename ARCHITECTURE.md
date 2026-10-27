# Adaptive Focus Studio – Architecture

## 1. Overview

Adaptive Focus Studio is an offline-first Flutter application designed to help users create focus presets, run timed focus sessions, review session history, and receive local smart duration suggestions through Session Scout.

The application uses a layered architecture so that UI, state management, business logic, persistence, and platform services remain separated.

The project does not depend on a cloud backend. All persistent application data is stored locally.

---

## 2. Technology Stack

- Flutter
- Dart
- Riverpod
- SQLite
- SharedPreferences
- flutter_local_notifications
- path_provider

---

## 3. High-Level Architecture

The application is divided into the following layers:

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

Platform-specific features such as notifications and local file operations are handled through dedicated services.

---

## 4. Presentation Layer

The presentation layer contains the Flutter screens and reusable widgets.

Main screens:

- Dashboard
- Create / Edit Preset
- Focus Session
- History & Insights
- Settings

Reusable widgets include:

- PresetCard
- SessionScoutCard

The presentation layer is responsible for:

- displaying application state
- collecting user input
- navigation
- buttons and gestures
- dialogs
- animations
- showing errors and success messages

The UI should not directly communicate with SQLite.

---

## 5. State Management

Riverpod is used for application state management.

Current Riverpod-managed features include:

- focus timer state
- application settings

Examples:

```text
focusTimerProvider
settingsProvider
```

Riverpod allows state to be shared reactively between screens while keeping business logic outside widgets.

The timer provider controls:

- start
- pause
- resume
- finish
- reset
- remaining time
- timer status
- progress

The settings provider manages persistent settings such as:

- default duration
- reduced motion
- sound preference
- reminder preference

---

## 6. Data Layer

The application uses SQLite for structured persistent data.

Two related entities are used.

### FocusPreset

Stores reusable focus configurations.

Fields include:

```text
id
label
moodTag
plannedSeconds
```

### SessionLog

Stores completed or interrupted focus-session information.

Fields include:

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

Foreign key enforcement is enabled in SQLite.

The relationship allows one preset to have multiple session logs.

---

## 7. Repository Pattern

The repository layer separates application logic from SQLite implementation details.

The intended structure is:

```text
UI
 ↓
Provider
 ↓
Repository interface
 ↓
SQLite repository implementation
 ↓
DatabaseHelper
 ↓
SQLite
```

Examples include:

```text
FocusPresetRepository
SessionLogRepository
```

Repository responsibilities include:

- create
- read
- update
- delete
- querying session history
- filtering completed sessions
- retrieving recent sessions for Session Scout

This architecture makes the application easier to test because repository implementations can later be replaced with fake repositories during testing.

---

## 8. Local Preferences

SharedPreferences stores lightweight user settings that do not require relational storage.

Examples include:

- default focus duration
- reduced motion
- sound enabled
- reminders enabled

These values persist when the application is restarted.

---

## 9. Focus Timer Architecture

The focus timer is controlled by Riverpod rather than being directly owned by the screen.

Timer states include:

```text
idle
running
paused
finished
```

The provider owns the periodic Dart timer and manages lifecycle cleanup.

Important actions include:

```text
start()
pause()
resume()
finish()
reset()
```

This design reduces duplicate timer callbacks and prevents timer logic from being scattered throughout the UI.

When the provider is disposed, the active Dart timer is cancelled.

---

## 10. Session Scout

Session Scout is the local smart-helper feature.

It does not require cloud AI or network access.

The algorithm:

1. Selects finished sessions matching the chosen mood.
2. Sorts them by most recent session.
3. Uses the three most recent valid sessions.
4. Converts completed duration from seconds to minutes.
5. Calculates the median.
6. Clamps the recommendation between 10 and 60 minutes.
7. Returns no personalized recommendation when fewer than three valid sessions exist.

A fixed 25-minute baseline is retained for comparison.

Example:

```text
Recent sessions:
20 minutes
30 minutes
25 minutes

Sorted:
20, 25, 30

Median:
25 minutes
```

Session Scout never automatically starts a focus session or saves a preset.

The user must explicitly apply the recommendation and may still edit the duration afterward.

---

## 11. Background Processing

Session insight calculations can be processed using Flutter's `compute()` function.

The `InsightsService` moves statistics processing away from the main UI isolate.

Currently calculated statistics include:

- completed-session count
- average completed duration

The background function ignores:

- cancelled sessions
- unfinished sessions
- invalid negative durations

This keeps larger calculations from blocking UI rendering.

---

## 12. Local Notifications

Local notifications are implemented using:

```text
flutter_local_notifications
```

The `NotificationService` manages:

- notification initialization
- permission requests
- completion notifications
- notification cancellation

Notifications are controlled by the user's reminder preference.

When reminders are enabled and a timer changes to the `finished` state, the application can display a local focus-session-complete notification.

No cloud notification service is required.

---

## 13. File System Operations

The application includes local file export through `SessionExportService`.

The service uses:

```text
path_provider
dart:io
```

It exports a local session-summary text file.

Example information includes:

- total completed sessions
- average duration
- selected mood
- Session Scout baseline
- generation date

The service can also read the exported summary back from local storage.

This functionality remains completely offline.

---

## 14. Animations

The application contains both implicit and explicit animations.

### Implicit Animation

`AnimatedContainer` is used to visually represent changes in focus-session status.

Examples include different visual states for:

- running
- paused
- finished
- idle

### Explicit Animation

`AnimationController` and `ScaleTransition` are used to animate the completion checkmark when a session finishes.

The controller is disposed correctly with the widget lifecycle.

When reduced motion is enabled, animations are shortened or skipped.

---

## 15. Dependency Injection

Riverpod is used as the primary dependency-injection mechanism.

Services, repositories, and state objects can be exposed through providers instead of being created directly inside UI widgets.

This improves:

- testability
- separation of concerns
- maintainability
- replacement of implementations

---

## 16. Error Handling

User-visible failures are handled using messages such as SnackBars and dialogs.

Examples include:

- invalid preset input
- failed file export
- notification permission rejection
- restricted preset deletion
- insufficient Session Scout history

Errors should not fail silently.

---

## 17. Testing Strategy

The project uses multiple levels of testing.

### Unit Tests

Used for isolated business logic such as:

- timer state transitions
- Session Scout algorithm
- background insight calculations
- database constraints

### Widget Tests

Used for UI components and screen behavior.

Examples include:

- dashboard rendering
- Session Scout card states
- navigation
- button availability

### Integration Testing

Integration testing will verify important end-to-end flows such as:

```text
Create preset
→ Start session
→ Finish session
→ Save SessionLog
→ View history
→ Generate Session Scout recommendation
```

---

## 18. Offline-First Design

Adaptive Focus Studio is designed to operate without network connectivity.

The application relies on:

```text
SQLite
SharedPreferences
local files
local notifications
local calculations
```

No Firebase, Firestore, cloud authentication, remote database, or cloud AI service is required.

This makes the application usable even when the device has no internet connection.

---

## 19. Current Integration Status

The application currently includes:

- Flutter screen structure
- reusable widgets
- Riverpod timer state
- persistent settings
- Session Scout algorithm
- Session Scout UI
- timer animations
- background insight processing
- local file export
- local notifications
- unit and widget tests

The SQLite repository layer is being integrated separately.

Once repository integration is complete, temporary sample values in the UI will be replaced with real persisted data.

---

## 20. Planned Final Data Flow

The final focus-session workflow is:

```text
User selects preset
        ↓
FocusPreset loaded from repository
        ↓
Timer provider receives planned duration
        ↓
User starts session
        ↓
Timer runs
        ↓
User finishes / timer completes
        ↓
SessionLog saved through repository
        ↓
History provider refreshes
        ↓
Insights calculated
        ↓
Session Scout uses recent completed sessions
        ↓
Recommendation displayed to user
```

---

## 21. Design Goals

The architecture was designed around the following goals:

- offline operation
- separation of concerns
- testability
- reactive state
- reusable components
- persistent user preferences
- reliable timer lifecycle
- local smart assistance
- accessibility through reduced motion
- maintainable graduate-level application structure
