# Pre-registration of Predictions and Estimates

**Written:** 2026-10-29
**Revised before execution:** 2026-11-04 (E-1 to E-3 filled from measured values; see revision note at the end)
**Author:** Logesh Balakrishnan
**Status:** Committed BEFORE any pathfinder execution

---

## Why this document exists

Chapter 4 of the report states four expected findings. Advisor feedback (2026-10-26)
correctly noted the risk that stated expectations become predetermined conclusions:

> "These are reasonable possibilities, but they should not become predetermined
> conclusions. Let the data determine whether the estimates were accurate, which
> estimates deviated most, and whether the revised estimates are better supported."

This document records the predictions and the numeric estimates they will be tested
against, with a commit timestamp that precedes execution. After the pathfinder runs,
each prediction is marked confirmed or contradicted against measured data.

A contradicted prediction is a valid result and will be reported as such. The purpose
is to make the predictions falsifiable, not to make them correct.

**This file is not edited after the pathfinder begins.** Results are recorded in a
separate file (`/reports/prediction-outcomes.md`).

---

## Numeric estimates

These are the planning estimates the measurements will be compared against. Each is
stated before execution with the reasoning that produced it.

| ID | Quantity | Estimate | Basis for the estimate |
|---|---|---|---|
| E-1 | Measured upload throughput | 37.27 Mbps | Ookla speedtest.net, Windows laptop, 2026-10-29, lower of two runs (37.27 and 39.13). Evidence: `evidence/week-01/E1-bandwidth-measurement.md` |
| E-2 | Data volume per VM | db01 12.09 GB (12,088,487,936 B); app01 11.30 GB (11,299,930,112 B); lic01 2.96 GB (2,955,026,432 B); total 26.34 GB (26,343,444,480 B) | Measured used bytes (`df -B1 --output=used /`) after the attempt 2 build, 2026-11-04, before any replication. The plan committed on 2026-10-29 was 8 GiB per VM (24 GiB total) |
| E-3 | Initial replication duration, all 3 VMs | 1.5 hours | Value committed on 2026-10-29 (3 x 8 GiB / 37.27 Mbps = 1.54 h), kept unchanged for P-1. Recomputed from the measured E-2 total: 26,343,444,480 B x 8 / 37.27 Mbps = 5,655 s (94.2 min, 1.57 h). Reported alongside, not substituted. No allowance for overhead |
| E-4 | Cutover window (freeze to validated) | 68 minutes | Sum of runbook step estimates, Worksheet A. Drafted with AI assistance, reviewed and adopted by the author. Instance launch and network-fix durations are guesses, no prior data |
| E-5 | Application downtime during cutover | 63 minutes | E-4 minus the 5-minute pre-check done before the source app is stopped. Clock starts when the source app stops and ends when AWS validation passes |
| E-6 | Defects found during validation | 4 | Judgment; no prior data. Three expected: the undocumented licence dependency (seeded), the audit_log table without a primary key (seeded), the hosts-file entries that point at old addresses. Plus one allowed for something unplanned. Drafted with AI assistance, reviewed and adopted by the author |
| E-7 | Rollback duration | 20 minutes | Sum of rollback plan step estimates, Worksheet B. Drafted with AI assistance, reviewed and adopted by the author. Assumes the source VMs were stopped but not changed |
| E-8 | Total AWS cost, pathfinder wave | $20 | Author's estimate. Sits between the $15 and $30 budget alerts. Pricing Calculator assumptions recorded separately in the cost baseline |
| E-9 | Effort, Wave 0 landing zone | 50.3 hours | Three-point (PERT) estimate for WBS 3.0 Landing Zone, committed in `pm-baselines/wbs.md` on 2026-10-29 before Wave 0 execution was logged complete |
| E-10 | Effort, Wave 1 pathfinder | 83.8 hours | Three-point (PERT) estimate for WBS 4.0 Pathfinder Migration, committed in `pm-baselines/wbs.md` on 2026-10-29: optimistic 36, most likely 74, pessimistic 170. Includes 29.3 hours of elapsed initial synchronization (WBS 4.2.2); attended effort is 54.5 hours. Scope is the full WBS 4.0, including the source build |

**Fill every blank before committing this file.** An estimate written after the fact is
worthless for the comparison this project is built on.

Where an estimate is close to a guess, say so in the basis column. "Judgment, no prior
data" is an honest entry and is itself a finding when the measurement comes in.

---

## Estimate worksheets

Estimates are written for a cutover that goes to plan. The failed cutover in the
exercise is a test of the plan, so its expected failure is not built into these numbers.

**Worksheet A, cutover (E-4, E-5)**

| Step | Minutes | Basis |
|---|---|---|
| Pre-cutover checklist and freeze announcement | 5 | Judgment |
| Stop the source app and writes | 3 | Judgment |
| Confirm replication lag is zero in the MGN console | 5 | Judgment |
| Launch the three cutover instances (in parallel) and wait for conversion and boot | 25 | Guess, to be checked against the MGN launch log |
| EC2 status checks pass | 5 | Judgment |
| Fix network settings (hosts file now points at old addresses, security groups) | 15 | Guess |
| Validation: app returns 200, 200000 patients, licence reachable | 10 | Judgment |
| **Total (E-4)** | **68** | |
| **Downtime (E-5): all steps after the pre-check** | **63** | |

**Worksheet B, rollback (E-7)**

| Step | Minutes | Basis |
|---|---|---|
| Decide to roll back and notify | 5 | Judgment |
| Stop or isolate the AWS instances | 5 | Judgment |
| Restart the source services (licsvc, MySQL, app) | 5 | Judgment |
| Confirm the source app answers correctly | 5 | Judgment |
| **Total (E-7)** | **20** | |

---

## Predictions

Each prediction states what is expected, what would confirm it, and what would
contradict it. The falsification condition matters as much as the prediction.

### P-1 Replication will take longer than estimated

**Prediction:** Measured initial replication duration will exceed E-3.

**Confirmed if:** actual duration > E-3.
**Contradicted if:** actual duration <= E-3.

**Reasoning:** E-3 assumes sustained throughput equals advertised upload speed.
Protocol overhead, contention on a shared residential connection, and variable
compression ratios all reduce sustained throughput below the advertised figure.

**If contradicted:** the assumption that advertised bandwidth overstates sustained
throughput did not hold in this environment, and the reason needs investigating.
Possible causes include a conservative initial estimate or better-than-expected
compression on the chosen dataset.

---

### P-2 An undocumented dependency will surface during validation

**Prediction:** At least one dependency will be identified during test launch
validation that is absent from the dependency documentation produced during discovery.

**Confirmed if:** >= 1 such dependency found and logged.
**Contradicted if:** 0 found; the application functions correctly on first test launch.

**Reasoning:** The literature identifies undocumented dependencies as a leading cause
of migration failure. The discovery process used here relies on documentation and
configuration inspection, which are known to be incomplete.

**Note on honesty:** the source environment includes a dependency deliberately omitted
from the inventory, as a methodological device to test whether the validation process
catches it. This seeding is disclosed in the methodology appendix. P-2 therefore tests
the *validation procedure*, not the discovery process. That distinction is stated in
Chapter 5 and the prediction is weaker as a result.

**If contradicted:** the validation procedure failed to surface a dependency known to
be present, which is a more serious finding than confirmation would be.

---

### P-3 Measured recovery time will exceed the stated objective

**Prediction:** Measured recovery time will exceed the four-hour recovery time
objective stated in the charter.

**Confirmed if:** measured recovery time > 4 hours.
**Contradicted if:** measured recovery time <= 4 hours.

**Scope note:** this prediction is only testable if the disaster recovery exercise is
executed. If the exercise is descoped, P-3 is recorded as not tested, with the change
request reference. It is not quietly dropped.

**Reasoning:** The objective was set from a business requirement rather than from a
measured capability. Objectives set this way are commonly optimistic.

---

### P-4 The rollback will expose gaps in the written plan

**Prediction:** Executing the rollback will identify at least one step that is missing,
wrong, or takes materially longer than the plan states.

**Confirmed if:** >= 1 defect in the rollback plan identified during execution.
**Contradicted if:** the rollback executes exactly as written, within the estimated
duration.

**Reasoning:** The rollback plan is written from reasoning rather than from experience.
Untested procedures commonly contain gaps that only appear under execution.

**If contradicted:** that is a meaningful result. It would suggest a carefully reasoned
rollback plan can be correct on first execution, which runs against the common claim
that rollback capability must be tested to be trusted.

---

## What will be reported

For each prediction, `/reports/prediction-outcomes.md` will record:

- The prediction ID and whether it was confirmed or contradicted
- The measured value against the estimate
- The magnitude of the difference
- The planning assumption that proved wrong, where one did
- What changed as a result: risk register, schedule, cost baseline, or wave estimates

Predictions that were contradicted are reported with the same prominence as those
confirmed. A pre-registration that is 100% confirmed should itself raise suspicion.

---

## Limits of what these predictions can establish

Stated here so the limitation is on record before any result exists:

- One application, three virtual machines, one architecture. No variance can be
  measured and no rate can be generalised.
- A single host, so no cluster-level behaviour is observable.
- A residential connection, so absolute durations do not transfer to an enterprise
  environment. The relationship between estimated and measured throughput may.
- No production load on the source application during migration.

Confirming these predictions does not establish that pathfinder measurement improves
estimates generally. It establishes what happened in this environment, under these
constraints, for this application.

---

## Revision note, 2026-11-04

E-2 was planned as 8 GiB per VM and is now recorded from measured used bytes after the
source environment was rebuilt. E-3 keeps its originally committed value. The first build used
Ubuntu 26.10, which AWS MGN does not support, so it was discarded before any
replication (attempt 1, kept as superseded evidence). The rebuild on Ubuntu Server
24.04.3 LTS gave the E-2 figures above. No replication has started. E-4 to E-8 were
filled on 2026-11-04 with AI assistance and adopted by the author, before any
replication. E-9 and E-10 are copied from the WBS committed on 2026-10-29.

---

*Committed before execution. Not edited afterwards.*
