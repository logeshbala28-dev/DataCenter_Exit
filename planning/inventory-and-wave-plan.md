# Application inventory and six-wave plan (lean version)

*Synthetic data. These counts and windows are planning assumptions for the simulated estate of Meridian Regional Health Partners. Created 16 Nov 2026, after the Wave 1 pathfinder. This file is not part of the committed baseline, and the change log records that it was produced late.*

**Wave rules.** (1) Group applications that talk to each other. (2) Sequence by rising criticality, since the process will be wrong the first few times. (3) Leave a 2-week hypercare period before the next wave starts. (4) Treat every wave as rehost, because the deadline is fixed.

| Wave | Applications | VMs | Criticality | Contents | Planned window |
|---|---|---|---|---|---|
| 1 (pathfinder) | 1 | 3 | Low | Meridian internal lookup app, its database and its licence service. Done 16 Nov 2026. | Nov 2026 |
| 2 | 14 | 62 | Low | Development, test and internal tools | Jan to Feb 2027 |
| 3 | 16 | 88 | Medium | HR, finance, document management, reporting | Mar to Apr 2027 |
| 4 | 12 | 84 | Medium | Interface engine, file transfer, monitoring, shared services | May to Jun 2027 |
| 5 | 14 | 98 | High | Scheduling, billing, claims processing | Jul to Aug 2027 |
| 6 | 11 | 77 | Highest | Clinical core systems, patient portal | Sep to Oct 2027 |
| **Total** | **68** | **412** | | | Decommission Nov 2027 |

Totals: 1 + 14 + 16 + 12 + 14 + 11 = 68 applications, and 3 + 62 + 88 + 84 + 98 + 77 = 412 VMs.

**Dependency note.** Wave 4 holds the shared services that other waves rely on, so its dependency map is checked before Waves 3 and 5 are cut over. Every application is searched for licence servers and hard-coded addresses, because the pathfinder's undocumented licence dependency is the kind of thing a normal inventory misses.

**Data volumes.** Not assumed here. They are estimated in WBS 6.2.1 from the measured throughput of 30.6 Mbps.

**Contract dates (derived from the charter, simulated).** Charter date 28 Sep 2026. VMware licence renewal: within 14 months, so by about 28 Nov 2027. Colocation lease expiry: two months later, about 28 Jan 2028. Wave 6 finishes in Oct 2027 and decommissioning is planned for Nov 2027, which leaves about one month before the renewal date and about three months before the lease ends. One month of margin is thin and is a planning risk.
