# E-1 Bandwidth Measurement

**Measured:** 2026-10-29
**Host:** Windows laptop (the machine that will run the source VMs and MGN agents)
**Connection:** Comcast Xfinity, Chicago IL
**Public IP at time of measurement:** 73.247.253.152
**Tool:** Speedtest by Ookla, speedtest.net

## Results

| Run | Download (Mbps) | Upload (Mbps) | Ping (ms) |
|---|---|---|---|
| 1 | 26.95 | 37.27 | 15 |
| 2 | 38.12 | 39.13 | 130 |

Screenshots: `E1-speedtest-run1.png`, `E1-speedtest-run2.png`

## Value adopted

**E-1 = 37.27 Mbps upload.**

The lower of the two upload readings was taken, as a conservative basis for the
replication duration estimate. Using the higher figure would produce a more
optimistic estimate and weaken the comparison.

## Observations

Upload exceeded download in both runs, which is atypical for residential cable
service and was re-tested to confirm. Upload was consistent across runs
(37.27, 39.13). Download varied considerably (26.95, 38.12), as did latency
(15 ms, 130 ms), which suggests the second run selected a different test server.

The variance between runs is itself relevant. A residential connection is shared
and contended, so throughput is not a fixed property of the link. This is noted as
a limitation: even the baseline measurement against which replication is compared
carries uncertainty of roughly 5 percent on upload.

## Derived estimate

E-3, initial replication duration for all three source VMs:

    3 VMs x 8 GiB     = 24 GiB
                      = 206,158 megabits
    / 37.27 Mbps      = 5,532 seconds
                      = 1.54 hours

**E-3 = 1.5 hours.**

This calculation deliberately assumes sustained throughput equals the measured
peak. That assumption is what prediction P-1 tests. Protocol overhead, link
contention, and variable compression ratios are all expected to reduce sustained
throughput below this figure, but no allowance for them has been made in the
estimate.
