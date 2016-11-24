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
DiskEvidence="/cases/Win7-64-001/Win7-64-C.E01"
MemoryImagePath="/cases/Win7-64-001/Win7-64-memory-raw.001"
ImageProfile="Win7SP1x86"
CaseFolder="/cases/Win7-64-001" 
L2tlStartDate="2016-04-02 20:00:00"
L2tlEndDate="2016-10-20 00:00:00"
Name=$(basename ${DiskEvidence%.*}) # remove folder and extension form path
################
###
##
#
echo Processing Timeline...

# check if disk image to process and process if exist
if [ -n $DiskEvidence ]; then
	fls -r -m C: $DiskEvidence > $CaseFolder/$Name.body
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

cat $CaseFolder/timeliner.body >> $CaseFolder/$Name.body
mactime -d -b $CaseFolder/$Name.body $l2tl_start_date..$l2tl_end_date > $CaseFolder/$Name-mactime.csv
grep -v -i -f /cases/whitelist.txt $CaseFolder/$Name-mactime.csv > $CaseFolder/$Name-mactime-final.csv

echo Timeline complete: $CaseFolder/$Name-mactime-final.csv


