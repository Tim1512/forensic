#!/bin/bash 

# Name: timeline.sh
# Author: Matthew Green - mgreen27(at)gmail.com
# Version 0.1
#
# Description:
# timeline.sh is a quick script to
# 1) Mount Evidence drive and availible vss
# 2) Generate Supertimeline.csv
#	- you will need to specifiy vss to process during execution
#	- you will need to merge supertimeline to colour template
#
# Instructions:
# - create case name folder in /cases/
# - add disk evidence, memory evidence and baseline memory
# - set paramaters in script
# - ensure /cases/whitelist.txt exists
# - run as sudo
#
#
##
###Paramaters###
name="<machine or case name>"
disk_evidence="<disk evidence file (E01|AFF|etc)>"
#memory_evidence="win7-64-memory-raw.001" # not yet used
case_folder="/cases/"$name
l2tl_start_date="2016-04-02 20:00:00"
l2tl_end_date="2016-10-20 00:00:00"
l2tl_parser_config="winevtx,filestat,winreg,webhist,lnk,prefetch" # modify as required
################
###
##
#

disk_evidence=$case_folder"/"$disk_evidence
#memory_evidence=$case_folder"/"$memory_evidence

echo mounting $disk_evidence...
ewfmount $disk_evidence /mnt/ewf_mount
mount -o loop,ro,show_sys_files,streams_interface=windows /mnt/ewf_mount/ewf1 /mnt/windows_mount

echo mounting $disk_evidence VSS...
vshadowmount /mnt/ewf_mount/ewf1 /mnt/vss
cd /mnt/vss
for i in $(ls vss*); do mount -o ro,loop,show_sys_files,streams_interface=windows $i /mnt/shadow_mount/$i; done

echo processing Supertimeline...
cd $case_folder
log2timeline.py --parsers "$l2tl_parser_config" plaso.dump $disk_evidence
psort.py -z "UTC" -o L2tcsv plaso.dump "date > '$l2tl_start_date' AND date < '$l2tl_end_date'" > $name-timeline.csv
grep -v -i -f /cases/whitelist.txt $name-timeline.csv > FINAL-$name-timeline.csv
echo Timeline complete: FINAL-$name-timeline.csv

