# Weekly Status Log

Produced every Monday, before any build work. Append — never edit a past entry.

---

## Week 1 — 2026-09-11

**Phase:** 0 — Pre-flight

**Progress**
- Project initiated. Repository created, first commit made.
- Capstone idea submitted to advisor for confirmation.
- Initial RAID log populated with five situation-specific risks.

**Earned value**

| Metric | Value |
|---|---|
| Planned Value (PV) | baseline not yet set |
| Earned Value (EV) | — |
| Actual Cost (AC) | $0.00 |
| CPI | — |
| SPI | — |
| EAC | — |

EVM reporting begins once the cost baseline is committed in Phase 1.

**Blockers**
- Awaiting advisor confirmation (D-01).

**Schedule buffer**

| | Weeks |
|---|---|
| Available | 2.0 |
| Consumed to date | 0.0 |
| Remaining | 2.0 |

**Next week**
- Complete Phase 0 exit criteria.
- Set cost and schedule baselines.
- Terraform practice build.

---

## Week of 2026-10-29

**Phase:** 3 — Wave 0 landing zone

**Progress**
- AWS access configured through IAM Identity Center. No long-lived access keys.
- Terraform remote state in S3, versioning enabled, public access blocked.
- Wave 0 landing zone applied: 27 resources. All free tier, no cost incurred.
- Environment destroyed and rebuilt from code with no manual steps.
  Charter objective O-2 verified.

**Decisions**
- Identity Center single-Region instance chosen over multi-Region to avoid
  customer-managed KMS key charges. No functional loss for a single-region
  pathfinder.

**Blockers**
- Pre-registration estimates E-1 to E-10 unfilled. Must be committed before
  replication begins.

**Next**
- MGN initialisation and replication template.
- Source environment build on the Windows host.

---

## Week of 2026-11-04

**Phase:** 4 — Wave 1 pathfinder, source environment

**Progress**
- First source build discarded. It ran Ubuntu 26.10, which AWS MGN does not support.
  Rebuilt on Ubuntu Server 24.04.3 LTS, kernel 6.8.0-147, held against updates.
- Three VMs built and loaded: db01 (MySQL, 200000 / 400000 / 300000 rows), lic01
  (licence service), app01 (nginx and Flask app). Fixed addresses through DHCP
  reservations.
- Dependency test repeated: app fails with the licence service stopped, recovers when
  restored.
- E-2 measured: 26,343,444,480 bytes used across the three VMs.
- Pre-registration E-1 to E-10 filled and committed (39d44b4) before any replication.
  E-4 to E-8 drafted with AI assistance and adopted by the author. E-9 and E-10 taken
  from the committed WBS.
- Snapshots `clean-os-24.04.3` and `source-ready` taken on all three VMs.

**Decisions**
- E-3 kept at the value committed on 2026-10-29 (1.5 hours). The recomputed figure from
  measured volume (1.57 hours) is recorded alongside it, not substituted.
- DHCP reservations used instead of static addresses in the guests, so the replicated
  instances get a normal network at cutover.

**Blockers**
- None.

**Next**
- Confirm the commit timestamp on GitHub and add evidence to the repository.
- Rebuild the landing zone, initialise MGN, install the agent on all three VMs.
- Start replication and record the start time.


### 2026-11-06 (Friday), entries so far

- 09:26 CST: Cost baseline (`pm-baselines/cost-baseline.md`, commit c78b236) confirmed pushed to GitHub before replication. Local and remote branches match.
- 09:42 CST: The four rates the cost baseline marked as unverified (t3.small, gp3, EBS snapshot Standard, public IPv4) were checked on the AWS pricing pages for us-east-1. All four match the committed baseline. Screenshots are in `evidence/week-02/attempt-2/cost-baseline-pricing-check-*.png`.
- 10:17 to 10:19 CST: MGN agent installer downloaded on all three VMs. About 150 to 300 KB/s per VM with three downloading at once; the agent install that followed took about 30 minutes on db01 and app01 (started about 10:23, both registered by about 10:56).
- 10:56 to 10:57 CST: Console replication start for app01 (10:56) and db01 (10:57). Both share replication server i-057254419e232394a.
- About 12:47 CST: Initial sync of db01 and app01 ended, read from CloudWatch NetworkIn (traffic stops). About 111 minutes, 25.5 GB received at an average of 30.6 Mbps. Analysis: `evidence/week-02/attempt-2/e3-initial-sync-analysis.md`. E-3 is not changed; lic01 is still to finish.
- 14:57 CST: lic01 raised from 1 GB to 2 GB RAM after the installer was killed for lack of memory (RAID I-08).
- 14:47 to 15:21 CST: Three failed installs on lic01 for credential reasons (RAID I-09). lic01 later registered and was at 12% of its initial sync at 16:11 CST, about 30 minutes left (console estimate).
- 16:09 CST: Windows event log shows no sleep, restart, shutdown or power loss on the laptop since 08:00 (PowerShell Get-WinEvent returned no events). No host outage is recorded.


### 2026-11-11 (Wednesday)

- 15:59 to 16:10 CST: Replication check before configuring launch. All three servers show Ready for testing and Healthy in MGN, with last snapshots 8, 8 and 1 minutes old. Replication kept running from 2026-11-06 to 2026-11-11 without intervention. Public IP still 73.247.253.152, matching `source_public_ip` and `admin_ip`, so the replication security group still admits the source.
- 16:22 to 17:02 CST: Launch settings set per server. MGN defaults were instance type right-sizing On (c5.large), blank subnet, blank security group, Public IP No. Changes: right-sizing Off, t3.small, subnet `pathfinder-public-us-east-1a` (`subnet-00cc79f2e48b9b0b8`), delete on termination Yes, Public IP No except app01.

| Server | Template | Default version | Security group | Public IP |
|---|---|---|---|---|
| app01 | lt-024820838947f5097 | 3 | pathfinder-app (sg-09cec7994b259cc3a) | Yes |
| db01 | lt-0679b539dcd6bfface | 4 | pathfinder-db (sg-021169865f79e1bae) | No |
| lic01 | lt-0686d7f97acedab13 | set in console | pathfinder-dependency (sg-04ddfaa3eb160b50d) | No |

- Decision: t3.small chosen over MGN's recommended c5.large (about 4 times the hourly price) to stay inside the cost baseline. Source VMs have 2 vCPU and 1.87 GiB RAM; t3.small has 2 vCPU and 2 GiB. If validation shows slow response, record it as a cost versus sizing finding.
- Note: new template versions are not used by MGN until set as the default version in the EC2 console. Version 3 for app01 and version 4 for db01 were created, then promoted. Right-sizing is a separate setting on the MGN launch settings page.
- Evidence: `evidence/week-03/launch-settings-{app01,db01,lic01}.png`, `mgn-health-before-test-1611cst.png`.

- 17:04 to 17:39 CST: First test launch, in order lic01, db01, app01 (licence service before the application, RAID I-07). All three jobs completed without errors.

| Server | Job | Start | Snapshot done | Conversion done | Instance launched | Duration |
|---|---|---|---|---|---|---|
| lic01 | mngjob-326bde564dc220c69 | 17:04 | 17:05 | 17:09 | 17:15 (i-0f20db1ee571ce899) | 11 min |
| db01 | mngjob-35832f6193e61cb82 | 17:08 | 17:09 | 17:13 | 17:19 (i-0fa7994976ab19a56) | 11 min |
| app01 | mngjob-31d3f6e17bd9b37ae | 17:29 | 17:30 | 17:34 | 17:39 (i-0bcf77ca72556f9ea) | 10 min |

- Each job used a temporary conversion server that MGN removes itself. Cost to be reconciled in the bill check.
- Validation checklist (`runbooks/validation-checklist.md`) and defect log (`logs/defect-log.md`) written at 17:30, before any instance was opened.

- 17:50 to 18:35 CST: Test instance validation (`runbooks/validation-checklist.md`, `logs/defect-log.md`). All three instances Running with 3/3 checks at 17:50. First request to app01 at 17:52 returned HTTP 500. Cause: stale old addresses in `/etc/hosts` (D-01), which made the licence check time out (D-02). Fix about 18:23 (31 min from first symptom, including a detour caused by a wrong example address I gave). After the fix the app returned `{"patients":200000,"status":"ok"}`. Database check at 18:35: row counts 200000 / 400000 / 300000 match the source, `audit_log` has no primary key (D-03). Defects found 3 against 4 estimated (E-6). Source VMs untouched and running throughout.
- 18:39 to 18:42 CST: Budget alerts created (`pathfinder-monthly-15` and `pathfinder-monthly-30`). They were planned in the cost baseline but had not been configured; found when the Billing home page showed no budget. Month-to-date spend $3.80, forecast $7.15 (before today's test instances, which have not posted yet).
- Observation: the application database password is in plain text in the application code and in the build runbook. Not a migration defect, noted for the lessons section.

**Next**
- Commit today's logs and evidence.
- Draft cutover and rollback runbooks and go-live criteria before any cutover step.
- Decide what to do with the three test instances overnight (about $0.083 an hour for the four running instances).

### 2026-11-11 (Wednesday) evening and 2026-11-16 (Monday): cutover attempt one

Attempt one used Option A (DEC-01): lic01 left out of the cutover launch. DP-1 limit 75 minutes (DEC-02).

| Step | Time (CST) | Note |
|---|---|---|
| Pre-window: Mark as Ready for cutover | 11 Nov 19:29 to 19:35 | Three terminate jobs, run separately (app01 19:29, db01 19:30, lic01 19:34) |
| 1 Pre-check, T0 | 11 Nov 19:46 | Deviation 1: last snapshots were app01 16, db01 37, lic01 12 minutes old. Lag and backlog none, all Healthy. Idle servers are not snapshotted until data changes |
| 2 Stop source services | about 20:07 (approximate, from "one or two minutes" before a 20:08 screenshot) | app01 stopped first. 502 Bad Gateway at 20:08. `licsvc.service` confirmed as the lic01 unit name |
| 3 Snapshot after stop | 20:14 | Deviation 2: only db01 had a snapshot after the stop (about 20:08). MGN took fresh snapshots of app01 and db01 when Launch was clicked (20:14 to 20:15) |
| 4 Launch cutover instances (app01, db01 only) | 11 Nov 20:14 to 20:25 | 11 minutes against 25 planned |
| Pause | 11 Nov about 20:26 to 16 Nov 09:07 | Attempt paused at the start of step 5. DP-1 limit (21:01) passed during the pause. E-4 and E-5 for attempt one are therefore not usable measurements |
| 5 EC2 status checks | observed 16 Nov 09:07 | Both instances 3/3 passed. Time of passing not captured |
| 6 Hosts file | 16 Nov 09:13 | app01 hosts had stale `192.168.161.11 meridian-db01`. Changed to `10.20.0.188`. Backup at `/etc/hosts.bak` |
| 7 Validation | 16 Nov 09:13 to 09:16 | `GET /` returned 500. Journal: `ConnectTimeout ... host='meridian-lic01', port=8080 ... /license`. curl from app01 to the licence address: exit 28 (timeout). This is the planned failure |
| DP-1 decision | 16 Nov about 09:17 | Roll back. Triggers: RB-1 (application does not return the expected response after step 6) and RB-3 (limit passed). Rollback clock starts here |

#### Rollback of attempt one, 2026-11-16 (rollback-plan.md v1, executed unchanged)

| Step | Plan (min) | Start | End | Actual | Note |
|---|---|---|---|---|---|
| 1 Decide and notify | 5 | 09:17 | 09:17 | under 1 | Decision logged. No action taken until 09:33 |
| (gap between decision and first action) | none | 09:17 | 09:33 | 16 | Not in the plan |
| 2 Remove AWS instances (revert to Ready for cutover, app01 and db01 only) | 5 | 09:33 | 09:33 | under 1 | Terminate job mgnjob-34e30289e318dd5f4 completed within the minute. Both instances Terminated |
| 3 Restart source services (lic01, db01, app01) | 5 | about 09:34 | about 09:38 | about 4 | All three active. Exact start and end times were not written down |
| 4 Source application confirmed | 5 | | 09:39 | about 1 | `{"patients":200000,"status":"ok"}` on first load |
| Extra check: MGN | n/a | | 09:39 | n/a | All three Ready for cutover and Healthy. No rescan seen. app01 took a new snapshot (2 min old); db01 25 min, lic01 37 min |

**E-7 (rollback duration):** estimate 20 min. Measured **about 22 min from decision to done**, of which about **6 min was hands-on work** (09:33 to 09:39) and **16 min was the gap** between deciding and acting.

**Answers to the plan's known unknowns:** MGN returned both servers to Ready for cutover with replication Healthy and no rescan. `licsvc.service` is the real unit name on lic01. The app answered on first load after the restart (time not measured). Whether billing stopped after the revert was not checked yet.

**Gaps found (P-4):**
1. **RB-G1, wrong step.** Step 2 says tick all three servers. In attempt one only app01 and db01 had been launched, so the instruction does not match the state. The plan assumes every server was launched.
2. **RB-G2, missing step.** Nothing says what to do between the decision and the first action, and nothing owns it. 16 minutes passed.
3. **RB-G3, missing provision.** The plan has no rule for a cutover window that is paused or abandoned. The source services stayed stopped for about 5 days (11 Nov 20:07 to 16 Nov 09:38) before the rollback, so the source application was down far beyond the planned 63 minutes.
4. **RB-G4, estimate.** Hands-on steps 2 to 4 took about 6 minutes against 15 planned. The plan overestimates the work and underestimates the decision delay.
5. **RB-G5, missing check.** The plan does not say how to confirm that billing stopped after the revert (EC2 instances terminated and no running cutover instances). Not yet verified.

**P-4: confirmed.** At least one step is wrong (RB-G1) and at least one is missing (RB-G2, RB-G3).

**RB-G5 check (09:42):** EC2 Instances (filter: running) shows only the MGN replication server (`t3.small`). Both cutover instances are gone, so the revert stopped their EC2 charges. Billing itself is checked later in the cost log.
