# Working across two machines

Windows laptop and MacBook. Which machine does what, and the rules that stop them
from fighting each other.

---

## Division of work

| Work | Machine | Reason |
|---|---|---|
| Writing, documents, baselines | Mac | Cross-platform |
| Terraform | **Mac only** | See below |
| AWS console and CLI | Either | Web and cross-platform |
| VMware, the three source VMs | **Windows only** | x86. Apple Silicon cannot run x86 guests. |
| MGN agents, starting replication | **Windows** | Agents run inside the source VMs |
| Evidence from the source side | **Windows**, committed from Windows | Screenshots and logs originate there |
| Analysis, scripts, report | Mac | |

---

## Terraform runs from the Mac only

Two files are gitignored and therefore do not sync between machines:

- `infrastructure/wave0/backend.hcl`
- `infrastructure/wave0/terraform.tfvars`

Maintaining both in two places means they drift, and a drifted tfvars means the
security group stops matching your real IP. Pick one machine and stay there.

State itself is shared because it lives in S3. That is the whole reason for using a
remote backend rather than local state.

---

## One-time setup on each machine

Mac:

    git config --global user.name "Logesh Balakrishnan"
    git config --global user.email "logeshbala28@gmail.com"
    git config --global core.autocrlf input

Windows:

    git config --global user.name "Logesh Balakrishnan"
    git config --global user.email "logeshbala28@gmail.com"
    git config --global core.autocrlf true

The autocrlf values differ on purpose. Windows ends lines with CRLF, Mac with LF.
Without these settings every commit shows every line of every file as changed, which
makes the commit history unreadable. The history is evidence, so this matters.

---

## Every session, both machines

    git pull        # first thing, before touching anything
    ... work ...
    git add .
    git commit -m "..."
    git push        # before closing the laptop

Forget the pull once and you get a merge conflict. Resolving one under deadline
pressure is miserable. This is tracked in the RAID log as a dependency.

---

## Replication night

Replication runs on the Windows laptop, unattended, for hours.

Before starting:

- Settings, System, Power
- Screen and sleep both set to **Never**, on battery and plugged in
- Laptop actually plugged in
- Wi-Fi set not to disconnect when idle

If the machine sleeps, replication stops. MGN reports it as an error rather than
silently resuming, so you lose the run and the timing measurement with it.

While it runs, work on the Mac. Chapter 2 needs 8 to 10 more sources read and
synthesised, and those hours are the natural place to do it.

---

## Recording the replication measurement

The throughput figure is the single most important number in this project and it
originates on the Windows side.

- Note the start time before walking away
- Note the finish time and the throughput from the MGN console in the morning
- Screenshot the console with a visible timestamp
- Commit both from Windows, the same morning, so the commit date matches the event

Do not write it down later from memory. The whole argument of the project rests on
measurements being recorded as they happen.
