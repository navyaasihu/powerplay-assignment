# DevOps Intern Assignment — PowerPlay

**Candidate:** Navya Srivastava

This repository contains all files, scripts, and documentation used to complete the PowerPlay DevOps Engineering intern assignment. 

---

## Project Structure

```
repo-root/
├─ README.md                      
├─ scripts/
│  ├─ system_report.sh            
│  ├─ disk_alert.sh               
├─ systemd/
│  ├─ system_report.service
│  ├─ system_report.timer
│  ├─ disk_alert.service
│  ├─ disk_alert.timer
├─ cloudwatch/
│  ├─ amazon-cloudwatch-agent.json
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

5. **Bonus — Disk alert**

   * Implemented `/usr/local/bin/disk_alert.sh` and a systemd timer `disk_alert.timer` to run every 10 minutes.
   * Sends email using `mail` (mailutils) when disk usage > 80%.
   * (Alternative recommended approach: SNS or SES — instructions included in comments of `disk_alert.sh`.)

6. **AWS CLI upload (additional deliverable)**

   * Demonstrated how to push `/var/log/system_report.log` to CloudWatch using `aws logs put-log-events` (CLI). A safe JSON upload process was used to avoid invalid JSON errors.

---

## Important Files & Commands

### Scripts (copy these into `/usr/local/bin`)

* `system_report.sh` — monitoring script (must be executable)

### Systemd units

* `system_report.service` and `system_report.timer` — run system_report every 5m

### Key commands run on the EC2 instance 

**Install packages & update**

```bash
sudo apt update
sudo apt install -y nginx sysstat mailutils python3-pip
```

**Make scripts & services executable & enable timers**

```bash
sudo chmod +x /usr/local/bin/system_report.sh /usr/local/bin/disk_alert.sh
sudo systemctl daemon-reload
sudo systemctl enable system_report.timer
```

**CloudWatch Agent (install & start)**

```bash
cd /tmp
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i amazon-cloudwatch-agent.deb
sudo vim /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json 
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
sudo systemctl enable amazon-cloudwatch-agent
```

**AWS CLI: create log group upload**

```bash
aws logs create-log-group --log-group-name "/devops/intern-metrics" || true
aws logs create-log-stream --log-group-name "/devops/intern-metrics" --log-stream-name "cli-upload" || true
# create valid JSON events file (python method) and upload as described in the repo
```

---


## How to start

1. Launch Ubuntu EC2 (t2.micro) in `ap-south-1`.
2. Attach IAM role `EC2-CloudWatch-Agent-Role` with policies: `CloudWatchAgentServerPolicy` and `AmazonSSMManagedInstanceCore`.
3. SSH into instance and run the commands from **Key commands** section.
4. Verify nginx page, system_report log, systemd timers, CloudWatch logs, and mail alerts.

---



