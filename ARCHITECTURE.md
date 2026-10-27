
# Adaptive Focus Studio — Architecture

## 1. Project Overview

Adaptive Focus Studio is an offline-first Flutter application
designed to help students manage focus sessions, save study
history, and receive personalized duration suggestions.

The application uses SQLite for persistent records,
SharedPreferences for lightweight settings, and Riverpod
for state management.

No cloud backend or online AI service is required.

## 2. Architecture

The project follows a layered architecture:

Flutter UI
    ↓
Riverpod State Management
    ↓
Repository Interfaces
    ↓
SQLite Repository Implementations
    ↓
DatabaseHelper
    ↓
SQLite Database

Each layer has a specific responsibility.

### Presentation Layer

Contains the five primary screens:

- Dashboard
- Create/Edit Preset
- Focus Session
- History & Insights
- Settings

The presentation layer handles user interactions,
navigation, and displaying application state.

### State Management Layer

Riverpod manages dependencies and shared application
state.

Repository providers expose the data layer to
the presentation layer.

### Repository Layer

Repository interfaces define operations independently
of the storage implementation.

FocusPresetRepository:
- Create preset
- Read presets
- Update preset
- Delete preset

SessionLogRepository:
- Create session log
- Read history
- Update session log
- Delete session log
- Filter by preset
- Retrieve recent finished sessions
- Calculate completed-session statistics

### Persistence Layer

SQLite stores the application records.

DatabaseHelper manages database initialization,
schema creation, and foreign-key configuration.

## 3. Data Models

### FocusPreset

Fields:
- id
- label
- moodTag
- plannedSeconds

### SessionLog

Fields:
- id
- presetId
- startedAt
- completedSeconds
- moodTagSnapshot
- status
- source
- note

One FocusPreset can have multiple SessionLogs.

Foreign keys are enabled in SQLite.

The database uses ON DELETE RESTRICT to prevent
deleting presets that still have linked session logs.

All durations are stored in seconds.

## 4. Session Scout

Session Scout is a local rule-based recommendation helper.

For a selected mood, it:

1. Retrieves the three most recent valid finished sessions.
2. Excludes cancelled, unfinished, and invalid records.
3. Converts completed seconds into minutes.
4. Calculates the median duration.
5. Clamps the suggested duration between 10 and 60 minutes.

If fewer than three valid sessions exist, the application
displays "Not enough history."

A fixed 25-minute baseline is used for evaluation.

The user may apply, edit, or ignore the suggestion.

Session Scout does not automatically start or save sessions.

## 5. Reliability

The data layer validates important input values.

Examples include:
- Preset labels cannot be empty.
- Planned duration must be positive.
- Completed duration cannot be negative.
- Session logs must reference an existing preset.
- Linked history must be removed before deleting a preset.

The timer layer is responsible for preventing
duplicate Finish actions and cleaning up timers
when screens are disposed.

## 6. Testing

The project uses Flutter's testing framework and
sqflite_common_ffi for desktop SQLite testing.

Tests cover:
- Database initialization
- Table creation
- Foreign-key enforcement
- FocusPreset CRUD
- SessionLog CRUD
- Input validation
- Restricted parent deletion
- Preset filtering
- Session Scout history queries
- Session aggregation calculations

Widget and integration tests verify app behavior.

The graduate project requires at least 10 meaningful unit
tests, widget tests, integration tests, and a coverage report.

## 7. Offline Storage

The application does not depend on remote databases,
cloud authentication, or online APIs.

SQLite stores presets and session history.

SharedPreferences stores simple user preferences.

Local files are used for session-summary exports.

Local notifications support focus reminders.

## 8. Team Responsibilities

### Parsh
- SQLite data layer
- Repository interfaces and implementations
- Dependency injection
- Database and repository tests
- Local notifications
- File export
- Architecture documentation

### Harshit
- Flutter UI
- Riverpod state management
- Dashboard
- Preset editor
- Timer workflow
- Session Scout integration
- Animations

Both members contribute to testing, integration,
documentation, and final demonstration.

