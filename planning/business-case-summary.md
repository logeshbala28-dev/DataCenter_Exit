# Business case summary: five-year TCO, NPV and sensitivity (lean version)

*Synthetic data. All figures are planning assumptions for the simulated estate of Meridian Regional Health Partners. Created 16 Nov 2026, after the Wave 1 pathfinder. This file is not part of the committed baseline. Amounts in thousands of US dollars unless stated.*

## Assumptions

| Assumption | Value |
|---|---|
| Current VMware licence, per year | $420k |
| VMware licence after renewal, per year | $780k |
| Colocation lease, per year | $540k |
| Hardware refresh for aging hosts (one-off, year 0) | $1,600k |
| AWS run cost, per VM per month (average) | $140 (412 VMs, so $692.16k a year) |
| Migration program cost (one-off, year 0) | $450k |
| Analysis period and discount rate | 5 years, 8% |
| Staff cost | Same in both options, so left out of the comparison |
| Year 1 under the migrate option | Old environment at the current rate, plus 25% of the AWS run cost |

The $140 per VM per month is an assumption. It is not measured. The pathfinder bill covers a short, transient run of three VMs and does not measure a steady-state run cost.

## Comparison

| Option | Year 0 | Year 1 | Years 2 to 5 (each) | 5-year total |
|---|---|---|---|---|
| Stay | $1,600k hardware refresh | $960k | $1,320k | $7,840k |
| Migrate | $450k program | $1,133k | $692k | $4,352k |
| Saving | $1,150k | -$173k | $628k | $3,488k |

## Results

- NPV of migrating, including the avoided hardware refresh: about $2.92M.
- Payback: immediate on that view, because the avoided $1.6M refresh is larger than the $450k program cost. Without the refresh, payback is at the end of year 2 and the NPV is about $1.32M. Both views are reported.

## Sensitivity

| Case | NPV |
|---|---|
| Base case | about $2.92M |
| AWS run cost 50% higher ($210 per VM per month) | about $1.77M |
| Migration program cost twice as high ($900k) | about $2.47M |

The NPV turns negative only if AWS costs about $319 per VM per month (2.3 times the assumption). Without the avoided refresh, it turns negative at about $221 (1.6 times).
