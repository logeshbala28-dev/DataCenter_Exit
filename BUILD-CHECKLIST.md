# Pathfinder Build Checklist

Tick each box as you complete it. Boxes render as checkboxes on GitHub and in VS Code.

Anything already done, tick and move on. Anything you are unsure about, the
verification command is given so you can check rather than guess.

---

## Stage 0 — Confirm what already exists

Run these and tick based on what comes back.

```bash
cd ~/Documents/Datacenter_Exit
git log --oneline
find . -type f -not -path './.git/*' | sort
```

- [ ] Repo exists locally and has at least one commit
- [ ] Repo is pushed to GitHub (`git status` shows nothing to push)
- [ ] `pm-baselines/project-charter.md` exists and is committed
- [ ] `pm-baselines/wbs.md` exists and is committed
- [ ] `logs/raid-log.md` exists
- [ ] `decision-records/ADR-001-source-environment.md` exists

**If any are missing:** that is fine, add them now. The charter and WBS were
delivered in earlier sessions. Commit whatever is missing before continuing.

---

## Stage 1 — Cost guardrails

Do these before any resource exists. This is the control that keeps the project
affordable, and it is much easier to set up now than after a surprise bill.

- [ ] Opened Cost Explorer and checked the last 3 months for anything already running
- [ ] Deleted or noted anything unexpected
- [ ] Created an AWS Budget with alerts at **$5**, **$15** and **$30**
- [ ] Alert email is one you actually read
- [ ] Recorded the budget thresholds in `logs/cost-log.md`

Verify no instances are running anywhere:

```bash
for r in us-east-1 us-west-2 eu-west-1; do
  echo "== $r"; aws ec2 describe-instances --region $r \
    --query 'Reservations[].Instances[?State.Name==`running`].InstanceId' --output text
done
```

- [ ] No unexpected running instances

---

## Stage 2 — Credentials

- [ ] Ran `aws configure list` and checked what is behind the profile
- [ ] If it shows a long-lived access key: switched to IAM Identity Center (`aws configure sso`)
- [ ] `aws sts get-caller-identity` returns your account without error

The charter states "no long-lived access keys" as a non-functional requirement.
The MGN agent install is the one justified exception, because it needs credentials
at install time. Record that as a time-boxed exception in a decision record and
delete the credential afterwards.

- [ ] Noted the MGN credential exception in `decision-records/`

---

## Stage 3 — Measurements taken BEFORE building

These have to exist before anything is created, or the comparison the whole
project rests on is invalid.

- [ ] Ran a speed test and recorded the **upload** figure (not download)
- [ ] Decided data volume per VM (**8-10 GB recommended**, keeps replication to about an hour each)
- [ ] Filled in **every blank** in `pm-baselines/pre-registration.md` (E-1 through E-10)
- [ ] Three-point estimates recorded per WBS work package
- [ ] Cost baseline recorded per WBS work package
- [ ] Ran the Monte Carlo script and recorded the P80 date
- [ ] Documented the Monte Carlo assumptions, inputs and limitations (advisor point 3)

Commit all of it together, before any `terraform apply`:

```bash
git add pm-baselines/
git commit -m "Pre-registration and baselines, committed before pathfinder execution"
git push
```

- [ ] **Committed and pushed.** Check the commit timestamp on GitHub. That timestamp
      is what proves the estimates preceded the measurements.

> Stop here if this stage is incomplete. Everything downstream depends on it, and
> it cannot be reconstructed afterwards.

---

## Stage 4 — Terraform state backend

The state bucket has to exist before Terraform can manage anything else. Create it
by hand, once. Pick a globally unique name.

```bash
BUCKET=dc-exit-tfstate-logesh-$(date +%s)
aws s3api create-bucket --bucket $BUCKET --region us-east-1
aws s3api put-bucket-versioning --bucket $BUCKET \
  --versioning-configuration Status=Enabled
aws s3api put-public-access-block --bucket $BUCKET \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
echo "bucket: $BUCKET"
```

- [ ] Bucket created, versioning on, public access blocked
- [ ] Bucket name written down

Create `infrastructure/wave0/backend.hcl` (gitignored):

```hcl
bucket       = "YOUR-BUCKET-NAME-HERE"
key          = "wave0/terraform.tfstate"
region       = "us-east-1"
encrypt      = true
use_lockfile = true
```

- [ ] `backend.hcl` created
- [ ] Wrote `ADR-004` explaining the bootstrapping problem and why the bucket sits
      outside managed configuration

---

## Stage 5 — Landing zone

```bash
cd ~/Documents/Datacenter_Exit/infrastructure/wave0
cp terraform.tfvars.example terraform.tfvars
curl -s https://checkip.amazonaws.com    # your public IP
# edit terraform.tfvars, put that IP with /32 into both fields
```

- [ ] `terraform.tfvars` filled in with your real public IP

```bash
terraform init -backend-config=backend.hcl
terraform fmt -check
terraform validate
terraform plan -out=wave0.tfplan
```

- [ ] `init` succeeded
- [ ] `validate` passed
- [ ] **Read the plan output.** Confirm it creates and destroys nothing unexpected.

```bash
terraform apply wave0.tfplan
terraform output
```

- [ ] Applied without error
- [ ] Recorded the outputs, especially `mgn_staging_subnet_id` and `mgn_staging_sg_id`
- [ ] Saved the plan and apply output into `evidence/week-XX/`
- [ ] Committed the Terraform and the outputs

Then prove it is reproducible, which is charter objective O-2:

```bash
terraform destroy
terraform apply -auto-approve
```

- [ ] Destroyed and rebuilt from code with no manual steps. **O-2 satisfied.**

> Your home IP may change. If replication later fails to connect, re-check
> `curl -s https://checkip.amazonaws.com` and update `terraform.tfvars`.

---

## Stage 6 — Source environment

- [ ] Three VMs built on the local hypervisor
  - [ ] Application server (2 GB RAM)
  - [ ] Database server (2 GB RAM)
  - [ ] Supporting dependency service (1 GB RAM)
- [ ] Linux server editions, no desktop
- [ ] Application installed and working end to end on the source
- [ ] Synthetic data loaded to the planned volume (8-10 GB per VM)
- [ ] Database contains **one table with no primary key** (seeded CDC problem)
- [ ] Application calls the dependency service, and that dependency is **absent**
      from the inventory in `pm-baselines/` (seeded discovery gap)
- [ ] Seeding decisions recorded in a methodology appendix, kept separate from
      the operational log

---

## Stage 7 — Replication

- [ ] MGN initialised in the console, replication template pointed at
      `mgn_staging_subnet_id` and `mgn_staging_sg_id`
- [ ] Agent installed on all three source VMs
- [ ] Laptop set to never sleep, plugged in
- [ ] **Replication started, and the start time written down**
- [ ] Walked away

Next morning:

- [ ] Initial sync complete on all three
- [ ] **Measured throughput recorded** (Mbps) — this is the single most important
      number in the project
- [ ] Actual duration recorded against estimate E-3
- [ ] Console screenshots filed in `evidence/`
- [ ] **P-1 marked confirmed or contradicted** in `reports/prediction-outcomes.md`

---

## Stage 8 — Test launch and validation

- [ ] Test instances launched (replication keeps running, do not stop it)
- [ ] Application tested end to end
- [ ] Defects logged with severity and time to fix
- [ ] Did the missing dependency surface? **Mark P-2** confirmed or contradicted
- [ ] Issue raised in `logs/raid-log.md` with discovery timestamp
- [ ] Impact assessed, change request raised, decision recorded
- [ ] Test instances terminated after each validation cycle

---

## Stage 9 — Cutover sequence

Write both documents **before** executing anything:

- [ ] `runbooks/cutover-runbook.md` — minute by minute, with owner, duration and
      validation step for each action
- [ ] `runbooks/rollback-plan.md` — including an explicit **rollback decision point**:
      a time by which, if criteria are unmet, you roll back regardless
- [ ] Go-live criteria written down before starting

**Attempt 1, deliberately failed:**

- [ ] DNS TTL left long on purpose
- [ ] Cutover executed, split-brain condition observed and evidenced
- [ ] Rollback executed and **timed**
- [ ] Rollback duration recorded against estimate E-7
- [ ] **P-4 marked** — did the rollback plan have gaps?
- [ ] Post-incident review written: cause, corrective action, lessons learned

**Attempt 2, corrected:**

- [ ] Runbook updated from what attempt 1 taught you
- [ ] TTL reduced at least 48 hours ahead
- [ ] Cutover executed successfully
- [ ] Cutover duration and downtime recorded against E-4 and E-5
- [ ] MGN cutover finalised, **staging resources confirmed deleted**

---

## Stage 10 — Analysis

- [ ] Cost pulled from Cost Explorer by WBS tag
- [ ] Actual against estimate per work package
- [ ] Three biggest variances root-caused to the **assumption** that was wrong,
      not the tool
- [ ] Waves 2 to 6 re-estimated from measured data
- [ ] Monte Carlo re-run with measured values, distributions compared
- [ ] Earned value computed: CPI, SPI, EAC, VAC
- [ ] Risk register updated with what actually happened
- [ ] `reports/prediction-outcomes.md` complete, all four predictions marked

---

## Every session

- [ ] `git pull` before starting
- [ ] `git push` before stopping
- [ ] Log entries dated the day the event happened, not the day written up

## Every Friday

- [ ] `terraform destroy` on anything not needed over the weekend
- [ ] No running instances, gateways, load balancers or unattached IPs
- [ ] All regions checked, including any touched briefly
- [ ] Cost screenshot filed, week's spend recorded against baseline

---

## The three things that cannot be fixed later

1. **Baselines committed before building.** Without the timestamp, no variance
   analysis is credible.
2. **Measurements recorded as they happen.** Reconstructed numbers are not data.
3. **Predictions pre-registered.** Written afterwards, they prove nothing.

Everything else on this list can be redone if it goes wrong.
