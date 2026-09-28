# RAID Log

Risks, Assumptions, Issues, Dependencies. Append as they arise. Never delete a row —
close it with a date and an outcome.

**ID convention:** R-01 risk, A-01 assumption, I-01 issue, D-01 dependency.

| ID | Date raised | Type | Description | Prob | Impact | Score | Response | Status | Date closed | Outcome |
|---|---|---|---|---|---|---|---|---|---|---|
| R-01 | 2026-09-11 | Risk | Home upload bandwidth constrains replication throughput; cutover window may be underestimated | H | H | 9 | Mitigate — measure actual throughput before committing to a cutover window | Open | | |
| R-02 | 2026-09-11 | Risk | New AWS member accounts may be held for verification or arrive with low service quotas | M | M | 4 | Mitigate — create accounts week 1, request quota increases immediately | Open | | |
| R-03 | 2026-09-11 | Risk | Preventive policy misapplied could lock out own admin access | M | H | 6 | Mitigate — test policies on a throwaway OU; exclude a named break-glass role | Open | | |
| R-04 | 2026-09-11 | Risk | Cloud spend runs unnoticed; billing alerts lag by roughly 24 hours | M | M | 4 | Mitigate — Friday teardown checklist as primary control; alerts as safety net | Open | | |
| R-05 | 2026-09-11 | Risk | No prior Terraform experience may slow the landing zone build | H | M | 6 | Mitigate — throwaway practice build in week 1 before landing zone design | Open | | |
| A-01 | 2026-09-11 | Assumption | Source environment simulated with 2 local VMs on a 16GB host is sufficiently representative | | | | Validate in week 3 | Open | | |
| A-02 | 2026-09-11 | Assumption | Pathfinder measurements can be extrapolated to later waves | | | | Test in week 8; state limits of extrapolation in closure report | Open | | |
| D-01 | 2026-09-11 | Dependency | Advisor confirmation of pathfinder-wave methodology before Phase 1 begins | | | | Idea submitted 2026-09-11 | Open | | |

## Scoring

Probability and impact scored L=1, M=2, H=3. Score = product. Review weekly in the
Monday session; re-score when circumstances change and note the date of the change.
