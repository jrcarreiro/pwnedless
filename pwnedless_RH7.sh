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
echo ""
echo "#Ensure mounting of freevxfs filesystems is disabled" > $file_pwnedless
echo "install freevxfs /bin/true" > $file_pwnedless
echo ""
echo "#Ensure mounting of jffs2 filesystems is disabled" > $file_pwnedless
echo "install jffs2 /bin/true" > $file_pwnedless
echo ""
echo "#Ensure mounting of hfs filesystems is disabled" > $file_pwnedless
echo "install hfs /bin/true" > $file_pwnedless
echo ""
echo "#Ensure mounting of hfsplus filesystems is disabled" $file_pwnedless
echo "install hfsplus /bin/true" > $file_pwnedless
echo ""
echo "#Ensure mounting of squashfs filesystems is disabled" > $file_pwnedless
echo "install squashfs /bin/true" > $file_pwnedless
echo ""
echo "#Ensure mounting of udf filesystems is disabled" > $file_pwnedless
echo "install udf /bin/true" > $file_pwnedless
echo ""
echo "#Ensure mounting of FAT filesystems is disabled" > $file_pwnedless
echo "install vfat /bin/true" > $file_pwnedless

<<<<<<< Updated upstream
sleep 2

echo ">>>>Ensure separate partition exists for /tmp"
mount | grep /tmp
audit=`echo $?`
    if $audit = 1
    	then
            systemctl unmask tmp.mount
            systemctl enable tmp.mount
        else
            echo "The /tmp is partitioned"
    fi

sed 's/Options/#&/' /etc/systemd/system/local-fs.target.wants/tmp.mount
sed '/Options/ a Options=mode=1777,strictatime,noexec,nodev,nosuid' /etc/systemd/system/local-fs.target.wants/tmp.mount
=======
>>>>>>> Stashed changes

echo "##############################################"
echo "###	installing pre requirements	 ###"
echo "##############################################"