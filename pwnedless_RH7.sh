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


echo "##############################################"
echo "###	installing pre requirements	 ###"
echo "##############################################"
