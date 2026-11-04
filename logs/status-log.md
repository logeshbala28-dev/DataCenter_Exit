# Weekly Status Log

Produced every Monday, before any build work. Append — never edit a past entry.

---

## Week 1 — 2026-09-11

**Phase:** 0 — Pre-flight

**Progress**
- Project initiated. Repository created, first commit made.
- Capstone idea submitted to advisor for confirmation.
- Initial RAID log populated with five situation-specific risks.

**Earned value**

| Metric | Value |
|---|---|
| Planned Value (PV) | baseline not yet set |
| Earned Value (EV) | — |
| Actual Cost (AC) | $0.00 |
| CPI | — |
| SPI | — |
| EAC | — |

EVM reporting begins once the cost baseline is committed in Phase 1.

**Blockers**
- Awaiting advisor confirmation (D-01).

**Schedule buffer**

| | Weeks |
|---|---|
| Available | 2.0 |
| Consumed to date | 0.0 |
| Remaining | 2.0 |

**Next week**
- Complete Phase 0 exit criteria.
- Set cost and schedule baselines.
- Terraform practice build.

---

## Week of 2026-10-29

**Phase:** 3 — Wave 0 landing zone

**Progress**
- AWS access configured through IAM Identity Center. No long-lived access keys.
- Terraform remote state in S3, versioning enabled, public access blocked.
- Wave 0 landing zone applied: 27 resources. All free tier, no cost incurred.
- Environment destroyed and rebuilt from code with no manual steps.
  Charter objective O-2 verified.

**Decisions**
- Identity Center single-Region instance chosen over multi-Region to avoid
  customer-managed KMS key charges. No functional loss for a single-region
  pathfinder.

**Blockers**
- Pre-registration estimates E-1 to E-10 unfilled. Must be committed before
  replication begins.

**Next**
- MGN initialisation and replication template.
- Source environment build on the Windows host.

---

## Week of 2026-11-04

**Phase:** 4 — Wave 1 pathfinder, source environment

**Progress**
- First source build discarded. It ran Ubuntu 26.10, which AWS MGN does not support.
  Rebuilt on Ubuntu Server 24.04.3 LTS, kernel 6.8.0-147, held against updates.
- Three VMs built and loaded: db01 (MySQL, 200000 / 400000 / 300000 rows), lic01
  (licence service), app01 (nginx and Flask app). Fixed addresses through DHCP
  reservations.
- Dependency test repeated: app fails with the licence service stopped, recovers when
  restored.
- E-2 measured: 26,343,444,480 bytes used across the three VMs.
- Pre-registration E-1 to E-10 filled and committed (39d44b4) before any replication.
  E-4 to E-8 drafted with AI assistance and adopted by the author. E-9 and E-10 taken
  from the committed WBS.
- Snapshots `clean-os-24.04.3` and `source-ready` taken on all three VMs.

**Decisions**
- E-3 kept at the value committed on 2026-10-29 (1.5 hours). The recomputed figure from
  measured volume (1.57 hours) is recorded alongside it, not substituted.
- DHCP reservations used instead of static addresses in the guests, so the replicated
  instances get a normal network at cutover.

**Blockers**
- None.

**Next**
- Confirm the commit timestamp on GitHub and add evidence to the repository.
- Rebuild the landing zone, initialise MGN, install the agent on all three VMs.
- Start replication and record the start time.

