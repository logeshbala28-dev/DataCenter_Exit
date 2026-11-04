# Evidence Index

Filed every Friday. Captured at the moment of the event, never reconstructed.

| Date | Event | Evidence type | Location | Notes |
|---|---|---|---|---|
| 2026-09-11 | Project initiation | Commit | Repository history | First commit — starts the project timeline |
| 2026-11-02 | Source build attempt 1 (superseded) | Screenshots | evidence/week-02/attempt-1-superseded/ | Ubuntu 26.10, not supported by MGN. Discarded before replication. Dates inside the screenshots take priority over this row |
| 2026-11-04 | Source environment rebuilt on Ubuntu Server 24.04.3 | Screenshots | evidence/week-02/attempt-2/ (01 to 09) | Kernel 6.8.0-147 held, headers and isc-dhcp-client installed, distinct machine IDs and SSH keys |
| 2026-11-04 | Application and data loaded | Screenshots | evidence/week-02/attempt-2/ (10 to 16) | Row counts 200000 / 400000 / 300000, app returns 200000 patients |
| 2026-11-04 | Dependency test, licence service stopped and restored | Screenshots | evidence/week-02/attempt-2/ (17, 18, 20) | App returns 500 with lic01 stopped, ok when restored. Server time in GMT |
| 2026-11-04 | E-2 measured (26,343,444,480 bytes used across three VMs) | Screenshots | evidence/week-02/attempt-2/ (12, 19) | db01 12,088,487,936, app01 11,299,930,112, lic01 2,955,026,432 |
| 2026-11-04 | Pre-registration E-1 to E-10 committed before replication | Commit | Repository history, commit 39d44b4 | Pushed 12:58 local time. GitHub timestamp screenshot still to add |

## Evidence strength, strongest first

1. Repository commit history — cannot be convincingly backdated
2. Terraform plan and apply outputs — shows what was deployed and when
3. CloudTrail extracts — independent, timestamped record of actions
4. Timestamped exercise logs — proves timings were measured, not estimated
5. Cost reports — real financial data behind the variance analysis
6. Screenshots — weak on their own; useful only with a visible timestamp and alongside the above
