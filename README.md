# Project Atlas

Project Atlas is an Android-first fitness application focused on structured
workout planning, set-level training logs, adaptive scheduling, progress
analysis, and interactive anatomical visualization.

The project is currently in its foundation phase. The working name and package
identifier are temporary until the release-branding checkpoint.

## Product Direction

- Offline-first personal release with no required account or remote service
- Turkish and English interface with metric and imperial units
- Fixed or ranged repetition targets with independent RIR tracking
- Explainable, user-approved training and schedule recommendations
- Body-measurement history and a clearly labeled visual anatomy estimate
- Interactive muscle regions and exercise-specific muscle highlighting

## Current Status

The base Flutter application scaffold now targets Android and iOS. Riverpod,
GoRouter, Drift, code generation, Turkish/English localization, metric/imperial
units, design tokens, five state-preserving primary navigation branches, schema
migrations, local-first repositories, backup controls, and automated tests are
configured. Phase 1 validation is recorded, while its remaining accessibility
and prescription acceptance items stay open in the master plan.

## Documentation

- [Master plan](docs/MASTER_PLAN.md)
- [Product specification](docs/PRODUCT_SPEC.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Core data model](docs/DATA_MODEL.md)
- [Local-first data flow](docs/LOCAL_DATA_FLOW.md)
- [Database reliability](docs/DATABASE_RELIABILITY.md)
- [Backup and encrypted export security](docs/SECURITY_AND_EXPORT.md)
- [Phase 1 validation](docs/PHASE_1_VALIDATION.md)
- [Design system](docs/DESIGN_SYSTEM.md)
- [Development setup](docs/DEVELOPMENT_SETUP.md)
- [Training rulebook](docs/TRAINING_RULEBOOK.md)
- [Exercise catalog plan](docs/EXERCISE_CATALOG.md)
- [Asset and license register](docs/ASSET_LICENSES.md)
- [Decision log](docs/DECISIONS.md)

## Safety Scope

The personal release targets healthy adults aged 18 and over for general
fitness use. It does not provide diagnosis, treatment, rehabilitation, or
medical body-composition analysis. Pain and urgent warning signs must stop
progression flows and direct the user to appropriate professional care.

## Data and Repository Safety

Real health, measurement, and workout data must not be committed. Secrets,
signing material, private exports, and assets without verified redistribution
rights are excluded from the repository.

## Development Workflow

Repository work follows [AGENTS.md](AGENTS.md). Each user command completes one
requested checklist item, validates its acceptance criteria, and stops before
the next item.

## License

Project source code is licensed under the [Apache License 2.0](LICENSE).
Dependencies and content assets remain subject to their respective licenses;
required records are maintained in [NOTICE](NOTICE) and the
[asset register](docs/ASSET_LICENSES.md).
