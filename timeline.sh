#!/bin/bash 

# Name: timeline.sh
# Author: Matthew Green - mgreen27(at)gmail.com
# Version 0.1
#
# Description:
# timeline.sh is a quick script to Generate a mactime timeline from fls and Volatility timeliner plugin
#	- you will need to merge to colour template
#
# Instructions:
# - create case name folder in /cases/
# - add disk evidence and memory evidence
# - set paramaters in script
# - ensure /cases/whitelist.txt exists
# - run as sudo
#
#
##
###Paramaters###
CaseName="win7-32-nromanoff"
DiskEvidence="win7-32-nromanoff-c-drive.E01"
MemoryImagePath="win7-32-nromanoff-memory-raw.001"
CaseFolder="/cases/"$CaseName
l2tl_start_date="2012-04-02"
l2tl_end_date="2012-04-07"
$ImageProfile="Win7SP1x86"
################
###
##
#

DiskEvidence=$CaseFolder"/"$DiskEvidence
MemoryImagePath=$CaseFolder"/"$MemoryImagePath

echo Processing Timeline...

# check if disk image to process and process if exist
if [ -n $DiskEvidence ]; then
	fls -r -m C: $DiskEvidence > $CaseFolder/$CaseName.body
fi 

# Check if memory image to process and process if exist
if [ -n $MemoryImagePath ]; then
	# Check if profile set or prompt for input
	if [ -z $ImageProfile ]; then 
		vol.py -f $MemoryImagePath imageinfo > $CaseFolder/imageinfo
		cat $CaseFolder/imageinfo | grep "Suggested Profile" 
  		echo "Please enter preffered profile: "
  	 	read ImageProfile
	fi
	vol.py -f $MemoryImagePath --profile=$ImageProfile timeliner --output=body --output-file=$CaseFolder/timeliner.body    
fi

cat $CaseFolder/timeliner.body >> $CaseFolder/$CaseName.body
mactime -d -b $CaseFolder/$CaseName.body $l2tl_start_date..$l2tl_end_date > $CaseFolder/$CaseName-mactime.csv
grep -v -i -f /cases/whitelist.txt $CaseFolder/$CaseName-mactime.csv > $CaseFolder/$CaseName-mactime-final.csv

echo Timeline complete: $CaseFolder/$CaseName-mactime-final.csv


