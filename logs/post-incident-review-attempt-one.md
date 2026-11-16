# Post-incident review: cutover attempt one (Wave 1 pathfinder)

**Status:** Draft, written 2026-11-16 after attempt two and the DR exercise. Drafted with AI
assistance for the author to review and correct. Facts come from `logs/status-log.md`,
`logs/decision-log.md` and `runbooks/rollback-plan.md` (v1). Blameless format: it asks what the
process allowed, not who erred.

## Summary

Attempt one was **planned to fail** (DEC-01, 11 Nov 19:40): lic01 was left out of the cutover
launch so the licence dependency would show up and the rollback plan could be tested. The
application returned HTTP 500, as predicted. The rollback ran on 16 Nov and worked, but it
exposed five gaps in the plan (RB-G1 to RB-G5). Attempt one's window figures (E-4, E-5) are not
usable, because the window was paused for about five days.

## Timeline (CST)

| When | What |
|---|---|
| 11 Nov 19:40 | DEC-01 and DEC-02 recorded: fail by Option A, DP-1 limit 75 minutes |
| 11 Nov 19:46 | Step 1 pre-check, T0. Snapshots 16, 37 and 12 minutes old |
| 11 Nov about 20:07 | Source services stopped, app returns 502 at 20:08 |
| 11 Nov 20:14 to 20:25 | Launch of app01 and db01 only: 11 minutes against 25 planned |
| 11 Nov about 20:26 | Attempt paused at the start of step 5 |
| 11 Nov 21:01 | DP-1 limit passed during the pause |
| 16 Nov 09:07 | Step 5 observed: both instances 3/3 |
| 16 Nov 09:13 to 09:16 | Hosts file fixed for db01; `GET /` returns 500; licence check times out (exit 28) |
| 16 Nov about 09:17 | Decision to roll back (RB-1 and RB-3) |
| 16 Nov 09:33 | First rollback action (16 minutes after the decision) |
| 16 Nov 09:39 | Source application back: 200000 patients. MGN shows all three Ready for cutover, Healthy |

## What the plan allowed (contributing factors)

1. **The plan assumed an uninterrupted window.** Nothing in the v1 plan says what to do when the
   window is paused or abandoned. The source application stayed down for about five days
   (about 20:07 on 11 Nov to 09:38 on 16 Nov) against a planned 63 minutes. The reason for the
   pause is not in the log; the author should add it here.
2. **The decision had no owner and no deadline.** Between "roll back" at about 09:17 and the
   first action at 09:33, 16 minutes passed with no step to cover them.
3. **The rollback text did not match the state it was run in.** Step 2 says tick all three
   servers; only app01 and db01 had been launched.
4. **Snapshot age was used as a precondition, but idle servers are not snapshotted until
   data changes.** The "under 15 minutes" rule could not be met by waiting.
5. **Commands were not timed as they were run**, so the stop time is only approximate and the
   step 3, 5 and 7 times are partly missing.

## What went well

- The failure was predicted, recorded in the decision log before the window, and reproduced.
- The journal line `ConnectTimeout ... host='meridian-lic01', port=8080` and the curl timeout
  (exit 28) located the cause quickly.
- Reverting to Ready for cutover returned both servers to replication with no rescan, and the
  source application answered on first load.
- Hands-on rollback work took about 6 minutes against 15 planned.

## Actions (all carried into the v2 documents)

| ID | Action | Where |
|---|---|---|
| C2-1 | Launch all three servers | `runbooks/cutover-runbook-v2.md` |
| C2-2 | Fix both `meridian-db01` and `meridian-lic01` hosts lines | cutover-runbook-v2.md |
| C2-3 | Snapshot age is no longer a precondition; a snapshot after the stop is required | cutover-runbook-v2.md |
| C2-4 | Mark Ready for cutover once, for all three servers, before the window | cutover-runbook-v2.md |
| C2-5 | Every command starts with `date` | cutover-runbook-v2.md |
| C2-6 | No-pause rule and act-within-5-minutes rule | cutover-runbook-v2.md, `rollback-plan-v2.md` |
| RB-G1 to RB-G5 | Rollback plan corrections (state-dependent step 2, decision-to-action step, paused-window rule, estimate, billing check) | `runbooks/rollback-plan-v2.md` |

## Result against the prediction

**P-4 (the rollback plan has at least one wrong or missing step): confirmed.** RB-G1 is a wrong
step, RB-G2 and RB-G3 are missing ones. Attempt two (same day, v2 runbooks) ran to Cutover
complete at 10:36 with the application, licence check and row counts all passing.

## Open items

- RB-G5: the EC2 check at 09:42 showed both cutover instances gone, so EC2 charges stopped.
  Billing itself is reconciled in the final bill check (`logs/cost-log.md`).
- E-4 and E-5 for attempt one are reported as "not measured" in the report, not as a number.
