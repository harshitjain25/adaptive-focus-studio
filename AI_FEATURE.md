# AI_FEATURE - Session Scout

## Feature Name

Session Scout

## Accurate Classification

Session Scout is a local rule-based/statistical helper. It is not a
trained machine-learning model and does not call an external AI service.

## User Benefit

The helper gives the user an optional focus-duration suggestion based on
recent completed sessions for the selected mood. The suggestion is
explained and remains fully editable.

## Inputs and Units

-   selected mood tag
-   three most recent finished sessions with the same mood
-   each session's `completedSeconds`

`completedSeconds` is converted from seconds to minutes before the
recommendation is calculated.

## Method

1.  Query the three most recent finished sessions matching the selected
    mood.
2.  Exclude unfinished, cancelled, or invalid sessions.
3.  Convert completed duration to minutes.
4.  Calculate the median of the three durations.
5.  Clamp the result to the range 10-60 minutes.
6.  Display the suggestion and explanation.

## Why Median

With only three recent sessions, the median is less sensitive than the
mean to one unusually short or long session. It is also simple enough to
explain directly to the user.

## Baseline

The comparison baseline is a fixed 25-minute suggestion.

## No-Data and Invalid Behavior

If fewer than three valid matching finished sessions exist, Session
Scout reports that there is not enough history rather than inventing a
value.

## User Control

The suggestion is never silently saved. - Apply opens/prefills the
preset editor. - The user may edit the suggested duration. - Apply does
not auto-save. - Apply does not auto-start a focus session.

## Held-Out Evaluation

The Graduate evaluation used five fixed synthetic held-out cases. The
three prior durations are used as the input; the next actual duration is
used only to evaluate error.

  -------------------------------------------------------------------------
  Case         Prior     Actual      Scout     25-min      Scout   Baseline
            sessions next (min)              baseline      error      error
               (min)                                             
  ------- ---------- ---------- ---------- ---------- ---------- ----------
  1       18, 22, 20         21         20         25          1          4

  2       32, 38, 35         36         35         25          1         11

  3       42, 50, 46         44         46         25          2         19

  4       12, 16, 14         15         14         25          1         10

  5       25, 30, 28         27         28         25          1          2
  -------------------------------------------------------------------------

Results: - Session Scout total absolute error: 6 minutes - Session Scout
MAE: 1.20 minutes - fixed 25-minute baseline total absolute error: 46
minutes - fixed baseline MAE: 9.20 minutes - Session Scout had lower
absolute error in 5/5 evaluation cases

## Counterexample / Limitation

Three recent sessions may be unusual or unrepresentative. A user may
also change study behavior over time. Therefore a recommendation based
on only three sessions can still be poor in real use.

The held-out evaluation is intentionally described as small and
synthetic. It does not prove real-world predictive accuracy.

## Retained Design / Next Revision

The current explainable median rule is retained because it is
transparent, local, and easy to override. A future iteration should
compare different history-window sizes on a larger set of real usage
data while keeping the explanation and manual override.

## Offline Behavior

The helper uses local SessionLog data and requires no cloud backend or
external API.

## Verification

Automated tests cover recommendation logic, insufficient history, mood
filtering, unfinished-session exclusion, and 10/60 minute clamps. A
separate held-out test contains the five evaluation fixtures. The final
automated suite reports 50 tests passing.
