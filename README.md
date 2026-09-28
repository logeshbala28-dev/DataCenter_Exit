# Enterprise Data Centre Exit — Cloud Migration Programme

**Capstone — Project Management Simulation**
Logesh Balakrishnan | Project Manager & Solutions Architect
Started: 2026-09-11 | Target completion: last week of November 2026

## Scenario

A regional healthcare organisation must exit its VMware-based data centre before its
licensing renewal and facility lease expire. Approximately 412 virtual machines across
68 applications must migrate to AWS under a fixed deadline, with regulated data in scope.

All data used in this project is synthetic. No real patient information is involved.

## Methodology — pathfinder wave

The full programme (six waves, 14 months on paper) is planned, estimated and costed.
One pathfinder wave is implemented hands-on. Measurements taken from the pathfinder —
replication throughput, cutover duration, downtime, defect count, effort and cost —
are used to re-estimate the remaining waves, so later planning rests on observed data
rather than assumption.

## Repository structure

| Path | Contents | Discipline |
|---|---|---|
| `/pm-baselines` | Charter, WBS, cost and schedule baselines | Written once, then frozen. Changes go through change control. |
| `/logs` | RAID, decisions, changes, status, cost, evidence index | Appended to continuously, never backfilled |
| `/decision-records` | One record per architecture decision | Written before implementation |
| `/evidence` | Screenshots, exports, outputs, organised by week | Captured at the moment of the event |
| `/runbooks` | Cutover, rollback, recovery procedures | Written before execution |
| `/infrastructure` | Terraform | Every change via the pipeline |
| `/reports` | Closure, lessons learned, variance analysis | Assembled from the logs at the end |
| `/scripts` | Monte Carlo, cost variance analysis | Python |

## Working rules

1. Commit every day worked. Never batch commits.
2. Log entries carry the date the event happened, not the date it was written up.
3. Baselines are frozen after Phase 1. Variance is measured against them, never hidden by editing them.
4. Friday: cost review, teardown checklist, file evidence.
5. Monday: status, earned value, RAID review — before any build work.

## Status

Phase 0 — pre-flight. See `/logs/status-log.md`.
