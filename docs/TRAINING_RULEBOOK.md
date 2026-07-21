# Training Rulebook

## Document Status

- Status: P5-15 adaptive-programming beta build complete
- Purpose: Define deterministic, testable, and versioned training decisions

## Supported Goals

- General fitness
- Hypertrophy
- Maximum strength
- Body recomposition
- Muscular endurance
- Athletic performance
- Maintenance

## Profile Inputs

- Self-reported training history
- Observed valid exercise exposures
- Equipment and available load increments
- Weekly availability and session duration
- Exercise preferences and exclusions
- Set-level performance history
- Optional readiness and soreness signals
- Pain and technique flags

Body measurements are primarily visualization and trend inputs, not direct load-prescription inputs.

P5-01 captures the first durable profile inputs: primary goal, training
experience, available equipment, preferred session length, and preferred
weekdays. These values are planning context only at this step. Calibration,
availability solving, program generation, and progression decisions remain
unapplied until their dedicated Phase 5 checklist items.

P5-02 defines the first calibration rule set:

- Calibration lasts two to four weeks.
- New and beginner trainees start at four weeks.
- Intermediate trainees start at three weeks, extended to four weeks for
  maximum-strength, body-recomposition, or athletic-performance goals.
- Advanced trainees start at two weeks, extended to three weeks for the same
  higher-risk goals.
- Weekly session count is capped by experience and cannot exceed the saved
  preferred training weekdays.
- Minimum RIR is at least 3 for new or beginner trainees and at least 2 for
  intermediate or advanced trainees; general fitness, endurance, and
  maintenance keep at least RIR 3.
- Planned volume ramps conservatively and stays below full target volume during
  calibration.
- Load progression is disabled during calibration.
- Leaving calibration requires completing the planned weeks, no pain reports,
  no repeated performance misses, and stable RIR evidence.

These are read-only guidance rules in P5-02. They do not create a program,
reschedule workouts, or change loads.

P5-03 records weekly availability as fixed or flexible periods:

- Fixed periods are treated as hard schedule constraints by future solvers.
- Flexible periods are usable time ranges where a future solver may place a
  session.
- Availability windows require a valid same-day start and end time.
- Recording availability does not itself schedule workouts, move missed
  sessions, change weekly exposure, or apply progression.

P5-04 defines the first program planner rule set:

- Rule set version is `adaptive_program_planner.v1`.
- Weekly session count cannot exceed the conservative calibration session cap
  or the count of valid saved availability windows.
- When more windows exist than the session cap allows, selected windows are
  spread across the ordered week rather than packed only at the start.
- Effective session length is the lesser of preferred session length and the
  shortest selected availability window, with a 30-minute minimum planning
  floor.
- Exercise count is capped by effective session length: three exercises up to
  40 minutes, four up to 60 minutes, five up to 75 minutes, and six above that.
- Exercise candidates are selected only from the local catalog and broad
  equipment capabilities saved during onboarding.
- Day focus alternates full-body, upper-emphasis, lower-emphasis, and
  posterior-chain patterns to reduce repeated high-stress overlap on adjacent
  exposures.
- Set count, repetition range, rest duration, and target RIR are derived from
  goal, experience, movement role, and the conservative calibration minimum
  RIR.
- Loads remain unset and progression remains unapplied. Later Phase 5 rules
  decide when increases, holds, decreases, missed-session replacements, and
  user-reviewed recommendations are proposed.
- Applying a plan creates only an editable local Program draft. It does not
  publish an active version or silently mutate saved program history.

P5-05 defines the first missed-session replacement rule set:

- Rule set version is `missed_session_replacement.v1`.
- A replacement can only be proposed for a generated program day that still
  exists in the current plan preview.
- Candidate windows come only from saved weekly availability.
- Candidate windows must be after the missed planned start in the same
  recurring week and must have enough duration for the planned session length.
- Windows already occupied by any generated training day are not used as
  replacement candidates.
- The proposed window is the earliest spare candidate that preserves recovery
  around remaining planned sessions.
- Minimum start-to-start recovery is 48 hours for maximum strength, 36 hours
  for hypertrophy, body recomposition, and athletic performance, and 24 hours
  for general fitness, muscular endurance, and maintenance.
- If no safe candidate exists, the rule returns a no-safe-window result with
  blockers such as insufficient duration, existing planned window, or recovery
  conflict.
- The result is an explanation/preview only. It does not create or move workout
  sessions, rewrite a program version, or trigger load progression.

P5-06 defines the first bounded progression rule set:

- Rule set version is `bounded_progression.v1`.
- The rule accepts a current exercise prescription, a requested direction
  of increase, hold, or decrease, and a load policy containing the available
  equipment increment, minimum load floor, maximum increase percentage, and
  maximum decrease percentage.
- Hold decisions return the existing prescription load unchanged and require no
  confirmation.
- Increase requests are rounded to the available load increment and capped by
  the configured maximum increase percentage, while still allowing one
  available increment as the smallest meaningful loaded change.
- Decrease requests are rounded to the available load increment, capped by the
  configured maximum decrease percentage, and never drop below the configured
  minimum load floor.
- Missing current load, invalid increments, invalid bounds, or invalid requested
  changes return a not-comparable decision rather than guessing a new load.
- Any actual load change is a proposal that requires later user review before
  it can be applied to a program prescription.
- The rule does not yet decide when an increase, hold, or decrease should be
  requested from workout history. Qualifying exposures, isolated versus
  repeated misses, interruption filtering, pain handling, plateau checks, and
  accept/reject/undo flows remain assigned to later Phase 5 items.

P5-07 defines the first smallest-load-increase proposal rule set:

- Rule set version is `smallest_load_increase.v1`.
- A load increase can be proposed only after two most recent matching exposures
  for the same exercise qualify.
- A qualifying exposure must contain at least the prescribed number of working
  sets.
- Each required set must have no limiting outcome, actual load at or above the
  current prescription load, repetitions at or above the upper repetition
  target, and, when a target RIR exists, actual RIR at or above that target.
- The rule does not skip a more recent non-qualifying exposure to find older
  successful exposures.
- The requested increase is exactly one available load increment and is passed
  through the P5-06 bounded progression rule before becoming a proposal.
- Missing current prescription load, invalid load policy, missing evidence, or
  insufficient qualifying exposures return no proposal rather than guessing.
- The result remains a read-only recommendation candidate. It does not update a
  program version, save a recommendation, or apply the change without a later
  review flow.
- Isolated misses, repeated miss reductions, interruption-specific streak
  filtering, pain safety guidance, plateau checks, explanations, and
  accept/reject/undo behavior remain assigned to later Phase 5 items.

P5-08 defines the first performance-miss response rule set:

- Rule set version is `performance_miss_response.v1`.
- The rule consumes pre-classified exposure signals for the current exercise:
  target met, performance miss, or not comparable.
- If there is no matching exposure history, the rule holds.
- If the most recent matching exposure is not a performance miss, the rule
  holds.
- If the most recent matching exposure is a performance miss but the previous
  matching exposure is not also a performance miss, the rule treats it as an
  isolated miss and holds.
- A decrease can be proposed only after the two most recent matching exposures
  are both performance misses.
- The requested decrease is one available load increment by default and is
  passed through the P5-06 bounded progression rule before becoming a proposal.
- If the bounded decrease cannot be compared, the rule returns not-comparable
  instead of guessing.
- The rule does not classify raw set outcomes into performance misses. Time,
  equipment, and external interruption filtering remains assigned to P5-09, and
  pain safety handling remains assigned to P5-10.
- The result remains a read-only recommendation candidate. It does not update a
  program version, save a recommendation, or apply the change without a later
  review flow.

P5-09 defines the first progression signal classifier:

- Rule set version is `progression_signal_classifier.v1`.
- The classifier converts raw exposure evidence into target-met,
  performance-miss, or not-comparable signals for the P5-08 miss-response rule.
- Strength and technique limitations, repetitions below the prescribed minimum,
  and load below the current prescription are performance-miss signals when no
  higher-priority non-comparable blocker exists.
- Time limitation, equipment limitation, and external interruption outcomes are
  not-comparable signals and do not count toward a performance-failure streak.
- Missing required set evidence, missing actual repetitions, missing actual
  load when load is prescribed, and pain reports are also not-comparable at
  this stage.
- If an exposure contains both interruption evidence and low numeric results,
  the interruption keeps the exposure out of the performance-failure streak.
- Pain remains a non-comparable safety signal in this classifier; stopping
  progression and displaying safety guidance remains assigned to P5-10.
- The classifier is read-only. It does not save streaks, update a program
  version, or apply recommendations.

P5-10 defines the first pain progression guard:

- Rule set version is `pain_progression_guard.v1`.
- The guard evaluates raw exposure evidence for the current exercise
  prescription and ignores pain reports from other exercises.
- Any matching set with a pain outcome stops loaded progression for that
  exercise.
- The returned bounded progression decision is always a hold decision, so the
  prescription remains unchanged and no increase or decrease is proposed.
- Pain remains separate from performance-miss streaks. It must not be counted
  as target-met, performance-miss, or earned-reduction evidence.
- Safety guidance is returned as typed guidance values: stop loaded
  progression, keep the prescription unchanged, avoid training through pain,
  resume only when pain-free, and seek qualified help for sharp, persistent, or
  worsening pain.
- The guard is read-only. It does not diagnose pain, prescribe rehabilitation,
  write safety state, update a program version, or apply recommendations.

P5-11 defines the plateau and deload data sufficiency gate:

- Rule set version is `plateau_deload_data_gate.v1`.
- The gate consumes classified exposure signals for the current exercise
  prescription.
- Target-met and performance-miss signals are comparable evidence.
- Not-comparable signals are excluded from the evidence count. This includes
  pain, time interruption, equipment interruption, external interruption, and
  missing required evidence from earlier classifiers.
- The latest matching exposure must be comparable. A latest not-comparable
  exposure blocks plateau and deload checks even when older data exists.
- Plateau checks require at least four comparable matching exposures spanning at
  least 21 days.
- Deload checks require at least three comparable matching exposures spanning at
  least 14 days.
- Other exercises are ignored when evaluating the current prescription.
- If the gate is not eligible, later plateau or deload recommendation logic
  must hold rather than infer from insufficient data.
- The gate is read-only. It does not diagnose a plateau, recommend a deload,
  update a program version, write recommendation state, explain changes, or
  apply recommendations.

P5-12 defines the recommendation explanation envelope:

- Rule set version is `adaptive_recommendation_explanation.v1`.
- The envelope can explain earned load increases from P5-07, repeated-miss load
  decreases from P5-08, and pain progression stops from P5-10.
- Every explained candidate identifies the subject, typed value changes, reason
  codes, triggering evidence references, and undo metadata.
- Load-change explanations include the previous load, proposed load, triggering
  exposure IDs, bounded-change reason, and any bounded-progression limit reason.
- Load-change undo metadata records the previous load that a later review flow
  can restore if the accepted change is undone.
- Pain progression-stop explanations reference the pain exposure and set orders,
  but they do not offer a load undo because P5-10 does not mutate the program.
- Held or insufficient recommendation candidates return a no-change explanation
  with no undo action.
- The envelope is read-only. It does not localize final text, accept, reject,
  edit, apply, persist, or undo recommendations.

P5-13 defines the recommendation review flow:

- Rule set version is `adaptive_recommendation_review.v1`.
- A review can be opened only for an explanation that contains a changed value.
  Held or no-change candidates are blocked.
- Accepting a load recommendation applies the proposed load to a copied
  prescription.
- Rejecting a recommendation keeps the copied prescription equal to the
  original prescription.
- Editing is available for load recommendations before acceptance. The edited
  load must be finite and non-negative, and it replaces the proposed load in
  the review state.
- Undo is available only after an accepted load recommendation with restore-load
  metadata. Undo restores the previous load on the copied prescription.
- Pain progression-stop reviews can be accepted, but they do not mutate the
  prescription load and do not offer a load undo.
- Finalized recommendations cannot be accepted, rejected, or edited again.
- The flow is read-only from the repository perspective. It does not save
  recommendation state, publish a program version, update `prescribed_sets`,
  localize copy, or apply changes outside the copied prescription.

P5-14 defines golden-persona simulation coverage:

- The simulation suite uses synthetic personas only and never stores real
  personal health or training data.
- Each simulation runs exactly twelve weekly exposures for one exercise
  prescription.
- The clean progression persona must earn bounded load increases every two
  qualifying exposures without exceeding the smallest available increment.
- The repeated-miss persona must hold after isolated misses, reduce only after
  repeated performance misses, and keep interruption evidence out of failure
  streaks.
- The pain-safety persona must stop later progression after a pain report while
  keeping the prescription load unchanged.
- The simulations must exercise P5-06 through P5-13 together: bounded
  progression, smallest increase, repeated miss response, interruption
  filtering, pain guard, plateau/deload data gate, explanation envelope, and
  review flow.
- The simulations are acceptance tests only. They do not create a runtime
  simulation engine, write recommendation state, publish program versions, or
  build an APK.

P5-15 defines no new training rule set. Build C3 packages the current
adaptive-programming beta after local validation of the deterministic rules,
golden-persona simulations, and Android debug APK metadata. It does not change
progression thresholds, recommendation semantics, safety guidance, or the
requirement for user confirmation before applying program changes.

## Prescription Model

Each exercise prescription will support:

- Number of working sets
- Minimum and maximum repetitions
- Optional target RIR
- Prescribed load and unit
- Rest duration
- Exercise priority
- Progression mode

Fixed repetitions are represented by equal minimum and maximum values. RIR remains an independent setting.

## Result Model

Every set stores prescribed and actual values plus one optional outcome:

- Strength limitation
- Technique limitation
- Pain
- Time limitation
- Equipment limitation
- External interruption

P4-04 records these outcomes on active-workout set logs. Outcome interpretation
for progression, pain handling, and interruption filtering remains owned by
Phase 5 decision rules.

P4-05 uses prescribed rest duration to drive the active workout countdown and
background rest alert. Timer completion is execution guidance only; it does not
change progression, fatigue, or session success rules in this phase.

P4-06 restores an `inProgress` session after app process restart so completed
set logs remain available for continued execution. Recovery does not classify
the session, replay rest timers, or interpret outcomes for progression.

P4-07 adds execution-status calculation without applying progression changes:

- Planned sets are pending.
- A completed set is target-met when no limiting outcome is reported,
  repetitions meet at least the prescribed minimum, and any prescribed load is
  met or exceeded.
- Strength and technique outcomes, below-minimum repetitions, or below-target
  load create a performance miss.
- Time, equipment, external, and skipped outcomes are interruptions rather than
  performance misses.
- Pain is its own highest-priority status and remains a safety signal.
- Exercise status aggregates its own set statuses.
- Session status aggregates exercise statuses and can require review without
  automatically treating the whole workout as failed.

P4-08 displays history and personal records without changing progression. A
personal-record candidate must be the latest revision for a completed set, must
contain repetitions or load, and must not contain a limiting outcome. The record
view is evidence display only; Phase 5 remains responsible for deciding whether
any observed performance should increase, hold, or reduce future prescriptions.

P4-09 corrections are evidence revisions, not retroactive rule decisions. When
a set is corrected, later read models and future progression logic use the
latest revision as the current fact, while earlier revisions remain available
for audit and troubleshooting. Corrections do not directly trigger a program
change in Phase 4.

P4-10 adds acceptance coverage without changing training rules. Offline and
reopened-database tests verify that the same latest-revision evidence is used
after app recovery before any Phase 5 progression decisions are allowed.

## Initial Decision Policies

- Increase only after qualifying repeated performance, rounded to available equipment increments.
- Hold after an isolated miss or when evidence is insufficient.
- Reduce within bounded limits after repeated performance misses.
- Do not count time, equipment, or external interruption as strength failure.
- Stop progression when pain is reported.
- Require user confirmation before applying a program change.
- Do not replace exercises on an arbitrary short schedule.

## Scheduling Priorities

1. Safety and hard availability constraints
2. Required equipment and location
3. Target weekly training exposure
4. Recovery between high-stress sessions
5. User preferences
6. Minimal disruption to the existing schedule

## Rule Output

Each decision records:

- Rule identifier and rule-set version
- Triggering observations
- Previous and proposed values
- Data-sufficiency assessment
- Human-readable rationale
- Confirmation requirement
- Accepted, rejected, edited, or reverted state

## Safety Boundary

- The system serves general wellness and fitness use only.
- Reported pain prevents automatic progression.
- Urgent warning signs end the workout flow and display appropriate safety guidance.
- The system does not diagnose injuries or prescribe rehabilitation.

## Test Matrix Placeholder

Rule tables, boundary values, property tests, and golden-persona simulations will be added as the engine is implemented.
