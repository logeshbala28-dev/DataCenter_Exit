# Cutover runbook, version 1 (Wave 1 pathfinder)

**Status:** Draft v1, written 2026-11-11 before any cutover step has been run. Drafted with
AI assistance for the author to review and adopt. **Not edited after execution.** Problems
found while running it go into the post-incident review and into a new file,
`cutover-runbook-v2.md` (WBS 4.7.1), so the comparison between plan and reality stays honest.

**Scope:** cutover of `meridian-app01`, `meridian-db01` and `meridian-lic01` from VMware
Workstation to AWS (us-east-1) using AWS MGN.

**Estimates:** the step durations in the "Plan" column are the pre-registered Worksheet A
values (`pm-baselines/pre-registration.md`). E-4 = 68 min (whole window), E-5 = 63 min
(downtime: from source app stop to validation pass).

## Roles

One operator, the author. The runbook still names who does each step, so a larger team could
follow it unchanged. All times are recorded in CST, to the minute, on a clock you can see.

## Preconditions (check before the window opens)

- [ ] Source laptop awake, plugged in, Windows updates paused
- [ ] Public IP unchanged and equal to `source_public_ip` (replication would stall otherwise)
- [ ] MGN shows all three servers Healthy, last snapshot under 15 minutes old
- [ ] `rollback-plan.md` and `go-live-criteria.md` open and read
- [ ] Source application answers `http://192.168.161.10/` with 200000 patients (baseline)
- [ ] Every earlier defect fixed or logged: see `logs/defect-log.md` (D-01 to D-03)

## Pre-window step (not in Worksheet A)

Mark the servers "Ready for cutover" and terminate the test instances: MGN, tick all three
servers, **Test and cutover, Testing, Mark as "Ready for cutover"**, tick "Yes, terminate
launched instances". Record the time and duration. This step is outside the downtime but
inside the real effort. Worksheet A did not include it; report it as an addition to E-4's
scope, not as an overrun of a step that existed.

## Window steps

| # | Step | Plan (min) | Start | End | Check before moving on |
|---|---|---|---|---|---|
| 1 | **Pre-check and freeze announcement.** Confirm the preconditions above still hold. Note this time as T0. The downtime clock has not started | 5 | | | All preconditions ticked |
| 2 | **Stop the source application and writes.** On app01: `sudo systemctl stop meridianapp`. On db01: `sudo systemctl stop mysql`. On lic01: `sudo systemctl stop licsvc` (confirm the unit name first with `systemctl list-units --type=service \| grep -i lic`). **The downtime clock (E-5) starts when the application stops** | 3 | | | Source page no longer answers |
| 3 | **Confirm replication lag is zero.** MGN, Source servers: Data replication status Healthy, lag none, last snapshot taken after the stop in step 2 | 5 | | | All three servers lag-free |
| 4 | **Launch the cutover instances.** Tick all three servers, **Test and cutover, Cutover, Launch cutover instances**. Wait for all three jobs to show "Launched". Lifecycle shows "Cutover in progress". Test launch took 10 to 11 minutes per server | 25 | | | Three jobs ended, no "failed" event |
| 5 | **EC2 status checks pass.** EC2, Instances: three cutover instances Running, 3/3 checks passed | 5 | | | 3/3 on every instance |
| 6 | **Fix network settings.** Cutover instances get **new** private addresses (not the ones the test instances had). Read them from the console. On app01 run `sudo cp /etc/hosts /etc/hosts.bak`, then edit `/etc/hosts` so `meridian-db01` and `meridian-lic01` point to the **new** addresses (type the numbers, not placeholders). Confirm security groups are `pathfinder-app`, `pathfinder-db`, `pathfinder-dependency` | 15 | | | `cat /etc/hosts` shows the new addresses |
| 7 | **Validation.** (a) `http://<app01 public IP>/` returns `{"patients":200000,"status":"ok"}`. (b) From app01 `curl -s http://<lic01 private IP>:8080/license` returns `valid:true`. (c) `mysql` row counts 200000 / 400000 / 300000. (d) Record that `audit_log` has no primary key (known, D-03). **The downtime clock stops when (a) first passes** | 10 | | | Go-live criteria all met, see `go-live-criteria.md` |
| 8 | **Decision point DP-1.** Go, or roll back. See below | | | | Written decision with the time |
| 9 | **If go: Finalize cutover.** Tick all three servers, **Test and cutover, Cutover, Finalize cutover**. This stops data replication and schedules the replication resources for deletion within about 90 minutes. Do **not** do this before DP-1 says go | | | | Lifecycle "Cutover complete" |

**Plan total: 68 minutes (E-4). Downtime: 63 minutes (E-5).**

## Decision point DP-1

A cutover that feels nearly finished is the one that overruns. The rule is set now, in
advance, so nobody has to decide it under pressure.

- **Roll back** if, at **T0 + 75 minutes** (E-4 plus about 10 percent), the validation in
  step 7 has not passed.
- **Roll back immediately** if any of RB-1 to RB-3 in `go-live-criteria.md` is true.
- **Go** only if every go-live criterion GL-1 to GL-6 is met.

The 75-minute limit is a proposal. Confirm or change it, and commit the change, before
attempt one runs.

## Attempt one: how it fails (decision for the author, record before running)

Attempt one is meant to fail so that the rollback can be tested (WBS 4.6.1). The failure
should be realistic and chosen in advance. Pick one, write the choice here and in
`logs/decision-log.md`, and commit it before the window opens.

- **Option A, omit the licence server.** Launch only app01 and db01 in step 4, as the
  discovery inventory (which does not list lic01) would have it. The app returns 500 at
  validation, DP-1 triggers, rollback runs. This reproduces the seeded dependency in the
  way it would really have hit a team. **Recommended.**
- **Option B, skip the hosts-file fix in step 6.** The app fails at validation for the
  reason D-01 already showed. Simple, but we already know this failure.
- **Option C, time-box failure.** Hold step 4 until the 75-minute limit passes. Tests the
  decision rule and not the technology.

Whichever is chosen, E-4 to E-7 are **not** adjusted for it (the pre-registration says
estimates assume a cutover that goes to plan).

## Record

Fill the Start and End columns as the window runs. Save screenshots as
`evidence/week-03/cutover1-<step>-<time>cst.png`. Anything that surprises goes into
`logs/defect-log.md` straight away.
