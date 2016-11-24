#!/bin/bash 

# Name: Mount VSS
# Author: Matthew Green - mgreen27(at)gmail.com
# Version 0.1
#
# Description:
# mountvss.sh i a quick script to:
# 1) Mount Evidence drive
# 2) Mount availible VSS
#
# Instructions:
# - add disk evidence to case folder
# - set paramaters in script
# - run as sudo
# - make sure no previous mount points
#
##
###Paramaters###
DiskEvidence="/cases/Win7-64-001/Win7-64-C.E01"
CaseFolder="/cases/Win7-64-001"
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
for i in $(ls vss*); do mount -o ro,loop,show_sys_files,streams_interface=windows $i /mnt/shadow_mount/$i; done

