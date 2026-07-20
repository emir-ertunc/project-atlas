# Training Rulebook

## Document Status

- Status: P4-10 resilience acceptance complete
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
