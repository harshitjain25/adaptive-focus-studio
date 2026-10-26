# Adaptive Focus Studio – AI / Smart Feature Documentation

## 1. Feature Name

**Session Scout**

Session Scout is the local smart-helper feature in Adaptive Focus Studio.

It recommends a focus-session duration based on the user's recent completed sessions for the selected mood.

The feature runs entirely on-device and does not use a cloud AI service, external API, or internet connection.

---

## 2. Purpose

The goal of Session Scout is to help the user choose a realistic focus duration based on their own recent behavior instead of always relying on a fixed default duration.

For example, if a user has recently completed focus sessions lasting:

```text
20 minutes
30 minutes
25 minutes
```

Session Scout recommends:

```text
25 minutes
```

because 25 is the median of the three recent completed durations.

---

## 3. Input Data

Session Scout uses locally stored `SessionLog` records.

Relevant fields include:

```text
startedAt
completedSeconds
moodTagSnapshot
status
```

The feature only considers sessions that:

- have status `finished`
- match the currently selected mood
- contain a valid completed duration
- are among the most recent sessions

Cancelled or unfinished sessions are ignored.

---

## 4. Exact Algorithm

Session Scout follows these steps:

1. Receive the selected mood.
2. Filter session history to keep only sessions with status `finished`.
3. Keep only sessions whose `moodTagSnapshot` matches the selected mood.
4. Ignore invalid sessions with negative completed duration.
5. Sort the remaining sessions from newest to oldest using `startedAt`.
6. Select the three most recent valid sessions.
7. If fewer than three valid matching sessions exist, return no personalized recommendation.
8. Convert `completedSeconds` into minutes.
9. Sort the three durations.
10. Select the middle value, which is the median.
11. Clamp the recommendation between 10 and 60 minutes.
12. Return the final suggested duration.

---

## 5. Minimum History Requirement

Session Scout requires at least:

```text
3 valid finished sessions
```

for the selected mood.

If fewer than three valid sessions exist, the application displays:

```text
Not enough history
```

This prevents the application from making a personalized recommendation from insufficient data.

---

## 6. Median Calculation

The personalized recommendation is based on the median rather than the average.

Example:

```text
Recent completed durations:
20, 30, 25
```

Sort the values:

```text
20, 25, 30
```

The middle value is:

```text
25
```

Therefore:

```text
Session Scout recommendation = 25 minutes
```

Using the median reduces the effect of one unusually long or unusually short session.

---

## 7. Recommendation Limits

Session Scout limits all personalized recommendations to:

```text
Minimum: 10 minutes
Maximum: 60 minutes
```

This is implemented using clamping.

For example:

```text
Recent durations:
5, 6, 8
```

Median:

```text
6
```

After clamping:

```text
Recommendation = 10 minutes
```

Another example:

```text
Recent durations:
70, 80, 90
```

Median:

```text
80
```

After clamping:

```text
Recommendation = 60 minutes
```

---

## 8. Baseline

The fixed baseline used for comparison is:

```text
25 minutes
```

The baseline does not depend on user history.

It provides a simple reference point for evaluating whether the personalized Session Scout recommendation adapts meaningfully to the user's recent behavior.

---

## 9. Personalized Recommendation vs Baseline

Example A:

```text
Recent finished sessions:
20, 30, 25

Session Scout:
25 minutes

Baseline:
25 minutes
```

In this case, the personalized recommendation matches the baseline.

Example B:

```text
Recent finished sessions:
35, 40, 45

Session Scout:
40 minutes

Baseline:
25 minutes
```

Session Scout adapts upward because the user has recently completed longer sessions.

Example C:

```text
Recent finished sessions:
10, 15, 20

Session Scout:
15 minutes

Baseline:
25 minutes
```

Session Scout adapts downward because the user has recently completed shorter sessions.

---

## 10. Mood-Aware Behavior

Session Scout calculates recommendations separately for the selected mood.

For example, suppose the local history contains:

```text
Focused:
30, 35, 40 minutes

Tired:
10, 15, 20 minutes
```

For mood:

```text
Focused
```

Session Scout returns:

```text
35 minutes
```

For mood:

```text
Tired
```

Session Scout returns:

```text
15 minutes
```

Sessions from other moods are ignored during the calculation.

This allows the recommendation to adapt to different user conditions.

---

## 11. User Control and Override

Session Scout is advisory only.

It does not:

- automatically start a timer
- automatically save a preset
- automatically change stored user data
- automatically force the suggested duration
- remove the user's ability to edit the value

The user must explicitly press:

```text
Apply
```

to use the recommendation.

Even after applying the recommendation, the user may manually change the duration.

This preserves user control over the final decision.

---

## 12. No-Data Behavior

If the application does not have enough qualifying history, Session Scout does not invent a recommendation.

Instead, it displays:

```text
Not enough history
```

The fixed 25-minute baseline remains available as a general reference.

This behavior makes the feature predictable and avoids misleading personalized output.

---

## 13. Invalid and Excluded Data

The following records are excluded from personalized calculation:

- cancelled sessions
- unfinished sessions
- sessions belonging to another mood
- sessions with invalid negative completed duration
- older sessions beyond the three most recent matching finished sessions

This ensures that the recommendation is based only on recent successful focus behavior.

---

## 14. Evaluation

Session Scout is evaluated by comparing its personalized result with the fixed 25-minute baseline.

### Evaluation Example 1

Input:

```text
20, 30, 25
```

Expected personalized output:

```text
25
```

Baseline:

```text
25
```

Result:

```text
Session Scout matches the baseline.
```

### Evaluation Example 2

Input:

```text
35, 40, 45
```

Expected personalized output:

```text
40
```

Baseline:

```text
25
```

Result:

```text
Session Scout adapts to longer successful sessions.
```

### Evaluation Example 3

Input:

```text
10, 15, 20
```

Expected personalized output:

```text
15
```

Baseline:

```text
25
```

Result:

```text
Session Scout adapts to shorter recent sessions.
```

### Evaluation Example 4

Input:

```text
5, 6, 8
```

Median:

```text
6
```

Expected output after clamping:

```text
10
```

Result:

```text
The lower safety bound is correctly applied.
```

### Evaluation Example 5

Input:

```text
70, 80, 90
```

Median:

```text
80
```

Expected output after clamping:

```text
60
```

Result:

```text
The upper safety bound is correctly applied.
```

---

## 15. Testing

Unit tests are used to verify Session Scout behavior.

The tests include cases for:

- correct median calculation
- fewer than three matching sessions
- ignoring different moods
- ignoring unfinished sessions
- minimum clamp
- maximum clamp

This helps ensure the smart helper behaves consistently and predictably.

---

## 16. Privacy

Session Scout operates entirely on local application data.

It does not send focus history to:

- cloud servers
- external APIs
- analytics services
- AI providers
- third-party databases

The recommendation is calculated locally on the user's device.

This supports the application's offline-first design and reduces unnecessary sharing of user data.

---

## 17. Offline Operation

Session Scout requires no network connection.

The data flow is:

```text
Local SessionLog history
        ↓
Filter by mood and finished status
        ↓
Select three most recent sessions
        ↓
Calculate median
        ↓
Clamp to 10–60 minutes
        ↓
Display recommendation
```

All processing occurs locally.

---

## 18. Limitations

Session Scout intentionally uses a simple and explainable algorithm.

Current limitations include:

- only the three most recent matching sessions are used
- mood is the primary personalization factor
- it does not consider time of day
- it does not consider day of week
- it does not consider task difficulty
- it does not predict session success probability
- it does not use a trained machine-learning model
- it requires at least three matching completed sessions

These limitations are acceptable for the project because the feature is designed to remain local, transparent, predictable, and easy for the user to understand.

---

## 19. Why This Approach Was Chosen

The median-based method was selected because it is:

- simple
- explainable
- deterministic
- lightweight
- suitable for offline use
- resistant to individual extreme values
- easy to test
- easy for users to understand

The user can clearly see how recent behavior influences the recommendation.

---

## 20. Future Improvements

Possible future versions of Session Scout could consider:

- larger history windows
- weighted recent sessions
- time-of-day patterns
- weekday vs weekend behavior
- session completion rate
- preset category
- task difficulty
- user-selected goals

Any future version should continue preserving user control and clearly explain how recommendations are produced.

---

## 21. Summary

Session Scout is a local, explainable smart helper that recommends focus duration using the median of the three most recent finished sessions for the selected mood.

Core rules:

```text
History required: 3 sessions
Status required: finished
Mood: must match selected mood
Statistic: median
Minimum recommendation: 10 minutes
Maximum recommendation: 60 minutes
Baseline: 25 minutes
No-data result: Not enough history
User override: always allowed
Internet required: no
Cloud AI required: no
```

The feature provides personalization while remaining transparent, private, offline, and fully controlled by the user.
