# ARCHITECTURE

## Overview

Adaptive Focus Studio separates UI, application state,
repositories/services, and local persistence.

`UI -> Riverpod providers/state -> repositories/services -> SQLite / SharedPreferences`

This keeps SQL and persistence details out of widgets and makes the data
layer easier to test.

## UI Layer

The app has five screen roles: - Dashboard / Catalog - Create / Edit
Preset - Focus Session - History & Insights - Settings

Reusable widgets are used for repeated UI such as preset and Session
Scout cards.

## State Management

Riverpod manages shared application state and dependencies.

The focus timer is owned outside the screen by the timer provider. The
Focus Session UI watches/reads that provider and sends actions such as
start, pause, resume, finish, and reset.

Repository providers expose the FocusPreset and SessionLog repositories
so screens do not manually construct database objects.

## Data Layer

### FocusPreset

Fields: id, label, moodTag, plannedSeconds.

### SessionLog

Fields: id, presetId, startedAt, completedSeconds, moodTagSnapshot,
status, source, note.

SQLite stores structured records and supports CRUD and queries.
SessionLog references FocusPreset through presetId. Database constraints
and UI validation help reject invalid records. The parent-delete policy
uses `ON DELETE RESTRICT` so related history is not silently removed.

## Settings

SharedPreferences stores small key/value settings: - default duration -
session reminders - sound

SQLite is used for structured/queryable records; SharedPreferences is
used for lightweight settings.

## Session Scout

Session Scout is rule-based, not ML.

Input: - selected mood - 3 most recent finished SessionLog records
matching that mood

Method: - ignore unfinished/cancelled/invalid records - convert
completed seconds to minutes - take the median of 3 - clamp result to
10-60 minutes

No-data behavior: - fewer than 3 valid matching sessions -\>
insufficient-history feedback

User control: - Apply only prefills the editor - the user can change the
value - Apply does not save or start a timer

## Background Processing

History insight calculation uses Flutter `compute()` through
`InsightsService`, moving the calculation away from the main UI isolate.

Flow:
`SQLite -> History screen -> InsightsService -> compute() -> rendered insight`

## Local Notifications and File Operations

`NotificationService` handles local focus-completion notifications.

`SessionExportService` writes a local text summary from History. The
feature was device-tested and produced a local application file path.

## Animation

The project includes both: - implicit animation with AnimatedContainer -
explicit animation using AnimationController and ScaleTransition

## Timer Safety

The timer workflow was designed to avoid stale callbacks and duplicate
SessionLog creation during pause, finish, reset, or navigation.
Finishing a session records one completed log.

## Test Boundaries

-   unit tests: Session Scout and repository/data logic
-   widget tests: UI behavior
-   integration test: app workflow
-   device acceptance: release APK, offline behavior, persistence,
    validation, timer/history, and second-device evidence

Final automated suite: 50 tests passing. Measured coverage: 30.07%.

## Key Trade-offs

Riverpod was chosen over only using `setState` because timer state and
repository dependencies are application concerns that cross widget
boundaries.

The app is intentionally local-only. This avoids account/cloud
dependency and supports offline use, but it means there is no
cross-device synchronization.

Session Scout stays simple and explainable. Its main limitation is the
short three-session history window.
