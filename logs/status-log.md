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

### 2026-11-16 (Monday): cutover attempt two (cutover-runbook-v2.md, committed bd474dc at 09:43 before the window)

| Step | Plan (min) | Time (CST) | Actual | Note |
|---|---|---|---|---|
| 1 Pre-check, T0 | 5 | between 09:43 and 09:48 | not recorded | T0 was not written down. Treated as approximate |
| 2 Stop source services | 3 | **09:48:17 to 09:48:18** (VM `date` 15:48:17/18 UTC) | under 1 | **Downtime clock starts 09:48:18.** db01 and lic01 stopped one second before app01. Source page: 502 |
| 3 Lag and backlog check | 5 | 09:49 | about 1 | Launch job took its own snapshots |
| 4 Launch cutover instances, all three servers | 25 | 09:49 to 10:01 (job mgnjob-33aef7f72a99c5cec ended 10:02) | 12 | app01, db01 and lic01 all Launched |
| 5 EC2 status checks | 5 | 10:06 | about 4 | Three instances 3/3 passed. app01 public IP 44.201.47.135; private IPs db01 10.20.0.145, lic01 10.20.0.105, app01 10.20.0.88 |
| 6 Hosts file | 15 | 10:06 to 10:10 | about 4 | Both lines fixed (db01 and lic01). `date` 16:10:04 UTC |
| 7a Application | | first load about 10:12 (recollection), screenshot with clock 10:18 | | `{"patients":200000,"status":"ok"}`. **Downtime clock stops at 10:18 at the latest** |
| 7b Licence | | 10:11:39 | | `{"org":"Meridian Regional Health Partners","seats":1800,"valid":true}` |
| 7c Row counts | | 10:28:35 | | patients 200000, appointments 400000, audit_log 300000 (from app01 over port 3306, `date` 16:28:35 UTC) |

**E-5 (downtime):** estimate 63 min. Measured **about 30 min** (09:48:18 to 10:18). Possibly about 24 min if the first pass was at 10:12 as recollected. The evidenced value is 10:18.
**E-4 (window):** estimate 68 min. T0 not recorded (between 09:43 and 09:48), so about 31 to 35 min up to 10:18, about 41 to 45 min including the row-count check at 10:28.

**Observations:** (1) SSH from app01 to db01 (port 22) timed out; port 3306 worked. Row counts were read through the database port. (2) The first PuTTY session to app01 timed out while idle and had to be reopened. (3) The screenshot with the clock for 7a was taken a second time, because the first pass was not captured with the clock.

**DP-1 decision: GO at about 10:30.** GL-1 to GL-6 all met. Next: Finalize cutover (step 9).

| 9 Finalize cutover (all three servers) | n/a | 10:35 (as reported; screenshot of "Cutover complete" to follow) | | DP-1 go at about 10:30. Replication servers scheduled for deletion within about 90 minutes. Cutover instances kept for the DR exercise |

**Observation, SSH to db01:** from app01, port 22 to db01 timed out and port 3306 connected. `ufw` on the source db01 is inactive. The likely cause is the `pathfinder-db` security group allowing only the database port. To be confirmed in the security group's inbound rules. Decide later whether to keep it (least privilege) or add a controlled access path for the wave plan.

## DR exercise, 2026-11-16

**Phase A (preparation, not in the RTO):** images created in us-east-1 at 11:07 (app01), 11:11 (db01), 11:12 (lic01). Cross-region copies to us-west-2 available at 13:08 (app01), 13:09 (db01), 13:06 (lic01) after two failed attempts (encryption not ticked; KMS key box held a us-east-1 key). Security groups dr-app, dr-db, dr-dependency created in us-west-2 by about 13:21. The dr-dependency outbound rule was first saved with the wrong destination and corrected at about 13:31 before the declaration.

**DISASTER DECLARED at 13:35:22 CST (clock start, B0).** The three us-east-1 instances are treated as lost.

### Phase B, timed recovery (16 Nov, CST; times from screenshots and `date` output)

| Step | Time | Result |
|---|---|---|
| B0 DISASTER DECLARED | 13:35:22 | Written to this log. RPO at declaration: app01 image 148 min old, db01 144, lic01 143 |
| B1 launch lic01 | about 13:40 | First attempt had Auto-assign public IP on Enable; cancelled and relaunched with Disable |
| B1 launch db01 | about 13:44 | Settings correct (dr-db, no public IP) |
| B1 launch app01 | about 13:50 | Form first showed public IP Disable; changed to Enable before launch |
| B1 end: three Running | 13:51 | lic01 and db01 3/3 checks; app01 Initializing. app01 public address recorded in the cloud console, not in this repository |
| B2 hosts file fixed | about 13:59:45 | Stale 10.20.0.145 (db01) and 10.20.0.105 (lic01) lines replaced by the new us-west-2 private addresses (D-01 repeats from the image). Backup in `/etc/hosts.bak` |
| B3a application page | 14:00 | `{"patients":200000,"status":"ok"}` |
| B3b licence check | 14:01:02 | `valid:true`, `exit=0` |
| B3c row counts | 14:03:53 | 200000 / 400000 / 300000. `mysql` client was not present on the recovered app01 (not found at 14:01:24); installed with apt, about 2 min |
| **B4 RECOVERED** | **14:03:53** | All three recovery conditions true |

**Phase B result:** 13:35:22 to 14:03:53 = **28 min 31 s** against the 60 min DR estimate and the 4 h objective (O-5). P-3 (recovery exceeds the 4 h objective) is **not supported**: the recovery took 28.5 min under controlled conditions. Limits: no writes during the exercise (RPO 148 min is the age of the oldest image), crash-consistent images, three servers and one application only.

**Findings:** (1) Cross-region copy failed twice at Phase A (encryption not ticked; KMS key field held a us-east-1 key); the cause was found from the AMI State reason. (2) Security groups do not copy across regions and the dr-dependency outbound rule was first saved with the wrong destination. (3) Public IP setting was wrong on two of three launches in B1 (caught before launch each time). (4) The stale hosts file (D-01) came back in the recovered image. (5) The database client was not on the recovered app01. (6) Phase A took longer than planned because of finding 1 and 2; it is not in the RTO.

### Phase C, destroy (16 Nov, CST)

| Step | Time | Result |
|---|---|---|
| C1 terminate the three us-west-2 instances | 14:07 | dr-app01, dr-lic01, dr-db01 show Terminated |
| C1 deregister the three us-west-2 AMIs, with "delete associated snapshots" ticked | 14:08 | Three AMIs deregistered; Snapshots, Owned by me, was empty at 14:09 (region Oregon, refreshed) |
| C1 delete the three security groups | about 14:17 | dr-db and dr-dependency deleted first; dr-app was refused until the two groups that referenced it were gone, then deleted. Only `default` remains |
| C2 deregister the three us-east-1 `dr-*-v1` AMIs, snapshots deleted | 14:12 | One snapshot remains in us-east-1: an "AWS Application Migration Service" snapshot of 1 GiB from 6 Nov. It is not part of the DR exercise; it goes on the main teardown list |
| C3 region check | 14:14 to 14:15 | us-east-1: only the three cutover instances (meridian-app01, meridian-db01, meridian-lic01), all Running 3/3. us-west-2: three Terminated, nothing running |

The default VPC and default security group in us-west-2 were left in place (free, created by AWS, not part of the exercise).

**DR evidence:** 31 redacted screenshots in `evidence/week-04/` named `dr1-<step>-<time>cst.png`. The account number, name, home address and public addresses were blanked before they were saved here.

**Confirmed, 16 Nov about 18:17 CST (SSH observation from attempt two):** the `pathfinder-db` security group in us-east-1 has **one** inbound rule, MySQL/Aurora TCP 3306 from another security group (`sg-09cec7994b259cc3a`; the screenshot does not show its name). There is no rule for port 22, which explains why SSH from app01 to db01 timed out while port 3306 connected. This matches the group's description, "Reachable only from the application tier". Proposed for the wave plan (author to confirm): keep it (least privilege) and plan a controlled access path (for example, Systems Manager Session Manager) for administration of later waves. The screenshot has no on-screen clock; the time is from the message that sent it. Evidence: `evidence/week-04/cutover2-db01-sg-inbound-1817cst.png`.

### 2026-11-16 (Monday) evening: teardown, step 1

- **18:25 CST (clock in screenshot): the three us-east-1 cutover instances were terminated** (meridian-db01, meridian-lic01, meridian-app01; "Successfully initiated termination", all three Terminated). They ran from the launches of attempt two (about 10:00) to 18:25 and carried the DR comparison. Evidence: `evidence/week-04/teardown-useast1-instances-terminated-1825cst.png`.
- Not yet done: MGN cleanup for the three source servers, the Terraform landing zone (Wave 0, kept until the end of the project), the region check after teardown, and the final bill check against E-8 (charges post about a day later).

- **Attempt two, launch job record (screenshot taken 18:41 CST, 16 Nov):** job `mgnjob-33aef7f72a99c5cec`, type Launch, status Completed, **started 09:49, completed 10:01** (console times, UTC-6). Snapshots for all three source servers started at 09:49 and finished at 09:50. All three source servers show Launched. The step 4 row above says "ended 10:02"; the console shows 10:01, so the job took 12 minutes. Evidence: `evidence/week-04/cutover2-launch-job-mgnjob-33aef7f7-1841cst.png`.

- **MGN launch history (screenshot 18:43 CST, 16 Nov): 9 jobs, all Completed.** This agrees with the timeline above. Three Launch test jobs (one server each, 11 Nov), three Terminate jobs (one server each, the pre-window "Mark as Ready for cutover" on 11 Nov), one Launch cutover job for 2 servers (attempt one, 11 Nov, `mgnjob-31810b27f7d196aa1`), one Terminate job for 2 servers (the rollback, 16 Nov, `mgnjob-34e30289e318dd5f4`), and one Launch cutover job for 3 servers (attempt two, 16 Nov, `mgnjob-33aef7f72a99c5cec`). Evidence: `evidence/week-04/cutover-mgn-launch-history-1843cst.png`.

- **MGN source servers after teardown (screenshot 18:45 CST, 16 Nov):** the **Active source servers** list was empty ("currently replicating 0 servers out of a quota of 150"). The three servers (meridian-app01, meridian-db01, meridian-lic01) are listed under **Archived source servers (3)**: alerts Launched, migration lifecycle **Cutover complete**, data replication **Disconnected**, EC2 status checks Passed (3/3). The dashboard shows 100 percent of the three servers as Cutover complete and Disconnected. Replication is stopped, so MGN has no running replication resources. [Author to confirm whether the servers were archived by MGN after Finalize or by an earlier click; this entry does not say which.] Evidence: `evidence/week-04/teardown-mgn-source-servers-cutover-complete-1845cst.png`.

- **Region check after teardown, 16 Nov about 18:59 CST (times from the messages; the screenshots show no clock and the region selector is cropped out):** EC2 Instances: only the three Terminated cutover instances. Volumes: none ("no volumes in this region"). Elastic IPs: none. NAT gateways: none found (two screenshots; the region of each is not visible, to be confirmed by the author). VPCs: two, `pathfinder-vpc` (10.20.0.0/16, the Terraform landing zone, Wave 0) and the default VPC (172.31.0.0/16), both Available. No resource that bills by the hour was found. The landing zone stays until the final teardown (WBS 8.3.1). Evidence: `evidence/week-04/teardown-check-*.png`.

- **Security cleanup, 16 Nov about 19:50 CST:** the shell history on the three source VMs (app01, db01, lic01) was wiped, as reported by the author (no screenshot). The AWS CLI session for the Terraform profile had expired ("session has expired"), and a fresh login worked at about 19:50. This closes the cleanup that was pending since 6 November (RAID I-09). No credential values are written in the repository.
