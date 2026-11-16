# Disaster recovery plan, version 1 (Wave 1 pathfinder)

**Status:** Draft v1, written 2026-11-16 before any DR step is run. Drafted with AI
assistance for the author to review and adopt. **Not edited after execution.** Problems found
while running it go into the DR report and into `dr-plan-v2.md`.

**Work packages:** WBS 5.1.1 (strategy), 5.2.1 (timing and recovery definition), 5.2.2
(recovery environment), 5.3.1 (exercise), 5.5.1 (destroy). **Charter:** O-5. **Prediction:**
P-3 (recovery time exceeds the four-hour objective).

## Decisions (recorded in `logs/decision-log.md` as DEC-03 to DEC-05)

| ID | Decision |
|---|---|
| DEC-03 | Recovery region: **us-west-2** (Oregon). Production stays in us-east-1 |
| DEC-04 | Scope: **all three servers** (app01, db01, lic01). The app calls the licence service on every request, so a recovery without lic01 would reproduce the attempt-one failure |
| DEC-05 | Clock definition: see "Recovery definition" below |

## Strategy

Backup and restore (the cheapest DR pattern, hours rather than minutes). Before the disaster,
machine images of the three cutover instances exist in us-west-2. After the disaster is
declared, three instances are launched from those images in us-west-2, the network settings
are fixed, and the application is validated.

Not tested: pilot light, warm standby and multi-site. They are described in Chapter 5 as
options with their expected cost and recovery time.

## Recovery definition (fixed before the exercise)

- **RTO objective:** 4 hours (charter O-5).
- **Disaster declared (clock start):** the moment the author writes "DISASTER DECLARED" with
  the time in `logs/status-log.md`. From then, the three us-east-1 instances are treated as
  lost. They keep running only so the evidence can be compared. No step uses them.
- **Recovered (clock stop):** the first time `http://<us-west-2 app01 public IP>/` returns
  `{"patients":200000,"status":"ok"}` **and** the licence check returns `valid:true` **and**
  the row counts are 200000 / 400000 / 300000.
- **RTO (primary, judged for P-3): Phase B** from "disaster declared" to "recovered".
- **Reported alongside, not used to judge P-3:** Phase A (preparation) and Phase A + B.
- **RPO:** the age of the images at the moment of the declaration, recorded in minutes. The
  application takes no writes during the exercise, so data loss is expected to be zero.

Phase A is a standing DR posture (it would be repeated on a schedule in a real programme).
This project did not automate it. That is stated as a limitation and as a recommendation
(scheduled cross-region copy with AWS Backup).

## Phase A: preparation (not in the RTO, but timed and costed)

| # | Step | Start | End | Check |
|---|---|---|---|---|
| A1 | us-east-1, EC2, each of the three instances: Actions, Image and templates, **Create image**, tick **No reboot**. Names `dr-app01-v1`, `dr-db01-v1`, `dr-lic01-v1` | | | Three images "Available" |
| A2 | EC2, AMIs: select each image, Actions, **Copy AMI**, destination **us-west-2**, same name | | | Three images "Available" in us-west-2 |
| A3 | us-west-2: use the default VPC. Create three security groups `dr-app`, `dr-db`, `dr-dependency` matching the us-east-1 rules (80 and 22 from the author's address, 3306 from `dr-app`, 8080 from `dr-app`). Do not write the author's address in any file in the repository | | | Groups exist |
| A4 | Write the time and the image creation time of each image (this gives the RPO) | | | RPO noted |

Images made with No reboot are crash-consistent. MySQL recovers from a crash. This is a
stated limitation. A coordinated backup would stop `mysql` first.

## Phase B: recovery (the timed part). Estimate: **60 minutes** (a DR-plan estimate, not part of
E-1 to E-10)

| # | Step | Plan (min) | Start | End | Check |
|---|---|---|---|---|---|
| B0 | **DISASTER DECLARED.** Write the time. This is the clock start | 0 | | | Time written |
| B1 | us-west-2, EC2, AMIs: **Launch instance from AMI** for lic01, then db01, then app01. Type `t3.small`, default VPC, groups `dr-dependency`, `dr-db`, `dr-app`. **Public IP only on app01** | 15 | | | Three Running, 3/3 checks |
| B2 | Read the three new private addresses. On app01 (SSH to its public IP): `date; sudo cp /etc/hosts /etc/hosts.bak`, then `sed` both `meridian-db01` and `meridian-lic01` lines to the new addresses (the stale addresses are copied with the image: the same defect as D-01 and attempt two). `hostname -I` first, to confirm the machine | 15 | | | `cat /etc/hosts` shows both |
| B3 | Validation: application page, licence check from app01, row counts (same commands as attempt two) | 15 | | | The three recovery conditions all true |
| B4 | **RECOVERED.** Write the time. This is the clock stop | 0 | | | Time written |

## Phase C: destroy (WBS 5.5.1)

| # | Step | Check |
|---|---|---|
| C1 | Terminate the three us-west-2 instances. Deregister the three us-west-2 images and delete their snapshots. Delete the three security groups | EC2 in us-west-2 lists nothing |
| C2 | In us-east-1, delete the three `dr-*-v1` images and their snapshots. (The cutover instances are removed at the main teardown) | Nothing named `dr-` remains |
| C3 | Run the region check from the build checklist (`describe-instances` in us-east-1 and us-west-2) | No unexpected instances |

## Cost

Estimate about $1.00 (E-8 allows $2.00 for outbound data and the DR test): image snapshots
in two regions, cross-region copy of about 26 GB, three `t3.small` for the exercise. Check the
bill after teardown. Snapshot price per GB-month is not yet confirmed on the AWS EBS pricing
page.

## Known unknowns (to test, not to assume)

- How long the cross-region AMI copy takes for about 26 GB (Phase A).
- Whether an image made with No reboot starts cleanly in us-west-2.
- Whether the three launch steps in B1 can run side by side without a quota problem.
- Whether the application answers on first load after the hosts-file fix.

## Record

Screenshots go in `evidence/week-04/dr1-<step>-<time>cst.png`. Use `date` in each command.
Check each screenshot for the AWS account number, the author's address and unrelated tabs
before it is committed.
