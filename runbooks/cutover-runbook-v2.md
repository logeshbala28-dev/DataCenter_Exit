# Cutover runbook, version 2 (Wave 1 pathfinder)

**Status:** Draft v2, written 2026-11-16 after cutover attempt one and its rollback. Drafted
with AI assistance for the author to review. `cutover-runbook.md` (v1) is unchanged. Every
change below traces to something observed in attempt one (see `logs/status-log.md`, entries
for 2026-11-11 and 2026-11-16) and is marked with its source. **Not edited after execution.**

**Estimates:** the Plan column keeps the pre-registered Worksheet A values (E-4 = 68 min,
E-5 = 63 min) so attempt two is compared with the same baseline. The Attempt 1 column shows
what attempt one actually measured, where it measured it.

## What changed from v1

| ID | Change | Why (source) |
|---|---|---|
| C2-1 | **Launch all three servers** in step 4, including lic01 | Attempt one left lic01 out on purpose and the app returned 500. The licence dependency is real |
| C2-2 | Step 6 fixes **both** `meridian-db01` and `meridian-lic01` in `/etc/hosts` on app01 | Attempt one: hosts had the stale source addresses (`192.168.161.11`, `.12`). The old addresses are copied with the disk |
| C2-3 | Snapshot precondition rewritten (see Preconditions) | Attempt one: idle servers showed snapshots 16 to 37 minutes old and the "under 15 minutes" rule could not be met by waiting |
| C2-4 | Mark Ready for cutover done **once, for all three servers together**, before the window | Attempt one: three separate runs, 6 minutes in total |
| C2-5 | Every command line starts with `date`, so the terminal records the time | Attempt one: the stop time was only approximate (about 20:07) |
| C2-6 | **No-pause rule** and **act-within-5-minutes rule** (see Decision point) | Attempt one: paused 5 days at step 5, and 16 minutes passed between the decision and the first rollback action |

## Preconditions (check before the window opens)

- [ ] Source laptop awake, plugged in, Windows updates paused
- [ ] Public IP unchanged and equal to `source_public_ip`
- [ ] MGN shows all three servers **Healthy**, lag none and backlog none (open each server)
- [ ] Source servers show **Ready for cutover**, and a terminate job for each server shows Completed
- [ ] `rollback-plan-v2.md` and `go-live-criteria.md` open and read
- [ ] Source application answers `http://192.168.161.10/` with 200000 patients (baseline)
- [ ] Every earlier defect fixed or logged: `logs/defect-log.md` (D-01 to D-03)
- [ ] The whole window (about 90 minutes) is free, with no break planned

Snapshot age is **not** a precondition (C2-3). A server with no data changes is not
snapshotted, so a "last snapshot" of 30 minutes or more is normal when idle. What matters is
step 3: a snapshot (or the snapshot MGN takes at Launch) after the stop.

## Window steps

| # | Step | Plan (min) | Attempt 1 | Start | End | Check before moving on |
|---|---|---|---|---|---|---|
| 1 | **Pre-check.** Confirm the preconditions. Note this time as T0. The downtime clock has not started | 5 | about 5 | | | All preconditions ticked |
| 2 | **Stop the source application and writes.** In each session run `date; sudo systemctl stop <unit>`: app01 `meridianapp`, db01 `mysql`, lic01 `licsvc` (unit name confirmed: `licsvc.service`). app01 first. **The downtime clock (E-5) starts when the app stops.** The time shown by `date` is the record | 3 | about 3 | | | `http://192.168.161.10/` no longer answers (502 is expected, nginx stays up) |
| 3 | **Confirm lag zero and a snapshot after the stop.** MGN, each server: lag none, backlog none. A new snapshot appears at Launch (job log "Started/Finished taking snapshot") | 5 | about 6 | | | All three servers lag-free |
| 4 | **Launch the cutover instances for all three servers** (C2-1). Tick all three, **Test and cutover, Cutover, Launch cutover instances**. Wait for the job to show Completed and all three servers "Launched" | 25 | 11 (two servers) | | | One job, three servers Launched, no failed event |
| 5 | **EC2 status checks pass.** Three instances Running, 3/3 checks | 5 | not measured | | | 3/3 on every instance |
| 6 | **Fix network settings.** Read the **new private addresses** of db01 and lic01 from EC2. On app01 (public IP, new session): `date; sudo cp /etc/hosts /etc/hosts.bak`. Then `sudo sed -i 's/^192\.168\.161\.11 meridian-db01/<db01 new IP> meridian-db01/' /etc/hosts` and the same for `192.168.161.12 meridian-lic01` (type real numbers). `cat /etc/hosts`. First confirm the machine with `hostname -I`: it must show `10.20.0.x` | 15 | about 5 (db01 only) | | | `cat /etc/hosts` shows both new addresses |
| 7 | **Validation.** (a) `http://<app01 public IP>/` returns `{"patients":200000,"status":"ok"}`. (b) From app01: `curl -s http://<lic01 new IP>:8080/license` returns `valid:true`. (c) `mysql` row counts 200000 / 400000 / 300000. (d) Note that `audit_log` has no primary key (known, D-03). **The downtime clock stops when (a) first passes** | 10 | failed as planned | | | All of GL-1 to GL-6 in `go-live-criteria.md` |
| 8 | **Decision point DP-1.** Go or roll back | | | | | Written decision with the time |
| 9 | **If go: Finalize cutover.** Tick all three, **Test and cutover, Cutover, Finalize cutover**. Only after DP-1 says go | | | | | Lifecycle "Cutover complete" |

**Plan total: 68 minutes (E-4). Downtime: 63 minutes (E-5).**

## Decision point DP-1

- **Roll back** if, at **T0 + 75 minutes**, validation has not passed.
- **Roll back immediately** if any of RB-1 to RB-3 in `go-live-criteria.md` is true.
- **Go** only if every go-live criterion GL-1 to GL-6 is met.
- **No-pause rule (C2-6).** The window runs without a break. If it is interrupted for more
  than 15 minutes, DP-1 is treated as expired and the rollback starts.
- **Act-within-5-minutes rule (C2-6).** When DP-1 says roll back, the first rollback action
  (rollback step 2) starts within 5 minutes of the decision. Write the decision time and the
  action time next to each other.

## Record

Fill Start and End as the window runs. Save screenshots as
`evidence/week-04/cutover2-<step>-<time>cst.png`. Check each screenshot for the home IP and
for unrelated browser tabs before it is committed. Anything that surprises goes into
`logs/defect-log.md` straight away.
