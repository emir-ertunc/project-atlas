# Asset and License Register

## Document Status

- Status: Initial skeleton
- Code license target: Apache-2.0

## Asset Policy

- Every binary or source asset must have verified distribution rights before entering the repository.
- Assets with non-commercial, no-derivatives, or unknown terms are rejected.
- Share-alike assets require an explicit compatibility review and separate tracking.
- Legally required copyright, license, and source notices are preserved.
- Runtime packages include only the minimum files needed by the application.

## Required Asset Metadata

- Stable asset identifier
- Repository path
- Asset type and purpose
- Source URL
- Copyright holder or author
- License identifier and version
- Required attribution text
- Source and processed-file hashes
- Modification summary
- Redistribution and modification permissions
- Review date and reviewer

## Asset Inventory

| Asset ID | Path | Source | License | Attribution | Hash | Status |
| --- | --- | --- | --- | --- | --- | --- |
| _Pending_ | _Pending_ | _Pending_ | _Pending_ | _Pending_ | _Pending_ | Not reviewed |

## Planned Validation

- Fail validation when a bundled asset has no manifest entry.
- Fail validation for missing hashes or required attribution.
- Reject forbidden license categories.
- Validate GLB files and enforce geometry and file-size budgets.
