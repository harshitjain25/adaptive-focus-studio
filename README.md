# Adaptive Focus Studio

Adaptive Focus Studio is an offline Flutter study-session application created for CSC 6360 - Mobile App Development at Georgia State University.

## Team

**Team Name:** Boomers  
**Harshit Jain:** 002916196  
**Parsh Jadon:** 002936134  
**Course:** CSC 6360 - Mobile App Development, Section 002  
**Instructor:** Louis Henry  
**Pathway:** Graduate

## Project Overview

The app helps users create reusable focus presets, run timed study sessions, review session history and insights, and manage local settings. It contains five main screens: Dashboard/Preset Catalog, Create/Edit Preset, Focus Session, History/Insights, and Settings.

## Main Features

- FocusPreset create, read, update, and delete
- Focus timer with Start, Pause, Resume, Finish, and Reset
- SessionLog history with mood filtering, note editing, and deletion
- Background insight calculation using Flutter `compute()`
- SharedPreferences persistence for default duration, reminders, and sound
- Local session-completion notifications
- Local session-summary file export
- Riverpod state management
- SQLite local persistence and repository-based data access
- Implicit and explicit animations
- Offline operation
- Session Scout local smart helper

## Session Scout

Session Scout is a local rule-based helper. For a selected mood, it uses the three most recent valid finished matching sessions, converts their durations to minutes, calculates the median, and clamps the result to 10-60 minutes. With fewer than three valid matching sessions it returns "Not enough history." Applying a suggestion only prefills the editor; the user can edit or ignore it.

The comparison baseline is a fixed 25-minute recommendation.

### Held-Out Evaluation

A separate fixed synthetic held-out evaluation used five cases that were separate from the existing Session Scout development unit-test examples.

| Method | Cases | MAE |
| --- | ---: | ---: |
| Session Scout | 5 | 1.20 min |
| Fixed 25-minute baseline | 5 | 9.20 min |

Session Scout had lower absolute error in all five fixed evaluation cases. These are synthetic evaluation fixtures, not real-user results, so they demonstrate behavior on this fixed set rather than general real-world predictive performance. See `AI_FEATURE.md` for full details.

## Local Data

### FocusPreset
`id`, `label`, `moodTag`, `plannedSeconds`

### SessionLog
`id`, `presetId`, `startedAt`, `completedSeconds`, `moodTagSnapshot`, `status`, `source`, `note`

SQLite stores structured preset/session data. SharedPreferences stores lightweight settings.

## Testing

The current automated suite reports:

```text
+50: All tests passed!
```

Run tests:

```bash
flutter test
```

Generate coverage:

```bash
flutter test --coverage
```

Previously measured coverage was 326 lines hit out of 1084 coverable lines, or **30.07%**. The held-out evaluation test was added after that measurement, so this README does not claim that 30.07% is a newly recalculated value. The optional 80%+ coverage bonus is not claimed.

Testing covers database behavior, repositories, timer state, Session Scout, held-out comparison, insights, widgets, and integration behavior. Physical Android release testing and offline testing were also completed. Second-device/emulator acceptance evidence is being completed separately for the final submission package.

## Offline Verification

The main workflow was verified without internet access on Android, including presets, focus sessions, history, settings, and local data. GitHub, ClickUp, and YouTube are collaboration/submission services, not app backends.

## Release APK

Build with:

```bash
flutter build apk --release
```

Output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

The release APK was installed and tested successfully on Android.

## Run the Project

```bash
git clone https://github.com/harshitjain25/adaptive-focus-studio.git
cd adaptive-focus-studio
flutter pub get
flutter analyze
flutter test
flutter run
```

## Documentation

- `README.md`
- `ARCHITECTURE.md`
- `AI_FEATURE.md`
- `Kanban_Contribution_Evidence.pdf` - add when the final evidence PDF is completed

## Project Links

**GitHub:** https://github.com/harshitjain25/adaptive-focus-studio  
**ClickUp:** https://app.clickup.com/90141778423/v/l/li/901422381505  
**YouTube:** Add the final accessible presentation link after upload.

## Contribution Summary

### Harshit Jain
UI and five-screen workflow, wireframes, Riverpod, timer workflow, Session Scout implementation/evaluation, History/Insights integration, settings, notifications, animations, release/device verification, ClickUp coordination, and final documentation/presentation preparation.

### Parsh Jadon
SQLite/schema work, FocusPreset CRUD, SessionLog CRUD, repository/data-layer work, automated testing contributions, and second-device/emulator acceptance testing.

Both members participate in integration, review, applicable testing, and the final presentation.

## Submission Status Note

The application implementation, release APK, primary Android verification, 50-test automated suite, and Session Scout held-out evaluation are complete. Final package items such as second-device evidence, Kanban contribution evidence, signed statement, approved proposal, presentation/video, YouTube link, and other course-required files should be added/verified before submission.
