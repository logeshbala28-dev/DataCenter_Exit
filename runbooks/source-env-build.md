# Source Environment Build Guide

The simulated on-premises estate. Three VMs on VMware Workstation, standing in for
the VMware cluster at Meridian Regional Health Partners.

Machine: Windows laptop. This is x86 work and cannot be done on the Mac.

---

## 1. Download

**Ubuntu Server 24.04 LTS**, not desktop. The desktop edition wastes 1 to 2 GB of RAM
per VM on a graphical environment nothing will use.

    https://ubuntu.com/download/server

About 2.5 GB. Start it now, it downloads while you do everything else.

---

## 2. VM specifications

| | App server | Database server | Dependency service |
|---|---|---|---|
| Hostname | `meridian-app01` | `meridian-db01` | `meridian-lic01` |
| RAM | 2048 MB | 2048 MB | 1024 MB |
| CPUs | 2 | 2 | 1 |
| Disk | 20 GB | 25 GB | 15 GB |
| Network | NAT | NAT | NAT |

Total 5 GB of RAM, leaving roughly 11 GB for Windows. Close Chrome before running all
three at once.

**Disk size is not data size.** MGN replicates used blocks, so a 20 GB disk holding
4 GB of data replicates roughly 4 GB. You control replication time by controlling how
much data you write, which is step 5.

### VMware settings that matter

- **Network: NAT.** The VMs need outbound internet for the MGN agent and for package
  installs. Nothing needs to connect inbound to them, so NAT is sufficient and simpler
  than bridged.
- **Disk: single file**, not split. Marginally faster, and simpler to reason about.
- Leave virtualization extensions off. Linux guests do not need them here.
- Take a snapshot of each VM once the application works, before installing the MGN
  agent. If a cutover goes wrong in a way you did not intend, snapshots get you back
  to a known state without rebuilding.

---

## 3. Install Ubuntu Server

Same for all three. Minimal install, no snaps, no desktop.

- Choose **minimized** install when offered
- **Install OpenSSH server** when prompted. You will need it.
- Create user `logesh` with a password you will remember
- Skip every featured snap

After first boot, on each VM:

    sudo apt update && sudo apt upgrade -y
    ip addr                 # note the IP, you will need it
    hostnamectl set-hostname meridian-app01   # adjust per VM

Record each VM's IP. They will be on the VMware NAT subnet, usually 192.168.x.x.

---

## 4. Build the application

A three-tier application where the app tier depends on both the database **and** a
separate service. That third dependency is the point.

### Database server (`meridian-db01`)

    sudo apt install -y mysql-server
    sudo mysql_secure_installation

Allow connections from the app tier:

    sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' \
      /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo systemctl restart mysql

Create the schema:

    sudo mysql <<'SQL'
    CREATE DATABASE meridian;
    CREATE USER 'appuser'@'%' IDENTIFIED BY 'ChangeMe123!';
    GRANT ALL ON meridian.* TO 'appuser'@'%';
    FLUSH PRIVILEGES;

    USE meridian;

    CREATE TABLE patients (
      id INT AUTO_INCREMENT PRIMARY KEY,
      mrn VARCHAR(20),
      name VARCHAR(100),
      dob DATE,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE appointments (
      id INT AUTO_INCREMENT PRIMARY KEY,
      patient_id INT,
      scheduled DATETIME,
      department VARCHAR(50)
    );

    -- Deliberately no primary key. Change data capture cannot reliably
    -- apply updates or deletes to a table without one. This is a seeded
    -- problem that should surface during validation.
    CREATE TABLE audit_log (
      event_time DATETIME,
      user_id INT,
      action VARCHAR(100),
      detail TEXT
    );
    SQL

All data here is fictional. Generate names with a script, do not use anything real.

### Dependency service (`meridian-lic01`)

A small service the application calls on startup. In a real estate this would be a
licence server, an authentication service, or a configuration endpoint. The pattern is
what matters: the application does not work without it, and nobody documented it.

    sudo apt install -y python3-flask

    sudo tee /opt/licsvc.py >/dev/null <<'PY'
    from flask import Flask, jsonify
    app = Flask(__name__)

    @app.route("/license")
    def license():
        return jsonify(valid=True, org="Meridian Regional Health Partners",
                       seats=1800)

    app.run(host="0.0.0.0", port=8080)
    PY

    sudo tee /etc/systemd/system/licsvc.service >/dev/null <<'UNIT'
    [Unit]
    Description=Meridian licence validation service
    After=network.target

    [Service]
    ExecStart=/usr/bin/python3 /opt/licsvc.py
    Restart=always

    [Install]
    WantedBy=multi-user.target
    UNIT

    sudo systemctl enable --now licsvc
    curl localhost:8080/license      # confirm it responds

### Application server (`meridian-app01`)

    sudo apt install -y nginx python3-flask python3-pymysql

Write an application that reads from the database **and** calls the licence service.
The licence call is what makes the dependency real: if `meridian-lic01` is unreachable,
the application must fail rather than degrade quietly.

    sudo tee /opt/app.py >/dev/null <<'PY'
    from flask import Flask, jsonify
    import pymysql, requests, sys

    DB_HOST  = "192.168.X.X"   # meridian-db01
    LIC_HOST = "192.168.Y.Y"   # meridian-lic01

    app = Flask(__name__)

    def check_license():
        r = requests.get(f"http://{LIC_HOST}:8080/license", timeout=3)
        if not r.json().get("valid"):
            sys.exit("Licence validation failed")

    @app.route("/")
    def index():
        check_license()
        c = pymysql.connect(host=DB_HOST, user="appuser",
                            password="ChangeMe123!", database="meridian")
        with c.cursor() as cur:
            cur.execute("SELECT COUNT(*) FROM patients")
            n = cur.fetchone()[0]
        return jsonify(status="ok", patients=n)

    check_license()
    app.run(host="0.0.0.0", port=80)
    PY

Run it as a systemd unit the same way as the licence service.

Test from the Windows host browser: `http://<app-vm-ip>/` should return a JSON
response with a patient count.

---

## 5. Load synthetic data

This controls replication time, so do it deliberately rather than by accident.

Target **8 to 10 GB of actual data per VM**. At a typical residential upload speed that
replicates in roughly an hour each. Larger datasets do not make the measurement more
valid, they just make the week longer.

On the database server, generate records until the data directory reaches target:

    sudo du -sh /var/lib/mysql

On the application server, pad with synthetic document files:

    sudo mkdir -p /var/app/documents
    sudo dd if=/dev/urandom of=/var/app/documents/archive.bin bs=1M count=6000

Use `/dev/urandom` rather than `/dev/zero`. Zeroed files compress to almost nothing,
and MGN compresses in transit, so a zero-filled disk would give you a replication time
that means nothing.

Record the final figure per VM. It is estimate **E-2** in the pre-registration.

---

## 6. Before installing agents

- [ ] All three VMs boot and the application works end to end
- [ ] Snapshot taken of each VM
- [ ] Data volume per VM recorded
- [ ] `audit_log` table exists with no primary key
- [ ] `meridian-lic01` is **absent** from the dependency inventory in `pm-baselines/`
- [ ] Seeding decisions written into the methodology appendix, separate from the
      operational log

That last pair is the whole point. The dependency exists in the environment and not in
the documentation, exactly as it would in a real estate where someone configured it
years ago and left.

---

## Notes for the report

The source environment is a single VMware Workstation host, not a cluster. It does not
reproduce shared storage, high availability, or host failure behaviour. State this in
Chapter 1 under limitations.

The application also has no users during migration. Real cutovers happen against live
systems, which changes both the volume of data to sync at the end and the pressure on
the cutover window. Worth a sentence.
