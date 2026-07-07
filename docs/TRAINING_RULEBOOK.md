# Training Rulebook

## Document Status

- Status: Initial skeleton
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
