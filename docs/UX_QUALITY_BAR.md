# Modern UX Quality Bar

## Scope

P7-01 defines the experience standard for the Phase 7 redesign. It does not
change product data, training rules, progression logic, measurement rules, or
renderer behavior. It sets the acceptance bar that P7-02 through P7-15 must
meet when rebuilding the interface.

The redesign direction is a serious strength-training coach with lightweight
local progress motivation. The app must feel compact, premium, and easy to
understand without copying another product's visual identity, brand language,
artwork, or proprietary interaction patterns.

## Non-Negotiable Quality Bar

Every redesigned primary flow must satisfy these rules:

- The first viewport shows the current state and one primary next action.
- Root destinations are dashboards, not long forms or stacked settings pages.
- A user can understand what to do next within three seconds.
- Complex tasks open focused routes, bottom sheets, or short step flows.
- Advanced details are collapsed behind tap-to-expand or detail routes.
- Workout logging works one-handed, with minimal typing during the session.
- Empty states teach the next action and provide one clear button.
- Recommendations explain what changed, why, and how to undo without long
  paragraphs.
- Motivation uses streaks, milestones, and progress paths only as local
  feedback. It never overrides pain, safety, load progression, or confirmation
  rules.
- Pain, medical, body-composition, and visual-estimate copy stays conservative
  and serious.
- Turkish and English copy must fit compact layouts at normal and large text
  sizes.
- All redesigned states must pass offline use, contrast, touch-target, and
  large-text checks.

## Measurable UX Gates

| Gate | Acceptance threshold |
| --- | --- |
| Root clarity | The main state and primary action are visible without scrolling on a 360 x 800 logical pixel viewport. |
| Start workout | Starting or resuming today's workout requires no more than two taps after an active program exists. |
| Log set | Completing a normal set requires one primary tap after values are already correct. |
| Quick correction | Editing load, repetitions, or RIR during a workout requires no more than two taps plus numeric adjustment. |
| Program edit | Editing a training day, exercise order, or prescription opens a focused route or sheet rather than expanding a long root page. |
| Catalog add | Adding an exercise from search to the current program path requires no more than four major steps. |
| Measurement entry | Measurement entry uses grouped steps with visible progress and never shows all measurement fields as one long form. |
| Recommendation review | Accept, reject, edit, and undo actions are visible in the recommendation review surface. |
| Empty state | Every empty primary surface has one next action and one sentence of explanation. |
| Copy length | Primary labels target 1-3 words; helper copy targets one short sentence. |
| Touch target | Interactive targets are at least 48 logical pixels. |
| Large text | Primary flows render at 2.0 text scale without clipped critical controls. |
| Offline | Today, Program, Workout, Anatomy, Progress, and Profile remain usable without network access. |

## App Map

The root shell keeps five destinations, but each destination becomes a hub with
focused child routes.

```text
App shell
|-- Today
|   |-- Active workout
|   |-- Rest timer sheet
|   |-- Set interruption sheet
|   |-- Recommendation review sheet
|   `-- Reschedule preview sheet
|-- Program
|   |-- Program overview
|   |-- Training day detail
|   |-- Guided program builder
|   |-- Catalog search
|   |-- Exercise detail
|   |-- Prescription editor
|   |-- Publish review
|   `-- Recommendation inbox
|-- Anatomy
|   |-- Region inspect sheet
|   |-- Heatmap mode sheet
|   |-- Measurement prompt
|   |-- Measurement entry flow
|   `-- Visual estimate details
|-- Progress
|   |-- Consistency detail
|   |-- Personal record detail
|   |-- Trend detail
|   |-- Measurement comparison
|   `-- Measurement report review
`-- Profile
    |-- Setup wizard
    |-- Goal and experience
    |-- Equipment
    |-- Availability
    |-- Units and language
    |-- Notifications
    |-- Privacy and safety
    `-- Backup and export
```

Route names can remain technically compatible with existing paths until P7-03
performs the navigation refactor. Product language should treat Settings as
Profile once the redesigned hub ships.

## Screen Acceptance Criteria

| Surface | Primary action | Acceptance criteria |
| --- | --- | --- |
| App shell | Switch destination | Bottom navigation is compact, thumb reachable, state preserving, and does not hide the primary action of the active screen. |
| Today dashboard | Start or resume workout | Shows next workout, streak, weekly consistency, pending recommendation, and one primary start/resume action in the first viewport. |
| Empty Today | Create or generate a program | Explains that no active workout exists and offers one path to setup or program creation. |
| Active workout | Complete current set | Shows one exercise focus, set target, previous performance, quick load/repetition/RIR controls, and a dominant complete-set action. |
| Rest state | Continue after rest | Timer state is obvious, can be skipped, and does not block logging the next set when appropriate. |
| Interruption and pain sheet | Save outcome | Time, equipment, external interruption, technique, strength, and pain are captured with short explicit choices. Pain uses serious safety copy. |
| Program hub | Edit or review active plan | Shows active program summary, training-day cards, recommendation inbox, and builder entry without exposing all prescription fields at once. |
| Training day detail | Edit day | Shows ordered exercise cards and one clear edit/add action. Ordering and prescription editing open focused controls. |
| Guided program builder | Continue setup | Uses step progress, one decision per step group, compact review, and explicit publish confirmation. |
| Exercise catalog | Add exercise | Search, filters, and result cards fit compactly. Filters are chips or sheets. Results show muscles, equipment, level, media status, and add action. |
| Exercise detail | Add or substitute | Shows media first, then primary muscles, cues, common errors, substitutions, and add-to-program action behind compact sections. |
| Recommendation inbox | Review change | Groups pending recommendations by impact and shows why each exists without long root-page text. |
| Recommendation review | Accept, reject, edit, or undo | Shows current value, proposed value, trigger data, reason, confidence/limits, and explicit actions. |
| Anatomy | Inspect visual estimate | Prioritizes anatomy viewport, overlay mode chips, heatmap state, selected region summary, and visible non-medical estimate disclosure. |
| Measurement prompt | Enter measurements | Appears only when useful data is missing and sends the user to a guided flow rather than embedding a long form. |
| Measurement entry | Save measurement | Groups fields by body area, shows progress, validates inline, and separates blocking errors from warnings. |
| Progress dashboard | Review progress | Shows streak path, milestones, personal records, trend cards, and measurement comparison without long tables on the root. |
| Trend detail | Inspect trend | Opens from a trend card and explains the metric, source data, and limitations in compact sections. |
| Measurement comparison | Review or copy report | Shows first/latest deltas, side differences, personal-data warning, and explicit copy actions. |
| Profile hub | Manage account-local preferences | Shows setup completion, goal, equipment, availability, units, language, privacy, and export as compact rows or cards. |
| Profile detail routes | Save focused preference | Each route edits one preference group and returns to Profile after save. No detail route becomes an unrelated settings dump. |

## Copy and Tone Criteria

- Primary action labels are direct verbs: Start, Resume, Continue, Review,
  Save, Add, Edit, Publish.
- Root cards use short titles and one-sentence helper text.
- Training recommendations use coaching language grounded in evidence, not
  hype.
- Streak and milestone copy rewards consistency without shaming missed days.
- Safety copy is explicit and conservative.
- Visual-estimate copy avoids scan, diagnosis, medical assessment, and body
  composition certainty claims.

## Visual Review Matrix

P7-14 must capture and review the redesigned primary states at minimum:

- Today with active workout, empty Today, and pending recommendation.
- Active workout before set, after set, rest timer, and interruption sheet.
- Program hub with active plan, empty Program, and recommendation inbox.
- Program builder first step, exercise selection, prescription edit, and
  publish review.
- Catalog search with results, filtered empty state, and exercise detail.
- Anatomy default, heatmap mode, selected region, and missing measurement
  prompt.
- Progress overview, trend detail, measurement comparison, and report review.
- Profile hub and two focused preference routes.

Each captured state must be reviewed in light mode, dark mode, English,
Turkish, normal text scale, and 2.0 text scale unless the test matrix records a
specific justified exception.

## Handoff to Phase 7 Items

- P7-02 owns tokens and reusable components needed to satisfy this quality bar.
  Its accepted foundation is dashboard cards, status chips, progress rings,
  dense form sections, dense text fields, and motion tokens.
- P7-03 owns route structure and navigation behavior. Its accepted foundation
  is dashboard roots with focused child routes for workout, Program builder,
  catalog, exercise detail, Progress history/review surfaces, and
  Settings/Profile setup and preference surfaces.
- P7-04 through P7-11 rebuild the main user flows against the screen criteria.
- P7-12 owns streak and milestone implementation within the safety boundary.
- P7-13 owns final concise Turkish and English microcopy.
- P7-14 proves the redesigned flows with automated and visual checks.
- P7-15 packages the redesigned experience into Build C4.5.
