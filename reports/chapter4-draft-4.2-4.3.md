# Chapter 4 draft: sections 4.2 and 4.3

**Status:** Draft written 2026-11-16, drafted with AI assistance for the author to review, edit
and adopt. Figures come from `logs/status-log.md`, `pm-baselines/pre-registration.md`,
`pm-baselines/wbs.md`, `evidence/week-01/wave0-outputs.txt` and
`evidence/week-02/attempt-2/e3-initial-sync-analysis.md`. Arithmetic is shown so it can be
checked. Text to check or complete is in square brackets.

## 4.2 Landing Zone (Wave 0)

The landing zone was applied (27 resources), destroyed and rebuilt from code with no manual steps
on 29 October 2026, which satisfies charter objective O-2. The Terraform state is kept in an S3
bucket with versioning enabled and public access blocked. Access to AWS went through IAM Identity
Center with no long-lived access keys. A single-Region Identity Center instance was chosen over a
multi-Region one to avoid customer-managed KMS key charges, with no functional loss for a
single-region pathfinder. The resources used the free tier and no cost was incurred. Evidence:
`evidence/week-01/wave0-outputs.txt` (VPC `10.20.0.0/16`, two availability zones, security groups
for the application, database, dependency and MGN staging tiers).

Actual effort was `[___]` hours against an estimate of 50.3 hours (E-9, the PERT estimate for WBS
3.0, committed on 2026-10-29). [Fill the actual from your effort log. Say how the hours were
recorded, as in section 4.9.]

The landing zone was rebuilt again on 4 November before replication. [Check this against your log:
the status entry says "rebuild the landing zone" as a next step, and I have no record of the date it
was done.]

## 4.3 Replication

| Measure | Estimate | Measured | Difference |
|---|---|---|---|
| Upload throughput (E-1) | n/a | 37.27 Mbps (lower of 37.27 and 39.13) | n/a |
| Data volume, three VMs (E-2) | 24 GiB (3 x 8 GiB), about 25.8 GB | 26.34 GB (24.5 GiB): db01 12.09 GB, app01 11.30 GB, lic01 2.96 GB | +0.5 GiB, about +2 percent |
| Sustained replication throughput | 37.27 Mbps (assumed equal to E-1) | 30.6 Mbps average for db01 and app01 (25.5 GB over about 111 minutes) | 6.7 Mbps lower, about 82 percent of E-1 |
| Initial replication, all three VMs (E-3) | 1.5 h (90 min) | db01 and app01 together: about 111 min (1.85 h). lic01: `[finish time]`. All three: `[___]` | db01 and app01 alone: +21 min over the whole-project estimate |

**Method.** The sync time for db01 and app01 was read from the CloudWatch `NetworkIn` metric of the
shared replication server (5-minute sums). Replication started in the console at 10:56 (app01) and
10:57 (db01) on 6 November and traffic stopped at about 12:47. The recomputed E-3 from the measured
volume at the measured upload speed is 94.2 minutes (26,343,444,480 B x 8 / 37.27 Mbps), kept
alongside the committed 90 minutes and not substituted for it. lic01 registered late because its
agent installs failed (RAID I-08 and I-09), and it was at 12 percent of its initial sync at 16:11,
with about 30 minutes left by the console's estimate. [Add the finish time for lic01 so the three-VM
total can be stated.]

**Result for P-1: confirmed.** Initial replication took longer than estimated. The sync of two of the
three servers already took 111 minutes against 90 for all three, so the result holds whatever lic01's
time was. The assumption in E-3 that did not hold is that sustained replication throughput would
equal the measured upload speed. The measured average was about 82 percent of it (30.6 against
37.27 Mbps), and the five-minute windows ranged from 21 to 35 Mbps while the sync ran, with some lower
windows near the end. A smaller part is volume: the measured data was about 2 percent above the plan.
Also, the two VMs received 25.5 GB over the wire while their used data was 23.39 GB (+9 percent);
[the reason is not established in the log, so state it as an observation or add the cause].

**Other observations.** Replication ran from 6 to 11 November without intervention. The Windows
event log shows no sleep, restart or power loss on the laptop on 6 November, and on 11 November the
public address was still the one recorded in the replication security group. Budget alerts were not
yet configured during those five days (RAID I-10).
