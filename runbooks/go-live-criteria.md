# Go-live criteria and sign-off, version 1 (Wave 1 pathfinder)

**Status:** Draft v1, written 2026-11-11 before any cutover step. For the author to review
and adopt. A cutover goes live only if every GL criterion is met.

## Go criteria (all must be true)

| ID | Criterion | How to check |
|---|---|---|
| GL-1 | All three cutover instances Running, 3/3 status checks | EC2 console |
| GL-2 | Application returns `{"patients":200000,"status":"ok"}` | Browser on `http://<app01 public IP>/` |
| GL-3 | Licence service reachable from app01 and returns `valid:true` | `curl` from app01 |
| GL-4 | Row counts match the source: 200000 patients, 400000 appointments, 300000 audit_log | `mysql` from app01 |
| GL-5 | `/etc/hosts` on app01 points at the new private addresses | `cat /etc/hosts` |
| GL-6 | All defects found in testing are fixed or have a written, accepted decision (D-03, the `audit_log` primary key, is accepted for the pathfinder and carried into the wave plan) | `logs/defect-log.md` |

## Roll-back triggers (any one is enough)

| ID | Trigger |
|---|---|
| RB-1 | Application does not return the expected response after the network fixes in cutover step 6 |
| RB-2 | Row counts differ from the source (data not intact) |
| RB-3 | Validation has not passed at T0 + 75 minutes |

## Sign-off

| Decision | Time (CST) | Criteria met (GL-1 to GL-6) | Name | Signature |
|---|---|---|---|---|
| Go / No-go | | | | |

Sign-off is a deliberate step, not an assumption. With one operator the author signs; in a
real wave a second person (the application owner) signs as well.
