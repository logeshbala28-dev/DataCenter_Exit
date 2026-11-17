# Chapter 4 draft: sections 4.1, 4.4 and 4.11

**Status:** Draft written 2026-11-16, drafted with AI assistance for the author to review, edit
and adopt. Figures come from `pm-baselines/wbs.md`, `logs/defect-log.md`,
`pm-baselines/pre-registration.md` and `logs/status-log.md`. Text to check or complete is in
square brackets.

## 4.1 Planning Artifacts

The program plan covers 412 virtual machines in 68 applications across six waves. The work
breakdown structure has 83 work packages in eight top-level elements, with expected effort of
343.8 hours (subtotals: 1.0 = 37.6 h, 2.0 = 33.5 h, 3.0 = 50.3 h, 4.0 = 83.8 h, 5.0 = 26.2 h,
6.0 = 28.8 h, 7.0 = 32.1 h, 8.0 = 51.5 h). The WBS notes that work package 4.2.2 (initial
synchronization) is mostly elapsed time, so attended effort is about 314 hours, or roughly 35
hours a week over nine working weeks. [The shell says "before the pathfinder". The WBS total of
343.8 hours covers the whole project including the pathfinder; check which figure you want to
quote and change this sentence to match.]

## 4.4 Test Launch and Validation

**Defects found (E-6).** The estimate was four defects: three seeded and one allowed for
something unplanned. Three were found and the allowance was not used.

| ID | Found | Symptom | Root cause | Seeded | Fix time |
|---|---|---|---|---|---|
| D-01 | 17:52 | App returned HTTP 500 on `/`; journal showed `ConnectTimeout` to `meridian-lic01:8080` | Hosts-file lines on app01 still held the old VMware addresses (192.168.161.11 and .12), which are unreachable from the AWS network | Yes | About 31 min from the first symptom (fixed about 18:23), including a detour caused by a wrong example address in the instructions |
| D-02 | 17:57 | The failing call is a licence check that runs on every page load, and lic01 is not in the dependency inventory | Undocumented dependency on lic01. A plan built from the inventory alone would have left it out of the wave | Yes | Resolved with D-01 |
| D-03 | 18:35 | `audit_log` has four columns and no primary key | Built without one on purpose; it migrated unchanged | Yes | Not fixed in the pathfinder; recorded for the wave plan |

[Add a severity column if the chapter needs one; the defect log does not grade severity.]

**Result for P-2: confirmed.** The dependency surfaced during validation, as predicted. The first
failed request was at 17:52 and the dependency was named at 17:57, 5 minutes later. [Add the time
from test launch (the three instances were 3/3 at 17:50) to detection, and say how long the
launch itself took, if you want that interval.] Detection method: the application journal line
(`ConnectTimeout ... host='meridian-lic01'`) pointed to `check_license()` in the application code,
and a curl from app01 to the licence address confirmed that the service was unreachable.

**The `audit_log` table, which has no primary key.** The table replicated with all 300,000 rows,
and the row counts at 18:35 matched the source (200000 / 400000 / 300000). Replication itself did
not fail. The issue is for later: change data capture and many database-level replication
tools cannot reliably apply updates or deletes to a table without a primary key, so for a
production wave this table needs a key or a different method. It is recorded as D-03 for the
wave plan.

## 4.11 Prediction Outcomes

| ID | Prediction | Result | Evidence |
|---|---|---|---|
| P-1 | Replication longer than estimate | **Confirmed.** E-3 was 1.5 hours for all three VMs. The initial sync of db01 and app01 alone took about 111 minutes (25.5 GB at an average of 30.6 Mbps against the 37.27 Mbps measured earlier). [Add the lic01 finish time and the three-VM total.] | `evidence/week-02/attempt-2/e3-initial-sync-analysis.md`, `logs/status-log.md` |
| P-2 | Undocumented dependency surfaces | **Confirmed.** Found at 17:52 and named at 17:57 on 11 Nov; seeded defect D-02 | `logs/defect-log.md`, `evidence/week-03/validation-app01-*` |
| P-3 | Recovery time exceeds 4 h | **Contradicted.** Measured recovery 28 min 31 s (13:35:22 to 14:03:53, 16 Nov) | `logs/status-log.md` (Phase B), `evidence/week-04/dr1-B*` |
| P-4 | Rollback exposes gaps | **Confirmed.** Five gaps (RB-G1 to RB-G5); one wrong step and two missing ones | `logs/status-log.md`, `logs/post-incident-review-attempt-one.md` |

Check: P-1 is confirmed whatever lic01's time was, because the sync of two of the three servers
already took 111 minutes against an estimate of 90 for all three.
