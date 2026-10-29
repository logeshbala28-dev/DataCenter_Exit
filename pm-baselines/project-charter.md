# Project Charter

**Project:** Enterprise Data Center Exit — VMware to AWS Migration Program
**Client (simulated):** Meridian Regional Health Partners
**Project Manager / Solutions Architect:** Logesh Balakrishnan
**Charter date:** 2026-09-28
**Status:** Baselined — changes require a change request (see `/logs/change-log.md`)

---

## 1. Business need

Meridian Regional Health Partners operates a VMware-based data center supporting
approximately 412 virtual machines across 68 applications. Two contractual events
converge within fourteen months: the VMware licensing agreement renews at a
substantially increased rate, and the colocation facility lease expires two months
later. Neither date is negotiable.

Remaining in place requires accepting the renewal cost, signing a new facility lease,
and funding a hardware refresh cycle for aging hosts. Migrating to AWS removes the
licensing and facility commitments and converts capital expenditure to operating
expenditure, but introduces migration risk against a fixed deadline.

The organization has approved a migration program. This charter authorizes that
program and defines how it will be planned, measured and controlled.

## 2. Problem statement

Large migration programs are typically planned using vendor estimates, industry
benchmarks and expert judgment rather than measurements taken from the environment
being migrated. The resulting cost, schedule and effort estimates remain unverified
until execution is already underway, at which point correction is expensive and the
deadline is closer.

This program addresses that by executing one instrumented pathfinder migration early
and using its measured results to re-baseline the remaining waves.

## 3. Project objectives

Each objective states its measurement method. Objectives without a measurement method
are not objectives.

| ID | Objective | Measurement |
|---|---|---|
| O-1 | Produce a complete, baselined migration program plan covering all 68 applications in six dependency-sequenced waves | Plan artifacts committed to version control before implementation begins |
| O-2 | Provision a reproducible AWS landing zone using infrastructure as code | Environment destroyed and rebuilt from code with no manual steps |
| O-3 | Migrate the pathfinder application end to end with measured outcomes | Recorded values for replication throughput, cutover duration, downtime, defect count |
| O-4 | Demonstrate a tested rollback capability | One cutover deliberately failed and rolled back, with a written post-incident review |
| O-5 | Measure recovery capability against a stated objective | Timed cross-region recovery exercise, compared against a 4-hour recovery time objective |
| O-6 | Re-baseline waves 2 to 6 using measured pathfinder data | Revised estimates with documented variance against the original baseline |
| O-7 | Maintain cost and schedule control throughout | Weekly earned value reporting from baseline through closure |

## 4. Success criteria

The project is successful if all of the following hold at closure:

- The pathfinder application runs correctly in AWS following a cutover executed from a
  written runbook.
- A rollback was executed and documented, whether or not it was needed on the final
  attempt.
- Recovery time was measured, not estimated, and the result — including a shortfall —
  is reported with a remediation position.
- Waves 2 to 6 carry estimates derived from measured data, with the variance against
  the original baseline explained.
- Actual cloud spend remained within the approved implementation budget.
- Every scope, cost or schedule change passed through change control and is recorded.

Note that O-5 does not require the recovery objective to be met. It requires it to be
measured. A quantified shortfall with a root cause is an acceptable and informative
outcome; an unmeasured claim of success is not.

## 5. Scope

### In scope

- Full program planning for 412 virtual machines across 68 applications, sequenced
  into six waves
- Business case including five-year total cost of ownership comparison and sensitivity
  analysis
- AWS landing zone: account structure, network, identity, logging, preventive
  guardrails, cost allocation tagging
- Infrastructure as code for all provisioned resources
- Pathfinder migration of one representative application (three virtual machines)
  using rehost methodology
- Controlled failed cutover, rollback, and successful cutover
- Cross-region disaster recovery design and timed exercise
- Measurement, variance analysis, and re-estimation of remaining waves
- Full project management artifact set through to closure

### Out of scope

- Physical migration of the remaining 409 virtual machines
- Application refactoring, replatforming or modernization; the pathfinder is rehost only
- Production operations after migration
- Procurement, contract negotiation, and vendor management
- Formal regulatory certification or audit; compliance requirements are treated as
  design constraints, not as claims of certified compliance
- Migration of physical, non-virtualized systems
- End-user training and organizational change management

## 6. Assumptions

| ID | Assumption | Validation |
|---|---|---|
| A-1 | A three-VM source environment is sufficiently representative to produce extrapolatable measurements | Tested at wave re-estimation; limits stated in the analysis |
| A-2 | Replication over a residential connection yields usable throughput data despite differing from enterprise bandwidth | Measured during initial synchronization |
| A-3 | Pathfinder measurements can be scaled to larger waves with stated uncertainty | Addressed explicitly in the re-estimation, not assumed to be linear |
| A-4 | The simulated organization's estate, dependencies and constraints are internally consistent and plausible | Reviewed against published migration case studies |
| A-5 | Migration tooling free-tier periods remain available for the duration of the pathfinder | Confirmed before replication begins |

## 7. Constraints

| ID | Constraint | Consequence |
|---|---|---|
| C-1 | Individual delivery; no project team | All roles performed by one person; stakeholder pressure is simulated and disclosed |
| C-2 | Academic deadline of late November 2026 | Approximately nine working weeks plus two weeks schedule buffer |
| C-3 | Limited implementation budget on a personal account | Components tiered: build and keep, build during active phases, bounded test window, or design only |
| C-4 | Source environment is a single host | Cluster-level high availability behavior is not reproduced; stated as a limitation |
| C-5 | Residential network bandwidth | Replication duration is bandwidth-bound; cutover windows planned accordingly |
| C-6 | Synthetic data only | No real patient, organizational or proprietary data at any stage |

## 8. Methodology

This program uses a **pathfinder wave** approach, consistent with established practice
for large migrations. The complete program is planned, estimated and costed. One
representative wave is then implemented and instrumented. Measurements from that wave
replace the planning assumptions used for the remaining waves.

The rationale is that estimates derived from observed behavior of the actual
environment are more defensible than estimates derived from benchmarks, and that
discovering process failures on a low-criticality application is substantially cheaper
than discovering them on a clinical system.

Delivery is hybrid: predictive planning and control for the program, with iterative
execution within the landing zone build and pathfinder implementation.

### Baseline discipline

Cost and schedule baselines are committed to version control before implementation
begins and are not subsequently edited. Any change is raised as a change request and
recorded as a separate re-baseline. This preserves the ability to measure variance,
which is the central mechanism of the project.

### Simulated stakeholders

A fixed stakeholder cast is simulated to generate decision pressure and change
requests. This mechanism is disclosed in the methodology and is not represented as
engagement with real stakeholders.

## 9. Deliverables

**Planning:** business case, this charter, work breakdown structure, cost baseline,
schedule baseline with three-point estimates, risk register, wave plan, communications
plan.

**Implementation:** infrastructure as code repository, landing zone, architecture
decision records, migrated pathfinder application, cutover runbook, rollback plan,
disaster recovery procedure.

**Measurement and analysis:** replication and cutover measurements, defect log, cost
variance analysis, earned value reporting, Monte Carlo schedule simulation, revised
wave estimates.

**Closure:** post-incident review of the failed cutover, recovery exercise report,
benefits realization, lessons learned, closure report with a recommendation on the
remaining waves.

## 10. Milestones

| ID | Milestone | Target |
|---|---|---|
| M-1 | Charter and baselines committed | Week 1 |
| M-2 | Wave plan and pathfinder selection complete | Week 3 |
| M-3 | Landing zone operational and reproducible | Week 5 |
| M-4 | Source environment built, replication started | Week 6 |
| M-5 | Cutover sequence complete (failed, rolled back, succeeded) | Week 7 |
| M-6 | Disaster recovery exercise complete with measured timings | Week 8 |
| M-7 | Waves re-estimated and cost analysis complete | Week 9 |
| M-8 | Project closed | Week 11 |

Two weeks of schedule buffer are held between M-7 and M-8. Buffer consumption is
reported weekly and is not treated as free time.

## 11. High-level risks

Full detail is maintained in `/logs/raid-log.md`. The risks most likely to affect
delivery:

| ID | Risk | Response |
|---|---|---|
| R-01 | Replication throughput constrained by residential bandwidth | Measure before committing to a cutover window; fallback to manual rehost if replication is not established by end of week 6 |
| R-03 | Preventive policy misapplied, causing loss of administrative access | Test policies against a throwaway organizational unit; maintain an excluded break-glass role |
| R-04 | Cloud spend accrues unnoticed; billing alerts lag by roughly a day | Weekly teardown checklist as the primary control; alerts as a safety net only |
| R-05 | Limited prior infrastructure-as-code experience slows the landing zone build | Practice build completed before landing zone design |
| R-06 | Scope expansion from feedback during the academic term | Route all changes through change control with impact assessment |

## 12. Budget

**Simulated program budget.** Established in the business case and used for earned
value reporting against the program plan.

**Actual implementation budget.** Cloud spend on a personal account, tracked weekly in
`/logs/cost-log.md`. Alert thresholds are configured and the weekly teardown checklist
is the primary control. The two budgets are reported separately and are never combined.

## 13. Authority and governance

The Project Manager has authority to make architecture and sequencing decisions within
the approved scope. Changes to scope, committed objectives, or the baselines require a
change request and a recorded decision.

Academic approval of the methodology was received prior to Phase 1 and is filed in
`/evidence/`.

## 14. Approval

| Role | Name | Date |
|---|---|---|
| Project Manager / Solutions Architect | Logesh Balakrishnan | 2026-09-28 |
| Faculty Advisor (methodology approval) | | |

---

*Baselined 2026-09-28. Subsequent changes are recorded in `/logs/change-log.md` and as
separate re-baseline records. This document is not edited in place.*
