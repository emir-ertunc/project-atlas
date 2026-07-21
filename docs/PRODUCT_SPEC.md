# Product Specification

## Document Status

- Status: P5-15 adaptive-programming beta build complete
- Working name: Project Atlas
- Initial audience: Healthy adults aged 18 and over
- Initial platform: Android-first, with an iOS-capable shared architecture

## Product Goal

Provide an offline-first training system that combines workout planning, set-level tracking, adaptive scheduling, progress analysis, and an interactive anatomical visualization.

## Core Outcomes

- Users can create and execute structured training programs.
- Users can choose fixed or ranged repetition targets independently from RIR tracking.
- Users can record actual load, repetitions, effort, and completion for every set.
- The system can recommend bounded program changes and explain their triggers.
- Availability constraints can be reconciled with training and recovery requirements.
- Body measurements can drive a clearly labeled visual estimate and progress history.

## Primary Navigation

- Today
- Program
- Anatomy
- Progress
- Settings

## Initial Goals

- General fitness
- Hypertrophy
- Maximum strength
- Body recomposition
- Muscular endurance
- Athletic performance
- Maintenance

## Out of Scope for the Personal Release

- Clinical diagnosis, treatment, or rehabilitation
- Nutrition planning
- Social feeds and messaging
- Coach dashboards
- Photo-based body scanning
- Accounts, remote storage, and multi-device synchronization

## Core User Flows

### Onboarding

Goal, training history, equipment, availability, session duration, progression preference, measurement preference, and safety acknowledgement.

P5-01 implements the first local onboarding slice in Settings: primary goal,
training experience, available equipment, preferred session length, and
preferred training weekdays. Saving these choices creates the local profile if
needed and stores the preferences on device for later planning. Availability
windows, calibration, progression preference, measurement preference, safety
acknowledgement, and generated program recommendations remain later Phase 5
tasks.

P5-02 adds a conservative calibration preview after onboarding is saved. The
preview derives a two-to-four-week block from goal, experience, preferred
training days, and session length. It caps early weekly exposure by experience,
keeps extra repetitions in reserve, uses reduced planned volume, and forbids
load increases during the block. It is guidance and future-planning context
only; it does not generate a program or automatically change prescriptions.

P5-03 adds weekly availability windows after onboarding. Each saved preferred
training day can be marked as a fixed period or a flexible period with a local
start and end time. Fixed periods represent hard appointment-like availability;
flexible periods give the later schedule solver a range in which it may place a
session. The feature stores weekly windows locally and does not yet solve
schedule conflicts, propose missed-session replacements, or generate programs.

P5-04 adds a program draft planner after availability is saved. The planner
uses goal, experience, available equipment, preferred session length, saved
weekly windows, conservative RIR, weekly volume limits, and recovery spacing to
build an editable local Program draft. Applying the plan never publishes an
active program automatically; the user still reviews, edits, saves, and
publishes from the Program screen.

P5-05 adds a missed-session replacement preview after the generated plan is
available. The user selects which generated training day was missed, and the
app proposes the earliest spare availability window that fits the session and
preserves goal-specific recovery around the remaining planned days. The preview
does not move the workout automatically; later recommendation review work owns
accept, reject, edit, and undo behavior.

P5-06 adds the first load-change guardrail behind adaptive programming. When a
later rule asks to increase, hold, or decrease a loaded exercise prescription,
the app can now bound that request by available equipment increments, maximum
increase and decrease percentages, and a minimum load floor. This step does not
yet decide whether workout history has earned a change; later Phase 5 items
own qualifying evidence, miss streaks, pain handling, explanations, and review
actions.

P5-07 adds the first earned load-increase proposal. After two most recent
matching exposures qualify for the same exercise, the app can propose exactly
one smallest available load increment, still bounded by the P5-06 guardrail.
The proposal requires clean set evidence at the current load, upper repetition
target, and target RIR when RIR is enabled. It remains a recommendation
candidate only; later review work owns acceptance, editing, rejection, and
undo.

P5-08 adds the first conservative miss response. A single performance miss does
not reduce the prescription; the app holds. A reduction candidate appears only
after the two most recent matching exposures for the exercise are both
performance misses, and the decrease is still bounded by the P5-06 guardrail.
This step uses pre-classified exposure signals; interruption filtering, pain
safety guidance, explanations, and user review remain later work.

P5-09 adds the first interruption filter for progression streaks. Time,
equipment, and external interruptions no longer become strength-failure
evidence for load reduction. If an interrupted set also has low repetitions or
load, the interruption keeps that exposure out of the performance-failure
streak. Pain remains separated for the next safety-focused rule.

P5-10 adds the first pain-focused progression guard. When a completed set for
the matching exercise is marked with a pain outcome, the app stops automatic
load progression for that exercise, keeps the prescription unchanged, and
returns safety guidance for the future review UI. Pain is not treated as a
performance miss or an earned load-reduction signal; it is a separate safety
state.

P5-11 adds a data sufficiency gate for future plateau and deload
recommendations. Plateau checks require at least four comparable exposures
spanning at least 21 days. Deload checks require at least three comparable
exposures spanning at least 14 days. Pain, interruptions, and missing evidence
do not count as comparable data, and the latest matching exposure must be
comparable before either future recommendation type can proceed.

P5-12 adds explanation metadata for adaptive recommendation candidates. A
future review surface can show what would change, why the candidate exists,
which exposure or pain data triggered it, and what previous value should be
restored if an accepted load change is undone. This step does not add the
review UI or perform undo; those flows remain later work.

P5-13 adds the first review flow behind adaptive recommendations. A recommendation
candidate can now be accepted, rejected, edited by changing the proposed load,
or undone after an accepted load change. The flow updates copied prescription
state for review and simulation; it still does not publish a new program
version or save durable recommendation history.

P5-14 adds golden-persona acceptance coverage for the adaptive engine. The test
suite simulates twelve weeks for a clean progression persona, a repeated-miss
persona with an interruption, and a pain-safety persona. These simulations prove
the Phase 5 rules work together before the adaptive-programming beta APK build.

P5-15 packages the adaptive-programming beta into Build C3, a
development-only Android debug APK. The build includes onboarding preferences,
calibration guidance, availability windows, generated program drafts,
missed-session replacement previews, bounded progression decisions,
recommendation explanations, recommendation review actions, and the
golden-persona acceptance coverage. It is not a signed release and does not
silently publish adaptive recommendations into active program versions.

### Manual Program Creation

Search or filter exercises, add them to training days, and define sets, repetition targets, optional RIR, load, and rest.

### Active Workout

Start a session, log every set, record non-performance interruptions separately, finish or partially complete the session, and review results.

P4-01 implements the first slice of this flow: Today can start a local session
from a selected training day in the active published program. P4-02 adds
set-level logging for actual repetitions, load, optional RIR, and completion
state. P4-03 shows the matching previous set performance next to the current
prescription when local history exists. P4-04 records strength, technique,
pain, time, equipment, and external-interruption outcomes on the completed set
log. P4-05 adds rest countdowns from the prescription, a background rest alert
on Android when notifications are available, and quick load +/- controls for
the pending set result. P4-06 restores an in-progress workout from local
storage after the app process restarts, including completed set logs and the
selected source training day. P4-07 shows separate calculated statuses for each
set, exercise, and active session so a specific performance miss can be
reviewed without automatically failing the whole workout. P4-08 turns the
Progress branch into a local review surface for workout history, selected set
details, and display-only personal records. P4-09 lets a user correct a
historical set result from Progress by saving a new revision instead of editing
or deleting the old log. P4-10 verifies the Phase 4 workout flow in airplane
mode and after database reopening, covering active workout logging, history,
corrections, and personal-record recalculation. P4-11 packages these local
workout capabilities into the Build C2 development APK. Explicit session-finish
or cancel actions and process-restored rest-timer replay remain future backlog
items outside Build C2.

### Recommendation Review

Review what would change, why it was proposed, which data triggered it, and accept, reject, or edit the recommendation.

### Measurement and Anatomy Review

Enter measurements, inspect historical changes, view a bounded visual estimate, and inspect muscle training heatmaps.

## Product Policies

- A failed accessory exercise does not automatically fail the entire session.
- Program changes require user confirmation.
- Missed sessions produce rescheduling proposals rather than silent calendar changes.
- Measurement data is not the primary driver of load progression.
- Pain reports stop progression and trigger safety guidance.
- All personal-release functionality remains usable without a network connection.

## Acceptance Criteria Index

Detailed acceptance criteria will be added beside their implementation tasks in `MASTER_PLAN.md` and the relevant domain documents.
