# Decision Log

Index of architecture and project decisions. Full records live in `/decision-records`.
A decision is recorded **before** implementation, not after.

| ID | Date | Decision | Status | Record |
|---|---|---|---|---|
| ADR-001 | 2026-09-11 | Simulated source environment: local hypervisor vs second AWS account | Proposed | `decision-records/ADR-001-source-environment.md` |
| ADR-002 | | Connectivity model between source environment and AWS | Not started | |
| ADR-003 | | Landing zone approach: managed service vs hand-built with Terraform | Not started | |

## Project decisions made before the cutover window

| ID | Date and time | Decision | Why |
|---|---|---|---|
| DEC-01 | 2026-11-11 19:40 CST | **Attempt one fails by Option A: launch only app01 and db01 in cutover step 4 and leave out lic01.** The application is expected to return 500 at validation, and the rollback is then run | Reproduces the undocumented licence dependency the way a team working from the discovery inventory (which does not list lic01) would have hit it. B repeats D-01; C tests the rule, not the technology. Chosen by the author on the recommendation of the AI assistant |
| DEC-02 | 2026-11-11 19:40 CST | **DP-1 limit: roll back if validation (step 7) has not passed at T0 + 75 minutes.** Also roll back at once if any of RB-1 to RB-3 is true | 75 minutes is E-4 (68 minutes) plus about 10 percent. Set before the window so it is not decided under pressure. Chosen by the author on the recommendation of the AI assistant |

Both decisions were recorded before step 1 of attempt one started. The pre-window step
(Mark as Ready for cutover, terminate the test instances) ran earlier, 19:29 to 19:35 CST.
