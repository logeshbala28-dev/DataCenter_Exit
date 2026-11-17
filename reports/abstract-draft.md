# Abstract: proposed changes

**Status:** Draft written 2026-11-16, drafted with AI assistance for the author to review and
adopt. The original is in `Abstract_Logesh_Balakrishnan.docx` and is not changed. Text in square
brackets needs your figure.

## A. Fixes only (keeps the original tense and structure)

| # | Original | Change | Why |
|---|---|---|---|
| 1 | "assumed to run 400 virtual machines" | "412 virtual machines" | Inventory and WBS say 412 |
| 2 | "This project simulates of planning and managing" | "This project simulates the planning and management of" | Typo |
| 3 | "made-up regional healthcare organization" and "made-up organization" | "fictional" (both places) | Matches the last sentence; less informal |
| 4 | "project charter work breakdown structure, schedule" | "project charter, work breakdown structure, schedule" | Missing comma |
| 5 | "technical problems rollback speed and recovery speed" | "technical problems, rollback speed and recovery speed" | Missing comma |
| 6 | "a disaster recovery test" | "a disaster recovery exercise in a second AWS Region (us-west-2)" | Says what was done |
| 7 | "This project shows that measured evidence from an initial migration which can give better planning" | "This project shows that measured evidence from an initial migration can give better planning" | Broken sentence |

## B. Past tense, with results, in plain first-person wording (recommended)

Changes to VMware licensing have pushed many organizations to rethink their on-premises
virtualization and look at moving to public cloud. Large migrations like this bring project
management problems as well as technical ones: dependencies nobody documented, cost and schedule
estimates that turn out wrong, and cutover and recovery procedures that were never properly tested.
In healthcare these problems matter more, because services have to stay available and data has to
stay secure the whole way through. This project simulated the planning and management of a large
VMware to Amazon Web Services (AWS) migration for a fictional regional healthcare organization with
412 virtual machines and 68 applications, split into six waves by dependency. Working as both
project manager and solutions architect, I wrote the migration strategy and the supporting project
documents, including the business case, charter, work breakdown structure, schedule and cost
baselines, risk management plan, change control process and wave plan. To check the strategy against
real evidence, I ran one pathfinder migration by hand. The source was three virtual machines (an
application server, a database server and a licence server) on a local VMware host, and the AWS side
was built with Terraform. The pathfinder covered replication, test validation, a cutover that I
deliberately let fail and then rolled back, a successful cutover, and a disaster recovery exercise in
a second AWS Region. I recorded my estimates and four predictions before starting. Replication took
longer than estimated, an undocumented dependency did show up, and the rollback plan had gaps.
Recovery, though, took about 29 minutes against a four-hour objective, so that prediction was wrong.
Downtime in the corrected cutover was about 30 minutes against 63 estimated, and the AWS bill came to
[$___] against an estimate of $20. I used these measurements to re-estimate the remaining waves. The
project shows that measured evidence from an initial migration can improve planning and
decision-making for a larger enterprise cloud migration. All organizational data in this project are
fictional.

**Check before adopting B:**
- "about 29 minutes": measured 28 min 31 s (Phase B). Round as you like, or write "28.5 minutes".
- "about 30 minutes" downtime is the evidenced figure (09:48:18 to 10:18); it may have been about 24.
- "[$___]" needs the final bill, which is not in yet.
- "confirmed" and "contradicted" assume the predictions (P-1 to P-4) stay as recorded in `4.11`.
- "were then used to re-estimate" is only true once Chapter 5.3 is done. Keep or cut that sentence
  accordingly.
