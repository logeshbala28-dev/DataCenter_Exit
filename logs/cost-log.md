# Cost Log

Updated every Friday during the cost review session. Figures from Cost Explorer.

| Week ending | Planned | Actual | Variance | Cumulative | Note on variance |
|---|---|---|---|---|---|
| 2026-09-11 | $0.00 | $0.00 | $0.00 | $0.00 | Project start. Existing account audited for residual resources. |

## Teardown verification

Run every Friday. Anything left running requires a written reason.

| Week ending | Compute | Gateways | Load balancers | Replication staging | Unattached IPs | All regions checked | Signed |
|---|---|---|---|---|---|---|---|
| 2026-09-11 | n/a | n/a | n/a | n/a | n/a | Yes | LB |

## Budget alerts

| Threshold | Configured | Date |
|---|---|---|
| $5 | No (the cost baseline names only $15 and $30) | |
| $15 | Yes. Budget `pathfinder-monthly-15` ($15 monthly, email alerts at $12.75 actual, $15 actual, $15 forecast) | 2026-11-11 |
| $30 | Yes. Budget `pathfinder-monthly-30` ($30 monthly, email alerts at $25.50 actual, $30 actual, $30 forecast) | 2026-11-11 |

Both created from the AWS Budgets simplified monthly-cost template, which fixes the alert points at 85% and 100% of the budget amount; two budgets were used to cover both thresholds in the baseline. The budgets were created on 2026-11-11, after replication had been running since 2026-11-06, so for the first five days of the pathfinder no alerts were configured. Month-to-date spend at creation: $3.80 (Billing home, 18:39 CST), forecast $7.15. Evidence: `evidence/week-03/billing-home-1839cst.png`, `evidence/week-03/budget-alerts-created-1842cst.png`.

### 2026-11-16 (Monday) cost check, 10:41 CST

| Item | Value |
|---|---|
| Month-to-date cost | $13.32 |
| Forecast for November | $30.31 (assumes everything keeps running to month end, so it falls after teardown) |
| Last month (October) | $0.00 |
| Previous check, 2026-11-11 | $3.80 month-to-date |
| Change in 5 days | +$9.52, about $1.90 a day |
| E-8 (pathfinder total, pre-registered) | $20 |
| Alerts | pathfinder-monthly-15 and pathfinder-monthly-30 (created 2026-11-11) |

Notes: AWS billing data lags by up to about a day, so the true figure is somewhat higher. At the current rate the $15 alert fires within about a day. Replication servers are removed about 90 minutes after Finalize (10:35); three cutover instances keep running until teardown. Evidence: `billing-home-1041cst.png`.

### 2026-11-16 (Monday) interim cost check, about 19:08 CST (after teardown at 18:25)

**Interim, not the final bill.** AWS billing data lags by up to about a day, so the afternoon and evening of 16 Nov (cutover instances to 18:25, the DR exercise) are probably not all in these figures. The final bill check is the next day.

| Item | Value |
|---|---|
| Month-to-date cost | $14.07 |
| Forecast for November | $37.10 (a straight-line forecast that assumes resources keep running; all billable resources were terminated at 18:25, so it overstates) |
| Last month (October 1 to 16) | $0.00 |
| Previous check, 16 Nov 10:41 | $13.32 month-to-date, forecast $30.31 |
| Change since 10:41 | +$0.75 in about 8.5 hours |
| E-8 (pathfinder total, pre-registered) | $20 (70 percent used at this reading) |
| Cost monitor | Budgets status OK (2 active budgets); anomaly detection: none |
| Recommended actions shown | "2 budgets forecasted to exceed their threshold" and "3 budget alerts have exceeded their threshold" |

**Reading of the budget messages:** the $15 budget alerts at $12.75 actual, $15 actual and $15 forecast, and the $30 budget at $25.50 actual, $30 actual and $30 forecast (see above). At $14.07 the $12.75 actual alert has fired, and the forecast of $37.10 is above both the $15 and $30 forecast alerts. That makes three, which matches the message. No actual-spend alert at $15 or $30 has been reached. [Author to confirm by opening Review budgets.]

**Cost breakdown chart (by service, November, read by eye from the chart, not exact):** EC2 compute is the largest part (about $9), then EC2 other (about $3, probably volumes, snapshots and data transfer), then Virtual Private Cloud (under $2, probably public IPv4 addresses), then small amounts for S3 and Secrets Manager. Exact values come from Cost Explorer.

Evidence: `evidence/week-04/cost-interim-billing-home-1908cst.png` (no on-screen clock; time from the message). Final bill check and the cost by WBS tag still to do.
