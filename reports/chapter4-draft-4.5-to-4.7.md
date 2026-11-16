# Chapter 4 draft: sections 4.5, 4.6 and 4.7

**Status:** Draft written 2026-11-16, drafted with AI assistance for the author to review, edit and
adopt. Every figure below is taken from `logs/status-log.md`, `logs/decision-log.md`,
`runbooks/rollback-plan-v2.md` and `runbooks/dr-plan-v1.md`. Text to check or complete is in
square brackets. Replaces the `___` blanks in `chapters4-6.md`.

## 4.5 Cutover Attempt 1 (Failed) and Rollback

Attempt one was planned to fail. Before the window opened (decision DEC-01, 11 November 2026,
19:40 CST), the author chose to launch only app01 and db01 and to leave out lic01, so that the
undocumented licence dependency would appear the way it would for a team working from the
inventory alone. The source services were stopped at about 20:07 and the two cutover instances
launched in 11 minutes (planned 25). The attempt was then paused at step 5, and the DP-1 limit of
75 minutes (DEC-02) passed during the pause. The window resumed on 16 November at 09:07.

The observed condition matched the prediction. After the hosts-file fix for db01 (09:13), the
application returned HTTP 500. The journal showed `ConnectTimeout ... host='meridian-lic01',
port=8080 ... /license`, and a curl from app01 to the licence address timed out (exit 28).
The rollback decision was taken at about 09:17, under triggers RB-1 (the application did not
return the expected response after the hosts fix) and RB-3 (the DP-1 limit had passed).

**Rollback duration (E-7).** The estimate was 20 minutes. The measured time from decision to
the source application answering again was about 22 minutes (09:17 to 09:39). Only about 6
minutes of that was hands-on work (09:33 to 09:39). The other 16 minutes passed between the
decision and the first action. The source application answered with 200000 patients on first
load, and MGN showed all three servers Ready for cutover and Healthy, with no rescan.

**Gaps found in the rollback plan (v1, executed unchanged):**

| ID | Gap | Type |
|---|---|---|
| RB-G1 | Step 2 says to tick all three servers, but only app01 and db01 had been launched | Wrong step |
| RB-G2 | No step and no owner for the time between the decision and the first action (16 minutes) | Missing step |
| RB-G3 | No rule for a window that is paused or abandoned. The source application stayed down for about five days against a planned 63 minutes | Missing provision |
| RB-G4 | Hands-on steps took about 6 minutes against 15 planned, so the plan overestimates the work and underestimates the decision delay | Estimate |
| RB-G5 | No check that billing stopped after the revert. At 09:42 the EC2 list showed both cutover instances gone | Missing check |

**Result for P-4: confirmed.** At least one step was wrong (RB-G1) and at least two were
missing (RB-G2 and RB-G3). Because of the five-day pause, attempt one's window and downtime
figures (E-4 and E-5) are not used as measurements. [State here how the pause came about, since
the log does not record the reason.]

## 4.6 Cutover Attempt 2 (Corrected)

Attempt two used `cutover-runbook-v2.md`, which was committed at 09:43 on 16 November before the
window opened. The source services were stopped at 09:48:17 to 09:48:18, which starts the downtime
clock. All three servers were launched (09:49 to 10:01), the status checks passed at about 10:06,
and the hosts file on app01 was corrected for both db01 and lic01 by 10:10. The licence check
returned `valid:true` at 10:11:39. The application page returned
`{"patients":200000,"status":"ok"}` with a clock in the screenshot at 10:18. Row counts were read at
10:28:35 and matched the source (200000, 400000 and 300000). The go decision at DP-1 was taken at
about 10:30 with all six go-live criteria met, and the cutover was finalized at 10:35 (Cutover
complete at 10:36).

**Application downtime (E-5).** The estimate was 63 minutes. The measured downtime is about 30
minutes (09:48:18 to 10:18, the earliest time a screenshot shows the clock). The author recalls
the first successful load at about 10:12, which would make it about 24 minutes. The evidenced
value is 10:18.

**Cutover window (E-4).** The estimate was 68 minutes. The start time of the pre-check (T0) was not
written down. It was between 09:43 and 09:48, so the window to the application check at 10:18 was
about 31 to 35 minutes, and about 41 to 45 minutes including the row-count check at 10:28.
[State that the missing T0 was recorded as a finding.]

**Changes made to the runbook after attempt one (version 2):**

| ID | Change |
|---|---|
| C2-1 | Launch all three servers, including lic01 |
| C2-2 | Fix both the `meridian-db01` and `meridian-lic01` hosts-file lines on app01 |
| C2-3 | Snapshot age is no longer a precondition; a snapshot after the stop is required |
| C2-4 | Mark Ready for cutover once, for all three servers, before the window |
| C2-5 | Every command line starts with `date` |
| C2-6 | No-pause rule and act-within-5-minutes rule at the decision point |

Observations from attempt two: SSH from app01 to db01 on port 22 timed out while port 3306 worked,
probably because the `pathfinder-db` security group allows only the database port (to be confirmed
in the group's inbound rules). The first PuTTY session to app01 also timed out while idle.

## 4.7 Disaster Recovery Exercise

The exercise followed `dr-plan-v1.md`: backup and restore into us-west-2 using machine images of
all three servers (DEC-03, DEC-04). The clock was defined before the exercise (DEC-05). It starts
when "DISASTER DECLARED" is written in the status log and stops when the application page returns
200000 patients, the licence check returns `valid:true` and the row counts are
200000 / 400000 / 300000.

**Preparation (Phase A, not part of the recovery time).** Images were created in us-east-1 at
11:07 (app01), 11:11 (db01) and 11:12 (lic01). The copies to us-west-2 failed twice (encryption
not selected; then a us-east-1 KMS key in the key field, found from the image's State reason), and
the correct copies were started at 13:01 and 13:02. They were Available at 13:06 (lic01), 13:08
(app01) and 13:09 (db01), 5 to 7 minutes each. The three security groups were created in the
default VPC by about 13:21.

**Recovery (Phase B).** The disaster was declared at 13:35:22. The three instances were launched
(lic01 at about 13:40, db01 at 13:44, app01 at about 13:50) and showed Running at 13:51. The
hosts file on the recovered app01 still held the old addresses, the same defect as D-01, and was
corrected at about 13:59:45. The application page passed at 14:00, the licence check at 14:01:02
and the row counts at 14:03:53. The `mysql` client was not on the recovered app01 and had to be
installed, which took about two minutes.

**Measured recovery time: 28 minutes 31 seconds** (13:35:22 to 14:03:53), against the plan's
60-minute estimate and the four-hour objective (charter O-5). The age of the oldest image at the
moment of declaration (RPO) was 148 minutes. Nothing was written to the database during the
exercise, so the test lost no data, and the row counts matched.

**Result for P-3 (recovery time exceeds four hours): contradicted.** Recovery took well under the
objective. The result applies to one three-server application, restored from images made by hand
and crash-consistent (no database stop), with no writes during the test. [Add a sentence on what
a larger or busier wave would change.]

**Cleanup (Phase C).** The three us-west-2 instances were terminated at 14:07, the three images and
their snapshots were deleted at 14:08, the security groups at about 14:17, and the three
us-east-1 images and snapshots at 14:12. The region check at 14:14 and 14:15 showed only the three
cutover instances in us-east-1 and nothing running in us-west-2.

**Findings from the exercise:** the stale hosts file came back with the image; the database client
was missing on the recovered application server; security groups do not copy between regions;
three console settings were wrong and caught before launch (RAID I-11 and I-12); and preparation is
manual, so the RPO grows until the next image (RAID R-09, with scheduled AWS Backup copies as the
recommendation).
