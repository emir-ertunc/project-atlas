# Product Specification

## Document Status

- Status: P7 modern UX redesign planned after P6 review
- Working name: Project Atlas
- Initial audience: Healthy adults aged 18 and over
- Initial platform: Android-first, with an iOS-capable shared architecture

## Product Goal

Provide an offline-first training system that combines workout planning,
set-level tracking, adaptive scheduling, progress analysis, and an interactive
anatomical visualization through a compact daily coaching experience.

## Core Outcomes

- Users can create and execute structured training programs.
- Users can choose fixed or ranged repetition targets independently from RIR tracking.
- Users can record actual load, repetitions, effort, and completion for every set.
- The system can recommend bounded program changes and explain their triggers.
- Availability constraints can be reconciled with training and recovery requirements.
- Body measurements can drive a clearly labeled visual estimate and progress history.

## Primary Navigation

- Today: daily coach, next workout, streak, quick start, and pending review
- Program: active-plan hub, training days, recommendations, builder, and catalog
- Anatomy: visual estimate, trained-muscle heatmaps, and muscle inspection
- Progress: streaks, milestones, records, trends, and measurement comparison
- Profile: setup, equipment, availability, units, safety, privacy, and export

Root destinations are dashboards. Long setup, editing, review, and detail tasks
must open focused routes, sheets, or step flows rather than stacking every
section on the root page.

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

### Modern UX Reset

Phase 7 rebuilds the experience after P6 feedback. The completed local engine
stays intact, but the interface must become compact, modern, and easier to
understand. The target is serious strength-training coaching with lightweight
gamified progress loops: daily missions, streaks, milestones, progress paths,
and concise action cards.

The redesign rules are:

- no root tab should become a long menu or long form;
- each screen should expose one primary action;
- advanced details should be one tap away, not always visible;
- onboarding, program editing, measurements, and settings should use focused
  subroutes or guided flows;
- workout logging should be one-handed and set-by-set;
- progress feedback should be motivating without changing conservative training
  and safety rules.

The detailed contract is recorded in
[the modern UX redesign plan](UX_REDESIGN_PLAN.md) and
[the modern UX quality bar](UX_QUALITY_BAR.md).

P7-03 converts the main navigation into dashboard roots with focused child
routes. The existing workout, Program builder, catalog, exercise detail,
Progress history, and setup functionality remains available, but heavy editing
and review surfaces no longer live directly on the root tab destinations.

P7-04 rebuilds setup as a guided wizard. Goal, experience, equipment,
availability, measurement preference, and review are handled as short focused
steps, then saved through the existing local onboarding and availability
repositories. Measurement preference is a UI preference for the upcoming
measurement flow in this step; no measurement value, new schema, progression
rule, or generated-plan mutation is added.

P7-05 rebuilds Today as the daily coach dashboard. The root view now shows the
next workout mission, one primary Start or Resume action, a local workout
streak, weekly consistency, and a compact review queue state. These summaries
are derived locally from completed workout sessions and the active program. The
detailed active-workout logger remains in the focused `/today/workout` route.

P7-06 rebuilds `/today/workout` for active sessions as a set-by-set execution
surface. The screen shows one current set with the prescription, compact
previous performance, quick load/repetition/RIR edits, one complete-set action,
and a visible rest timer state after completion. Other session sets remain
available only as compact status chips so the route does not become another
long program page.

P7-07 rebuilds Program as an active-plan hub. The root reads the current active
program and version, summarizes training-day count, exercise count, and set
count, shows compact training-day cards, and exposes separate route entries for
builder editing, catalog search, and the recommendation inbox. It does not
publish versions, mutate prescriptions, or implement the guided builder; those
remain focused child-route responsibilities.

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

P7-04 moves the onboarding and availability inputs into one short guided setup
wizard. The user completes one decision group per step, reviews the full setup,
and saves onboarding preferences plus weekly availability together. The setup
route no longer embeds calibration guidance, generated program previews, or
missed-session replacement previews in a single long page.

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

P7-08 presents manual creation as a guided builder instead of one long editor:
setup, training days, catalog search and ordering, prescription targets, and
publish review are separate step groups. Publishing now requires a visible review
and confirmation while saving a draft remains available for iteration.

P7-09 presents catalog search as a compact add-to-program surface. The catalog
keeps local search and all filter facets, but moves filters into a sheet with
active chips on the main page. Result cards emphasize procedural media,
primary muscle categories, equipment, level, animation status, and a direct
add action. Exercise detail pages lead with media, primary muscle chips,
substitutions, compact metadata, and the same add action before longer coaching
sections.

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

P7-05 keeps the P4 workout logger intact but moves daily decision-making to the
Today root. If an active session exists, Today resumes it. If an active program
exists, Today quick-starts the currently selected training day. If no active
program exists, Today offers one path to Program creation. Streak,
consistency, and review queue cards are motivational and informational only;
they cannot override safety, pain handling, progression, or confirmation rules.

P7-06 changes only the active-workout presentation. Once a session is active,
the `/today/workout` route no longer shows the training-day selector, program
overview, or start button. It focuses the first incomplete set unless a rest
timer is active, in which case the just-completed rest source remains in focus
until the user dismisses the timer. Set logging, outcome rules, volatile rest
timers, and local repository writes remain the existing P4 behavior.

P7-07 changes only the Program root presentation. It loads active program data
from existing local repositories, keeps recommendations schema-free with a
clear inbox state, and routes edits to the existing builder. Training-day cards
are navigation and summary surfaces, not inline editors.

### Recommendation Review

Review what would change, why it was proposed, which data triggered it, and accept, reject, or edit the recommendation.

### Measurement and Anatomy Review

Enter measurements, inspect historical changes, view a bounded visual estimate, and inspect muscle training heatmaps.

P6-01 adds the first persistent body-measurement fields. A measurement event
can now store height, weight, torso length, chest, waist, hips, and side-specific
upper-arm, forearm, thigh, and calf measurements. Values are normalized to
centimeters and kilograms in storage.

P6-02 adds optional body-fat percentage and method metadata to the same
measurement event. The app can now distinguish how body measurements were
captured from how body-fat was estimated, while leaving guidance, validation
copy, visual morph targets, and trend UI for later Phase 6 work.

P6-03 adds the first measurement guidance contract. Each measurement field now
has an English and Turkish title, reference point, and capture instruction.
Saving a new measurement is blocked only when the event has no numeric value,
contains non-finite values, contains non-positive length or mass values, or has
body-fat percentage outside the open 0-100 range. Broader range checks, missing
method metadata, and side-to-side differences are warning-level prompts for
later UI review.

P6-04 adds the first body-measurement-to-anatomy morph rule. A measurement
record can now be converted into bounded regional target signals for stature,
mass-to-height scale, torso length, circumference, and soft-tissue estimate
channels. These signals are keyed to stable anatomy region IDs and remain
in-memory only.

P6-05 maps those normalized morph signals into target-specific visual minimum,
neutral, and maximum multipliers. The clamp layer fails closed when a visual
range is missing, remains in memory, and does not label the estimate, integrate
the renderer, or add visual regression tests.

P6-06 labels personalized anatomy output as "Visual estimate, not a medical
scan" in English and Turkish. The disclosure explains that the anatomy view is
approximate, derived from saved measurements and training data, and cannot
diagnose health, injury, disease, or body composition.

P6-07 adds training-derived heatmaps to the Anatomy screen. The user can apply
trained-muscle, weekly-volume, or fatigue views generated from completed local
set logs in the trailing seven-day window and the bundled exercise-catalog
muscle mappings. These heatmaps are visual review aids only; they do not change
training prescriptions or create medical, recovery, or body-composition
diagnoses.

P6-08 adds display-only trends to the Progress screen. Measurement trends are
derived from saved measurement history. Training volume, load, repetition, and
estimated-strength trends are derived from completed clean set logs using the
latest revision for each set. Estimated strength is a local training estimate,
not a true one-repetition max and not an automatic progression decision.

P6-09 adds measurement-history comparison and an explicit report copy on the
Progress screen. The app compares first and latest usable values for each
measurement field, shows latest left/right circumference differences, and lets
the user copy CSV or JSON text with a personal-data warning. It does not write a
plaintext file, create restore behavior, or replace the later encrypted backup
export.

P6-10 completes morph-boundary and visual-regression coverage. Tests now lock
valid minimum and maximum measurement behavior, missing-height fallback
behavior, conservative visual range interpolation, deterministic clamped morph
snapshots, and visual-estimate disclosure placement. This does not add renderer
mesh deformation or new product behavior.

P6-11 packages the personalized anatomy alpha into Build C4, a
development-only Android debug APK. The checkpoint opens to the Anatomy branch
and includes measurement storage, body-fat provenance, measurement guidance,
bounded morph targets, visual range clamps, visual-estimate disclosure,
training heatmaps, Progress trends, measurement-history comparison, report
copy, and P6-10 coverage. It is not a signed release and does not add renderer
mesh deformation, reviewed runtime GLB packaging, encrypted backup restore, or
account synchronization.

## Product Policies

- A failed accessory exercise does not automatically fail the entire session.
- Program changes require user confirmation.
- Missed sessions produce rescheduling proposals rather than silent calendar changes.
- Measurement data is not the primary driver of load progression.
- Pain reports stop progression and trigger safety guidance.
- All personal-release functionality remains usable without a network connection.
- Motivation features are local and non-social; they cannot override safety,
  pain, progression, or user-confirmation rules.
- Root screens must stay compact and action-oriented. Complex editing belongs
  in focused routes, sheets, or guided flows.

## Acceptance Criteria Index

Detailed acceptance criteria will be added beside their implementation tasks in `MASTER_PLAN.md` and the relevant domain documents.
