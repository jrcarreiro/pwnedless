#!/bin/bash
##############################################
#   					                     #
#    	Script for  hardening		         #
#    	S.O (RedHat/CentOS		             #
#  created by: Junior Carreiro aka 0x4a0x72  #
#
##############################################
##############################################
##          Variables                       ##
##############################################
file_pwnedless="/etc/modprobe.d/pwnedless.conf"
echo "##############################################"
echo "###	        Initial Setup      	        ###"
echo "##############################################"
echo ""
echo "Filesystem Configuration"
echo "#Ensure mounting of cramfs filesystems is disabled" > $file_pwnedless
echo "install cramfs /bin/true" > $file_pwnedless

echo "#Ensure mounting of freevxfs filesystems is disabled" > $file_pwnedless
echo "install freevxfs /bin/true" > $file_pwnedless

echo "#Ensure mounting of jffs2 filesystems is disabled" > $file_pwnedless
echo "install jffs2 /bin/true" > $file_pwnedless

echo "#Ensure mounting of hfs filesystems is disabled" > $file_pwnedless
echo "install hfs /bin/true" > $file_pwnedless

echo "#Ensure mounting of hfsplus filesystems is disabled" > $file_pwnedless
echo "install hfsplus /bin/true" > $file_pwnedless

echo "#Ensure mounting of squashfs filesystems is disabled" > $file_pwnedless
echo "install squashfs /bin/true" > $file_pwnedless

echo "#Ensure mounting of udf filesystems is disabled" > $file_pwnedless
echo "install udf /bin/true" > $file_pwnedless

echo "#Ensure mounting of FAT filesystems is disabled" > $file_pwnedless
echo "install vfat /bin/true" > $file_pwnedless

sleep 2
echo ""
echo ">>>>Ensure separate partition exists for /tmp"
cmd=$(mount | grep /tmp)
audit=$(echo $?)
  if [ $audit = 1 ]; then
    systemctl unmask tmp.mount
    systemctl enable tmp.mount
  else
    echo "The /tmp is partitioned"
  fi
sleep 2
echo ""
echo ">>>> Apply nosuid, noexec and nodev on /tmp "
file="/etc/systemd/system/local-fs.target.wants/tmp.mount"
sed -i 's/Options/#&/' $file
sed -i '/Options/ a Options=mode=1777,strictatime,noexec,nodev,nosuid' $file

sleep 2
echo ""
echo ">>>> Ensure sticky bit is set on all world-writable directories"
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null
audit=$(echo $?)
remediation=$(df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d -perm -0002 2>/dev/null | xargs chmod a+t &>/dev/null)

  if [ $audit = 0 ]; then
    echo "sticky bit is set on all world-writable directories"
    $remediation &>/dev/null
  fi

sleep 2
echo ""
echo ">>>> Check Automounting"
audit=$(systemctl is-enabled autofs)
remediation=$(systemctl disable autofs)

  if [ $audit = "enabled" ] ; then
    echo "Disabling Automounting"
    $remediation &>/dev/null
  else
    echo "Automounting is disabled"
  fi

sleep 2
echo ""
echo "Configure Software Updates"
echo ">>>> Ensure gpgcheck is globally activated"
audit=$(grep gpgcheck=0 /etc/yum.conf)
remediation="sed -i s/gpgcheck=0/gpgcheck=1/g /etc/yum.conf"

  if [ -z "$audit" ]; then
    echo "gpgcheck was globally activated on yum.conf file"
    $remediation
  else
    echo "gpgcheck is globally activated on yum.conf file"
  fi

audit=$(grep gpgcheck=0 /etc/yum.repos.d/*)
remediation="sed -i s/gpgcheck=0/gpgcheck=1/g /etc/yum.repos.d/*"

  if [ -z "$audit" ]; then
    echo "gpgcheck was globally activated on files inside yum.repos.d directory"
    $remediation
  else
    echo "gpgcheck is globally activated on files inside yum.repos.d directory"
  fi

sleep 2
echo ""
echo "Filesystem Integrity Checking"
echo ">>>> Ensure AIDE is installed"
rpm -q aide &>/dev/null
audit=$(echo $?)

  if [ $audit = 0 ]; then
    echo "AIDE was installed"
  else
    echo "AIDE will be install...."
    yum install aide -y &>/dev/null
    echo "AIDE database is initializing, this may take a few minutes...be patient"
    aide --init
    mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
    echo "Configure filesystem integrity for regularly check"
    echo "0 5 * * * /usr/sbin/aide --check" >> aide_cron ; crontab aide_cron ; rm -y aide_cron
    echo "AIDE was installed successfully"
  fi
sleep 2
echo ""
echo ">>>> Ensure filesystem integrity is regularly checked"
crontab -u root -l | grep aide &>/dev/null
audit1=$(echo $?)
grep -r aide /etc/cron.* /etc/crontab &>/dev/null
audit2=$(echo $?)

  if [ $audit1 = 0 ]; then
    echo "Filesystem configured for regularly check on crontab"
  else
    if [ $audit2 = 0 ]; then
      echo "Filesystem configured for regularly check on cron files"
    else
      echo "Configure filesystem integrity for regularly check"
      echo "0 5 * * * /usr/sbin/aide --check"
      >> aide_cron ; crontab aide_cron ; rm -y aide_cron
    fi
  fi

sleep 2
echo ""
echo "Secure Boot Settings"
echo ">>>> Ensure permissions on bootloader config are configured"
stat -L -c "%u %g" /boot/grub2/grub.cfg | egrep "0 0" > /dev/null
permission=`echo $?`
    if test $permission = 0
        then
            echo "Permission OK"
        else
            chown root:root /boot/grub2/grub.cfg
            echo "Permissions wrong, but it was corrected"
    fi
stat -L -c "%a" /boot/grub2/grub.cfg | egrep ".00" > /dev/null
permission=`echo $?`
    if test $permission = 1
        then
          chmod og-rwx /boot/grub2/grub.cfg
    fi
echo ""
sleep 2
echo ""
echo ">>>> Ensure authentication required for single user mode"
file="/usr/lib/systemd/system/rescue.service"
grep /sbin/sulogin /usr/lib/systemd/system/rescue.service &>/dev/null
audit=$(echo $?)
  if [ $audit = 1 ]; then
    cp $file{,.pwnedless}
    echo "Configuring authentication for single user mode"
    echo "" >> $file
    echo "#----> Security Changes <----#" >> $file
    echo "ExecStart=-/bin/sh -c "/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"" >> $file
  fi
file="/usr/lib/systemd/system/emergency.service"
grep /sbin/sulogin /usr/lib/systemd/system/emergency.service
audit=$(echo $?)
  if [ $audit = 1 ]; then
    cp $file{,.pwnedless}
    echo "Configuring authentication for single user mode"
    echo "" >> $file
    echo "#----> Security Changes <----#" >> $file
    echo "ExecStart=-/bin/sh -c "/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"" >> $file

sleep 2
echo ""
echo "Additional Process Hardening"
echo ">>>> Ensure core dumps are restricted"
file="/etc/security/limits.conf"
grep "hard core" /etc/security/limits.conf /etc/security/limits.d/*
audit=$(echo $?)
  if [ $audit = 1 ]; then
    cp $file{,.pwnedless}
    echo "Configuring core dumps restrict on limits.conf"
    echo "" >> $file
    echo "#----> Security Changes <----#" >> $file
    echo "hard core 0" >> $file
  fi

file="/etc/sysctl.d/72-coredump-pwnedless.conf"
audit=$(sysctl fs.suid_dumpable | awk '{print $3}')
  if [ $audit != 0 ]; then
    echo "Configuring core dumps restrict on sysctl.d"
    echo "" >> $file
    echo "#----> Security Changes <----#" >> $file
    echo "fs.suid_dumpable = 0" >> $file
    sysctl -w fs.suid_dumpable=0 &>/dev/null
  fi

sleep 2
echo ">>>> Ensure address space layout randomization (ASLR) is enabled"
file="/etc/sysctl.d/72-aslr-pwnedless.conf"
audit=$(sysctl kernel.randomize_va_space| awk '{print $3}')
  if [ $audit != 2 ]; then
    echo "Configuring address space layout randomization (ASLR) on sysctl.d"
    echo "" >> $file
    echo "#----> Security Changes <----#" >> $file
    echo "kernel.randomize_va_space = 2" >> $file
    sysctl -w kernel.randomize_va_space=2 &>/dev/null
  fi



















if [ -f $file_init.original ]
        then
            echo "The file already exists"
        else
            cp $file_init{,.original}
            echo "Created file"
    fi
echo "###       Security Changes                 ###" >> $file_init
echo "" >> $file_init
echo ">> Require Authentication for Single-User Mode"
sleep 2
grep "SINGLE=/sbin/sulogin" $file_init > /dev/null
parameter=`echo $?`
    if test $parameter = 0
        then
            echo "- The parameter correct"
        else
            sed -i 's\SINGLE=/sbin/sushell\#SINGLE=/sbin/sushell\g' $file_init
            echo "#Require Authentication for Single-User Mode" >> $file_init
            echo "SINGLE=/sbin/sulogin" >> $file_init
            echo "- The parameter fixed"
    fi

echo ">> Disable Interactive Boot"
sleep 2
grep "PROMPT=no" $file_init > /dev/null
parameter=`echo $?`
    if test $parameter = 0
        then
            echo "- The parameter correct"
        else
            sed -i 's/PROMPT=yes/#PROMPT=yes/g' $file_init
            echo "#Disable Interactive Boot" >> $file_init
            echo "PROMPT=no" >> $file_init
            echo "- The parameter fixed"
    fi

echo ">> Set Daemon umask"
sleep 2
grep "umask 027" $file_init > /dev/null
parameter=`echo $?`
    if test $parameter = 0
        then
            echo "- The parameter correct"
        else
            echo "#Set Daemon umask" >> $file_init
            echo "umask 027" >> $file_init
            echo "- The parameter fixed"
    fi







echo "##############################################"
echo "###	installing pre requirements	 ###"
echo "##############################################"
