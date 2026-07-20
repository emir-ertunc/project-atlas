# Repository Working Rules

## Ownership and Attribution

- Preserve only the real project owner's identity and contributions.
- Do not add production notices, process credits, automated signatures, or co-author records for anyone other than the project owner.
- Preserve legally required third-party licenses, copyright notices, and source attributions.
- Keep all public repository content professional and human-authored in tone.

## Task Execution

- Perform only the checklist item explicitly requested by the user in each command.
- Do not continue to another checklist item without an explicit request.
- Before starting work, read `docs/MASTER_PLAN.md` and any relevant technical documentation when those files exist.
- Mark a task complete only after its tests and acceptance criteria pass.
- Preserve existing user changes and do not modify unrelated files.

## Repository Safety

- Do not commit secrets, signing keys, personal health or training data, or assets without verified distribution rights.
- Commit or push only when the active checklist item explicitly requires it.
- Keep legally required asset and dependency records accurate and complete.

## Completion Standard

- Validate the changed files with the checks required by the active checklist item.
- After a completed checklist item, update `docs/MASTER_PLAN.md` and include the current phase progress plus the next open checklist item in the completion response.
- Report which validation commands were run and whether they passed.
- Stop after completing and reporting the requested checklist item.
