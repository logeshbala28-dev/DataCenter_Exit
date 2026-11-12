# Rollback plan, version 1 (Wave 1 pathfinder)

**Status:** Draft v1, written 2026-11-11 from reasoning, not from experience (pre-registered
prediction P-4 expects the execution to expose gaps). Drafted with AI assistance for the
author to review and adopt. **Not edited after execution.** Gaps found go into the
post-incident review and into `rollback-plan-v2.md`.

**Estimate:** E-7 = 20 minutes (Worksheet B). It assumes the source VMs were stopped
at the service level but not changed.

## What a rollback is here

The source VMs on the laptop are never deleted or modified during cutover. Cutover only
stops their services. So rolling back means: remove the AWS cutover instances, put the
servers back to the state "never cut over", and restart the source services.

**Data caveat:** anything written to the AWS copy after cutover is lost on rollback. In the
simulation nobody writes to the application. In a real migration the decision point must
come before users are allowed in, or the plan needs a way to bring changes back.

## Triggers

Roll back when any of these is true (the same rule as DP-1 in the cutover runbook):

- At T0 + 75 minutes, validation (cutover step 7) has not passed.
- RB-1 to RB-3 in `go-live-criteria.md` is true.
- The operator is unsure whether it is safe to proceed. Doubt is a reason to roll back.

## Steps

| # | Step | Plan (min) | Start | End | Check |
|---|---|---|---|---|---|
| 1 | **Decide and notify.** Write the decision and the reason, with the time, in `logs/status-log.md`. Note which trigger fired. Stop any work on the AWS side | 5 | | | Time and reason written down |
| 2 | **Remove the AWS instances.** MGN, tick all three servers, **Test and cutover, Cutover, Revert to "ready for cutover"**, tick "Yes, terminate launched instances". Lifecycle returns to "Ready for cutover". Check EC2 shows the cutover instances terminated | 5 | | | Instances terminated, lifecycle "Ready for cutover" |
| 3 | **Restart the source services, in dependency order.** lic01 first: `sudo systemctl start licsvc`. Then db01: `sudo systemctl start mysql`. Then app01: `sudo systemctl start meridianapp` (nginx should already be running). Order matters: the app calls the licence service on every request (RAID I-07) | 5 | | | `systemctl status` active on all three |
| 4 | **Confirm the source application answers correctly.** From the laptop browser `http://192.168.161.10/` returns `{"patients":200000,"status":"ok"}` | 5 | | | Same response as before cutover |

**Plan total: 20 minutes (E-7).**

## Extra check, not in the Worksheet

After step 4, in MGN confirm all three servers return to **Healthy** replication. Stopping
and restarting the source services might trigger a rescan. This is not in Worksheet B. Time
it and record it; it is probably the most likely gap.

## Known unknowns (to test, not to assume)

- Does MGN go back to "Ready for cutover" with replication still healthy, or does it
  rescan?
- Is `licsvc` the real unit name on lic01? (Not yet confirmed on the source.)
- Does the test-launch cleanup behave the same on revert (instances really terminated and
  billing stopped)?
- How long does the app take to answer after the services restart?
- Whether notification and sign-off belong in this plan at all for one operator.

## Record

Save screenshots as `evidence/week-03/rollback1-<step>-<time>cst.png`. Record the actual
duration and compare with E-7. Record every gap: P-4 is confirmed if at least one step is
missing, wrong or takes materially longer than the plan states.
