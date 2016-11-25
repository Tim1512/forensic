#!/bin/bash 

# Name: Mount VSS
# Author: Matthew Green - mgreen27(at)gmail.com
# Version 0.2
#
# Description:
# mountvss.sh i a quick script to:
# 1) Mount Evidence drive
# 2) Mount availible VSS
# 3) run some processing accross all mounts
#		- RecentFileCache.bcf
#
# Instructions:
# - add disk evidence to case folder
# - set paramaters in script
# - run as sudo
# - make sure no previous mount points
#
##
###Paramaters###
DiskEvidence="/cases/win7-32-nromanoff/win7-32-nromanoff-c-drive.E01"
CaseFolder="/cases/win7-32-nromanoff"
################
###
##
#
echo mounting $DiskEvidence...
ewfmount $DiskEvidence /mnt/ewf_mount
mount -o loop,ro,show_sys_files,streams_interface=windows /mnt/ewf_mount/ewf1 /mnt/windows_mount

echo mounting $DiskEvidence VSS...
vshadowmount /mnt/ewf_mount/ewf1 /mnt/vss
cd /mnt/vss
for i in $(ls vss*); do 
	mount -o ro,loop,show_sys_files,streams_interface=windows $i /mnt/shadow_mount/$i
	rfc.pl /mnt/shadow_mount/$i/Windows/AppCompat/Programs/RecentFileCache.bcf >> $CaseFolder/RecentFileCache
done

###Processing###
rfc.pl /mnt/windows_mount/Windows/AppCompat/Programs/RecentFileCache.bcf >> $CaseFolder/RecentFileCache
cat $CaseFolder/RecentFileCache | uniq | sort > $CaseFolder/RecentFileCache.Final
cat $CaseFolder/RecentFileCache.Final
################

