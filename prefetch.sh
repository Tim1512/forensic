#!/bin/bash 

# Name: prefetch.sh
# Author: Matthew Green - mgreen27(at)gmail(*)com
# Version 0.1
#
# Description:
# PrefetchCarve.sh will
# 1) carve prefetch files from slack space
# 2) Process recovered prefetch
# 3) Process standard prefetch
# 4) Sort unique entries
#
# Instructions:
# - create case name folder in /cases/
# - add disk evidence and memory evidence
# - mount disk to windows_mount
# - set paramaters in script
# - run as sudo
#
##
##
###Paramaters###
DiskEvidence="/cases/win7-32-nromanoff/win7-32-nromanoff-c-drive.E01"
CaseFolder="/cases/win7-32-nromanoff"
Name=$(basename ${DiskEvidence%.*}) # remove folder and extension form path
OutputPath="$CaseFolder/output" # output folder path
TempPath="$CaseFolder/temp"
#################
###
##
#
# check Output and Temp Path exist and create if they do not.
if [ ! -d $OutputPath ]; then mkdir $OutputPath; fi
if [ ! -d $TempPath ]; then mkdir $TempPath; fi

cd $CaseFolder
echo Carving prefetch from slack space...
blkls $DiskEvidence > $TempPath/carve.blkls
foremost -q -b 4096 -o $TempPath/foremost -c /usr/local/etc/foremost.conf $TempPath/carve.blkls

# Process Recovered Prefetch
for i in $TempPath/foremost/pf/*.pf; do pf -csv $i; done | grep .pf | cut -d, -f2,3,4,5 | grep -v "pf -csv" > $TempPath/recovered-pf-analysis.csv

echo mounting $DiskEvidence... and processing prefetch
ewfmount $DiskEvidence /mnt/ewf_mount
mount -o loop,ro,show_sys_files,streams_interface=windows /mnt/ewf_mount/ewf1 /mnt/windows_mount

# Process Prefetch from main system
for i in /mnt/windows_mount/Windows/Prefetch/*.pf; do pf -csv $i; done | grep .pf | cut -d, -f2,3,4,5 | grep -v "pf -csv" >> $TempPath/recovered-pf-analysis.csv
sed  -i '1i AppName,TimesRan,LastRunDate,LastRunTime' $TempPath/recovered-pf-analysis.csv
mv $TempPath/recovered-pf-analysis.csv $OutputPath/recovered-pf-analysis.csv
echo Complete. Please see $OutputPath/recovered-pf-analysis.csv