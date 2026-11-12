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
