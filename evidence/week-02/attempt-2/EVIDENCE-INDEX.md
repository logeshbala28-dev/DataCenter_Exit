# Evidence index: source environment, attempt 2

Valid source environment. Ubuntu Server 24.04.3 LTS, kernel 6.8.0-147-generic (held),
built 2026-11-04. Attempt 1 is in `../attempt-1-superseded/`.

Server clocks are GMT (Chicago CST = GMT minus 6). File times in the chat are send
times, not event times; use the timestamps visible inside each screenshot.

## Final identities

| VM | Reserved IP | MAC | Disk | Role |
|---|---|---|---|---|
| meridian-app01 | 192.168.161.10 | 00:0c:29:10:60:d6 | 17.83 GB root | nginx + Flask app |
| meridian-db01 | 192.168.161.11 | 00:0c:29:31:2f:13 | 17.83 GB root | MySQL |
| meridian-lic01 | 192.168.161.12 | 00:0c:29:be:ae:10 | 17.83 GB root | Licence service |

IPs fixed with DHCP reservations in `vmnetdhcp.conf` (guests stay on DHCP).

## Measured data volume (E-2)

| VM | Used bytes | Evidence |
|---|---|---|
| db01 | 12,088,487,936 | 12 |
| app01 | 11,299,930,112 | 19 |
| lic01 | 2,955,026,432 | 19 |
| Total | 26,343,444,480 | |

## Files

| # | What it shows |
|---|---|
| 01 to 03 | Kernel 6.8.0-147, 18 GB root, distinct SSH host keys on each VM |
| 04 to 06 | Kernel packages held, matching headers and isc-dhcp-client installed (MGN prerequisites) |
| 07 to 09 | MAC addresses used for the DHCP reservations |
| 10 | MySQL installed, listening on all interfaces, active |
| 11 | Schema created (audit_log deliberately has no primary key) and row counts 200000 / 400000 / 300000 |
| 12 | 8 GB random padding file on db01 and used bytes |
| 13 | Licence service created; first curl refused because it ran before the service had started |
| 14 | Licence service responding with valid:true |
| 15, 16 | App returns patient count 200000 through nginx, from the VM and from the browser |
| 17 | Dependency test: licence service stopped, app returns 500 |
| 18 | Licence service restored, app returns ok |
| 19 | Used bytes for lic01 and app01 |
| 20 | After snapshot reboots: app01 500 until lic01 finished starting, then 200 (boot order) |
| troubleshooting/T1 | vmnetdhcp.conf before the reservation blocks were added (edit had not saved) |

## Known gaps

- No screenshot of app01 padding command output on its own (used bytes is in 19).
- The `source-ready` and `clean-os-24.04.3` snapshots are not photographed; add VMware
  Snapshot Manager screenshots for all three VMs.
- Screenshot of the GitHub commit timestamp for the pre-registration (commit 39d44b4)
  to be added as `pre-registration-commit-timestamp.png`.
- The lab password placeholder `ChangeMe123!` is visible in 11. It is a lab placeholder,
  not a real credential.
