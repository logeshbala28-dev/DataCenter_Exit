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
| 2026-11-11 | Replication health before launch | Screenshot | evidence/week-03/mgn-health-before-test-1611cst.png | All three servers Ready for testing and Healthy, snapshots under 10 minutes old, five days after initial sync |
| 2026-11-11 | Launch settings per server | Screenshots | evidence/week-03/launch-settings-{app01,db01,lic01}.png | t3.small, pathfinder public subnet, security group per tier, Public IP only on app01, right-sizing off |
| 2026-11-11 | Test launch jobs | Screenshots | evidence/week-03/test-launch-{lic01,db01,app01}-*.png | Job logs from start to "Job ended", 10 to 11 minutes each (17:04, 17:08, 17:29 starts) |
| 2026-11-11 | Test instances running | Screenshot | evidence/week-03/test-instances-running-1750cst.png | Replication server plus three test instances, 3/3 status checks |
| 2026-11-11 | Validation, defects D-01 and D-02 | Screenshots | evidence/week-03/validation-app01-*.png, lic01-instance-summary-1800cst.png | HTTP 500 at first load, stale hosts file, licence timeout in the journal, licence service reachable at the new address, page returns 200000 patients after the fix |
| 2026-11-11 | Validation, defect D-03 | Screenshot | evidence/week-03/validation-db01-counts-and-audit-log-1835cst.png | Row counts 200000 / 400000 / 300000, audit_log has no primary key |
| 2026-11-11 | Cost and budget alerts | Screenshots | evidence/week-03/billing-home-1839cst.png, budget-alerts-created-1842cst.png | Month-to-date $3.80, forecast $7.15; budgets of $15 and $30 created |
| 2026-11-16 | DR Phase A: images, cross-region copy, security groups | Screenshots | evidence/week-04/dr1-A2-*.png, dr1-A3-*.png, dr1-A4-*.png | Two failed copies (State reason shown), AMI creation times 11:07 to 11:12, copies Available 13:06 to 13:09, groups created by 13:21, outbound rule corrected 13:31. Account number, name and addresses blanked |
| 2026-11-16 | DR Phase B: launch in us-west-2 and recovery | Screenshots | evidence/week-04/dr1-B1-*.png, dr1-B2-*.png, dr1-B3*-*.png | DISASTER DECLARED 13:35:22, three Running 13:51, hosts fixed about 13:59, page 14:00, licence 14:01, row counts 14:03:53. Log: logs/status-log.md |
| 2026-11-16 | DR Phase C: destroy and region check | Screenshots | evidence/week-04/dr1-C1-*.png, dr1-C2-*.png, dr1-C3-*.png | us-west-2 empty at 14:17; us-east-1 shows only the three cutover instances and one MGN snapshot from 6 Nov |
| 2026-11-16 | Teardown: cutover instances terminated | Screenshot | evidence/week-04/teardown-useast1-instances-terminated-1825cst.png; cutover2-db01-sg-inbound-1817cst.png | 18:25 CST all three Terminated; db01 security group has only port 3306 (explains the SSH timeout) |
| 2026-11-16 | Teardown region check: instances, volumes, Elastic IPs, VPCs, NAT gateways; MGN servers and launch history | Screenshots | evidence/week-04/teardown-check-*.png, teardown-mgn-source-servers-*.png, cutover-mgn-launch-history-1843cst.png, cutover2-launch-job-*.png | About 18:41 to 18:59 CST. No hourly-billed resource left; replication 0 servers |

## Evidence strength, strongest first

1. Repository commit history — cannot be convincingly backdated
2. Terraform plan and apply outputs — shows what was deployed and when
3. CloudTrail extracts — independent, timestamped record of actions
4. Timestamped exercise logs — proves timings were measured, not estimated
5. Cost reports — real financial data behind the variance analysis
6. Screenshots — weak on their own; useful only with a visible timestamp and alongside the above
