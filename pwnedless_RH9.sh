#!/bin/bash
#
# ==============================================================================
# Advanced Hardening Script for Red Hat Enterprise Linux 9
# Based on: CIS Red Hat Enterprise Linux 9 Benchmark v2.0.0
#
# Author: Perplexity AI
# Version: 1.0
# ==============================================================================
#
# ATTENTION:
# 1. THIS SCRIPT PERFORMS SIGNIFICANT CHANGES TO THE SYSTEM CONFIGURATION.
# 2. RUN IT ONLY IN A TEST ENVIRONMENT BEFORE APPLYING TO PRODUCTION.
# 3. MAKE A FULL BACKUP OF YOUR SYSTEM BEFORE PROCEEDING.
# 4. THE AUTHOR IS NOT RESPONSIBLE FOR ANY DAMAGE CAUSED BY THE USE OF THIS SCRIPT.
#
# ==============================================================================

# Global Variables
LOG_FILE="/var/log/hardening-rhel9-cis-$(date +%Y%m%d-%H%M%S).log"
CIS_LEVEL=1

# Function to log messages to console and log file
log_msg() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to create a backup of a configuration file
backup_file() {
    if [ -f "$1" ]; then
        cp "$1" "$1.bak.$(date +%F)"
        log_msg "Backup of file '$1' created at '$1.bak...'"
    fi
}

# --- Section 1: Initial Setup ---
section_1_initial_setup() {
    log_msg "--- [Section 1] Starting Initial Setup ---"

    # CIS 1.1.2 - Ensure separate partitions are used (Manual Action)
    log_msg "[MANUAL WARNING] CIS 1.1.2 to 1.1.21: Verify that /tmp, /var, /var/tmp, /var/log, /var/log/audit, and /home are on separate partitions."
    
    # CIS 1.4.1 - Ensure permissions on bootloader config are correct
    log_msg "[1.4.1] Adjusting GRUB permissions..."
    chown root:root /boot/grub2/grub.cfg
    chmod og-rwx /boot/grub2/grub.cfg
    chown root:root /boot/grub2/user.cfg
    chmod og-rwx /boot/grub2/user.cfg

    log_msg "--- [Section 1] Completed. ---"
}

# --- Section 2: Services ---
section_2_services() {
    log_msg "--- [Section 2] Hardening Services ---"

    # CIS 2.3 - Disable unused network services
    log_msg "[2.3] Disabling legacy services (xinetd, etc)..."
    dnf remove -y xinetd &>> "$LOG_FILE"

    log_msg "--- [Section 2] Completed. ---"
}

# --- Section 3: Network Configuration ---
section_3_network_config() {
    log_msg "--- [Section 3] Network Configuration ---"
    
    # CIS 3.2.1 and 3.2.2 - Ensure packet forwarding and router advertisements are disabled
    log_msg "[3.2.1, 3.2.2] Disabling packet forwarding..."
    sysctl -w net.ipv4.ip_forward=0 &>> "$LOG_FILE"
    sysctl -w net.ipv4.conf.all.send_redirects=0 &>> "$LOG_FILE"
    sysctl -w net.ipv4.conf.default.send_redirects=0 &>> "$LOG_FILE"
    sysctl -p &>> "$LOG_FILE"

    # CIS 3.4.2.1 - Configure firewalld
    log_msg "[3.4.2.1] Enabling and starting firewalld..."
    systemctl enable --now firewalld &>> "$LOG_FILE"

    log_msg "--- [Section 3] Completed. ---"
}

# --- Section 4: Logging and Auditing ---
section_4_logging_audit() {
    log_msg "--- [Section 4] Configuring Logging and Auditing ---"

    # CIS 4.1 - Configure auditd
    log_msg "[4.1] Installing and enabling audit service (auditd)..."
    dnf install -y audit &>> "$LOG_FILE"
    systemctl enable --now auditd &>> "$LOG_FILE"

    log_msg "[MANUAL WARNING] CIS 4.1.1.1: Add 'audit=1' to kernel boot parameters to enable auditing at boot."
    
    # CIS 4.1.2 - Audit rule configuration
    log_msg "[4.1.2] Configuring CIS audit rules..."
    AUDIT_RULES_FILE="/etc/audit/rules.d/50-cis.rules"
    backup_file "$AUDIT_RULES_FILE"
    cat > "$AUDIT_RULES_FILE" <<EOF
# Audit rules based on CIS RHEL 9 Benchmark v2.0.0

# 4.1.2.1 - Audit Information
-w /etc/group -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity

# 4.1.2.2 - Login and Logout Events
-w /var/log/lastlog -p wa -k logins
-w /var/run/faillock/ -p wa -k logins

# 4.1.2.5 - Administrative Actions
-w /etc/sudoers -p wa -k scope
-w /etc/sudoers.d/ -p wa -k scope
EOF

    if [ "$CIS_LEVEL" -eq 2 ]; then
        log_msg "[LEVEL 2] CIS 4.1.2.7: Making audit configuration immutable..."
        echo "-e 2" >> "$AUDIT_RULES_FILE"
    else
        echo "-e 1" >> "$AUDIT_RULES_FILE"
    fi
    
    # Reload audit rules
    augenrules --load &>> "$LOG_FILE"

    log_msg "--- [Section 4] Completed. ---"
}

# --- Section 5: Access, Authentication, and Authorization Control ---
section_5_access_auth() {
    log_msg "--- [Section 5] Access, Authentication, and Authorization Control ---"
    
    SSHD_CONFIG="/etc/ssh/sshd_config"
    log_msg "[5.2] Hardening SSH service..."
    backup_file "$SSHD_CONFIG"

    # CIS 5.2.2 - Configure SSH Protocol to 2
    sed -i -E 's/^#?Protocol.*/Protocol 2/' "$SSHD_CONFIG"
    # CIS 5.2.5 - Configure LogLevel to VERBOSE
    sed -i -E 's/^#?LogLevel.*/LogLevel VERBOSE/' "$SSHD_CONFIG"
    # CIS 5.2.6 - Limit authentication attempts
    sed -i -E 's/^#?MaxAuthTries.*/MaxAuthTries 4/' "$SSHD_CONFIG"
    # CIS 5.2.11 - Disable root login
    sed -i -E 's/^#?PermitRootLogin.*/PermitRootLogin no/' "$SSHD_CONFIG"
    # CIS 5.2.14 - Configure warning banner
    echo "Banner /etc/issue.net" >> "$SSHD_CONFIG"
    echo "This system is monitored. Unauthorized access is prohibited." > /etc/issue.net

    if [ "$CIS_LEVEL" -eq 2 ]; then
        log_msg "[LEVEL 2] CIS 5.2.7: Allow only strong ciphers..."
        echo "Ciphers aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr" >> "$SSHD_CONFIG"
        echo "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256" >> "$SSHD_CONFIG"
    fi

    # Restart SSH to apply changes
    systemctl restart sshd
    log_msg "SSH service restarted with new configuration."

    # CIS 5.3 - Configure sudo
    log_msg "[5.3] Configuring sudo..."
    echo "Defaults use_pty" > /etc/sudoers.d/99-cis-pty
    echo "Defaults logfile=/var/log/sudo.log" > /etc/sudoers.d/99-cis-logfile

    log_msg "--- [Section 5] Completed. ---"
}

# --- Main Function ---
main() {
    log_msg "Starting Pwnedless-NG RHEL 9 hardening script..."
    
    section_1_initial_setup
    section_2_services
    section_3_network_config
    section_4_logging_audit
    section_5_access_auth

    log_msg "--- HARDENING SCRIPT COMPLETED ---"
    log_msg "Full report saved to: $LOG_FILE"
    log_msg "WARNING: IT IS HIGHLY RECOMMENDED TO REBOOT THE SYSTEM to ensure all changes are applied."
}

# --- Script Entry Point ---
clear
echo "==================================================================="
echo "    Pwnedless-NG: RHEL 9 Hardening Script (CIS Benchmark)        "
echo "==================================================================="
echo
echo "This script will apply Center for Internet Security (CIS) best practices"
echo "to your system."
echo

# Check if the script is being run as root
if [[ "$EUID" -ne 0 ]]; then
    echo "[ERROR] This script must be run as root."
    exit 1
fi

# Ask the user which hardening level to apply
read -p "Which CIS hardening level do you want to apply? (1 or 2) [Default: 1]: " level_choice
CIS_LEVEL=${level_choice:-1}

if [[ "$CIS_LEVEL" != "1" && "$CIS_LEVEL" != "2" ]]; then
    log_msg "Invalid level selection. Using Level 1 as default."
    CIS_LEVEL=1
fi
log_msg "Selected hardening level: Level $CIS_LEVEL"

# Final confirmation before execution
echo
echo "ATTENTION: The script is ready to apply CIS Level $CIS_LEVEL hardening configurations."
echo "Ensure you have a system backup."
read -p "Do you wish to continue? (y/n): " confirm
if [[ "$confirm" =~ ^[yY]$ ]]; then
    main
else
    echo "Operation cancelled by user."
fi

exit 0
