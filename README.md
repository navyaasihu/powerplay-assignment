# DevOps Intern Assignment — PowerPlay

**Candidate:** Navya Srivastava

This repository contains all files, scripts, and documentation used to complete the PowerPlay DevOps Engineering intern assignment. It also documents the commands I ran, verification steps, and the screenshots to include in the submission.

---

## Project Structure

```
repo-root/
├─ README.md                      
├─ scripts/
│  ├─ system_report.sh           
├─ systemd/
│  ├─ system_report.service
│  ├─ system_report.timer
├─ screenshots/                                
```


---

## Summary of Work Completed

1. **Environment & user setup**

   * Launched `t2.micro` Ubuntu EC2 instance (name: `devops-intern`).
   * Created user `devops_intern` with passwordless sudo.
   * Set hostname to `navya-devops`.

2. **Web server**

   * Installed `nginx` and created `/var/www/html/index.html` containing candidate name, instance ID and uptime.

3. **Monitoring script**

   * Implemented `/usr/local/bin/system_report.sh` which collects timestamp, uptime, CPU, memory, disk usage and top CPU processes.
   * Log file: `/var/log/system_report.log`.
   * Replaced cron with a systemd timer: `system_report.service` + `system_report.timer` (runs every 5 minutes).

4. **CloudWatch integration**

   * Installed Amazon CloudWatch Agent and configured it to ship `/var/log/system_report.log` to CloudWatch Log Group `/devops/intern-metrics` (log stream = instance id).
   * Verified logs in CloudWatch Console.
  

5. **AWS CLI upload**

   * Demonstrated how to push `/var/log/system_report.log` to CloudWatch using `aws logs put-log-events` (CLI).

---

## Important Files & Commands

### Scripts (copy these into `/usr/local/bin`)

* `system_report.sh` — monitoring script (must be executable)

### Systemd units

* `system_report.service` and `system_report.timer` — run system_report every 5m

### Key commands run on the EC2 instance (examples to reproduce)

**Install packages & update**

```bash
sudo apt update
sudo apt install -y nginx sysstat mailutils python3-pip
```

**Make scripts & services executable & enable timers**

```bash
sudo chmod +x /usr/local/bin/system_report.sh 
sudo systemctl daemon-reload
sudo systemctl enable --now system_report.timer

**AWS CLI: create log group / stream and upload **

```bash
aws logs create-log-group --log-group-name "/devops/intern-metrics"

aws logs create-log-stream \ --log-group-name "/devops/intern-metrics" \ --log-stream-name "cli-upload"

LOG_DATA=$(sed ':a;N;$!ba;s/\n/ /g' /var/log/system_report.log)

aws logs put-log-events \
  --log-group-name "/devops/intern-metrics" \
  --log-stream-name "cli-upload" \
  --log-events "[{\"timestamp\": $(date +%s000), \"message\": \"$LOG_DATA\"}]"
  
```
# create valid JSON events file (python method) and upload as described in the repo
```

---

## Screenshots 

Place screenshots under `/screenshots`.

---

## How to proceed

1. Launch Ubuntu EC2 (t2.micro) in `ap-south-1`.
2. Attach IAM role `EC2-CloudWatch-Agent-Role` with policies: `CloudWatchAgentServerPolicy` and `AmazonSSMManagedInstanceCore`.
3. SSH into instance and run the commands from **Key commands** section.
4. Verify nginx page, system_report log, systemd timers, CloudWatch logs, and mail alerts.


---


