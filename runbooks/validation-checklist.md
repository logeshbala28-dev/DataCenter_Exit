# Test launch validation checklist (Wave 1 pathfinder)

Written 2026-11-11 17:30 CST, before the app01 test instance finished launching.
Run in order. Record the clock time at each step. Anything that fails or surprises
goes into `logs/defect-log.md` as it is found, not afterwards. Do not fix anything
until it is logged with its symptom and evidence.

Test instances: lic01 `i-0f20db1ee571ce899` (launched 17:15), db01 `i-0fa7994976ab19a56`
(launched 17:19), app01 (launched about 17:40). Only app01 has a public IP.

## A. Infrastructure checks (AWS console)

- [ ] All three instances Running, status checks passed. Record the time each passed.
- [ ] Private IPs of db01 and lic01 recorded (they will not match 192.168.161.11 / .12)
- [ ] Security groups match the launch settings table in the status log

## B. Application check from the laptop browser

- [ ] `http://<app01 public IP>/` returns the JSON with a patient count
      Expected on the source: JSON response. Record what the test instance returns.
- [ ] Screenshot of the response, whatever it is

## C. On app01 (SSH, `ssh logesh@<app01 public IP>`)

- [ ] `hostname -I` and `cat /etc/hosts` (what addresses does the app use for db01 and lic01?)
- [ ] `systemctl status nginx` and the application service
- [ ] `nc -zv <db01 private IP> 3306` and `nc -zv <lic01 private IP> 8080`
- [ ] `curl -s http://<lic01 private IP>:8080/license`
- [ ] Application log: last 30 lines, looking for the failing call

## D. Through app01 to the other tiers

- [ ] db01: `mysql -h <db01 private IP> -u appuser -p -e "SELECT COUNT(*) FROM <patients table>"`
      Compare the row count with the source value (200000 / 400000 / 300000 across tables)
- [ ] db01: `SHOW CREATE TABLE audit_log\G` (is there a primary key?)
- [ ] lic01: licence endpoint responds with the expected content

## E. Result

- [ ] Count of defects found: ____ (pre-registered estimate E-6 = 4)
- [ ] Time from "first instance Running" to "application passes end to end": ____
- [ ] Decision: ready for cutover rehearsal, or fix and retest
