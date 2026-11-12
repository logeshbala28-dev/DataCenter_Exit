# Defect log

Defects found during test launch validation. Compare the count with pre-registered
estimate E-6 (4 defects: three seeded, one allowed for something unplanned).

Seeded defects, defined before the pathfinder (see `pm-baselines/pre-registration.md`):
1. Undocumented licence dependency (lic01 absent from the dependency inventory)
2. `audit_log` table without a primary key
3. Hosts-file entries on app01 pointing at the old VMware addresses

| ID | Found (CST) | Step | Symptom | Root cause | Seeded? | Fix | Fix time | Evidence |
|---|---|---|---|---|---|---|---|---|
| D-01 | 17:52 | B, C | App returns HTTP 500 on `/`. Journal shows `ConnectTimeout` to `meridian-lic01:8080` from `check_license()` (`/opt/app.py` line 10) | `/etc/hosts` on app01 maps `meridian-db01` to 192.168.161.11 and `meridian-lic01` to 192.168.161.12, the old VMware addresses. The AWS instances are on 10.20.0.0/16, so both names resolve to unreachable addresses | Yes (seeded 3) | Replaced the two lines in `/etc/hosts` on app01 with the AWS private addresses (db01 10.20.0.59, lic01 10.20.0.145); original saved as `/etc/hosts.bak`. Page then returned `{"patients":200000,"status":"ok"}` | About 18:23 (approximate, time given by author). 31 min from first symptom, which includes diagnosis and a detour caused by a wrong example address I gave (10.20.0.55) | `validation-app01-first-response-1752cst.png`, `validation-app01-hosts-file-1756cst.png`, `validation-app01-journal-licence-timeout-1757cst.png`, `validation-app01-old-address-timeout-1757cst.png`, `validation-app01-hosts-fixed-1823cst.png`, `validation-app01-after-hosts-fix-1823cst.png` |
| D-02 | 17:57 | C | The failing call is a licence check that runs on every page load. The licence server (lic01) does not appear in the dependency inventory in `pm-baselines/` | The application depends on lic01 and this dependency is undocumented. A migration plan built from the inventory alone would have left it out of the wave | Yes (seeded 1) | Pending fix of D-01. Confirmed at 18:01 that the lic01 test instance (10.20.0.145) answers on 8080 and `/license` returns `valid:true`, so the dependency itself migrated correctly | | same journal screenshot, plus `source-env-build.md` section 6 checklist, `validation-app01-lic01-licence-ok-1801cst.png` |
| D-03 | 18:35 | D | `SHOW CREATE TABLE audit_log` on db01 shows four columns (`event_time`, `user_id`, `action`, `detail`) and no PRIMARY KEY | Table built without a primary key on purpose in the source. It migrated as it was. Change data capture and many database-level replication tools cannot reliably apply updates or deletes to a table without one | Yes (seeded 2) | Not fixed in this pathfinder. Recorded for the wave plan: add a primary key before any database-level replication, or exclude the table from CDC | n/a | `validation-db01-counts-and-audit-log-1835cst.png` |

## Summary (fill at the end of validation)

- Total found: 3 (D-01 stale hosts-file addresses, D-02 undocumented licence dependency, D-03 audit_log without primary key)
- Seeded found: 3 of 3
- Unplanned: 0 (E-6 allowed one)
- Seeded missed: 0
- E-6 estimate versus actual: 4 estimated, 3 found. Over-estimate by 1; the allowance for an unplanned defect was not used. Row counts matched the source (200000 / 400000 / 300000) and the application returned 200000 patients after D-01 was fixed. D-01 and D-02 were counted separately because their root causes differ (configuration versus documentation), though they showed up together in one failing request.
