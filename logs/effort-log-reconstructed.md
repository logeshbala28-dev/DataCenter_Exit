# Effort log (reconstructed)

**Status:** Draft written 2026-11-16 with AI assistance. **This is a reconstruction, not a measured
log.** No effort log was kept during the project (no hours were recorded). The "Span" column is the time between the first and last logged event of a
session, taken from timestamps in the logs, screenshots and commits. It is not attended time.
The "Attended" column uses the logged span as attended time where one exists, and an estimate for
4 Nov. The weeks without timestamps are the author's recollection. Every figure that rests on memory
or on an estimate must be reported as such in section 4.9.

Estimates to compare against: E-9 (Wave 0, WBS 3.0) 50.3 h. E-10 (pathfinder, WBS 4.0) 83.8 h,
of which 29.3 h is elapsed initial synchronization, so **attended effort is 54.5 h**. WBS 5.0
(resilience and recovery) is 26.2 h and is reported separately.

## Sessions with timestamps in the record

| Date (CST) | Work (from the logs) | WBS | First to last logged time | Span (h) | Attended (h) |
|---|---|---|---|---|---|
| 2026-10-29 | Wave 0 landing zone applied (27 resources), destroyed and rebuilt, pre-registration committed | 3.x | 10:51 to 14:11 (commit times) | 3.3 | 3.3 (span used as attended time) |
| 2026-11-04 | Source rebuild on Ubuntu 24.04.3, E-2 measured, E-1 to E-10 committed | 4.1 | commits 12:57 and 13:07; the rest of the day is not timestamped | not recorded | 5.5 (estimated from the evidence dated 4 Nov: rebuild, data load, dependency test, E-2 and pre-registration; author reviewed and adopted) |
| 2026-11-05 | Monte Carlo baseline (commit 12:21) and pathfinder cost baseline (commit 15:22), both committed before replication | 1.3.2, 1.3.4 | 12:21 to 15:22 (commit times) | 3.0 | 3.0 (span used as attended time) |
| 2026-11-06 | Cost baseline push confirmed, pricing check, agent installs, replication start (console 10:56 and 10:57), lic01 install failures (I-08, I-09); log write-up committed 23:42 | 4.2 | 09:26 to 16:11, then write-up to 23:42 | 6.8 to 14.3 | 6.8 (daytime span; the evening write-up and the unattended initial sync, about 111 min, are not counted) |
| 2026-11-11 | Launch settings, test launch and validation, budget alerts, attempt one to its pause | 4.3 | 15:59 to 20:26 | 4.5 | 4.5 (span used as attended time) |
| 2026-11-16 morning | Rollback, v2 runbooks, attempt two, cost check, DR plan | 4.3 to 5.1 | 09:07 to 11:01 | 1.9 | 1.9 (span used as attended time) |
| 2026-11-16 midday | DR exercise, phases A, B and C | 5.2 to 5.5 | 11:08 to 14:17 | 3.2 | 3.2 (span used as attended time) |
| 2026-11-16 evening | Teardown, evidence, region check, security cleanup | 5.5, 7.0 | 18:15 to 19:50, then work to 20:57 | 2.7 | 2.7 (18:15 to 20:57, includes the billing, CLI and effort log work after 19:50) |

## Weeks with no timestamps (author to fill from memory, label as recalled)

| Period | Work (from the repository) | WBS | Attended (h) |
|---|---|---|---|
| 11 to 30 Sep | Research on how to approach the project, charter, WBS and risk drafting (no dated artifacts, one commit on 28 Sep) | 1.0, 2.0 | About 13 h a week (2 to 3 h a day, about 3 weeks, so about 37 h), author's recollection |
| 1 to 28 Oct | Charter, WBS, risk register, wave plan, documents | 1.0, 2.0 | About 24 h, author's recollection (part of about 10 h a week, 4 weeks, about 40 h). Split estimated and adopted by the author on 16 Nov. Midterm week (19 to 23 Oct, exam on 22 Oct) was lower |
| 1 to 28 Oct | Wave 0 Terraform code (committed 29 Oct) | 3.0 | About 16 h, author's recollection (part of the same 40 h). Split estimated and adopted by the author on 16 Nov |
| 30 Oct to 3 Nov, 7 to 10 Nov, 12 to 15 Nov (days with no commits; the week of 9 Nov was slower) | Learning AWS technical and development skills (about 30 h); cutover, rollback and DR runbooks (about 11 h); literature review and past work on the project (about 8 h); Terraform practice (about 13 h) | 1.0, 3.0, 4.0, 5.0; learning is outside the WBS | About 62 h in total, author's recollection. These hours may overlap with the 11 Nov and 16 Nov session rows and the 1 to 28 Oct row [confirm] |
| 16 Nov, drafting by the AI assistant | Runbooks, DR plan, review and Chapter 4 drafts; the author's review time counts | 4.0, 5.0, 8.0 | [___] |

## Treatment of AI assistance (section 3.12, decision for the author)

Hours are the author's own attended time.

## Availability note for sections 4.9 and 5.5

The baseline assumed about 35 hours a week. The author's recalled effort was about 13 hours a week in September and about 10 hours a week in October, with a midterm exam week (exam on 22 October). From 30 October to 15 November the recalled effort was about 62 hours across 13 days (about 33 hours a week), spent on AWS learning, runbooks, the literature review and Terraform practice, with a slower week around 9 November. The recalled figures are a limitation, not a measurement. Personal reasons are not recorded in the repository.
