#!/bin/bash
##############################################
#   					     #
#    	Script for  hardening		     #
#    	S.O (RedHat/CentOS		     #
#					     #
##############################################
echo "##############################################"
echo "###	installing pre requirements	 ###"
echo "##############################################"
yum install yum-plugin-security yum-utils ed sysstat -y


echo "##############################################"
echo "###         Secure Boot Settings           ###"
echo "##############################################"
sleep 2
echo "Set User/Group Owner on /etc/grub.conf"
stat -L -c "%u %g" /etc/grub.conf | egrep "0 0" > /dev/null
permission=`echo $?`
	if test $permission = 0
		then
			echo "Permission OK"
		else
			chown root:root /etc/grub.conf
			echo "Permissions wrong, but it was corrected"
	fi

echo ""
echo "Set Permissions on /etc/grub.conf"
stat -L -c "%a" /etc/grub.conf | egrep ".00" > /dev/null
permission=`echo $?`
	if test $permission = 0
		then
			echo "Permission OK"
		else
			chmod og-rwx /etc/grub.conf
			echo "Permissions wrong, but it was corrected"
	fi
echo ""

echo "##############################################"
echo "###     Additional Process Hardening       ###"
echo "##############################################"

echo "Create a copy of file"
ls -l /etc/security/limits.conf.original > /dev/null 2> /dev/null
existe=`echo $?`
	if test $existe = 0
		then
			echo "The file already exists"
		else
			cp /etc/security/limits.conf{,.original}
			echo "Created file"
	fi

ls -l /etc/sysctl.conf.original > /dev/null 2> /dev/null
existe=`echo $?`
	if test $existe = 0
		then
			echo "The file already exists"
		else
			cp /etc/sysctl.conf{,.original}
			echo "Created file"
	fi
sleep 2
echo "##############################################" >> /etc/security/limits.conf
echo "###      Security Changes           ###" >> /etc/security/limits.conf
echo "##############################################" >> /etc/security/limits.conf
echo ""
echo "##############################################" >> /etc/sysctl.conf
echo "###       Security Changes          ###" >> /etc/sysctl.conf
echo "##############################################" >> /etc/sysctl.conf
echo ""

echo "Restrict Core Dumps"
sleep 2
grep "hard core" /etc/security/limits.conf > /dev/null
valida_limits=`echo $?`
par_limits="hard core 0"

	if test $valida_limits = 0
		then
			echo "The parameter is already set"
		else
			echo "The parameter '$par_limits' configured in limits.conf"
			echo $par_limits >> /etc/security/limits.conf
	fi
echo "Configurando suid_dumpable"
sleep 2
valida_sysctl=`sysctl fs.suid_dumpable | awk '{print $3}'`
par_sysctl="fs.suid_dumpable = 0"

    if test $valida_sysctl = 0
            then
                echo "The parameter is already set"
            else
                sysctl -w fs.suid_dumpable=0
				echo "The parameter '$par_sysctl' configured in sysctl.conf"
				echo $par_sysctl >> /etc/sysctl.conf
				echo ""
	fi

echo "Configure ExecShield"
sleep 2
valida_sysctl=`sysctl kernel.exec-shield | awk '{print $3}'`
par_sysctl="kernel.exec-shield = 1"

    if test $valida_sysctl = 1
            then
                echo "The parameter is already set"
            else
                sysctl -w sysctl kernel.exec-shield=1
				echo "The parameter '$par_sysctl' configured in sysctl.conf"
				echo $par_sysctl >> /etc/sysctl.conf
				echo ""
	fi

echo "Enable Randomized Virtual Memory Region Placement"
sleep 2
valida_sysctl=`sysctl kernel.randomize_va_space | awk '{print $3}'`
par_sysctl="kernel.randomize_va_space = 2"

    if test $valida_sysctl = 2
            then
                echo "The parameter is already set"
            else
                sysctl -w kernel.randomize_va_space=2
				echo "The parameter '$par_sysctl' configured in sysctl.conf"
				echo $par_sysctl >> /etc/sysctl.conf
				echo ""
	fi


echo "##############################################"
echo "###       Remove Legacy Services           ###"
echo "##############################################"
echo ""
echo ""
echo "##############################################"
echo "###    Create a list of the software       ###"
echo "###    to be uninstalled within            ###"
echo "###	 /tmp/soft.lst         		 ###"
echo "##############################################"



for soft in $(cat /tmp/soft.lst);
    do
        yum info $soft | grep installed > /dev/null
        install=`echo $?`
            if test $install = 0
                then
                    yum remove $soft -y > /dev/null
                        echo "'$soft' removed"
                else
                    echo "'$soft' not installed"
            fi

done


echo "Configure Network Time Protocol (NTP)"
echo "*/5 * * * * root /usr/sbin/ntpdate a.ntp.br 1> /dev/null 2> /dev/null" >  /etc/cron.d/ntpdate


echo "##############################################"
echo "###         Logging and Auditing           ###"
echo "##############################################"

echo "Install the rsyslog package"
yum info rsyslog | grep installed > /dev/null
        install=`echo $?`
            if test $install = 1
                then
                    yum install rsyslog -y > /dev/null
                        echo "The rsyslog was installed"
                else
                    echo "The rsyslog is installed"
            fi


echo "Enable Auditing for Processes That Start Prior to auditd"
sleep 2
ed /etc/grub.conf << END
g/audit=1/s///g
g/kernel/s/$/ audit=1/
w
q
END

echo "Creating security copies of audit.rules"
sleep 2
ls -l /etc/audit/audit.rules.original > /dev/null 2> /dev/null
existe=`echo $?`
	if test $existe = 0
		then
			echo "The file already exists"
		else
			cp /etc/audit/audit.rules{,.original}
			echo "Created file"
	fi

echo "##############################################" >> /etc/audit/audit.rules
echo "###       Security Changes          ###" >> /etc/audit/audit.rules
echo "##############################################" >> /etc/audit/audit.rules
echo ""
echo "Record Events That Modify Date and Time Information"
sleep 2
echo "#Record Events That Modify Date and Time Information" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -S clock_settime -k time-change" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b32 -S clock_settime -k time-change" >> /etc/audit/audit.rules
echo "-w /etc/localtime -p wa -k time-change" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "Record Events That Modify User/Group Information"
sleep 2
echo "#Record Events That Modify User/Group Information" >> /etc/audit/audit.rules
echo "-w /etc/group -p wa -k identity" >> /etc/audit/audit.rules
echo "-w /etc/passwd -p wa -k identity" >> /etc/audit/audit.rules
echo "-w /etc/gshadow -p wa -k identity" >> /etc/audit/audit.rules
echo "-w /etc/shadow -p wa -k identity" >> /etc/audit/audit.rules
echo "-w /etc/security/opasswd -p wa -k identity" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "Record Events That Modify the System's Network Environment"
sleep 2
echo "#Record Events That Modify the System's Network Environment" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale" >> /etc/audit/audit.rules
echo "-w /etc/issue -p wa -k system-locale" >> /etc/audit/audit.rules
echo "-w /etc/issue.net -p wa -k system-locale" >> /etc/audit/audit.rules
echo "-w /etc/hosts -p wa -k system-locale" >> /etc/audit/audit.rules
echo "-w /etc/sysconfig/network -p wa -k system-locale " >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "Record Events That Modify the System's Mandatory Access Controls"
sleep 2
echo "#Record Events That Modify the System's Mandatory Access Controls" >> /etc/audit/audit.rules
echo "-w /etc/selinux/ -p wa -k MAC-policy" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "Collect Login and Logout Events"
sleep 2
echo "#Collect Login and Logout Events" >> /etc/audit/audit.rules
echo "-w /var/log/faillog -p wa -k logins" >> /etc/audit/audit.rules
echo "-w /var/log/lastlog -p wa -k logins" >> /etc/audit/audit.rules
echo "-w /var/log/tallylog -p wa -k logins" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "Collect Session Initiation Information"
sleep 2
echo "#Collect Session Initiation Information" >> /etc/audit/audit.rules
echo "-w /var/run/utmp -p wa -k session"  >> /etc/audit/audit.rules
echo "-w /var/log/wtmp -p wa -k " >> /etc/audit/audit.rules
echo "-w /var/log/btmp -p wa -k session" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "Collect Discretionary Access Control Permission Modification Events"
sleep 2
echo "#Collect Discretionary Access Control Permission Modification Events" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=500 -F auid!=4294967295 -k perm_mod" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=500 -F auid!=4294967295 -k perm_mod" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=500 -F auid!=4294967295 -k perm_mod" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=500 -F auid!=4294967295 -k perm_mod" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=500 -F auid!=4294967295 -k perm_mod" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=500 -F auid!=4294967295 -k perm_mod" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "Collect Unsuccessful Unauthorized Access Attempts to Files"
sleep 2
echo "#Collect Unsuccessful Unauthorized Access Attempts to Files" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=500 -F auid!=4294967295 -k access" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=500 -F auid!=4294967295 -k access" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=500 -F auid!=4294967295 -k access" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=500 -F auid!=4294967295 -k access" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "Collect Use of Privileged Commands"
sleep 2
echo "#Collect Use of Privileged Commands" >> /etc/audit/audit.rules
echo "find PART -xdev \( -perm -4000 -o -perm -2000 \) -type f | awk '{print \""-a always,exit -F path=\"" \$1 \"" -F perm=x -F "auid>=500" -F auid!=4294967295 -k privileged\"" }'" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "Collect Successful File System Mounts"
sleep 2
echo "#Collect Successful File System Mounts" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -S mount -F auid>=500 -F auid!=4294967295 -k mounts" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b32 -S mount -F auid>=500 -F auid!=4294967295 -k mounts" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "Collect File Deletion Events by User"
sleep 2
echo "#Collect File Deletion Events by User" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=500 -F auid!=4294967295 -k delete" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=500 -F auid!=4294967295 -k delete" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "Collect Changes to System Administration Scope"
sleep 2
echo "#Collect Changes to System Administration Scope" >> /etc/audit/audit.rules
echo "-w /etc/sudoers -p wa -k scope" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "Collect System Administrator Actions"
sleep 2
echo "#Collect System Administrator Actions" >> /etc/audit/audit.rules
echo "-w /var/log/sudo.log -p wa -k actions" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "Collect Kernel Module Loading and Unloading"
sleep 2
echo "#Collect Kernel Module Loading and Unloading" >> /etc/audit/audit.rules
echo "-w /sbin/insmod -p x -k modules" >> /etc/audit/audit.rules
echo "-w /sbin/rmmod -p x -k modules" >> /etc/audit/audit.rules
echo "-w /sbin/modprobe -p x -k modules" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -S init_module -S delete_module -k modules" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "#Audit the audit logs" >> /etc/audit/audit.rules
sleep 2
echo "-w /var/log/audit/ -k auditlog" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "# Modifications to audit configuration that occur while the audit (check your paths)" >> /etc/audit/audit.rules
sleep 2
echo "-w /etc/audit/ -p wa -k auditconfig" >> /etc/audit/audit.rules
echo "-w /etc/libaudit.conf -p wa -k auditconfig" >> /etc/audit/audit.rules
echo "-w /etc/audisp/ -p wa -k audispconfig" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "# Monitor for use of audit management tools" >> /etc/audit/audit.rules
sleep 2
echo "# Check your paths" >> /etc/audit/audit.rules
echo "-w /sbin/auditctl -p x -k audittools" >> /etc/audit/audit.rules
echo "-w /sbin/auditd -p x -k audittools" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "# Special files" >> /etc/audit/audit.rules
sleep 2
echo "-a exit,always -F arch=b32 -S mknod -S mknodat -k specialfiles" >> /etc/audit/audit.rules
echo "-a exit,always -F arch=b64 -S mknod -S mknodat -k specialfiles" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "# Mount operations" >> /etc/audit/audit.rules
sleep 2
echo "-a exit,always -F arch=b32 -S mount -S umount -S umount2 -k mount" >> /etc/audit/audit.rules
echo "-a exit,always -F arch=b64 -S mount -S umount2 -k mount" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "# Changes to the time" >> /etc/audit/audit.rules
sleep 2
echo "-a exit,always -F arch=b32 -S adjtimex -S settimeofday -S stime -S clock_settime -k time" >> /etc/audit/audit.rules
echo "-a exit,always -F arch=b64 -S adjtimex -S settimeofday -S clock_settime -k time" >> /etc/audit/audit.rules
echo "-w /etc/localtime -p wa -k localtime" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "# Use of stunnel" >> /etc/audit/audit.rules
sleep 2
echo "-w /usr/sbin/stunnel -p x -k stunnel" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "# Schedule jobs" >> /etc/audit/audit.rules
sleep 2
echo "-w /etc/cron.allow -p wa -k cron" >> /etc/audit/audit.rules
echo "-w /etc/cron.deny -p wa -k cron" >> /etc/audit/audit.rules
echo "-w /etc/cron.d/ -p wa -k cron" >> /etc/audit/audit.rules
echo "-w /etc/cron.daily/ -p wa -k cron" >> /etc/audit/audit.rules
echo "-w /etc/cron.hourly/ -p wa -k cron" >> /etc/audit/audit.rules
echo "-w /etc/cron.monthly/ -p wa -k cron" >> /etc/audit/audit.rules
echo "-w /etc/cron.weekly/ -p wa -k cron" >> /etc/audit/audit.rules
echo "-w /etc/crontab -p wa -k cron" >> /etc/audit/audit.rules
echo "-w /var/spool/cron/crontabs/ -k cron" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "## user, group, password databases" >> /etc/audit/audit.rules
sleep 2
echo "-w /etc/group -p wa -k etcgroup" >> /etc/audit/audit.rules
echo "-w /etc/passwd -p wa -k etcpasswd" >> /etc/audit/audit.rules
echo "-w /etc/gshadow -k etcgroup" >> /etc/audit/audit.rules
echo "-w /etc/shadow -k etcpasswd" >> /etc/audit/audit.rules
echo "-w /etc/security/opasswd -k opasswd" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "# Monitor usage of passwd command" >> /etc/audit/audit.rules
sleep 2
echo "-w /usr/bin/passwd -p x -k passwd_modification" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "# Monitor user/group tools" >> /etc/audit/audit.rules
sleep 2
echo "-w /usr/sbin/groupadd -p x -k group_modification" >> /etc/audit/audit.rules
echo "-w /usr/sbin/groupmod -p x -k group_modification" >> /etc/audit/audit.rules
echo "-w /usr/sbin/addgroup -p x -k group_modification" >> /etc/audit/audit.rules
echo "-w /usr/sbin/useradd -p x -k user_modification" >> /etc/audit/audit.rules
echo "-w /usr/sbin/usermod -p x -k user_modification" >> /etc/audit/audit.rules
echo "-w /usr/sbin/adduser -p x -k user_modification" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "# Login configuration and stored info" >> /etc/audit/audit.rules
sleep 2
echo "-w /etc/login.defs -p wa -k login" >> /etc/audit/audit.rules
echo "-w /etc/securetty -p wa -k login" >> /etc/audit/audit.rules
echo "-w /var/log/faillog -p wa -k login" >> /etc/audit/audit.rules
echo "-w /var/log/lastlog -p wa -k login" >> /etc/audit/audit.rules
echo "-w /var/log/tallylog -p wa -k login" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "# Network configuration" >> /etc/audit/audit.rules
sleep 2
echo "-w /etc/hosts -p wa -k hosts" >> /etc/audit/audit.rules
echo "-w /etc/network/ -p wa -k network" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "## system startup scripts" >> /etc/audit/audit.rules
sleep 2
echo "-w /etc/inittab -p wa -k init" >> /etc/audit/audit.rules
echo "-w /etc/init.d/ -p wa -k init" >> /etc/audit/audit.rules
echo "-w /etc/init/ -p wa -k init" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "# Library search paths" >> /etc/audit/audit.rules
sleep 2
echo "-w /etc/ld.so.conf -p wa -k libpath" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "# Kernel parameters and modules" >> /etc/audit/audit.rules
sleep 2
echo "-w /etc/sysctl.conf -p wa -k sysctl" >> /etc/audit/audit.rules
echo "-w /etc/modprobe.conf -p wa -k modprobe" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules


echo "# PAM configuration" >> /etc/audit/audit.rules
sleep 2
echo "-w /etc/pam.d/ -p wa -k pam" >> /etc/audit/audit.rules
echo "-w /etc/security/limits.conf -p wa  -k pam" >> /etc/audit/audit.rules
echo "-w /etc/security/pam_env.conf -p wa -k pam" >> /etc/audit/audit.rules
echo "-w /etc/security/namespace.conf -p wa -k pam" >> /etc/audit/audit.rules
echo "-w /etc/security/namespace.init -p wa -k pam" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules


echo "# Postfix configuration" >> /etc/audit/audit.rules
sleep 2
echo "-w /etc/aliases -p wa -k mail" >> /etc/audit/audit.rules
echo "-w /etc/postfix/ -p wa -k mail" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules


echo "# SSH configuration" >> /etc/audit/audit.rules
sleep 2
echo "-w /etc/ssh/sshd_config -k sshd" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "# Hostname" >> /etc/audit/audit.rules
sleep 2
echo "-a exit,always -F arch=b32 -S sethostname -k hostname" >> /etc/audit/audit.rules
echo "-a exit,always -F arch=b64 -S sethostname -k hostname" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "# Changes to issue" >> /etc/audit/audit.rules
sleep 2
echo "-w /etc/issue -p wa -k etcissue" >> /etc/audit/audit.rules
echo "-w /etc/issue.net -p wa -k etcissue" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "# Log all commands executed by root" >> /etc/audit/audit.rules
sleep 2
echo "-a exit,always -F arch=b64 -F euid=0 -S execve -k rootcmd" >> /etc/audit/audit.rules
echo "-a exit,always -F arch=b32 -F euid=0 -S execve -k rootcmd" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "## Capture all failures to access on critical elements" >> /etc/audit/audit.rules
sleep 2
echo "-a exit,always -F arch=b64 -S open -F dir=/etc -F success=0 -k unauthedfileacess" >> /etc/audit/audit.rules
echo "-a exit,always -F arch=b64 -S open -F dir=/bin -F success=0 -k unauthedfileacess" >> /etc/audit/audit.rules
echo "-a exit,always -F arch=b64 -S open -F dir=/home -F success=0 -k unauthedfileacess" >> /etc/audit/audit.rules
echo "-a exit,always -F arch=b64 -S open -F dir=/sbin -F success=0 -k unauthedfileacess" >> /etc/audit/audit.rules
echo "-a exit,always -F arch=b64 -S open -F dir=/srv -F success=0 -k unauthedfileacess" >> /etc/audit/audit.rules
echo "-a exit,always -F arch=b64 -S open -F dir=/usr/bin -F success=0 -k unauthedfileacess" >> /etc/audit/audit.rules
echo "-a exit,always -F arch=b64 -S open -F dir=/usr/local/bin -F success=0 -k unauthedfileacess" >> /etc/audit/audit.rules
echo "-a exit,always -F arch=b64 -S open -F dir=/usr/sbin -F success=0 -k unauthedfileacess" >> /etc/audit/audit.rules
echo "-a exit,always -F arch=b64 -S open -F dir=/var -F success=0 -k unauthedfileacess" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "## su/sudo" >> /etc/audit/audit.rules
sleep 2
echo "-w /bin/su -p x -k priv_esc" >> /etc/audit/audit.rules
echo "-w /usr/bin/sudo -p x -k priv_esc" >> /etc/audit/audit.rules
echo "-w /etc/sudoers -p rw -k priv_esc" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "# Poweroff/reboot tools" >> /etc/audit/audit.rules
sleep 2
echo "-w /sbin/halt -p x -k power" >> /etc/audit/audit.rules
echo "-w /sbin/poweroff -p x -k power" >> /etc/audit/audit.rules
echo "-w /sbin/reboot -p x -k power" >> /etc/audit/audit.rules
echo "-w /sbin/shutdown -p x -k power" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

echo "# Make the configuration immutable" >> /etc/audit/audit.rules
sleep 2
echo "-e 2" >> /etc/audit/audit.rules
echo "" >> /etc/audit/audit.rules

pkill -HUP -P 1 auditd


echo "##############################################"
echo "###      Modify Network Parameters         ###"
echo "##############################################"
sleep 2
echo "Disable IP Forwarding"
sleep 2
echo "#Disable IP Forwarding" >> /etc/sysctl.conf
echo "net.ipv4.ip_forward=0" >> /etc/sysctl.conf
echo "" >> /etc/sysctl.conf

/sbin/sysctl -w net.ipv4.ip_forward=0
/sbin/sysctl -w net.ipv4.route.flush=1

echo "Disable Send Packet Redirects"
sleep 2
echo "#Disable Send Packet Redirects" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.send_redirects=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.send_redirects=0" >> /etc/sysctl.conf
echo "" >> /etc/sysctl.conf

/sbin/sysctl -w net.ipv4.conf.all.send_redirects=0
/sbin/sysctl -w net.ipv4.route.flush=1

echo "Disable Source Routed Packet Acceptance"
sleep 2
echo "#Disable Source Routed Packet Acceptance" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.accept_source_route=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_source_route=0" >> /etc/sysctl.conf
echo "" >> /etc/sysctl.conf

/sbin/sysctl -w net.ipv4.conf.all.accept_source_route=0
/sbin/sysctl -w net.ipv4.conf.default.accept_source_route=0
/sbin/sysctl -w net.ipv4.route.flush=1

echo "Disable ICMP Redirect Acceptance"
sleep 2
echo "#Disable ICMP Redirect Acceptance" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.accept_redirects=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_redirects=0" >> /etc/sysctl.conf
echo "" >> /etc/sysctl.conf

/sbin/sysctl -w net.ipv4.conf.all.accept_redirects=0
/sbin/sysctl -w net.ipv4.conf.default.accept_redirects=0
/sbin/sysctl -w net.ipv4.route.flush=1

echo "Disable Secure ICMP Redirect Acceptance"
sleep 2
echo "#Disable Secure ICMP Redirect Acceptance" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.secure_redirects=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.secure_redirects=0" >> /etc/sysctl.conf
echo "" >> /etc/sysctl.conf

/sbin/sysctl -w net.ipv4.conf.all.secure_redirects=0
/sbin/sysctl -w net.ipv4.conf.default.secure_redirects=0
/sbin/sysctl -w net.ipv4.route.flush=1

echo "Log Suspicious Packets"
sleep 2
echo "#Log Suspicious Packets" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.log_martians=1" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.log_martians=1" >> /etc/sysctl.conf
echo "" >> /etc/sysctl.conf

/sbin/sysctl -w net.ipv4.conf.all.log_martians=1
/sbin/sysctl -w net.ipv4.conf.default.log_martians=1
/sbin/sysctl -w net.ipv4.route.flush=1

echo "Enable Ignore Broadcast Requests"
sleep 2
echo "#Enable Ignore Broadcast Requests" >> /etc/sysctl.conf
echo "net.ipv4.icmp_echo_ignore_broadcasts=1" >> /etc/sysctl.conf
echo "" >> /etc/sysctl.conf

/sbin/sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1
/sbin/sysctl -w net.ipv4.route.flush=1

echo "Enable Bad Error Message Protection"
sleep 2
echo "#Enable Bad Error Message Protection" >> /etc/sysctl.conf
echo "net.ipv4.icmp_ignore_bogus_error_responses=1" >> /etc/sysctl.conf
echo "" >> /etc/sysctl.conf

/sbin/sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1
/sbin/sysctl -w net.ipv4.route.flush=1

echo "Enable RFC-recommended Source Route Validation"
sleep 2
echo "#Enable RFC-recommended Source Route Validation" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter=1" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter=1" >> /etc/sysctl.conf
echo "" >> /etc/sysctl.conf

/sbin/sysctl -w net.ipv4.conf.all.rp_filter=1
/sbin/sysctl -w net.ipv4.conf.default.rp_filter=1
/sbin/sysctl -w net.ipv4.route.flush=1

echo "Enable TCP SYN Cookies"
sleep 2
echo "#Enable TCP SYN Cookies" >> /etc/sysctl.conf
echo "net.ipv4.tcp_syncookies=1" >> /etc/sysctl.conf
echo "" >> /etc/sysctl.conf

/sbin/sysctl -w net.ipv4.tcp_syncookies=1
/sbin/sysctl -w net.ipv4.route.flush=1


echo "Others"
sleep 2
echo "#Others" >> /etc/sysctl.conf
echo "net.ipv4.tcp_timestamps=0" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.accept_redirects=0" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.accept_redirects=0" >> /etc/sysctl.conf
echo "" >> /etc/sysctl.conf

/sbin/sysctl -w net.ipv4.tcp_timestamps=0
/sbin/sysctl -w net.ipv6.conf.all.accept_redirects=0
/sbin/sysctl -w net.ipv6.conf.default.accept_redirects=0

echo "##############################################"
echo "###         Disable IPv6                   ###"
echo "##############################################"
sleep 2
echo "NETWORKING_IPV6=no" >> /etc/sysconfig/network
echo "IPV6INIT=no" >> /etc/sysconfig/network

echo "##############################################"
echo "###     Configure cron and anacron         ###"
echo "##############################################"

echo "Set User/Group Owner and Permission on /etc/anacrontab"
sleep 2
stat -L -c "%a %u %g" /etc/anacrontab | egrep ".00 0 0" > /dev/null
permission=`echo $?`
	if test $permission = 0
		then
			echo "Permissions OK"
		else
			chown root:root /etc/anacrontab
			chmod og-rwx /etc/anacrontab
			echo "Permissions wrong, but it was corrected"
	fi

echo ""

echo "Set User/Group Owner and Permission on /etc/crontab"
sleep 2
stat -L -c "%a %u %g" /etc/crontab | egrep ".00 0 0" > /dev/null
permission=`echo $?`
	if test $permission = 0
		then
			echo "Permissions OK"
		else
			chown root:root /etc/crontab
			chmod og-rwx /etc/crontab
			echo "Permissions wrong, but it was corrected"
	fi

echo ""

echo "Set User/Group Owner and Permission on /etc/cron.hourly"
sleep 2
stat -L -c "%a %u %g" /etc/cron.hourly | egrep ".00 0 0" > /dev/null
permission=`echo $?`
	if test $permission = 0
		then
			echo "Permissions OK"
		else
			chown root:root /etc/cron.hourly
			chmod og-rwx /etc/cron.hourly
			echo "Permissions wrong, but it was corrected"
	fi

echo ""

echo "Set User/Group Owner and Permission on /etc/cron.daily"
sleep 2
stat -L -c "%a %u %g" /etc/cron.daily | egrep ".00 0 0"  > /dev/null
permission=`echo $?`
	if test $permission = 0
		then
			echo "Permissions OK"
		else
			chown root:root /etc/cron.daily
			chmod og-rwx /etc/cron.daily
			echo "Permissions wrong, but it was corrected"
	fi

echo ""

echo "Set User/Group Owner and Permission on /etc/cron.weekly"
sleep 2
stat -L -c "%a %u %g" /etc/cron.weekly | egrep ".00 0 0"  > /dev/null
permission=`echo $?`
	if test $permission = 0
		then
			echo "Permissions OK"
		else
			chown root:root /etc/cron.weekly
			chmod og-rwx /etc/cron.weekly
			echo "Permissions wrong, but it was corrected"
	fi

echo ""

echo "Set User/Group Owner and Permission on /etc/cron.monthly"
sleep 2
stat -L -c "%a %u %g" /etc/cron.monthly | egrep ".00 0 0"  > /dev/null
permission=`echo $?`
	if test $permission = 0
		then
			echo "Permissions OK"
		else
			chown root:root /etc/cron.monthly
			chmod og-rwx /etc/cron.monthly
			echo "Permissions wrong, but it was corrected"
	fi

echo ""

echo "Set User/Group Owner and Permission on /etc/cron.d"
sleep 2
stat -L -c "%a %u %g" /etc/cron.d | egrep ".00 0 0"  > /dev/null
permission=`echo $?`
	if test $permission = 0
		then
			echo "Permissions OK"
		else
			chown root:root /etc/cron.d
			chmod og-rwx /etc/cron.d
			echo "Permissions wrong, but it was corrected"
	fi

echo ""

echo "##############################################"
echo "###            Configure SSH               ###"
echo "##############################################"
file_sshd="/etc/ssh/sshd_config"
echo "Creating security copies of sshd_config"
if [ -f $file_sshd.original ]
		then
			echo "The file already exists"
		else
			cp $file_sshd{,.original}
			echo "Created file"
	fi
sleep 2
echo "##############################################" >> $file_sshd
echo "###       Security Changes                 ###" >> $file_sshd
echo "##############################################" >> $file_sshd
echo ""
echo "#Set LogLevel to INFO"
sleep 2
grep "^LogLevel" $file_sshd > /dev/null
parameter=`echo $?`
	if test $parameter = 0
		then
			echo "The parameter correct"
		else
			echo "#Set LogLevel to INFO" >> $file_sshd
			echo "LogLevel INFO" >> $file_sshd
			echo "The parameter fixed"
	fi

echo ""
echo "#Disable SSH X11 Forwarding"
sleep 2
grep "^X11Forwarding yes" $file_sshd > /dev/null
parameter=`echo $?`
	if test $parameter = 1
		then
			echo "The parameter correct"
		else
			sed -i 's/X11Forwarding yes/#X11Forwarding yes/g' $file_sshd
			echo "#Disable SSH X11 Forwarding" >> $file_sshd
			echo "X11Forwarding no" >> $file_sshd
			echo "The parameter fixed"
	fi

echo ""
#echo "#Disable SSH Password authentication"
#sleep 2
#grep "^PasswordAuthentication yes" $file_sshd > /dev/null
#parameter=`echo $?`
#	if test $parameter = 1
#		then
#			echo "The parameter correct"
#		else
#			sed -i 's/PasswordAuthentication yes/#PasswordAuthentication yes/g' $file_sshd
#			echo "#Disable SSH Password authentication" >> $file_sshd
#			echo "PasswordAuthentication no" >> $file_sshd
#			echo "The parameter fixed"
#	fi

echo ""
echo "#Disable SSH Root Login"
sleep 2
grep "^PermitRootLogin yes" $file_sshd > /dev/null
parameter=`echo $?`
	if test $parameter = 1
		then
			echo "The parameter correct"
		else
			sed -i 's/PermitRootLogin yes/#PermitRootLogin yes/g' $file_sshd
			echo "#Disable SSH Root Login" >> $file_sshd 
			echo "PermitRootLogin no" >> $file_sshd
			echo "The parameter fixed"
	fi

echo ""
echo "#Disable rhosts"
sleep 2
grep "^IgnoreRhosts yes" $file_sshd > /dev/null
parameter=`echo $?`
	if test $parameter = 0
		then
			echo "The parameter correct"
		else
			sed -i 's/IgnoreRhosts no/#PermitRootLogin no/g' $file_sshd
			echo "#Disable rhosts" >> $file_sshd 
			echo "IgnoreRhosts yes" >> $file_sshd
			echo "The parameter fixed"
fi

echo ""
echo "#Prevent the use of insecure home directory and key file permissions"
sleep 2
grep "^StrictModes yes" $file_sshd > /dev/null
parameter=`echo $?`
	if test $parameter = 0
		then
			echo "The parameter correct"
		else
			sed -i 's/StrictModes no/#StrictModes no/g' $file_sshd
			echo "#Prevent the use of insecure home directory and key file permissions" >> $file_sshd 
			echo "StrictModes yes" >> $file_sshd
			echo "The parameter fixed"
	fi

echo ""
echo "#Turn on privilege separation"
sleep 2
grep "^UsePrivilegeSeparation yes" $file_sshd > /dev/null
parameter=`echo $?`
	if test $parameter = 0
		then
			echo "The parameter correct"
		else
			sed -i 's/UsePrivilegeSeparation no/#UsePrivilegeSeparation no/g' $file_sshd
			echo "#Turn on privilege separation" >> $file_sshd 
			echo "UsePrivilegeSeparation yes" >> $file_sshd
			echo "The parameter fixed"
	fi
				
echo ""
echo "#Disable Empty Passwords"
sleep 2
grep "^PermitEmptyPasswords no" $file_sshd > /dev/null
parameter=`echo $?`
if test $parameter = 0
	then
		echo "The parameter correct"
	else
		sed -i 's/PermitEmptyPasswords yes/#PermitEmptyPasswords yes/g' $file_sshd
		echo "#Disable Empty Passwords" >> $file_sshd 
		echo "PermitEmptyPasswords no" >> $file_sshd
		echo "The parameter fixed"
	fi
			
echo ""
echo "#Configure Idle Log Out Timeout Interval"
sleep 2
grep "^ClientAliveInterval" $file_sshd > /dev/null
parameter=`echo $?`
if test $parameter = 1
	then
		echo "The parameter correct"
	else
		echo "#Configure Idle Log Out Timeout Interval" >> $file_sshd 
		echo "ClientAliveInterval 300" >> $file_sshd
		echo "ClientAliveCountMax 0" >> $file_sshd
		echo "The parameter fixed"
fi
					
echo ""
echo "Set SSH MaxAuthTries to 4 or Less"
sleep 2
grep "^MaxAuthTries 4" $file_sshd > /dev/null
parameter=`echo $?`
	if test $parameter = 0
		then
			echo "The parameter correct"
		else
			echo "#Set SSH MaxAuthTries to 4 or Less" >> $file_sshd
			echo "MaxAuthTries 4" >> $file_sshd
			echo "The parameter fixed"
	fi
	
echo ""
echo "#Set Permissions on '$file_sshd'"
sleep 2
stat -L -c "%a %u %g" $file_sshd | egrep ".00 0 0"  > /dev/null
permission=`echo $?`
	if test $permission = 0
		then
			echo "Permissions OK"
		else
			chown root:root $file_sshd
			chmod 600 $file_sshd
			echo "Permissions wrong, but it was corrected"
	fi

echo ""
echo "Reload service SSH"
/etc/init.d/sshd reload

echo "##############################################"
echo "###     User Accounts and Environment      ###"
echo "##############################################"
echo "Disable System Accounts"
egrep -v "^\+" /etc/passwd | awk -F: '($1!="root" && $1!="sync" && $1!="shutdown" && $1!="halt" && $3<500 && $7!="/sbin/nologin") {print}'

echo "Set Default umask for Users"
sleep 2
grep "^umask 077" /etc/bashrc > /dev/null
parameter=`echo $?`
	if test $parameter = 1
		then
			echo "The parameter correct"
		else
			sed -i 's/umask 022/umask 077/g' /etc/bashrc
			sed -i 's/umask 002/umask 077/g' /etc/bashrc
			echo "The parameter fixed"
	fi

grep "^umask 077" /etc/profile > /dev/null
parameter=`echo $?`
	if test $parameter = 1
		then
			echo "The parameter correct"
		else
			sed -i 's/umask 022/umask 077/g' /etc/profile
                        sed -i 's/umask 002/umask 077/g' /etc/profile
                        echo "The parameter fixed"
	fi

echo "Permissions on /etc/passwd"
dir="/etc/passwd"
/bin/chmod 644 $dir
ls -l $dir | awk '{print $1, $3, $4, $9}'
sleep 2

echo "Permissions on /etc/shadow"
dir="/etc/shadow"
/bin/chmod 000 $dir
ls -l $dir | awk '{print $1, $3, $4, $9}'
sleep 2

echo "Permissions on /etc/gshadow"
dir="/etc/gshadow"
/bin/chmod 000 $dir
ls -l $dir | awk '{print $1, $3, $4, $9}'
sleep 2

echo "Permissions on /etc/group"
dir="/etc/group"
/bin/chmod 644 $dir
ls -l $dir | awk '{print $1, $3, $4, $9}'
sleep 2

echo "Set User/Group Ownership on /etc/passwd"
dir="/etc/passwd"
/bin/chown root:root $dir
ls -l $dir | awk '{print $1, $3, $4, $9}'
sleep 2

echo "Set User/Group Ownership on /etc/shadow"
dir="/etc/shadow"
/bin/chown root:root $dir
ls -l $dir | awk '{print $1, $3, $4, $9}'
sleep 2

echo "Set User/Group Ownership on /etc/gshadow"
dir="/etc/gshadow"
/bin/chown root:root $dir
ls -l $dir | awk '{print $1, $3, $4, $9}'
sleep 2

echo "Set User/Group Ownership on /etc/group"
dir="/etc/group"
/bin/chown root:root $dir
ls -l $dir | awk '{print $1, $3, $4, $9}'
sleep 2

echo "################################################################"
echo "###         Disable services 			        ######"
echo "################################################################"
echo "Disabling NFS"
chkconfig nfslock off 2> /dev/null
chkconfig rpcgssd off 2> /dev/null
chkconfig rpcbind off 2> /dev/null
chkconfig rpcidmapd off 2> /dev/null
chkconfig rpcsvcgssd off 2> /dev/null
sleep 2

echo "Disabling firewall IPv6"
chkconfig ip6tables off 2> /dev/null
sleep 2

echo "Disabling CUPS"
chkconfig cups off 2> /dev/null
sleep 2

echo "################################################################"
echo "###         Password configuration		        ######"
echo "################################################################"
echo ""

echo "Upgrade Password Hashing Algorithm to SHA-512s"
sleep 2
authconfig --test | grep hashing | grep sha512 > /dev/null

parameter=`echo $?`
	if test $parameter = 0
		then
			echo "The parameter correct"
		else
			authconfig --passalgo=sha512 --update
			echo "The parameter fixed"
	fi

	echo ""

	echo "##############################################" >> /etc/pam.d/system-auth
	echo "###       Security Changes          ###" >> /etc/pam.d/system-auth
	echo "##############################################" >> /etc/pam.d/system-auth
	sleep 2

	echo "Limit Password Reuse"
	sleep 2
	grep "remember" /etc/pam.d/system-auth > /dev/null

	parameter=`echo $?`
		if test $parameter = 0
			then
				echo "The parameter correct"
			else
				echo "#Limit Password Reuse" >> /etc/pam.d/system-auth
				echo "password    sufficient    pam_unix.so remember=5" >> /etc/pam.d/system-auth
				echo "The parameter fixed"
		fi



echo "################################################################"
echo "###         Hardening successfully                        ######"
echo "################################################################"
