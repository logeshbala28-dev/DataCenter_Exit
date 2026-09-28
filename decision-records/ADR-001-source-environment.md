# ADR-001 — Simulated source environment

**Date decided:** 2026-09-11
**Status:** Proposed

## Context
The programme simulates migrating 412 VMs out of a VMware data centre. No such data
centre exists, so a source environment must be simulated. The choice determines the
connectivity model, the realism of replication measurements, and the cost profile.

Constraint: host machine has 16 GB RAM, of which roughly 12 GB is usable for guests.
Constraint: residential internet connection, upload bandwidth unverified.
Constraint: no student credits — costs fall on a personal account.

## Options considered

**Option A — local hypervisor.** Two Linux VMs on the host machine, connected to AWS
over a tunnel. Produces genuine replication throughput data constrained by real upload
bandwidth, which makes cutover-window estimates measured rather than invented.

**Option B — second AWS account as the source.** More reliable, no hardware limits, no
tunnel complexity. Replication runs over the AWS backbone, so throughput measurements
would not reflect a realistic constrained link.

## Decision
Option A, with Option B as a documented fallback if replication cannot be established
by the end of week 4.

## Rationale
The central claim of the pathfinder methodology is that later wave estimates rest on
measured data. Bandwidth is the binding constraint in real migrations, so measuring it
on a genuinely constrained link is what makes the extrapolation defensible. Option B
would produce throughput figures that flatter the plan and weaken the argument.

Two VMs rather than three, Linux server editions without a desktop, to fit 12 GB.

## Trade-offs accepted
Lower reliability and more setup effort. Host machine resource pressure during
migration work. Possible carrier-grade NAT on the residential connection, which would
block a standard site-to-site tunnel and force a software endpoint (see ADR-002).

## Cost implication
Tier A — near zero. Local compute is free; AWS costs are the replication staging
volumes and target instances only.

## How this will be tested
Replication established and initial sync completed by end of week 4, with throughput
recorded. If not achieved, the fallback triggers as a formal change request.

## Consequences
Makes the throughput measurement credible, which is the foundation of the wave
re-estimation in week 8. Makes weeks 3 to 5 more fragile and dependent on home
network conditions — tracked as R-01.
