# Product Specification

## Document Status

- Status: Initial skeleton
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
