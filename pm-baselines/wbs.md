# Work Breakdown Structure

**Project:** Enterprise Data Center Exit — VMware to AWS Migration Program
**Version:** 1.0
**Date:** 2026-09-28
**Status:** Baseline — changes require a change request (see `/logs/change-log.md`)

---

## How to read this

Decomposed to level 4. Every work package carries a unique identifier. Those
identifiers are the key against which the cost baseline, schedule baseline, AWS cost
allocation tags and earned value calculations are all recorded. A cost or a duration
that cannot be attributed to a work package ID cannot be measured for variance.

Estimates are three-point: optimistic (O), most likely (M), pessimistic (P), in hours.
Expected duration uses the PERT formula (O + 4M + P) / 6. These values are recorded
before execution begins and are not edited afterwards.

The 100% rule applies: the children of any node constitute that node entirely. Work
not present in this structure is not in the project.

---

## 1.0 Program Planning

| ID | Work package | O | M | P | Expected |
|---|---|---|---|---|---|
| 1.1.1 | Five-year total cost of ownership model | 3 | 5 | 9 | 5.3 |
| 1.1.2 | Net present value, payback and return calculation | 2 | 3 | 5 | 3.2 |
| 1.1.3 | Sensitivity analysis on cloud run cost and migration effort | 2 | 3 | 6 | 3.3 |
| 1.2.1 | Project charter | 2 | 3 | 5 | 3.2 |
| 1.2.2 | Stakeholder register and communications plan | 1 | 2 | 4 | 2.2 |
| 1.3.1 | Work breakdown structure | 2 | 3 | 5 | 3.2 |
| 1.3.2 | Cost baseline with contingency and management reserve | 2 | 3 | 6 | 3.3 |
| 1.3.3 | Schedule baseline with three-point estimates | 2 | 3 | 5 | 3.2 |
| 1.3.4 | Monte Carlo simulation script and initial run | 3 | 5 | 10 | 5.5 |
| 1.4.1 | Risk register with expected monetary value scoring | 2 | 3 | 5 | 3.2 |
| 1.4.2 | Change control process definition | 1 | 2 | 3 | 2.0 |

**Subtotal: 37.6 hours**

## 2.0 Discovery and Wave Planning

| ID | Work package | O | M | P | Expected |
|---|---|---|---|---|---|
| 2.1.1 | Application inventory for 68 applications and 412 virtual machines | 3 | 5 | 9 | 5.3 |
| 2.1.2 | Dependency mapping, including seeded undocumented dependency | 3 | 5 | 8 | 5.2 |
| 2.2.1 | Wave grouping criteria and sequencing logic | 2 | 3 | 5 | 3.2 |
| 2.2.2 | Six-wave plan with dates, counts and critical path | 3 | 4 | 7 | 4.3 |
| 2.3.1 | Pathfinder selection criteria and decision record | 1 | 2 | 3 | 2.0 |
| 2.4.1 | Target architecture design and diagrams | 4 | 6 | 10 | 6.3 |
| 2.4.2 | Architecture decision records per selected service | 3 | 5 | 8 | 5.2 |
| 2.4.3 | Budget tier classification of all components | 1 | 2 | 3 | 2.0 |

**Subtotal: 33.5 hours**

## 3.0 Landing Zone (Wave 0)

| ID | Work package | O | M | P | Expected |
|---|---|---|---|---|---|
| 3.1.1 | Terraform practice build (VPC, subnets, routing) | 3 | 5 | 10 | 5.5 |
| 3.1.2 | Remote state backend and bootstrap | 2 | 4 | 9 | 4.5 |
| 3.1.3 | Provider aliasing and cross-account role assumption | 2 | 4 | 8 | 4.3 |
| 3.2.1 | Account structure and organizational units | 2 | 3 | 6 | 3.3 |
| 3.2.2 | Preventive guardrails, tested against a throwaway unit | 3 | 5 | 10 | 5.5 |
| 3.2.3 | Tag policy enforcing cost allocation tags | 1 | 2 | 4 | 2.2 |
| 3.3.1 | Centralized identity and permission sets | 2 | 4 | 7 | 4.2 |
| 3.3.2 | Organization-wide audit logging to log archive account | 2 | 3 | 6 | 3.3 |
| 3.4.1 | VPC, subnets and routing for the target environment | 2 | 4 | 7 | 4.2 |
| 3.4.2 | Staging subnet for migration replication | 1 | 2 | 4 | 2.2 |
| 3.4.3 | Hybrid name resolution configuration | 2 | 3 | 6 | 3.3 |
| 3.5.1 | Service level indicators and objectives defined | 1 | 2 | 4 | 2.2 |
| 3.5.2 | Dashboards, alarms and notification routing | 2 | 3 | 6 | 3.3 |
| 3.6.1 | Landing zone destroy and rebuild verification | 1 | 2 | 5 | 2.3 |

**Subtotal: 50.3 hours**

## 4.0 Pathfinder Migration (Wave 1)

| ID | Work package | O | M | P | Expected |
|---|---|---|---|---|---|
| 4.1.1 | Source virtual machines built on local hypervisor | 3 | 5 | 9 | 5.3 |
| 4.1.2 | Pathfinder application and synthetic data loaded | 2 | 4 | 7 | 4.2 |
| 4.1.3 | Supporting dependency service configured | 1 | 2 | 4 | 2.2 |
| 4.2.1 | Replication agents installed and registered | 1 | 3 | 6 | 3.2 |
| 4.2.2 | Initial synchronization (elapsed, largely unattended) | 8 | 24 | 72 | 29.3 |
| 4.2.3 | Replication throughput measured and recorded | 1 | 1 | 2 | 1.2 |
| 4.3.1 | Database replication with change data capture | 3 | 6 | 12 | 6.5 |
| 4.4.1 | Test launch and application validation | 2 | 4 | 8 | 4.3 |
| 4.4.2 | Defect log and remediation | 2 | 4 | 10 | 4.7 |
| 4.5.1 | Cutover runbook | 2 | 3 | 5 | 3.2 |
| 4.5.2 | Rollback plan with defined decision point | 1 | 2 | 4 | 2.2 |
| 4.5.3 | Go-live criteria and sign-off | 1 | 1 | 2 | 1.2 |
| 4.6.1 | Cutover attempt one (deliberately failed) | 2 | 3 | 6 | 3.3 |
| 4.6.2 | Rollback execution and timing | 1 | 2 | 5 | 2.3 |
| 4.6.3 | Post-incident review | 2 | 3 | 5 | 3.2 |
| 4.7.1 | Runbook remediation | 1 | 2 | 3 | 2.0 |
| 4.7.2 | Cutover attempt two (successful), with measurements | 2 | 4 | 8 | 4.3 |
| 4.8.1 | Replication staging resources deleted and verified | 1 | 1 | 2 | 1.2 |

**Subtotal: 83.8 hours**

## 5.0 Resilience and Recovery

| ID | Work package | O | M | P | Expected |
|---|---|---|---|---|---|
| 5.1.1 | Recovery strategy evaluation and selection | 2 | 3 | 5 | 3.2 |
| 5.1.2 | Control-plane dependency analysis and redesign | 2 | 4 | 7 | 4.2 |
| 5.2.1 | Timing instrumentation and recovery definition | 1 | 2 | 4 | 2.2 |
| 5.2.2 | Recovery environment provisioned in second region | 2 | 4 | 8 | 4.3 |
| 5.3.1 | Recovery exercise executed and timed | 2 | 3 | 6 | 3.3 |
| 5.3.2 | Gap analysis against the four-hour objective | 1 | 2 | 4 | 2.2 |
| 5.3.3 | Change request and sponsor decision on the gap | 1 | 1 | 3 | 1.3 |
| 5.4.1 | Controlled failure tests (instance, database, dependency) | 2 | 4 | 8 | 4.3 |
| 5.5.1 | Recovery environment destroyed and verified | 1 | 1 | 2 | 1.2 |

**Subtotal: 26.2 hours**

## 6.0 Measurement and Re-estimation

| ID | Work package | O | M | P | Expected |
|---|---|---|---|---|---|
| 6.1.1 | Cost variance analysis script and report | 3 | 5 | 9 | 5.3 |
| 6.1.2 | Root cause analysis of the three largest variances | 2 | 3 | 5 | 3.2 |
| 6.2.1 | Waves 2 to 6 re-estimated from measured data | 3 | 5 | 9 | 5.3 |
| 6.2.2 | Monte Carlo re-run with measured inputs | 1 | 2 | 4 | 2.2 |
| 6.2.3 | Variance narrative against the original baseline | 2 | 3 | 5 | 3.2 |
| 6.3.1 | Optimized architecture proposal with trade-offs | 2 | 4 | 7 | 4.2 |
| 6.3.2 | Business case updated with revised figures | 1 | 2 | 4 | 2.2 |
| 6.4.1 | Final earned value analysis and narrative | 2 | 3 | 5 | 3.2 |

**Subtotal: 28.8 hours**

## 7.0 Project Control (recurring)

| ID | Work package | O | M | P | Expected |
|---|---|---|---|---|---|
| 7.1.1 | Weekly management session (9 weeks at 1.5h) | 11 | 14 | 18 | 14.2 |
| 7.1.2 | Weekly cost review and teardown (9 weeks at 0.5h) | 4 | 5 | 7 | 5.2 |
| 7.1.3 | Weekly evidence filing (9 weeks at 0.3h) | 2 | 3 | 5 | 3.2 |
| 7.2.1 | Simulated stakeholder interactions and logging | 3 | 5 | 8 | 5.2 |
| 7.2.2 | Change request processing | 2 | 4 | 8 | 4.3 |

**Subtotal: 32.1 hours**

## 8.0 Reporting and Closure

| ID | Work package | O | M | P | Expected |
|---|---|---|---|---|---|
| 8.1.1 | Report Chapters 1 to 2 (introduction, literature review) | 6 | 10 | 16 | 10.3 |
| 8.1.2 | Report Chapter 3 (methodology) | 4 | 6 | 10 | 6.3 |
| 8.1.3 | Report Chapters 4 to 5 (results, discussion) | 5 | 8 | 14 | 8.5 |
| 8.1.4 | Report Chapter 6 and references | 3 | 5 | 8 | 5.2 |
| 8.2.1 | Benefits realization against charter objectives | 2 | 3 | 5 | 3.2 |
| 8.2.2 | Lessons learned register | 1 | 2 | 4 | 2.2 |
| 8.2.3 | Operational handover documentation | 2 | 4 | 7 | 4.2 |
| 8.3.1 | Final teardown across all accounts and regions | 1 | 2 | 4 | 2.2 |
| 8.3.2 | Project closure report with wave recommendation | 2 | 4 | 7 | 4.2 |
| 8.4.1 | Final presentation preparation | 3 | 5 | 8 | 5.2 |

**Subtotal: 51.5 hours**

---

## Summary

| Element | Expected hours |
|---|---|
| 1.0 Program Planning | 37.6 |
| 2.0 Discovery and Wave Planning | 33.5 |
| 3.0 Landing Zone | 50.3 |
| 4.0 Pathfinder Migration | 83.8 |
| 5.0 Resilience and Recovery | 26.2 |
| 6.0 Measurement and Re-estimation | 28.8 |
| 7.0 Project Control | 32.1 |
| 8.0 Reporting and Closure | 51.5 |
| **Total** | **343.8** |

Work package 4.2.2 (initial synchronization) is predominantly elapsed time rather than
attended effort. Excluding it, attended effort is approximately 314 hours.

Across nine working weeks this implies roughly 35 hours per week. This is the single
most important number in the baseline: if the available weekly hours are materially
lower, the scope must be reduced now, through change control, rather than discovered
as schedule variance in week seven.

## Critical path

1.3.x (baselines) → 2.2.2 (wave plan) → 3.x (landing zone) → 4.1.x (source build) →
4.2.2 (initial synchronization) → 4.6.x and 4.7.x (cutover sequence) → 5.3.1 (recovery
exercise) → 6.2.x (re-estimation) → 8.x (closure).

Work package 4.2.2 sits on the critical path and has the widest estimate range
(8 to 72 hours). It is the dominant source of schedule uncertainty and is tracked as
risk R-01.

## Exclusions

Consistent with the charter, this structure excludes migration of the remaining 409
virtual machines, application refactoring, post-migration operations, vendor
management, regulatory certification, and end-user training.
