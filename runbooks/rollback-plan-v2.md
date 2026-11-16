# Rollback plan, version 2 (Wave 1 pathfinder)

**Status:** Draft v2, written 2026-11-16 from the rollback of attempt one. Drafted with AI
assistance for the author to review. `rollback-plan.md` (v1) is unchanged. **Not edited after
execution.**

**Estimate:** E-7 = 20 minutes, kept from v1 so the comparison stays honest. Attempt one
measured about 22 minutes from decision to done, about 6 of them hands-on.

## What changed from v1

| ID | Gap in v1 | Change in v2 |
|---|---|---|
| RB-G1 | Step 2 said tick all three servers | Tick **only the servers that were launched**. Check the lifecycle column first |
| RB-G2 | No owner or time limit between the decision and the first action | Add step 1b: the first action starts **within 5 minutes** of the decision. Write both times |
| RB-G3 | No rule for a paused or abandoned window | A window paused for more than 15 minutes is rolled back, and the source services are restarted at once, not left stopped |
| RB-G4 | Steps 2 to 4 planned at 15 minutes, took about 6 | Keep the plan numbers (so the comparison with E-7 is clean) and report the measured values next to them |
| RB-G5 | No billing check | Add step 5: EC2 shows no running cutover instances |

## Steps

| # | Step | Plan (min) | Attempt 1 | Start | End | Check |
|---|---|---|---|---|---|---|
| 1 | **Decide and notify.** Write the decision, the trigger that fired and the time in `logs/status-log.md` | 5 | under 1 | | | Time and reason written |
| 1b | **First action within 5 minutes of step 1** (RB-G2). Write the time next to the decision | 0 | 16 | | | Gap under 5 minutes |
| 2 | **Remove the AWS instances.** MGN: tick **only the servers that were launched** (RB-G1). **Test and cutover, Cutover, Revert to "ready for cutover"**, tick "Yes, terminate launched instances" | 5 | under 1 | | | Terminate job Completed, lifecycle "Ready for cutover" |
| 3 | **Restart the source services in dependency order.** `date; sudo systemctl start licsvc` on lic01, then `mysql` on db01, then `meridianapp` on app01. `systemctl is-active` shows active on each | 5 | about 4 | | | All three active |
| 4 | **Confirm the source application.** `http://192.168.161.10/` returns `{"patients":200000,"status":"ok"}` | 5 | about 1 | | | Same as the baseline |
| 5 | **Check billing and replication.** EC2 (filter: running) shows no cutover instances (RB-G5). MGN shows all three servers Ready for cutover and Healthy, no rescan | 0 | about 2 | | | Only the replication server remains |

**Plan total: 20 minutes (E-7).**

## Triggers

Roll back when any of these is true:
- At T0 + 75 minutes, validation has not passed.
- RB-1 to RB-3 in `go-live-criteria.md` is true.
- The operator is unsure it is safe to proceed.
- The window has been paused for more than 15 minutes (RB-G3).

## Record

Save screenshots as `evidence/week-04/rollback2-<step>-<time>cst.png`. Use `date` in each
command for exact times. Record every gap again: P-4 was confirmed in attempt one, and a
second rollback shows whether the v2 changes closed the gaps.
