# Evidence Index: Source Environment Build, 2 Nov 2026

Times are approximate, in CST, taken from when each screenshot was shared in chat.
They are NOT the event times. The true event time is the file timestamp on your
own computer, or a timestamp visible inside the screenshot. Where a screenshot
shows its own time, it is noted below. Keep your original files unedited.

Server clocks on the VMs are in GMT (CST is GMT minus 6).

## source-build/

| File | What it shows | Why it matters | ~Time |
|---|---|---|---|
| 01-ubuntu-install-type-standard-server.png | Installer with standard Ubuntu Server chosen | Documents that standard (not minimized) was used, a change from the build guide | 09:19 |
| 02-clone-machine-id-removal-attempt.png | rm of /etc/machine-id on a clone | Start of the clone identity fix | 10:22 |
| 03 / 04 / 05 machine-id files | Machine IDs of app01, db01, lic01 | 05 shows lic01 had the SAME ID as app01 (d1ba9ccd...) after cloning | 10:47 |
| 06 / 07 df files | Root volume only 9.8 GB on a 20 GB disk | Evidence of the half-disk LVM default | 10:57 |
| 08 lic01 lvextend | lic01 with a NEW machine ID (e440343d...) and root grown to 18 GB | Shows the duplicate ID was fixed and the disk extended | 11:08 |
| 09 db01 lvextend | db01 root grown from 10 GB to 18.22 GB | Same fix | 11:08 |
| 10 app01 lvextend CROPPED | app01 root grown to 18 GB | Cropped to remove a password fragment visible in the original. Do not use the original | 11:08 |
| 11 / 12 / 13 ip addr files | IPs: app01 .137, db01 .135, lic01 .136 | Source network baseline | 11:29 |
| 14 db01 mysql tables | appointments, audit_log, patients exist | Seeded table with no primary key is in place | 11:57 |
| 15 lic01 licence service | Service answers {"valid":true,"seats":1800} | Dependency service works | 12:02 |
| 16 app01 curl ok | {"patients":0,"status":"ok"} | App works end to end before data load | 12:07 |
| 17 browser output | Same result from the Windows browser at 192.168.161.137 | Proof from outside the VM | 12:11 |

## dependency-test/

| File | What it shows | ~Time |
|---|---|---|
| lic01-stopped-failure-terminal.png | 500 Internal Server Error with lic01 stopped. Server Date header: 18:14:34 GMT (12:14:34 CST) | 12:15 |
| lic01-stopped-failure-terminal-full.png | Same, uncropped | 12:15 |
| lic01-stopped-failure-browser.png | 500 error in the Windows browser | 12:15 |
| lic01-restored-ok.png | App OK again after lic01 restarted | 12:20 |

These four are the proof that the app depends on lic01.

## troubleshooting/

These are real problems met while building. They are evidence for the RAID
log and good material for the report. Keep them.

| File | Problem |
|---|---|
| T1 | First boot: login incorrect (password mistyped) |
| T2 | A paste began with ^[[200~ and the first command failed ("sudo: command not found") |
| T3 | licsvc started before its file existed, so curl was refused |
| T4 | VM settings: NAT, 4 GB RAM (spec is 2 GB), CD still connected |
| T5 | Windows ping to the VM timed out |
| T6 | Test-NetConnection to port 22 failed, routed via Wi-Fi |
| T7 | VMnet1 and VMnet8 adapters exist and are Up |
| T8 | VMnet8 held a 169.254.x.x fallback address |
| T9 | ipconfig /renew: "adapter is not enabled for DHCP" |

## Suggested RAID log entries (write these in your own words)

1. **Duplicate machine ID after clone.** lic01 and app01 shared a machine ID. Found at ~10:47 by comparing IDs. Fixed by removing /etc/machine-id and regenerating. Lesson: verify IDs after cloning, because MGN identifies servers by them.
2. **Root volume used half the disk.** Found at ~10:57 (9.8 GB of 20 GB). Fixed with lvextend. Lesson: check df after install, before loading data.
3. **Windows could not reach the VMs.** VMnet8 had a 169.254 fallback address. Cause: the adapter lost its VMware-assigned address. Fix: set 192.168.161.1/24 manually. Lesson: host-to-VM reachability is a dependency, and ping is a poor test.
4. **Paste corruption.** A control-character prefix broke the first command of a block. Lesson: check the first line of long pastes.

## Still missing: please capture and add

- The Windows fix working: `Get-NetIPAddress -InterfaceIndex 12` showing 192.168.161.1, and `Test-NetConnection 192.168.161.137 -Port 22` showing TcpTestSucceeded True
- app01-journal-error.png (you have it)
- Screenshots of `df -h /` on all three VMs AFTER the data load
- `curl localhost` on app01 showing patients 200000 after the load
- The VMware snapshots list for all three VMs
- A screenshot of the VM settings after you resize RAM and CPUs
- The Windows free disk space before the data load
