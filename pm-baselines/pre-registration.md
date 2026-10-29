# Pre-registration of Predictions and Estimates

**Written:** 2026-10-29
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
| E-1 | Measured upload throughput | ___ Mbps | Speed test result, recorded before build |
| E-2 | Data volume per VM | ___ GB | Planned VM sizing |
| E-3 | Initial replication duration, all 3 VMs | ___ hours | E-2 x 3 / E-1, assuming sustained throughput equals advertised |
| E-4 | Cutover window (freeze to validated) | ___ minutes | Estimate from runbook step durations |
| E-5 | Application downtime during cutover | ___ minutes | Subset of E-4 |
| E-6 | Defects found during validation | ___ | Judgment; no prior data |
| E-7 | Rollback duration | ___ minutes | Estimate from rollback plan step durations |
| E-8 | Total AWS cost, pathfinder wave | $ ___ | AWS Pricing Calculator, assumptions recorded separately |
| E-9 | Effort, Wave 0 landing zone | ___ hours | Three-point estimate, see schedule baseline |
| E-10 | Effort, Wave 1 pathfinder | ___ hours | Three-point estimate, see schedule baseline |

**Fill every blank before committing this file.** An estimate written after the fact is
worthless for the comparison this project is built on.

Where an estimate is close to a guess, say so in the basis column. "Judgment, no prior
data" is an honest entry and is itself a finding when the measurement comes in.

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

*Committed before execution. Not edited afterwards.*
