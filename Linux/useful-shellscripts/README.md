# 🐧 Useful Shell Scripts for Linux

This directory contains a collection of practical and reusable shell scripts designed to help with Linux system administration, monitoring, and troubleshooting. These scripts are aimed at system engineers, SREs, and DevOps professionals who manage Linux servers regularly.

---

## 📁 Folder Structure

Linux/
└── useful-shellscripts/
├── system-health-check.sh
└── (more scripts to be added...)



---

## 📜 Available Scripts

### 1. `system-health-check.sh`

A comprehensive health-check script that provides a detailed summary of the system’s current status, including:

- ✅ OS and kernel info  
- ✅ CPU uptime and usage  
- ✅ Memory consumption  
- ✅ Disk and inode usage  
- ✅ Top CPU & memory processes  
- ✅ Recent failed services (last 1 hour)  
- ✅ OS patch/update availability (supports apt, yum, dnf)

#### 🔧 How to Use:
```bash
chmod +x system-health-check.sh
./system-health-check.sh



🛠️ Planned Additions
Service uptime tracker

Log analysis utilities

Network diagnostics

Resource alert scripts

Cleanup/maintenance utilities

📢 Contributions
Pull requests and suggestions are welcome! If you have useful one-liners or shell utilities you'd like to share, feel free to open an issue or PR.

⚠️ Disclaimer
These scripts are intended for internal or test environments. Use with caution on production systems and always review code before execution.