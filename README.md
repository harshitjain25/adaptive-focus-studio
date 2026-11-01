# Adaptive Focus Studio

**Team Boomers**\
**CSC 6360-002 - Mobile App Development - Project One - Graduate
Pathway**\
**Instructor:** Louis Henry

## Team

-   Harshit Jain - Panther ID 002916196
-   Parsh Jadon - Panther ID 002936134

## Project

Adaptive Focus Studio is an offline-first Flutter study-session
application. Users can create reusable focus presets, run a focus timer,
review completed-session history and local insights, save settings
locally, export a local session summary, receive a local completion
notification, and optionally use Session Scout for an explainable
duration suggestion.

## Links

-   GitHub: https://github.com/harshitjain25/adaptive-focus-studio
-   ClickUp: https://app.clickup.com/90141778423/v/l/li/901422381505
-   Final presentation video: https://youtu.be/7WOXboAY480

## Main Screens

1.  Dashboard / Preset Catalog
2.  Create / Edit Preset
3.  Focus Session
4.  History & Insights
5.  Settings

## Local Data

### SQLite

`FocusPreset` - id - label - moodTag - plannedSeconds

`SessionLog` - id - presetId - startedAt - completedSeconds -
moodTagSnapshot - status - source - note

### SharedPreferences

-   default duration
-   session reminders
-   sound

The application does not use a cloud backend for app data.

## Session Scout

Session Scout is a rule-based local helper, not a machine-learning
model.

For the selected mood it: 1. retrieves the 3 most recent finished
matching sessions; 2. converts completed duration from seconds to
minutes; 3. takes the median; 4. clamps the suggestion to 10-60 minutes.

If fewer than 3 valid matching sessions exist, the helper reports
insufficient history. The fixed comparison baseline is 25 minutes.
Applying a suggestion only prefills the preset editor; it does not
auto-save or auto-start a session.

## Graduate Features

-   Riverpod state management and dependency injection
-   repository boundaries for SQLite access
-   background History insight calculation with Flutter `compute()`
-   local notifications
-   local file export
-   implicit and explicit animations
-   unit, widget, and integration testing
-   held-out Session Scout comparison

## Testing Status

-   `flutter analyze`: No issues found
-   automated suite: 50 tests passing
-   measured code coverage: 30.07%
-   release APK tested on Android
-   separate second-device Android acceptance evidence captured by Parsh
-   offline local-data behavior demonstrated
-   Session Scout held-out evaluation: 5 fixed synthetic cases

The 80% coverage threshold is not claimed. The measured value above is
the actual recorded coverage.

## Session Scout Held-Out Evaluation

Five fixed synthetic held-out cases were used only for evaluation.

-   Session Scout MAE: 1.20 minutes
-   Fixed 25-minute baseline MAE: 9.20 minutes
-   Session Scout lower absolute error: 5/5 cases

These results do not establish real-world predictive accuracy. The
evaluation is small and synthetic.

## Run

1.  Install Flutter and Android tooling.
2.  From the project root run `flutter pub get`.
3.  Run `flutter analyze`.
4.  Run `flutter test`.
5.  Start a supported Android device/emulator.
6.  Run `flutter run`.

## Release APK

Final release APK location after build:

`build/app/outputs/flutter-apk/app-release.apk`

Build command:

`flutter build apk --release`

## Important Documentation

-   `ARCHITECTURE.md`
-   `AI_FEATURE.md`
-   `AI_Usage_Log.md`
-   `PROJECT_REPORT.md`
-   `Boomers_Project1_SelectedQuestions.docx`
-   `Second_Device_Testing_Evidence_Parsh.pdf`
-   `Kanban_Contribution_Evidence.pdf`

## Known Limitations

-   local-only application; no account or cross-device synchronization
-   Session Scout uses only 3 recent finished matching sessions
-   held-out comparison is small and synthetic
-   measured automated code coverage is 30.07%, not the optional \>80%
    bonus threshold

## Contribution Summary

Harshit: 58 commits. Main areas include UI, Riverpod/timer integration,
Session Scout, advanced features, integration, and documentation.

Parsh: 28 commits. Main areas include SQLite, repositories, CRUD,
queries, constraints, and data-layer testing.

See the Kanban/contribution evidence for task-to-code/test traces.
