# E-3 analysis: initial sync of db01 and app01 (measured 2026-11-06)

**Status:** measurement record. Written after the data was collected. Does not change `pm-baselines/pre-registration.md`.
**Prepared with AI assistance (Claude); numbers transcribed by Claude from the screenshot `attempt2-cloudwatch-networkin-replication-server.png`, reviewed by the author.**

## Source

- CloudWatch metric `AWS/EC2 NetworkIn`, Sum, 5-minute period, region us-east-1.
- Instance `i-057254419e232394a`, the MGN replication server shared by db01 and app01.
- Timestamps are CST (UTC-6). Each value is bytes received in that 5-minute window.
- Console replication start: db01 10:57, app01 10:56 (screenshots `attempt2-mgn-db01-details-1605cst.png`, `attempt2-mgn-app01-details-1608cst.png`).
- lic01 is not included: it registered later and had not finished its first sync when this was taken.

## Data, 10:55 to 12:50 CST

| Window starting (CST) | Bytes received | Mbps (window average) |
|---|---|---|
| 10:55 | 793,303,291 | 21.2 |
| 11:00 | 1,188,712,544 | 31.7 |
| 11:05 | 866,275,354 | 23.1 |
| 11:10 | 1,109,660,351 | 29.6 |
| 11:15 | 1,100,365,685 | 29.3 |
| 11:20 | 1,199,418,478 | 32.0 |
| 11:25 | 1,241,126,913 | 33.1 |
| 11:30 | 1,242,680,933 | 33.1 |
| 11:35 | 1,207,367,732 | 32.2 |
| 11:40 | 1,237,823,605 | 33.0 |
| 11:45 | 1,156,615,141 | 30.8 |
| 11:50 | 1,282,472,557 | 34.2 |
| 11:55 | 1,270,557,588 | 33.9 |
| 12:00 | 1,277,581,448 | 34.1 |
| 12:05 | 1,303,943,889 | 34.8 |
| 12:10 | 918,114,727 | 24.5 |
| 12:15 | 1,175,080,150 | 31.3 |
| 12:20 | 1,218,727,658 | 32.5 |
| 12:25 | 1,228,311,842 | 32.8 |
| 12:30 | 497,172,743 | 13.3 |
| 12:35 | 1,262,173,735 | 33.7 |
| 12:40 | 1,236,299,780 | 33.0 |
| 12:45 | 453,202,818 | 12.1 |
| 12:50 | 903,733 | 0.0 |

After 12:50 the traffic falls to under 1 MB per 5 minutes (continuous replication of changes only).

## Results

| Measure | Value |
|---|---|
| Initial sync start (console) | 10:56 to 10:57 CST |
| Initial sync end (traffic stops) | about 12:47 CST, plus or minus 3 minutes. The 12:45 window holds 453 MB, a partial window |
| Duration, db01 and app01 together | about 111 minutes (1.85 hours) |
| Bytes received 10:55 to 12:45 | 25,466,988,962 (25.5 GB, 23.7 GiB) |
| Used data on the two disks (E-2) | 23,388,418,048 (23.4 GB). Received is about 9% higher |
| Average rate | 30.6 Mbps |
| Median 5-minute rate | 32.2 Mbps |
| Peak 5-minute rate | 34.8 Mbps |
| Measured upload speed (E-1) | 37.27 Mbps. Observed average is about 82% of it |

## Comparison with the pre-registered values

- **E-3 as committed: 1.5 hours.** Observed for db01 and app01: about 1.85 hours, 23% longer. E-3 covered three VMs, so the full comparison waits for lic01.
- **E-3 recalculated from measured data: 1.57 hours.** Observed is 18% longer. The recalculation allowed no overhead.
- **E-2:** the console shows "20 of 20 GiB" replicated per server, but the network traffic matches the used data (about 25.5 GB received for 23.4 GB of used data), not the full 40 GiB of provisioned disk.

## Caveats

- The replication server's NetworkIn includes protocol overhead and anything else sent to that instance, so received bytes are an upper bound on payload.
- The sync end time is read from where the traffic stops, not from a console timestamp. The console page showed no finish time.
- The two servers replicated at the same time and shared one upload link. The rate above is the combined rate.
- A burst of about 238 MB appears at 15:00 to 15:10 (67.2 MB and 170.8 MB). Cause not yet confirmed.
