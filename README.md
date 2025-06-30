# Pwnedless - Modern Hardening Scripts for Red Hat Enterprise Linux

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## A Project Reborn

After nearly a decade of inactivity, the Pwnedless project has been revitalized. The original goal was to provide simple, effective hardening scripts for Red Hat systems. Now, that goal has been modernized for the current landscape of cybersecurity.

With the assistance of **Perplexity AI**, the original scripts for RHEL 6 and 7 have been evolved into a new, advanced hardening script specifically designed for **Red Hat Enterprise Linux 9**. This update bridges a 9-year gap, bringing the project up to date with the latest security standards recommended by the Center for Internet Security (CIS).

---

## What's New? The RHEL 9 Hardening Script

The new `hardening-rhel9-cis.sh` script is not just an update; it's a complete reimagining of the original concept. It was built from the ground up to be more robust, flexible, and aligned with modern DevOps and security practices.

### Key Features:

*   **CIS Benchmark Alignment**: The script is based on the **CIS Red Hat Enterprise Linux 9 Benchmark v2.0.0**, ensuring that the applied configurations meet industry-standard security guidelines.
*   **Interactive Hardening Levels**: You can choose between applying **Level 1** (recommended baseline) or **Level 2** (for high-security environments) hardening profiles, providing flexibility for different use cases.
*   **Robust and Safe by Design**:
    *   **Automatic Backups**: Automatically creates backups of any configuration file it modifies.
    *   **Detailed Logging**: All actions are logged to a timestamped file in `/var/log/` for complete transparency and easier auditing.
    *   **User Confirmation**: Requires final user confirmation before applying any changes to the system.
*   **Modular and Readable**: The code is organized into clean, commented functions that correspond to different sections of the CIS benchmark, making it easy to understand and customize.
*   **Modern Security Controls**: Implements current best practices, including:
    *   Configuration of `auditd` with detailed rules.
    *   Hardening of the SSH service.
    *   Configuration of `firewalld`.
    *   Secure settings for `sudo`.

---

## Usage

The script is designed to be straightforward to use.

**1. Clone the repository:**
```
git clone https://github.com/jrcarreiro/pwnedless.git
cd pwnedless
```

**2. Run the script with root privileges:**
```
sudo ./hardening-rhel9-cis.sh
```

**3. Follow the on-screen prompts:**
The script will ask you to select a CIS hardening level and will request a final confirmation before making any changes to your system.

---

## ⚠️ Disclaimer

This script performs significant changes to your system's configuration. It is strongly recommended to **run it in a test environment first**. The author and contributors are not responsible for any damage or data loss that may result from its use. **Always back up your system before proceeding.**
