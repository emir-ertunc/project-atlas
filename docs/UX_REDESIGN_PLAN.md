# Modern UX Redesign Plan

## Purpose

Phase 7 resets the product experience before the personal release. The current
feature set is functional, but the interface is too long, primitive, and hard
to understand. The redesign must keep the completed offline-first engine while
making the app feel compact, modern, premium, and immediately usable.

The product direction is serious strength-training coaching combined with
lightweight gamified progress loops. The app should feel disciplined and
performance-focused, while using streaks, milestones, progress paths, and clear
daily missions to reduce friction.

This is an interaction and visual-quality direction, not permission to copy any
third-party interface, brand, artwork, copy, or asset.

## UX Principles

- Every screen has one obvious primary action.
- Root tabs are dashboards, not long forms or stacked menus.
- Setup, editing, and review tasks use short focused routes, step flows, or
  bottom sheets instead of one long vertical page.
- Advanced details are behind progressive disclosure: summary first, detail on
  tap.
- Cards are compact and high-signal: title, current state, next action, and one
  secondary detail at most.
- Fitness decisions stay serious: no cartoonish tone around pain, safety,
  body-composition estimates, or load progression.
- Motivation uses local streaks, consistency, milestones, and visible progress,
  not social pressure or dark patterns.
- The app should work one-handed during training: large primary controls,
  minimal typing, clear set state, and quick load/repetition adjustments.
- Empty states must teach the next action instead of showing blank dashboards.
- Turkish and English copy must be short enough for compact cards without
  truncation.

## Target App Shape

### Today

Today becomes the daily coach surface:

- next workout mission
- current streak and weekly consistency
- one-tap workout start or resume
- recovery or pain warning when relevant
- pending recommendation card
- compact progress snapshot

### Program

Program becomes a hub, not a long editor:

- active program overview
- training-day cards
- generated plan preview
- recommendations inbox
- separate routes for day editing, exercise ordering, catalog search, and
  prescription editing

### Active Workout

The workout screen becomes a focused set-by-set surface:

- one exercise block at a time
- one primary complete-set action
- compact previous performance
- quick load/repetition/RIR controls
- rest timer as a clear next-step state
- interruptions and pain captured with short explicit actions

### Anatomy

Anatomy becomes a visual-first review surface:

- large anatomy viewport
- overlay chips for trained muscle, weekly volume, fatigue, and visual estimate
- compact disclosure for visual-estimate limitations
- tap-to-inspect muscle regions
- measurement prompt only when no usable data exists

### Progress

Progress becomes a compact achievement and trend surface:

- streak and consistency path
- personal-record cards
- trend cards with short interpretation
- measurement comparison cards
- export/copy actions behind explicit review

### Profile and Settings

Settings become a profile hub with focused subroutes:

- training goal and experience
- equipment
- availability
- measurement preferences
- units and language
- backup/export
- safety and privacy

Settings must not be the dumping ground for onboarding, generated plans,
availability editing, and recommendation details on one long page.

## Visual Direction

- Dense but breathable card layout.
- Strong hierarchy through size, weight, and spacing rather than long labels.
- Premium dark mode and clean light mode from the same tokens.
- Bottom navigation stays compact and thumb-friendly.
- Use rings, streak dots, progress paths, and status chips for state.
- Use subtle motion for completion, streak continuation, card expansion, and
  route transitions.
- Avoid novelty animations that slow down workout logging.

P7-02 implements the first reusable visual foundation for this direction:
compact dashboard cards, status chips, progress rings, dense form sections,
dense text fields, and shared motion tokens. Later Phase 7 screens should use
these components before adding feature-specific visual structures.

P7-03 implements the first navigation foundation for this direction. The root
tabs now act as dashboard entry points, and existing complex surfaces are
opened through focused child routes instead of living directly on root tabs.
The preserved child routes are the current workout flow, Program builder,
catalog, recommendation inbox placeholder, exercise detail, Progress history,
trend and measurement review placeholders, Settings setup, and Settings
preference placeholders.

P7-04 rebuilds Settings setup as a compact guided wizard. The flow now presents
goal, experience, equipment, availability, measurement preference, and review
as separate short decisions instead of stacking onboarding, availability,
generated-plan, and replacement-preview sections on one page. It preserves the
existing local onboarding and availability repositories and does not add schema
or progression-rule changes.

P7-05 rebuilds the Today root as the first daily coach dashboard. The first
viewport now centers on the next workout mission, a root-level Start or Resume
action, local streak, weekly consistency, and a compact review queue card. The
dashboard derives those state summaries from existing local workout and program
data.

P7-06 rebuilds `/today/workout` as the focused active-workout route. When an
active session exists, the route hides program selection and day planning,
centers the current set, keeps only that set's completion action visible, shows
compact previous performance and quick load/repetition/RIR edits, preserves the
rest timer as the next-step state, and compresses non-focused sets into a status
queue.

P7-07 rebuilds the Program root as a read-only hub. The root now shows the
active plan overview, compact training-day cards, a recommendation inbox entry,
and route cards for builder and catalog work. Editing remains in focused child
routes so the Program destination no longer behaves like a long editor.

P7-08 rebuilds `/program/builder` as a guided creation flow. The builder now
shows step progress for setup, day editing, catalog and ordering work,
prescription targets, and publish review. It keeps catalog search in a focused
bottom sheet, preserves day and exercise ordering controls, and adds an explicit
publish confirmation before an immutable active version is created.

P7-09 rebuilds `/program/catalog` and `/program/exercise/:exerciseId` around
compact discovery. The catalog now uses a search hero, filter sheet, active
filter chips, larger media-led result cards, media-status badges, and a direct
add-to-program action. Detail pages lead with a media hero, primary muscle
chips, substitution chips, compact metadata, and the same add action before the
longer setup, execution, cue, and error sections.

P7-10 rebuilds the Anatomy root as a visual-first review surface. The anatomy
viewport now leads the screen, heatmap modes sit as overlay chips on the
viewport, tap-to-inspect keeps the selected region summary close to the visual,
missing-measurement guidance appears only when no usable body measurement value
exists, and the visual-estimate disclosure remains visible without changing the
renderer bridge, measurement schema, morph bounds, or training heatmap rules.

P7-11 rebuilds the Progress root as a compact path and review dashboard. The
root now leads with a local progress path, presentation-only streak and
seven-day consistency indicators, milestone chips, a personal-record preview,
one trend card, and one measurement-comparison card. Detailed history,
correction, trend, and export work remains in focused child routes, and the
change does not add achievement storage, alter training progression, or change
measurement-history export behavior.

P7-12 extracts local consistency streaks, milestones, and achievement feedback
into a shared read model used by Today and Progress. The model derives its state
from completed local workout sessions, personal-record summaries, and
measurement comparison availability; it does not persist achievements, add
social comparison, award points, or feed Phase 5 training progression rules.

P7-13 tightens the core Turkish and English product language across the primary
Phase 7 surfaces. Root navigation now uses Profile language for the local
preference hub, card copy targets one short sentence, empty states state the
next action, and workout labels prioritize immediate logging decisions. Safety,
pain, visual-estimate, export, and progression language remains conservative.

P7-14 adds deterministic UX golden baselines for stable redesigned primary
states, strengthens large-text checks across the five root routes, and broadens
touch-target checks for the main dashboard actions. Program builder and catalog
child routes remain covered by focused widget tests because the standard golden
harness is unstable for those input-heavy Program child routes; this exception
and the screenshot review matrix are recorded in
[the Phase 7 UX review](PHASE_7_UX_REVIEW.md).

P7-15 produces Build C4.5 as a development-only Android debug APK for the
modern UX preview. The checkpoint opens to the redesigned Today dashboard via
`PROJECT_ATLAS_INITIAL_LOCATION=/today`, keeps release signing and store-ready
identifiers out of scope, and records artifact metadata in
[the Phase 7 validation record](PHASE_7_VALIDATION.md).

## Implementation Boundary

Phase 7 may refactor presentation routes, controllers, widgets, copy, and
non-persisted UI state. It must preserve the existing local data model and
repository contracts unless a specific checklist item explicitly introduces a
schema migration.

The redesign does not change completed Phase 5 progression rules or Phase 6
visual-estimate safety boundaries. Pain handling, program changes, and body
estimate disclosures remain conservative and user-confirmed.

## Acceptance Standard

A Phase 7 screen is accepted only when:

- the main user action is visible without reading a long page;
- the screen has no avoidable long-form stacked sections;
- primary tasks can be completed through short focused flows;
- Turkish and English fit at normal and large text sizes;
- key states have widget or golden coverage;
- accessibility, contrast, and touch-target checks remain green;
- the screen works offline with existing local data.

The detailed P7-01 quality gates, app map, and screen-by-screen acceptance
criteria are recorded in [the modern UX quality bar](UX_QUALITY_BAR.md).
