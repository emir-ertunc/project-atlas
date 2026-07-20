# Product Specification

## Document Status

- Status: P4-11 workout MVP APK complete
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
