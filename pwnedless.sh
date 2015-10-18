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

############################################
###             Variables                ###
############################################
rsyslog="rsyslog"
yumpluginsecurity="yum-plugin-security"
yumutils="yum-utils"
ed="ed"
sysstat="sysstat"
tcp_wrappers="tcp_wrappers"


########################################
###             Arrays               ###
########################################
Soft=();


#
########################################

echo "Verify the ${rsyslog} package"

yum info ${rsyslog} | grep installed > /dev/null
        install=`echo $?`
            if test $install = 1
                then
                    Soft=("${Soft[@]}" "${rsyslog}")
                    echo "The ${rsyslog} will be installed"
                else
                    echo "The ${rsyslog} is installed"
            fi
echo ""
echo "Verify the ${yumpluginsecurity}"

yum info ${yumpluginsecurity} | grep installed > /dev/null
        install=`echo $?`
            if test $install = 1
                then
                    Soft=("${Soft[@]}" "${yumpluginsecurity}")
                    echo "${yumpluginsecurity} will be installed"
                else
                    echo "${yumpluginsecurity} is installed"
            fi
echo ""
echo "Verify the ${yumutils}"

yum info ${yumutils} | grep installed > /dev/null
        install=`echo $?`
            if test $install = 1
                then
                    Soft=("$Soft[@]}" "${yumutils}")
                    echo "${yumutils} will be installed"
                else
                    echo "${yumutils} is installed"
            fi
echo ""
echo "Verify the ${ed}"

yum info ${ed} | grep installed > /dev/null
        install=`echo $?`
            if test $install = 1
                then
                    Soft=("${Soft[@]}" "${ed}")
                    echo "${ed} will be installed"
                else
                    echo "${ed} is installed"
            fi
echo ""
echo "Verify the ${sysstat}"

yum info ${sysstat} | grep installed > /dev/null
        install=`echo $?`
            if test $install = 1
                then
                    Soft=("${Soft[@]}" "${sysstat}")
                    echo "${sysstat} will be installed"
                else
                    echo "${sysstat} is installed"
            fi
echo ""

echo "Verify the ${tcp_wrappers}"

yum info ${tcp_wrappers} | grep installed > /dev/null
        install=`echo $?`
            if test $install = 1
                then
                    Soft=("${Soft[@]}" "${tcp_wrappers}")
                    echo "${tcp_wrappers} will be installed"
                else
                    echo "${tcp_wrappers} is installed"
            fi
echo ""


yum install -y ${Soft[*]}

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

########################################
###             Variables            ###
########################################

file_grub="/etc/grub.conf"
file_init="/etc/sysconfig/init"

echo "Creating security copies of $file_init"

if [ -f $file_init.original ]
        then
            echo "The file already exists"
        else
            cp $file_init{,.original}
            echo "Created file"
    fi
sleep 2
echo ""

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

echo "" >> $file_init
echo "##############################################" >> $file_init
echo "###       Security Changes                 ###" >> $file_init
echo "##############################################" >> $file_init
echo ""
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

########################################
###             Variables            ###
########################################

file_sshd="/etc/ssh/sshd_config"

echo "##############################################"
echo "###            Configure SSH               ###"
echo "##############################################"
echo "Creating security copies of sshd_config"

if [ -f $file_sshd.original ]
        then
            echo "The file already exists"
        else
            cp $file_sshd{,.original}
            echo "Created file"
    fi
sleep 2
echo ""
echo "##############################################" >> $file_sshd
echo "###       Security Changes                 ###" >> $file_sshd
echo "##############################################" >> $file_sshd
echo ""
echo ">> Set LogLevel to INFO"
sleep 2
grep "^LogLevel" $file_sshd > /dev/null
parameter=`echo $?`
    if test $parameter = 0
        then
            echo "- The parameter correct"
        else
            echo "#Set LogLevel to INFO" >> $file_sshd
            echo "LogLevel INFO" >> $file_sshd
            echo "- The parameter fixed"
    fi

echo ""
echo ">> Disable SSH X11 Forwarding"
sleep 2
grep "^X11Forwarding yes" $file_sshd > /dev/null
parameter=`echo $?`
    if test $parameter = 1
        then
            echo "- The parameter correct"
        else
            sed -i 's/X11Forwarding yes/#X11Forwarding yes/g' $file_sshd
            echo "#Disable SSH X11 Forwarding" >> $file_sshd
            echo "X11Forwarding no" >> $file_sshd
            echo "- The parameter fixed"
    fi

echo ""
echo ">> Disable SSH Password authentication"
sleep 2
grep "^PasswordAuthentication yes" $file_sshd > /dev/null
parameter=`echo $?`
    if test $parameter = 1
        then
            echo "- The parameter correct"
        else
            sed -i 's/PasswordAuthentication yes/#PasswordAuthentication yes/g' $file_sshd
            echo "#Disable SSH Password authentication" >> $file_sshd
            echo "PasswordAuthentication no" >> $file_sshd
            echo "- The parameter fixed"
    fi

echo ""
echo ">> Disable SSH Root Login"
sleep 2
grep "^PermitRootLogin yes" $file_sshd > /dev/null
parameter=`echo $?`
    if test $parameter = 1
        then
            echo "- The parameter correct"
        else
            sed -i 's/PermitRootLogin yes/#PermitRootLogin yes/g' $file_sshd
            echo "#Disable SSH Root Login" >> $file_sshd 
            echo "PermitRootLogin no" >> $file_sshd
            echo "- The parameter fixed"
    fi

echo ">> Disable rhosts"
sleep 2
grep "^IgnoreRhosts yes" $file_sshd > /dev/null
parameter=`echo $?`
    if test $parameter = 0
        then
            echo "- The parameter correct"
        else
            sed -i 's/IgnoreRhosts no/#PermitRootLogin no/g' $file_sshd
            echo "#Disable rhosts" >> $file_sshd 
            echo "IgnoreRhosts yes" >> $file_sshd
            echo "- The parameter fixed"
fi

echo ""
echo ">> Prevent the use of insecure home directory and key file permissions"
sleep 2
grep "^StrictModes yes" $file_sshd > /dev/null
parameter=`echo $?`
    if test $parameter = 0
        then
            echo "- The parameter correct"
        else
            sed -i 's/StrictModes no/#StrictModes no/g' $file_sshd
            echo "#Prevent the use of insecure home directory and key file permissions" >> $file_sshd 
            echo "StrictModes yes" >> $file_sshd
            echo "- The parameter fixed"
    fi

echo ""
echo ">> Turn on privilege separation"
sleep 2
grep "^UsePrivilegeSeparation yes" $file_sshd > /dev/null
parameter=`echo $?`
    if test $parameter = 0
        then
            echo "- The parameter correct"
        else
            sed -i 's/UsePrivilegeSeparation no/#UsePrivilegeSeparation no/g' $file_sshd
            echo "#Turn on privilege separation" >> $file_sshd 
            echo "UsePrivilegeSeparation yes" >> $file_sshd
            echo "- The parameter fixed"
    fi
                
echo ""
echo ">> Disable Empty Passwords"
sleep 2
grep "^PermitEmptyPasswords no" $file_sshd > /dev/null
parameter=`echo $?`
if test $parameter = 0
    then
        echo "- The parameter correct"
    else
        sed -i 's/PermitEmptyPasswords yes/#PermitEmptyPasswords yes/g' $file_sshd
        echo "#Disable Empty Passwords" >> $file_sshd 
        echo "PermitEmptyPasswords no" >> $file_sshd
        echo "- The parameter fixed"
    fi
            
echo ""
echo "#Configure Idle Log Out Timeout Interval"
sleep 2
grep "^ClientAliveInterval" $file_sshd > /dev/null
parameter=`echo $?`
if test $parameter = 1
    then
        echo "- The parameter correct"
    else
        echo "#Configure Idle Log Out Timeout Interval" >> $file_sshd 
        echo "ClientAliveInterval 300" >> $file_sshd
        echo "ClientAliveCountMax 0" >> $file_sshd
        echo "- The parameter fixed"
fi

echo ""
echo ">> Set SSH MaxAuthTries to 4 or Less"
sleep 2
grep "^MaxAuthTries 4" $file_sshd > /dev/null

parameter=`echo $?`
    if test $parameter = 0
        then
            echo "- The parameter correct"
        else
            echo "#Set SSH MaxAuthTries to 4 or Less" >> $file_sshd
            echo "MaxAuthTries 4" >> $file_sshd
            echo "- The parameter fixed"
    fi

echo ""
echo ">> Set SSH HostbasedAuthentication to No"
sleep 2
grep "^HostbasedAuthentication no" $file_sshd > /dev/null

parameter=`echo $?`
    if test $parameter = 0
        then
            echo "- The parameter correct"
        else
            sed -i 's/HostbasedAuthentication yes/#HostbasedAuthentication yes/g' $file_sshd
            echo "#Set SSH HostbasedAuthentication to No" >> $file_sshd
            echo "HostbasedAuthentication no" >> $file_sshd
            echo "- The parameter fixed"
    fi

echo ""
echo ">> Do Not Allow Users to Set Environment Options"
sleep 2
grep "^PermitUserEnvironment no" $file_sshd > /dev/null

parameter=`echo $?`
    if test $parameter = 0
        then
            echo "- The parameter correct"
        else
            sed -i 's/PermitUserEnvironment yes/#PermitUserEnvironmen tyes/g' $file_sshd
            echo "#Do Not Allow Users to Set Environment Options" >> $file_sshd
            echo "PermitUserEnvironment no" >> $file_sshd
            echo "- The parameter fixed"
    fi

echo ">> Set Permissions on '$file_sshd'"
sleep 2
stat -L -c "%a %u %g" $file_sshd | egrep ".00 0 0"  > /dev/null
permission=`echo $?`
    if test $permission = 0
        then
            echo "- Permissions OK"
        else
            chown root:root $file_sshd
            chmod 600 $file_sshd
            echo "- Permissions wrong, but it was corrected"
    fi

echo ""

echo "Reload service SSH"
/etc/init.d/sshd reload

########################################
###             Variables            ###
########################################

issue_net="/etc/issue.net"
issue="/etc/issue"
motd="/etc/motd"



echo "##############################################"
echo "###     Verifiy Permissions                ###"
echo "##############################################"
##############################################
###     Configure cron and anacron          ##
##############################################

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

##############################################
###     Configure password files            ##
##############################################

echo "Permissions on /etc/passwd"
dir="/etc/passwd"
/bin/chmod 644 $dir
ls -l $dir | awk '{print $1, $3, $4, $9}' > /dev/null
sleep 2

echo "Permissions on /etc/shadow"
dir="/etc/shadow"
/bin/chmod 000 $dir
ls -l $dir | awk '{print $1, $3, $4, $9}' > /dev/null
sleep 2

echo "Permissions on /etc/gshadow"
dir="/etc/gshadow"
/bin/chmod 000 $dir
ls -l $dir | awk '{print $1, $3, $4, $9}' > /dev/null
sleep 2

echo "Permissions on /etc/group"
dir="/etc/group"
/bin/chmod 644 $dir
ls -l $dir | awk '{print $1, $3, $4, $9}' > /dev/null
sleep 2

echo "Set User/Group Ownership on /etc/passwd"
dir="/etc/passwd"
/bin/chown root:root $dir
ls -l $dir | awk '{print $1, $3, $4, $9}' > /dev/null
sleep 2

echo "Set User/Group Ownership on /etc/shadow"
dir="/etc/shadow"
/bin/chown root:root $dir
ls -l $dir | awk '{print $1, $3, $4, $9}' > /dev/null
sleep 2

echo "Set User/Group Ownership on /etc/gshadow"
dir="/etc/gshadow"
/bin/chown root:root $dir
ls -l $dir | awk '{print $1, $3, $4, $9}' > /dev/null
sleep 2

echo "Set User/Group Ownership on /etc/group"
dir="/etc/group"
/bin/chown root:root $dir
ls -l $dir | awk '{print $1, $3, $4, $9}' > /dev/null
sleep 2

##############################################
###     Configure password files            ##
##############################################

echo "Set User/Group Ownership on $motd"
sleep 2
stat -L -c "%a %u %g" $motd | egrep ".44 0 0"  > /dev/null
permission=`echo $?`
    if test $permission = 0
        then
            echo "Permissions OK"
        else
            chown root:root $motd
            chmod 644 $motd
            echo "Permissions wrong, but it was corrected"
    fi

echo ""

echo "Set User/Group Ownership on $issue"
sleep 2
stat -L -c "%a %u %g" $issue | egrep ".44 0 0"  > /dev/null
permission=`echo $?`
    if test $permission = 0
        then
            echo "Permissions OK"
        else
            chown root:root $issue
            chmod 644 $issue
            echo "Permissions wrong, but it was corrected"
    fi

echo ""

echo "Set User/Group Ownership on $issue_net"
sleep 2
stat -L -c "%a %u %g" $issue_net | egrep ".44 0 0"  > /dev/null
permission=`echo $?`
    if test $permission = 0
        then
            echo "Permissions OK"
        else
            chown root:root $issue_net
            chmod 644 $issue_net
            echo "Permissions wrong, but it was corrected"
    fi

echo ""

########################################
###             Variables            ###
########################################

sysctl="/sbin/sysctl"
file_sysctl="/etc/sysctl.conf"
file_network="/etc/sysconfig/network"
file_ipv6="/etc/modprobe.d/ipv6.conf"

echo "Creating security copies of $file_network"

if [ -f $file_network.original ]
        then
            echo "The file already exists"
        else
            cp $file_network{,.original}
            echo "Created file"
    fi

echo "##############################################"
echo "###         Configure IPv6                 ###"
echo "##############################################"
echo "" >> $file_sysctl
echo "##############################################" >> $file_sysctl
echo "###         Configure IPv6                 ###" >> $file_sysctl
echo "##############################################" >> $file_sysctl
sleep 2
echo ">> Disable IPv6 Router Advertisements"
sleep 2
valida_sysctl1=`$sysctl net.ipv6.conf.all.accept_ra | awk '{print $3}'`
valida_sysctl2=`$sysctl net.ipv6.conf.default.accept_ra | awk '{print $3}'`
par_sysctl1="net.ipv6.conf.all.accept_ra = 0"
par_sysctl2="net.ipv6.conf.default.accept_ra = 0"
    if test $valida_sysctl1 = 0
        then
            echo "- The '$par_sysctl1' was enabled"
        else
            echo "- The parameter '$par_sysctl1' configured in sysctl.conf"
            echo "#Disable IPv6 Router Advertisements" >> $file_sysctl
            echo $par_sysctl1 >> $file_sysctl
    fi

    if test $valida_sysctl2 = 0
        then
            echo "- The '$par_sysctl2' was enabled"
        else
            echo "- The parameter '$par_sysctl2' configured in sysctl.conf"
            echo $par_sysctl2 >> $file_sysctl
            echo "" >> $file_sysctl
    fi

echo ">> Disable IPv6 Redirect Acceptance"
sleep 2
valida_sysctl1=`$sysctl net.ipv6.conf.all.accept_redirects | awk '{print $3}'`
valida_sysctl2=`$sysctl net.ipv6.conf.default.accept_redirects | awk '{print $3}'`
par_sysctl1="net.ipv6.conf.all.accept_redirects = 0"
par_sysctl2="net.ipv6.conf.default.accept_redirects = 0"
    if test $valida_sysctl1 = 0
        then
            echo "- The '$par_sysctl1' was enabled"
        else
            echo "- The parameter '$par_sysctl1' configured in sysctl.conf"
            echo "#Disable IPv6 Redirect Acceptance" >> $file_sysctl
            echo $par_sysctl1 >> $file_sysctl
    fi

    if test $valida_sysctl2 = 0
        then
            echo "- The '$par_sysctl2' was enabled"
        else
            echo "- The parameter '$par_sysctl2' configured in sysctl.conf"
            echo $par_sysctl2 >> $file_sysctl
            echo "" >> $file_sysctl
    fi

$sysctl -w net.ipv6.route.flush=1 > /dev/null
$sysctl -p > /dev/null

echo "##############################################"
echo "###         Disable IPv6                   ###"
echo "##############################################"
echo "" >> $file_network
echo "##############################################" >> $file_network
echo "###         Disable IPv6                   ###" >> $file_network
echo "##############################################" >> $file_network
sleep 2
grep NETWORKING_IPV6 $file_network >> /dev/null
parameter=`echo $?`
    if test $parameter = 0
        then
            echo "- The parameter correct"
        else
            echo "NETWORKING_IPV6=no" >> $file_network
            echo "- The parameter fixed"
    fi

grep IPV6INIT $file_network >> /dev/null
parameter=`echo $?`
    if test $parameter = 0
        then
            echo "- The parameter correct"
        else
            echo "IPV6INIT=no" >> $file_network
            echo "- The parameter fixed"
    fi
echo "##############################################" >> $file_ipv6
echo "###         Disable IPv6                   ###" >> $file_ipv6
echo "##############################################" >> $file_ipv6
grep ipv6 $file_ipv6 >> /dev/null
parameter=`echo $?`
    if test $parameter = 0
        then
            echo "- The parameter correct"
        else
            echo "options ipv6 disable=1" >> $file_ipv6
            echo "- The parameter fixed"
    fi

########################################
###             Variables            ###
########################################

file_pam_passwd="/etc/pam.d/password-auth"
file_pam_system="/etc/pam.d/system-auth"
file_pam_su="/etc/pam.d/su"
verify_auth=`grep "^auth" /etc/pam.d/password-auth | tail -1`
verify_auth1=`grep "auth" /etc/pam.d/su | tail -1`
verify_passwd=`grep "^password" /etc/pam.d/system-auth | tail -1`


echo "################################################################"
echo "###         Password configuration                ######"
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

echo ">> Limit Password Reuse"
sleep 2
grep "remember" $file_pam_system > /dev/null
parameter=`echo $?`
    if test $parameter = 0
        then
            echo "- The parameter correct"
        else
            sed -i "/${verify_passwd}/a password    sufficient    pam_unix.so remember=5" $file_pam_system
            echo "The parameter fixed"
    fi

echo ">> Set Lockout for Failed Password Attempts"
sleep 2
grep "pam_faillock" $file_pam_passwd > /dev/null
parameter=`echo $?`
    if test $parameter = 0
        then
            echo "- The parameter correct"
        else
            sed -i "/${verify_auth}/a auth        required       pam_faillock.so preauth audit silent deny=5 unlock_time=900" $file_pam_passwd
            sed -i "/${verify_auth}/a auth        [default=die]  pam_faillock.so authfail audit deny=5 unlock_time=900" $file_pam_passwd
            sed -i "/${verify_auth}/a auth        sufficient     pam_faillock.so authsucc audit deny=5 unlock_time=900" $file_pam_passwd
            echo "- The parameter fixed"
    fi
grep "pam_unix.so" $file_pam_passwd | grep success=1 > /dev/null
parameter=`echo $?`
    if test $parameter = 0
        then
            echo "- The parameter correct"
        else
            sed -i "/${verify_auth}/a auth        [success=1     default=bad] pam_unix.so" $file_pam_passwd
            echo "- The parameter fixed"
    fi

grep "pam_faillock" $file_pam_system > /dev/null
parameter=`echo $?`
    if test $parameter = 0
        then
            echo "- The parameter correct"
        else
            sed -i "/${verify_auth}/a auth        required      pam_faillock.so preauth audit silent deny=5 unlock_time=900" $file_pam_system
            sed -i "/${verify_auth}/a auth        [default=die] pam_faillock.so authfail audit deny=5 unlock_time=900" $file_pam_system
            sed -i "/${verify_auth}/a auth        sufficient    pam_faillock.so authsucc audit deny=5 unlock_time=900" $file_pam_system
            echo "- The parameter fixed"
    fi
grep "pam_unix.so" $file_pam_system | grep success=1 > /dev/null
parameter=`echo $?`
    if test $parameter = 0
        then
            echo "- The parameter correct"
        else
            sed -i "/${verify_auth}/a auth        [success=1    default=bad] pam_unix.so" $file_pam_system
            echo "- The parameter fixed"
    fi

echo ""
echo ">> Restrict Access to the su Command"
sleep 2
grep -E pam_wheel.so $file_pam_su | grep -E "^auth" > /dev/null
parameter=`echo $?`
    if test $parameter = 0
        then
            echo "- The parameter correct"
        else
            sed -i "/${verify_auth1}/a auth            required        pam_wheel.so use_uid" $file_pam_su
            echo "- The parameter fixed"
    fi

echo "##############################################"
echo "###     User Accounts and Environment      ###"
echo "##############################################"
echo "Disable System Accounts"
for user in `awk -F: '($3 < 500) {print $1 }' /etc/passwd`; do
    if [ $user != "root" ]
        then
            /usr/sbin/usermod -L $user 2> /dev/null
            if [ $user != "sync" ] && [ $user != "shutdown" ] && [ $user != "halt" ]
                then
                    /usr/sbin/usermod -s /sbin/nologin $user 2> /dev/null
            fi
    fi
done

echo "Ensure Password Fields are Not Empty"
for user in `/bin/cat /etc/shadow | /bin/awk -F: '($2 == "" ) { print $1 " does not have a password "}'`; do
    /usr/bin/passwd -l $user 2> /dev/null
done
    
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

echo "Set Default Group for root Account"
sleep 2
grep "^root:" /etc/passwd | cut -f4 -d: > /dev/null
parameter=`echo $?`
    if test $parameter = 0
        then
            echo "The parameter correct"
        else
            usermod -g 0 root
            echo "The parameter fixed"
    fi

echo "Lock Inactive User Accounts"
sleep 2
useradd -D -f 35 > /dev/null

echo "Set Warning Banner for Standard Login Services"
echo "Authorized uses only. All activity may be monitored and reported." > /etc/issue
echo "Authorized uses only. All activity may be monitored and reported." > /etc/issue.net
echo "Authorized uses only. All activity may be monitored and reported." > /etc/motd

########################################
###             Variables            ###
########################################

file_audit="/etc/audit/audit.rules"

echo "##############################################"
echo "###         Logging and Auditing           ###"
echo "##############################################"

echo "Creating security copies of audit.rules"
sleep 2

    if [ -f $file_audit.original ]
        then
            echo "The file already exists"
        else
            cp $file_audit{,.original}
            echo "Created file"
    fi

echo "Enable Auditing for Processes That Start Prior to auditd"
sleep 2
ed /etc/grub.conf << END
g/audit=1/s///g
g/kernel/s/$/ audit=1/
w
q
END


echo "##############################################" >> $file_audit
echo "###       Security Changes          ###" >> $file_audit
echo "##############################################" >> $file_audit
echo ""
echo "Record Events That Modify Date and Time Information"
sleep 2
echo "#Record Events That Modify Date and Time Information" >> $file_audit
echo "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change" >> $file_audit
echo "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change" >> $file_audit
echo "-a always,exit -F arch=b64 -S clock_settime -k time-change" >> $file_audit
echo "-a always,exit -F arch=b32 -S clock_settime -k time-change" >> $file_audit
echo "-w /etc/localtime -p wa -k time-change" >> $file_audit
echo "" >> $file_audit

echo "Record Events That Modify User/Group Information"
sleep 2
echo "#Record Events That Modify User/Group Information" >> $file_audit
echo "-w /etc/group -p wa -k identity" >> $file_audit
echo "-w /etc/passwd -p wa -k identity" >> $file_audit
echo "-w /etc/gshadow -p wa -k identity" >> $file_audit
echo "-w /etc/shadow -p wa -k identity" >> $file_audit
echo "-w /etc/security/opasswd -p wa -k identity" >> $file_audit
echo "" >> $file_audit

echo "Record Events That Modify the System's Network Environment"
sleep 2
echo "#Record Events That Modify the System's Network Environment" >> $file_audit
echo "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale" >> $file_audit
echo "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale" >> $file_audit
echo "-w /etc/issue -p wa -k system-locale" >> $file_audit
echo "-w /etc/issue.net -p wa -k system-locale" >> $file_audit
echo "-w /etc/hosts -p wa -k system-locale" >> $file_audit
echo "-w /etc/sysconfig/network -p wa -k system-locale " >> $file_audit
echo "" >> $file_audit

echo "Record Events That Modify the System's Mandatory Access Controls"
sleep 2
echo "#Record Events That Modify the System's Mandatory Access Controls" >> $file_audit
echo "-w /etc/selinux/ -p wa -k MAC-policy" >> $file_audit
echo "" >> $file_audit

echo "Collect Login and Logout Events"
sleep 2
echo "#Collect Login and Logout Events" >> $file_audit
echo "-w /var/log/faillog -p wa -k logins" >> $file_audit
echo "-w /var/log/lastlog -p wa -k logins" >> $file_audit
echo "-w /var/log/tallylog -p wa -k logins" >> $file_audit
echo "" >> $file_audit

echo "Collect Session Initiation Information"
sleep 2
echo "#Collect Session Initiation Information" >> $file_audit
echo "-w /var/run/utmp -p wa -k session"  >> $file_audit
echo "-w /var/log/wtmp -p wa -k " >> $file_audit
echo "-w /var/log/btmp -p wa -k session" >> $file_audit
echo "" >> $file_audit

echo "Collect Discretionary Access Control Permission Modification Events"
sleep 2
echo "#Collect Discretionary Access Control Permission Modification Events" >> $file_audit
echo "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=500 -F auid!=4294967295 -k perm_mod" >> $file_audit
echo "-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=500 -F auid!=4294967295 -k perm_mod" >> $file_audit
echo "-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=500 -F auid!=4294967295 -k perm_mod" >> $file_audit
echo "-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=500 -F auid!=4294967295 -k perm_mod" >> $file_audit
echo "-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=500 -F auid!=4294967295 -k perm_mod" >> $file_audit
echo "-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=500 -F auid!=4294967295 -k perm_mod" >> $file_audit
echo "" >> $file_audit

echo "Collect Unsuccessful Unauthorized Access Attempts to Files"
sleep 2
echo "#Collect Unsuccessful Unauthorized Access Attempts to Files" >> $file_audit
echo "-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=500 -F auid!=4294967295 -k access" >> $file_audit
echo "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=500 -F auid!=4294967295 -k access" >> $file_audit
echo "-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=500 -F auid!=4294967295 -k access" >> $file_audit
echo "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=500 -F auid!=4294967295 -k access" >> $file_audit
echo "" >> $file_audit

echo "Collect Use of Privileged Commands"
sleep 2
echo "#Collect Use of Privileged Commands" >> $file_audit
echo "find PART -xdev \( -perm -4000 -o -perm -2000 \) -type f | awk '{print \""-a always,exit -F path=\"" \$1 \"" -F perm=x -F "auid>=500" -F auid!=4294967295 -k privileged\"" }'" >> $file_audit
echo "" >> $file_audit

echo "Collect Successful File System Mounts"
sleep 2
echo "#Collect Successful File System Mounts" >> $file_audit
echo "-a always,exit -F arch=b64 -S mount -F auid>=500 -F auid!=4294967295 -k mounts" >> $file_audit
echo "-a always,exit -F arch=b32 -S mount -F auid>=500 -F auid!=4294967295 -k mounts" >> $file_audit
echo "" >> $file_audit

echo "Collect File Deletion Events by User"
sleep 2
echo "#Collect File Deletion Events by User" >> $file_audit
echo "-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=500 -F auid!=4294967295 -k delete" >> $file_audit
echo "-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=500 -F auid!=4294967295 -k delete" >> $file_audit
echo "" >> $file_audit

echo "Collect Changes to System Administration Scope"
sleep 2
echo "#Collect Changes to System Administration Scope" >> $file_audit
echo "-w /etc/sudoers -p wa -k scope" >> $file_audit
echo "" >> $file_audit

echo "Collect System Administrator Actions"
sleep 2
echo "#Collect System Administrator Actions" >> $file_audit
echo "-w /var/log/sudo.log -p wa -k actions" >> $file_audit
echo "" >> $file_audit

echo "Collect Kernel Module Loading and Unloading"
sleep 2
echo "#Collect Kernel Module Loading and Unloading" >> $file_audit
echo "-w /sbin/insmod -p x -k modules" >> $file_audit
echo "-w /sbin/rmmod -p x -k modules" >> $file_audit
echo "-w /sbin/modprobe -p x -k modules" >> $file_audit
echo "-a always,exit -F arch=b64 -S init_module -S delete_module -k modules" >> $file_audit
echo "" >> $file_audit

echo "#Audit the audit logs" >> $file_audit
sleep 2
echo "-w /var/log/audit/ -k auditlog" >> $file_audit
echo "" >> $file_audit

echo "# Modifications to audit configuration that occur while the audit (check your paths)" >> $file_audit
sleep 2
echo "-w /etc/audit/ -p wa -k auditconfig" >> $file_audit
echo "-w /etc/libaudit.conf -p wa -k auditconfig" >> $file_audit
echo "-w /etc/audisp/ -p wa -k audispconfig" >> $file_audit
echo "" >> $file_audit

echo "# Monitor for use of audit management tools" >> $file_audit
sleep 2
echo "# Check your paths" >> $file_audit
echo "-w /sbin/auditctl -p x -k audittools" >> $file_audit
echo "-w /sbin/auditd -p x -k audittools" >> $file_audit
echo "" >> $file_audit

echo "# Special files" >> $file_audit
sleep 2
echo "-a exit,always -F arch=b32 -S mknod -S mknodat -k specialfiles" >> $file_audit
echo "-a exit,always -F arch=b64 -S mknod -S mknodat -k specialfiles" >> $file_audit
echo "" >> $file_audit

echo "# Mount operations" >> $file_audit
sleep 2
echo "-a exit,always -F arch=b32 -S mount -S umount -S umount2 -k mount" >> $file_audit
echo "-a exit,always -F arch=b64 -S mount -S umount2 -k mount" >> $file_audit
echo "" >> $file_audit

echo "# Changes to the time" >> $file_audit
sleep 2
echo "-a exit,always -F arch=b32 -S adjtimex -S settimeofday -S stime -S clock_settime -k time" >> $file_audit
echo "-a exit,always -F arch=b64 -S adjtimex -S settimeofday -S clock_settime -k time" >> $file_audit
echo "-w /etc/localtime -p wa -k localtime" >> $file_audit
echo "" >> $file_audit

echo "# Use of stunnel" >> $file_audit
sleep 2
echo "-w /usr/sbin/stunnel -p x -k stunnel" >> $file_audit
echo "" >> $file_audit

echo "# Schedule jobs" >> $file_audit
sleep 2
echo "-w /etc/cron.allow -p wa -k cron" >> $file_audit
echo "-w /etc/cron.deny -p wa -k cron" >> $file_audit
echo "-w /etc/cron.d/ -p wa -k cron" >> $file_audit
echo "-w /etc/cron.daily/ -p wa -k cron" >> $file_audit
echo "-w /etc/cron.hourly/ -p wa -k cron" >> $file_audit
echo "-w /etc/cron.monthly/ -p wa -k cron" >> $file_audit
echo "-w /etc/cron.weekly/ -p wa -k cron" >> $file_audit
echo "-w /etc/crontab -p wa -k cron" >> $file_audit
echo "-w /var/spool/cron/crontabs/ -k cron" >> $file_audit
echo "" >> $file_audit

echo "## user, group, password databases" >> $file_audit
sleep 2
echo "-w /etc/group -p wa -k etcgroup" >> $file_audit
echo "-w /etc/passwd -p wa -k etcpasswd" >> $file_audit
echo "-w /etc/gshadow -k etcgroup" >> $file_audit
echo "-w /etc/shadow -k etcpasswd" >> $file_audit
echo "-w /etc/security/opasswd -k opasswd" >> $file_audit
echo "" >> $file_audit

echo "# Monitor usage of passwd command" >> $file_audit
sleep 2
echo "-w /usr/bin/passwd -p x -k passwd_modification" >> $file_audit
echo "" >> $file_audit

echo "# Monitor user/group tools" >> $file_audit
sleep 2
echo "-w /usr/sbin/groupadd -p x -k group_modification" >> $file_audit
echo "-w /usr/sbin/groupmod -p x -k group_modification" >> $file_audit
echo "-w /usr/sbin/addgroup -p x -k group_modification" >> $file_audit
echo "-w /usr/sbin/useradd -p x -k user_modification" >> $file_audit
echo "-w /usr/sbin/usermod -p x -k user_modification" >> $file_audit
echo "-w /usr/sbin/adduser -p x -k user_modification" >> $file_audit
echo "" >> $file_audit

echo "# Login configuration and stored info" >> $file_audit
sleep 2
echo "-w /etc/login.defs -p wa -k login" >> $file_audit
echo "-w /etc/securetty -p wa -k login" >> $file_audit
echo "-w /var/log/faillog -p wa -k login" >> $file_audit
echo "-w /var/log/lastlog -p wa -k login" >> $file_audit
echo "-w /var/log/tallylog -p wa -k login" >> $file_audit
echo "" >> $file_audit

echo "# Network configuration" >> $file_audit
sleep 2
echo "-w /etc/hosts -p wa -k hosts" >> $file_audit
echo "-w /etc/network/ -p wa -k network" >> $file_audit
echo "" >> $file_audit

echo "## system startup scripts" >> $file_audit
sleep 2
echo "-w /etc/inittab -p wa -k init" >> $file_audit
echo "-w /etc/init.d/ -p wa -k init" >> $file_audit
echo "-w /etc/init/ -p wa -k init" >> $file_audit
echo "" >> $file_audit

echo "# Library search paths" >> $file_audit
sleep 2
echo "-w /etc/ld.so.conf -p wa -k libpath" >> $file_audit
echo "" >> $file_audit

echo "# Kernel parameters and modules" >> $file_audit
sleep 2
echo "-w /etc/sysctl.conf -p wa -k sysctl" >> $file_audit
echo "-w /etc/modprobe.conf -p wa -k modprobe" >> $file_audit
echo "" >> $file_audit


echo "# PAM configuration" >> $file_audit
sleep 2
echo "-w /etc/pam.d/ -p wa -k pam" >> $file_audit
echo "-w /etc/security/limits.conf -p wa  -k pam" >> $file_audit
echo "-w /etc/security/pam_env.conf -p wa -k pam" >> $file_audit
echo "-w /etc/security/namespace.conf -p wa -k pam" >> $file_audit
echo "-w /etc/security/namespace.init -p wa -k pam" >> $file_audit
echo "" >> $file_audit


echo "# Postfix configuration" >> $file_audit
sleep 2
echo "-w /etc/aliases -p wa -k mail" >> $file_audit
echo "-w /etc/postfix/ -p wa -k mail" >> $file_audit
echo "" >> $file_audit


echo "# SSH configuration" >> $file_audit
sleep 2
echo "-w /etc/ssh/sshd_config -k sshd" >> $file_audit
echo "" >> $file_audit

echo "# Hostname" >> $file_audit
sleep 2
echo "-a exit,always -F arch=b32 -S sethostname -k hostname" >> $file_audit
echo "-a exit,always -F arch=b64 -S sethostname -k hostname" >> $file_audit
echo "" >> $file_audit

echo "# Changes to issue" >> $file_audit
sleep 2
echo "-w /etc/issue -p wa -k etcissue" >> $file_audit
echo "-w /etc/issue.net -p wa -k etcissue" >> $file_audit
echo "" >> $file_audit

echo "# Log all commands executed by root" >> $file_audit
sleep 2
echo "-a exit,always -F arch=b64 -F euid=0 -S execve -k rootcmd" >> $file_audit
echo "-a exit,always -F arch=b32 -F euid=0 -S execve -k rootcmd" >> $file_audit
echo "" >> $file_audit

echo "## Capture all failures to access on critical elements" >> $file_audit
sleep 2
echo "-a exit,always -F arch=b64 -S open -F dir=/etc -F success=0 -k unauthedfileacess" >> $file_audit
echo "-a exit,always -F arch=b64 -S open -F dir=/bin -F success=0 -k unauthedfileacess" >> $file_audit
echo "-a exit,always -F arch=b64 -S open -F dir=/home -F success=0 -k unauthedfileacess" >> $file_audit
echo "-a exit,always -F arch=b64 -S open -F dir=/sbin -F success=0 -k unauthedfileacess" >> $file_audit
echo "-a exit,always -F arch=b64 -S open -F dir=/srv -F success=0 -k unauthedfileacess" >> $file_audit
echo "-a exit,always -F arch=b64 -S open -F dir=/usr/bin -F success=0 -k unauthedfileacess" >> $file_audit
echo "-a exit,always -F arch=b64 -S open -F dir=/usr/local/bin -F success=0 -k unauthedfileacess" >> $file_audit
echo "-a exit,always -F arch=b64 -S open -F dir=/usr/sbin -F success=0 -k unauthedfileacess" >> $file_audit
echo "-a exit,always -F arch=b64 -S open -F dir=/var -F success=0 -k unauthedfileacess" >> $file_audit
echo "" >> $file_audit

echo "## su/sudo" >> $file_audit
sleep 2
echo "-w /bin/su -p x -k priv_esc" >> $file_audit
echo "-w /usr/bin/sudo -p x -k priv_esc" >> $file_audit
echo "-w /etc/sudoers -p rw -k priv_esc" >> $file_audit
echo "" >> $file_audit

echo "# Poweroff/reboot tools" >> $file_audit
sleep 2
echo "-w /sbin/halt -p x -k power" >> $file_audit
echo "-w /sbin/poweroff -p x -k power" >> $file_audit
echo "-w /sbin/reboot -p x -k power" >> $file_audit
echo "-w /sbin/shutdown -p x -k power" >> $file_audit
echo "" >> $file_audit

echo "# Make the configuration immutable" >> $file_audit
sleep 2
echo "-e 2" >> $file_audit
echo "" >> $file_audit

pkill -HUP -P 1 auditd

########################################
###             Variables            ###
########################################

file_limits="/etc/security/limits.conf"

echo "##############################################"
echo "###     Additional Process Hardening       ###"
echo "##############################################"

echo "Create a copy of file"

    if [ -f $file_limits.original ]
        then
            echo "The file already exists"
        else
            cp $file_limits{,.original}
            echo "Created file"
    fi


echo "##############################################" >> $file_limits
echo "###      Security Changes           ###" >> $file_limits
echo "##############################################" >> $file_limits
echo ""


echo "Restrict Core Dumps"
sleep 2
grep "hard core" $file_limits > /dev/null
valida_limits=`echo $?`
par_limits="hard core 0"

    if test $valida_limits = 0
        then
            echo "The parameter is already set"
        else
            echo "The parameter '$par_limits' configured in limits.conf"
            echo $par_limits >> $file_limits
    fi

########################################
###             Variables            ###
########################################

sysctl="/sbin/sysctl"
file_sysctl="/etc/sysctl.conf"

echo "##############################################"
echo "###     Kernel Parameters                  ###"
echo "##############################################"

if [ -f /etc/sysctl.conf.original ]
    then
        echo "The file already exists"
    else
        cp $file_sysctl{,.original}
        echo "Created file"
fi
sleep 2
echo ""
echo "##############################################" >> $file_sysctl
echo "###       Security Changes                 ###" >> $file_sysctl
echo "##############################################" >> $file_sysctl
echo ""

echo ">> Configuring suid_dumpable"
sleep 2
valida_sysctl=`$sysctl fs.suid_dumpable | awk '{print $3}'`
par_sysctl="fs.suid_dumpable = 0"

    if test $valida_sysctl = 0
        then
            echo "- The parameter is already set"
        else
            echo "- The parameter '$par_sysctl' configured in sysctl.conf"
            echo "#Configuring suid_dumpable" >> $file_sysctl
            echo $par_sysctl >> $file_sysctl
            echo ""
    fi

echo ">> Configure ExecShield"
sleep 2
valida_sysctl=`$sysctl kernel.exec-shield | awk '{print $3}'`
par_sysctl="kernel.exec-shield = 1"

    if test $valida_sysctl = 1
        then
            echo "- The parameter is already set"
        else
            echo "- The parameter '$par_sysctl' configured in sysctl.conf"
            echo "#Configure ExecShield" >> $file_sysctl
            echo $par_sysctl >> $file_sysctl
            echo ""
    fi

echo ">> Enable Randomized Virtual Memory Region Placement"
sleep 2
valida_sysctl=`$sysctl kernel.randomize_va_space | awk '{print $3}'`
par_sysctl="kernel.randomize_va_space = 2"

    if test $valida_sysctl = 2
        then
            echo "- The parameter is already set"
        else
            echo "- The parameter '$par_sysctl' configured in sysctl.conf"
            echo "#Enable Randomized Virtual Memory Region Placement" >> $file_sysctl
            echo $par_sysctl >> $file_sysctl
            echo ""
    fi

sleep 2
echo ">> Disable IP Forwarding"
sleep 2
valida_sysctl=`$sysctl net.ipv4.ip_forward | awk '{print $3}'`
par_sysctl="net.ipv4.ip_forward = 0"
    if test $valida_sysctl = 0
        then
            echo "- IP Forwarding was Disabled"
        else
            echo "- The parameter '$par_sysctl' configured in sysctl.conf"
            echo "#Disable IP Forwarding" >> $file_sysctl
            echo $par_sysctl >> $file_sysctl
            echo "" >> $file_sysctl
    fi

sleep 2
echo ">> Disable Send Packet Redirects"
sleep 2
valida_sysctl=`$sysctl net.ipv4.conf.all.send_redirects | awk '{print $3}'`
par_sysctl="net.ipv4.conf.all.send_redirects = 0"
    if test $valida_sysctl = 0
        then
            echo "- Send Packet Redirects was Disabled"
        else
            echo "- The parameter '$par_sysctl' configured in sysctl.conf"
            echo "#Disable Send Packet Redirects" >> $file_sysctl
            echo $par_sysctl >> $file_sysctl
            echo "" >> $file_sysctl
    fi

echo ">> Disable Source Routed Packet Acceptance"
sleep 2
valida_sysctl=`$sysctl net.ipv4.conf.all.accept_source_route | awk '{print $3}'`
valida_sysctl1=`$sysctl net.ipv4.conf.default.accept_source_route | awk '{print $3}'`
par_sysctl="net.ipv4.conf.all.accept_source_route = 0"
par_sysctl1="net.ipv4.conf.default.accept_source_route = 0"
    if test $valida_sysctl = 0
        then
            echo "- The '$par_sysctl' was Disabled"
        else
            echo "- The parameter '$par_sysctl' configured in sysctl.conf"
            echo "#Disable Source Routed Packet Acceptance" >> $file_sysctl
            echo $par_sysctl >> $file_sysctl
            echo "" >> $file_sysctl
    fi

    if test $valida_sysctl = 0
        then
            echo "- The '$par_sysctl1' was Disabled"
        else
            echo "- The parameter '$par_sysctl1' configured in sysctl.conf"
            echo "#Disable Source Routed Packet Acceptance" >> $file_sysctl
            echo $par_sysctl1 >> $file_sysctl
            echo "" >> $file_sysctl
    fi

echo ">> Disable ICMP Redirect Acceptance"
sleep 2
valida_sysctl=`$sysctl net.ipv4.conf.all.accept_redirects | awk '{print $3}'`
valida_sysctl1=`$sysctl net.ipv4.conf.default.accept_redirects | awk '{print $3}'`
par_sysctl="net.ipv4.conf.all.accept_redirects = 0"
par_sysctl1="net.ipv4.conf.default.accept_redirects = 0"
    if test $valida_sysctl = 0
        then
            echo "- The '$par_sysctl' was Disabled"
        else
            echo "- The parameter '$par_sysctl' configured in sysctl.conf"
            echo "#Disable ICMP Redirect Acceptance" >> $file_sysctl
            echo $par_sysctl >> $file_sysctl
            echo "" >> $file_sysctl
    fi

    if test $valida_sysctl1 = 0
        then
            echo "- The '$par_sysctl1' was Disabled"
        else
            echo "- The parameter '$par_sysctl1' configured in sysctl.conf"
            echo "#Disable ICMP Redirect Acceptance" >> $file_sysctl
            echo $par_sysctl1 >> $file_sysctl
            echo "" >> $file_sysctl
    fi


echo ">> Disable Secure ICMP Redirect Acceptance"
sleep 2
valida_sysctl=`$sysctl net.ipv4.conf.all.secure_redirects | awk '{print $3}'`
valida_sysctl1=`$sysctl net.ipv4.conf.all.secure_redirects | awk '{print $3}'`
par_sysctl="net.ipv4.conf.all.secure_redirects = 0"
par_sysctl1="net.ipv4.conf.default.secure_redirects = 0"
    if test $valida_sysctl = 0
        then
            echo "- The '$par_sysctl' was Disabled"
        else
            echo "- The parameter '$par_sysctl' configured in sysctl.conf"
            echo "#Disable Secure ICMP Redirect Acceptance" >> $file_sysctl
            echo $par_sysctl >> $file_sysctl
            echo "" >> $file_sysctl
    fi

    if test $valida_sysctl1 = 0
        then
            echo "- The '$par_sysctl1' was Disabled"
        else
            echo "- The parameter '$par_sysctl1' configured in sysctl.conf"
            echo "#Disable Secure ICMP Redirect Acceptance" >> $file_sysctl
            echo $par_sysctl1 >> $file_sysctl
            echo "" >> $file_sysctl
    fi

echo ">> Log Suspicious Packets"
sleep 2
valida_sysctl=`$sysctl net.ipv4.conf.all.log_martians | awk '{print $3}'`
valida_sysctl1=`$sysctl net.ipv4.conf.all.log_martians | awk '{print $3}'`
par_sysctl="net.ipv4.conf.all.log_martians = 1"
par_sysctl1="net.ipv4.conf.default.log_martians = 1"
    if test $valida_sysctl = 1
        then
            echo "- The '$par_sysctl' was Disabled"
        else
            echo "- The parameter '$par_sysctl' configured in sysctl.conf"
            echo "#Log Suspicious Packets" >> $file_sysctl
            echo $par_sysctl >> $file_sysctl
            echo "" >> $file_sysctl
    fi

    if test $valida_sysctl1 = 1
        then
            echo "- The '$par_sysctl1' was Disabled"
        else
            echo "- The parameter '$par_sysctl1' configured in sysctl.conf"
            echo "#Log Suspicious Packets" >> $file_sysctl
            echo $par_sysctl1 >> $file_sysctl
            echo "" >> $file_sysctl
    fi

echo ">> Enable Ignore Broadcast Requests"
sleep 2
valida_sysctl=`$sysctl net.ipv4.icmp_echo_ignore_broadcasts | awk '{print $3}'`
par_sysctl="net.ipv4.icmp_echo_ignore_broadcasts = 1"
    if test $valida_sysctl = 1
        then
            echo "- Ignore Broadcast Requests was Enabled"
        else
            echo "- The parameter '$par_sysctl' configured in sysctl.conf"
            echo "#Enable Ignore Broadcast Requests" >> $file_sysctl
            echo $par_sysctl >> $file_sysctl
            echo "" >> $file_sysctl
    fi

echo ">> Enable Bad Error Message Protection"
sleep 2
valida_sysctl=`$sysctl net.ipv4.icmp_ignore_bogus_error_responses | awk '{print $3}'`
par_sysctl="net.ipv4.icmp_ignore_bogus_error_responses = 1"
    if test $valida_sysctl = 1
        then
            echo "- Bad Error Message Protection was Enabled"
        else
            echo "- The parameter '$par_sysctl' configured in sysctl.conf"
            echo "#Enable Bad Error Message Protection" >> $file_sysctl
            echo $par_sysctl >> $file_sysctl
            echo "" >> $file_sysctl
    fi

echo ">> Enable RFC-recommended Source Route Validation"
sleep 2
valida_sysctl=`$sysctl net.ipv4.conf.all.rp_filter | awk '{print $3}'`
par_sysctl="net.ipv4.conf.all.rp_filter = 1"
par_sysctl1="net.ipv4.conf.default.rp_filter = 1"
    if test $valida_sysctl = 1
        then
            echo "- RFC-recommended Source Route Validation was Enabled"
        else
            echo "- The parameter '$par_sysctl' configured in sysctl.conf"
            echo "- The parameter '$par_sysctl1' configured in sysctl.conf"
            echo "#Enable RFC-recommended Source Route Validation" >> $file_sysctl
            echo $par_sysctl >> $file_sysctl
            echo $par_sysctl1 >> $file_sysctl
            echo "" >> $file_sysctl
    fi

echo ">> Enable TCP SYN Cookies"
sleep 2
valida_sysctl=`$sysctl net.ipv4.tcp_syncookies | awk '{print $3}'`
par_sysctl="net.ipv4.tcp_syncookies = 1"
    if test $valida_sysctl = 1
        then
            echo "- Enable TCP SYN Cookies was Enabled"
        else
            echo "- The parameter '$par_sysctl' configured in sysctl.conf"
            echo "#Enable TCP SYN Cookies" >> $file_sysctl
            echo $par_sysctl >> $file_sysctl
            echo "" >> $file_sysctl
    fi

echo "- Others"
sleep 2
valida_sysctl=`$sysctl net.ipv4.tcp_timestamps | awk '{print $3}'`
par_sysctl="net.ipv4.tcp_timestamps = 0"
    if test $valida_sysctl = 0
        then
            echo "The '$par_sysctl' was enabled"
        else
            echo "The parameter '$par_sysctl' configured in sysctl.conf"
            echo "#Others" >> $file_sysctl
            echo $par_sysctl >> $file_sysctl
    fi

$sysctl -w net.ipv4.route.flush=1 > /dev/null
$sysctl -p > /dev/null

echo "##############################################"
echo "###       Configure NTPD                   ###"
echo "##############################################"
echo ""
echo "Configure Network Time Protocol (NTP)"
echo "*/5 * * * * root /usr/sbin/ntpdate a.ntp.br 1> /dev/null 2> /dev/null" >  /etc/cron.d/ntpdate

echo "################################################################"
echo "###         Disable services                  ######"
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

echo "##############################################"
echo "###    Create a list of the software       ###"
echo "###    to be uninstalled within            ###"
echo "###    /tmp/soft.lst               ###"
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
echo "################################################################"
echo "###         Hardening successfully                        ######"
echo "################################################################"
