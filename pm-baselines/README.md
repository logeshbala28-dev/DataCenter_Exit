# Baselines — frozen after Phase 1

Files in this directory are written once in Phase 1 and then **not edited**.

If something changes, raise a change request in `/logs/change-log.md` and write a
re-baseline record as a new file (e.g. `cost-baseline-rebaseline-01.md`). The original
stays exactly as committed.

This matters because every variance figure in the project — CPI, SPI, cost variance,
schedule variance — is measured against these files. A baseline that was quietly
updated to match reality cannot demonstrate variance, and the absence of variance in a
project report is itself a finding.

## To be created in Phase 1 (week 1)

- `business-case.md` — five-year TCO comparison, NPV, payback, sensitivity analysis
- `project-charter.md` — objectives, scope, constraints, methodology statement
- `wbs.md` — decomposed to level 4, every work package with a unique ID
- `cost-baseline.md` — planned cost per work package ID, plus contingency and management reserve
- `schedule-baseline.md` — three-point estimates per work package, P80 committed date
