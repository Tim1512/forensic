#!/bin/bash 

# Name: timeline.sh
# Author: Matthew Green - mgreen27(at)gmail.com
# Version 0.1
#
# Description:
# timeline.sh is a quick script to Generate Supertimeline.csv
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
DiskEvidence="/cases/Win7-64-001/Win7-64-C.E01"
CaseFolder="/cases/Win7-64-001"
L2tlStartDate="2016-04-02 20:00:00"
L2tlEndDate="2016-10-20 00:00:00"
L2tlParserConfig="winevtx,filestat,winreg,webhist,lnk,prefetch" # modify as required
Name=$(basename ${DiskEvidence%.*}) # remove folder and extension form path
################
###
##
#

echo $DiskEvidence
echo Configured parsers are: $L2tlParserConfig
echo Processing Supertimeline... from $L2tlStartDate to $L2tlEndDate
cd $CaseFolder
log2timeline.py --parsers "$L2tlParserConfig" plaso.dump $DiskEvidence
psort.py -z "UTC" -o L2tcsv plaso.dump "date > '$L2tlStartDate' AND date < '$L2tlEndDate'" > echo $Name-timeline.csv
grep -v -i -f /cases/whitelist.txt $Name-timeline.csv > $Name-timeline-final.csv
echo Timeline complete: $Name-timeline-final.csv


